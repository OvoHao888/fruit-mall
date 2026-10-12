package org.example.springboot.controller;

import org.example.springboot.common.Result;
import org.example.springboot.entity.ChatMessage;
import org.example.springboot.service.ChatMessageService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/chat")
public class ChatMessageController {
    private static final Logger LOGGER = LoggerFactory.getLogger(ChatMessageController.class);

    @Autowired
    private ChatMessageService chatMessageService;

    @PostMapping
    public Result<?> sendMessage(@RequestBody ChatMessage message) {
        LOGGER.info("发送消息: productId={}, customerId={}, merchantId={}", 
            message.getProductId(), message.getCustomerId(), message.getMerchantId());
        ChatMessage saved = chatMessageService.sendMessage(message);
        return Result.success(saved);
    }

    @GetMapping("/conversation")
    public Result<?> getConversation(
            @RequestParam Long productId,
            @RequestParam Long customerId) {
        LOGGER.info("获取会话记录: productId={}, customerId={}", productId, customerId);
        List<Map<String, Object>> messages = chatMessageService.getConversation(productId, customerId);
        return Result.success(messages);
    }

    @GetMapping("/merchant/conversations")
    public Result<?> getMerchantConversations(@RequestParam Long merchantId) {
        LOGGER.info("获取商户会话列表: merchantId={}", merchantId);
        List<Map<String, Object>> conversations = chatMessageService.getMerchantConversations(merchantId);
        return Result.success(conversations);
    }

    @GetMapping("/merchant/unread")
    public Result<?> getMerchantUnreadCount(@RequestParam Long merchantId) {
        LOGGER.info("获取商户未读消息数: merchantId={}", merchantId);
        int count = chatMessageService.getMerchantUnreadCount(merchantId);
        return Result.success(count);
    }

    @PutMapping("/read")
    public Result<?> markAsRead(
            @RequestParam Long productId,
            @RequestParam Long customerId,
            @RequestParam Long merchantId) {
        LOGGER.info("标记消息已读: productId={}, customerId={}, merchantId={}", productId, customerId, merchantId);
        chatMessageService.markAsRead(productId, customerId, merchantId);
        return Result.success();
    }

    @GetMapping("/customer/conversations")
    public Result<?> getCustomerConversations(@RequestParam Long customerId) {
        LOGGER.info("获取顾客会话列表: customerId={}", customerId);
        List<Map<String, Object>> conversations = chatMessageService.getCustomerConversations(customerId);
        return Result.success(conversations);
    }

    @GetMapping("/customer/unread")
    public Result<?> getCustomerUnreadCount(@RequestParam Long customerId) {
        LOGGER.info("获取顾客未读消息数: customerId={}", customerId);
        int count = chatMessageService.getCustomerUnreadCount(customerId);
        return Result.success(count);
    }

    @PutMapping("/customer/read")
    public Result<?> markAsReadForCustomer(
            @RequestParam Long productId,
            @RequestParam Long customerId) {
        LOGGER.info("标记顾客消息已读: productId={}, customerId={}", productId, customerId);
        chatMessageService.markAsReadForCustomer(productId, customerId);
        return Result.success();
    }

    @GetMapping("/notification")
    public Result<?> getUnreadNotification(@RequestParam Long merchantId) {
        Map<String, Object> notification = chatMessageService.getUnreadNotification(merchantId);
        return Result.success(notification);
    }
}
