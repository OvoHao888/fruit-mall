package org.example.springboot.config;

import jakarta.annotation.Resource;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.PathMatchConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
/**
 * Web配置�?
 * 用于配置Spring MVC的核心行为，包括�?
 * - REST API的统一路径前缀
 * - JWT认证拦截�?
 * - 请求路径匹配规则
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Resource
    private JwtInterceptor jwtInterceptor;

    /**
     * 配置路径匹配规则
     * 为所有带有@RestController注解的控制器类添加统一的路径前缀
     * 这样可以将API接口与其他Web资源区分开
     *
     * @param configurer 路径匹配配置�?
     */

    @Override
    public void configurePathMatch(PathMatchConfigurer configurer) {
        // 为带有RestController注解的类添加"/api"路径前缀
        configurer.addPathPrefix("/api", clazz ->
                clazz.isAnnotationPresent(RestController.class) &&
                        !clazz.getPackage().getName().contains("springfox") &&
                        !clazz.getPackage().getName().contains("doc")
        );
    }

    /**
     * 配置拦截?
     * 添加JWT认证拦截器，并详细配置拦截规?
     * 拦截器配置包括：
     * 1. 需要拦截的路径?api/**
     * 2. 不需要拦截的路径?
     *    - 用户相关：登录、注册、找回密码等
     *    - 静态资源：图片、文件等
     *    - 其他开放接口：邮件服务、打卡等
     *
     * @param registry 拦截器注册表
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 添加JWT拦截器，应用?/api/**"路径下的请求
        registry.addInterceptor(jwtInterceptor)
                // 拦截 /api/** 下的全部请求
                .addPathPatterns("/api/**")
                // 以下路径完全不校验令牌
                .excludePathPatterns(
                        // 认证相关
                        "/api/user/login",
                        "/api/user/add",
                        "/api/user/forget",
                        // 注册验证码邮件
                        "/api/email/**",
                        // 静态资源与接口文档
                        "/api/img/**",
                        "/api/doc.html",
                        "/api/webjars/**",
                        "/api/favicon.ico"
                );

        // 说明：商品、分类、轮播、公告、文章、评论这些「匿名可读」的接口
        // 不在这里放行 —— excludePathPatterns 不区分 HTTP 方法，
        // 一旦写成 /api/product/**，连 POST/PUT/DELETE 的商品写接口都会被放开。
        // 它们的放行由 JwtInterceptor 按「GET + 路径前缀」单独判断。
    }
}
