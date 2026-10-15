package org.example.springboot.cache;

import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.data.redis.core.RedisTemplate;

import java.time.Duration;
import java.util.Collection;
import java.util.Collections;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 按需创建 {@link TwoLevelCache} 的缓存管理器。
 *
 * <p>Spring 的 {@code @Cacheable(value = "products")} 在执行时会调用
 * {@link #getCache(String)} 拿缓存实例，这里第一次访问某个名字时才创建，
 * 之后复用同一个（每个 cache 名字对应一个独立的 L1）。
 */
public class TwoLevelCacheManager implements CacheManager {

    private final Map<String, Cache> caches = new ConcurrentHashMap<>();

    private final RedisTemplate<String, Object> redis;
    private final long l1MaxSize;
    private final Duration l1Ttl;
    private final Duration l2Ttl;
    private final boolean redisEnabled;

    public TwoLevelCacheManager(RedisTemplate<String, Object> redis,
                                long l1MaxSize,
                                Duration l1Ttl,
                                Duration l2Ttl,
                                boolean redisEnabled) {
        this.redis = redis;
        this.l1MaxSize = l1MaxSize;
        this.l1Ttl = l1Ttl;
        this.l2Ttl = l2Ttl;
        this.redisEnabled = redisEnabled;
    }

    @Override
    public Cache getCache(String name) {
        return caches.computeIfAbsent(name, cacheName -> {
            com.github.benmanes.caffeine.cache.Cache<Object, Object> l1 =
                    Caffeine.newBuilder()
                            .maximumSize(l1MaxSize)
                            .expireAfterWrite(l1Ttl)
                            .recordStats()
                            .build();
            return new TwoLevelCache(cacheName, l1, redis, l2Ttl, redisEnabled);
        });
    }

    @Override
    public Collection<String> getCacheNames() {
        return Collections.unmodifiableSet(caches.keySet());
    }

    /** 供排查用：列出所有已创建的缓存及其命中情况 */
    public String stats() {
        StringBuilder sb = new StringBuilder();
        caches.values().forEach(c -> sb.append(((TwoLevelCache) c).stats()).append("\n"));
        return sb.toString();
    }
}
