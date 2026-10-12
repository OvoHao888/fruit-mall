package org.example.springboot.controller;

import org.example.springboot.common.Result;
import org.example.springboot.entity.Product;
import org.example.springboot.service.AiService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/ai")
public class AiController {

    private static final Logger LOGGER = LoggerFactory.getLogger(AiController.class);

    private final AiService aiService;

    public AiController(AiService aiService) {
        this.aiService = aiService;
    }

    @PostMapping("/recommend")
    public Result<?> recommend(@RequestBody Map<String, String> request) {
        String requirement = request.get("requirement");
        if (requirement == null || requirement.trim().isEmpty()) {
            return Result.error("-1", "需求不能为空");
        }

        try {
            List<Product> recommendations = aiService.recommend(requirement);
            return Result.success(recommendations);
        } catch (Exception e) {
            // 记录完整堆栈，但只向客户端返回通用提示，避免泄露内部实现
            LOGGER.error("AI 推荐失败, requirement={}", requirement, e);
            return Result.error("-1", "AI 推荐服务暂时不可用");
        }
    }
}
