package org.example.springboot.cache;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cache.Cache;
import org.springframework.cache.support.SimpleValueWrapper;
import org.springframework.data.redis.core.RedisTemplate;

import java.time.Duration;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 两级缓存：L1 进程内 Caffeine + L2 Redis。
 *
 * <p>为什么要有两级：
 * <ul>
 *   <li>L1 在进程内存里，读取是纳秒级，但多实例之间互不可见；</li>
 *   <li>L2 在 Redis 里，多实例共享，但每次读取都要走一次网络。</li>
 * </ul>
 * 热点数据放在 L1 挡掉绝大多数请求，L1 没命中再回落到 L2，
 * 这样既省了网络往返，又不会因为多实例而各缓存各的。
 *
 * <p>多实例下的脏读：别的实例改了数据并清掉 Redis，本实例的 L1 并不知道。
 * 因此 L1 的 TTL 刻意设得比 L2 短得多（默认 30 秒 vs 10 分钟），
 * 最坏情况下脏读不超过 L1 的 TTL。要更实时可以用 Redis 的 pub/sub
 * 做失效广播，本项目数据量小，用短 TTL 换实现简单。
 *
 * <p>容错：所有 Redis 操作都包了 try/catch。Redis 不可用或对象序列化失败时，
 * 只记录日志并降级为「仅用 L1」，绝不让缓存问题变成接口 500 ——
 * 缓存是优化手段，不是业务依赖。
 */
public class TwoLevelCache implements Cache {

    private static final Logger log = LoggerFactory.getLogger(TwoLevelCache.class);

    /** Redis key 的统一前缀，便于运维排查和批量清理 */
    private static final String KEY_PREFIX = "mall:cache:";

    private final String name;
    private final com.github.benmanes.caffeine.cache.Cache<Object, Object> l1;
    private final RedisTemplate<String, Object> redis;
    private final Duration l2Ttl;
    private final boolean redisEnabled;

    /** 命中统计，用来观察两级各自挡下了多少请求 */
    private final AtomicLong l1Hits = new AtomicLong();
    private final AtomicLong l2Hits = new AtomicLong();
    private final AtomicLong misses = new AtomicLong();
    private final AtomicLong redisErrors = new AtomicLong();

    public TwoLevelCache(String name,
                         com.github.benmanes.caffeine.cache.Cache<Object, Object> l1,
                         RedisTemplate<String, Object> redis,
                         Duration l2Ttl,
                         boolean redisEnabled) {
        this.name = name;
        this.l1 = l1;
        this.redis = redis;
        this.l2Ttl = l2Ttl;
        this.redisEnabled = redisEnabled;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public Object getNativeCache() {
        return this;
    }

    private String redisKey(Object key) {
        return KEY_PREFIX + name + "::" + key;
    }

    @Override
    public ValueWrapper get(Object key) {
        // 第一级：进程内
        Object value = l1.getIfPresent(key);
        if (value != null) {
            l1Hits.incrementAndGet();
            return new SimpleValueWrapper(value);
        }

        // 第二级：Redis，命中后回填 L1
        if (redisEnabled) {
            try {
                Object fromRedis = redis.opsForValue().get(redisKey(key));
                if (fromRedis != null) {
                    l2Hits.incrementAndGet();
                    l1.put(key, fromRedis);
                    return new SimpleValueWrapper(fromRedis);
                }
            } catch (Exception e) {
                redisErrors.incrementAndGet();
                log.warn("L2 读取失败，本次降级为仅用 L1。cache={}, key={}, err={}",
                        name, key, e.toString());
            }
        }

        misses.incrementAndGet();
        return null;
    }

    @Override
    @SuppressWarnings("unchecked")
    public <T> T get(Object key, Class<T> type) {
        ValueWrapper wrapper = get(key);
        if (wrapper == null) {
            return null;
        }
        Object value = wrapper.get();
        if (value != null && type != null && !type.isInstance(value)) {
            throw new IllegalStateException("缓存类型不匹配：期望 " + type.getName()
                    + "，实际 " + value.getClass().getName());
        }
        return (T) value;
    }

    @Override
    @SuppressWarnings("unchecked")
    public <T> T get(Object key, Callable<T> valueLoader) {
        ValueWrapper wrapper = get(key);
        if (wrapper != null) {
            return (T) wrapper.get();
        }
        try {
            T value = valueLoader.call();
            put(key, value);
            return value;
        } catch (Exception e) {
            throw new ValueRetrievalException(key, valueLoader, e);
        }
    }

    @Override
    public void put(Object key, Object value) {
        if (value == null) {
            return;
        }
        l1.put(key, value);
        if (!redisEnabled) {
            return;
        }
        try {
            redis.opsForValue().set(redisKey(key), value, l2Ttl);
        } catch (Exception e) {
            redisErrors.incrementAndGet();
            log.warn("L2 写入失败（业务不受影响，仅 L1 生效）。cache={}, key={}, err={}",
                    name, key, e.toString());
        }
    }

    @Override
    public void evict(Object key) {
        l1.invalidate(key);
        if (!redisEnabled) {
            return;
        }
        try {
            redis.delete(redisKey(key));
        } catch (Exception e) {
            redisErrors.incrementAndGet();
            log.warn("L2 删除失败。cache={}, key={}, err={}", name, key, e.toString());
        }
    }

    @Override
    public void clear() {
        l1.invalidateAll();
        if (!redisEnabled) {
            return;
        }
        try {
            // 注意：KEYS 会阻塞 Redis，生产环境数据量大时应改用 SCAN 游标遍历。
            // 本项目的缓存 key 数量有限（一个 cache 名下一个前缀），这里可以接受。
            Set<String> keys = redis.keys(KEY_PREFIX + name + "::*");
            if (keys != null && !keys.isEmpty()) {
                redis.delete(keys);
            }
        } catch (Exception e) {
            redisErrors.incrementAndGet();
            log.warn("L2 清空失败。cache={}, err={}", name, e.toString());
        }
    }

    /** 供排查用：看一眼两级各自的表现 */
    public String stats() {
        return String.format("cache=%s l1Hit=%d l2Hit=%d miss=%d redisError=%d",
                name, l1Hits.get(), l2Hits.get(), misses.get(), redisErrors.get());
    }

    @Override
    public String toString() {
        return "TwoLevelCache{" + stats() + "}";
    }
}
