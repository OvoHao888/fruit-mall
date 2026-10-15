package org.example.springboot.config;

import org.example.springboot.cache.TwoLevelCacheManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.RedisTemplate;

import java.time.Duration;

/**
 * 缓存配置：Caffeine(L1) + Redis(L2) 两级。
 *
 * <p>原来的实现只有一个未被 @Configuration 标注的 Caffeine Bean，
 * 实际生效的是 Spring Boot 凭借 {@code spring.cache.type=caffeine}
 * 自动配置出来的单级缓存，Redis 依赖声明了却完全没用上。
 *
 * <p>现在把 {@code spring.cache.type} 设为 none（关掉自动配置），
 * 由本类显式提供一个两级 CacheManager。业务代码里的
 * {@code @Cacheable} / {@code @CacheEvict} 完全不用改，
 * Spring 的缓存抽象会把它们路由到这里。
 */
@Configuration
@EnableCaching
public class CacheConfig {

    private static final Logger log = LoggerFactory.getLogger(CacheConfig.class);

    /** L1 最多缓存多少个条目，防止内存被撑爆 */
    @Value("${mall.cache.l1.max-size:1000}")
    private long l1MaxSize;

    /** L1 过期时间（秒）。刻意设短，用来兜底多实例之间的脏读 */
    @Value("${mall.cache.l1.ttl-seconds:30}")
    private long l1TtlSeconds;

    /** L2 过期时间（秒） */
    @Value("${mall.cache.l2.ttl-seconds:600}")
    private long l2TtlSeconds;

    /** 是否启用 L2。关掉即退化为单级 Caffeine，便于排查问题 */
    @Value("${mall.cache.redis.enabled:true}")
    private boolean redisEnabled;

    @Bean
    public CacheManager cacheManager(RedisTemplate<String, Object> redisTemplate) {
        log.info("启用两级缓存：L1=Caffeine(maxSize={}, ttl={}s)  L2=Redis(ttl={}s, enabled={})",
                l1MaxSize, l1TtlSeconds, l2TtlSeconds, redisEnabled);
        return new TwoLevelCacheManager(
                redisTemplate,
                l1MaxSize,
                Duration.ofSeconds(l1TtlSeconds),
                Duration.ofSeconds(l2TtlSeconds),
                redisEnabled);
    }
}
