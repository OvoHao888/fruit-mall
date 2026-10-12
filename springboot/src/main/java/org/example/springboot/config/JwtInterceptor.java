package org.example.springboot.config;


import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.baomidou.mybatisplus.core.toolkit.StringUtils;

import jakarta.annotation.Resource;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.springboot.entity.User;
import org.example.springboot.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;




@Component
public class JwtInterceptor implements HandlerInterceptor {
    public static final Logger LOGGER = LoggerFactory.getLogger(HandlerInterceptor.class);
    @Resource
    private UserService userService;

    /**
     * 匿名可读的接口前缀。
     *
     * 只放行 GET：这些资源游客也要能浏览，但同路径下的写操作
     * （如 POST /api/product 新增商品）仍然必须带令牌。
     */
    private static final String[] PUBLIC_GET_PREFIXES = {
            "/api/product", "/api/category", "/api/carousel",
            "/api/notice", "/api/article", "/api/review", "/api/file"
    };

    /** 判断是否为「匿名可读」的 GET 请求。 */
    private boolean isPublicGet(HttpServletRequest request) {
        if (!"GET".equalsIgnoreCase(request.getMethod())) {
            return false;
        }
        String uri = request.getRequestURI();
        for (String prefix : PUBLIC_GET_PREFIXES) {
            if (uri.equals(prefix) || uri.startsWith(prefix + "/")) {
                return true;
            }
        }
        return false;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 匿名可读的 GET 直接放行（游客浏览商品、分类、公告等）
        if (isPublicGet(request)) {
            return true;
        }

        String token = request.getHeader("token");
        if (StringUtils.isBlank(token)) {
            token = request.getParameter("token");
        }
        if (StringUtils.isBlank(token)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 401状态码
            response.getWriter().print("Token缺失"); // 返回错误信息
            return false;
        }

        User user = null;
        try {
            String userId = JWT.decode(token).getAudience().get(0);
            user = userService.getUserById(Integer.parseInt(userId));
        } catch (Exception e) {
            String errMsg = "token失效，重新登录！";
            LOGGER.error(errMsg + " ,token=" + token, e);
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print(errMsg); // 返回错误信息
            return false;
        }
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("User not found");
            return false;
        }
        try {
            JWTVerifier jwtVerifier = JWT.require(Algorithm.HMAC256(user.getPassword())).build();
            jwtVerifier.verify(token);
        } catch (JWTVerificationException e) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("token认证失败，重新登录！");
            return false;
        }
        LOGGER.info("验证成功，允许放行。{}",user);
        return HandlerInterceptor.super.preHandle(request, response, handler);
    }
}
