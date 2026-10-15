package org.example.springboot.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

/**
 * RedisTemplate 配置。
 *
 * <p>为什么不用 Spring Boot 默认的 RedisTemplate：
 * 默认用的是 JDK 序列化，存进 Redis 的是一串二进制乱码，
 * 用 redis-cli 根本看不懂，跨语言也用不了。
 * 这里改成：key 用普通字符串，value 用 JSON（带类型信息，反序列化能还原成原类型）。
 * 这样在 redis-cli 里能直接看到缓存的内容。
 */
@Configuration
public class RedisConfig {

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);

        StringRedisSerializer keySerializer = new StringRedisSerializer();
        // 无参构造内部已开启受限的默认类型信息（写入 @class 字段），
        // 既能还原对象类型，又不像完全放开 default typing 那样有反序列化 gadget 风险。
        GenericJackson2JsonRedisSerializer valueSerializer = new GenericJackson2JsonRedisSerializer();

        template.setKeySerializer(keySerializer);
        template.setHashKeySerializer(keySerializer);
        template.setValueSerializer(valueSerializer);
        template.setHashValueSerializer(valueSerializer);
        template.afterPropertiesSet();
        return template;
    }
}
