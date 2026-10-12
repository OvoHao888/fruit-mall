package org.example.springboot.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import jakarta.annotation.Resource;
import org.example.springboot.entity.ChatMessage;
import org.example.springboot.mapper.ChatMessageMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ChatMessageService {
    private static final Logger LOGGER = LoggerFactory.getLogger(ChatMessageService.class);

    @Resource
    private ChatMessageMapper chatMessageMapper;

    public ChatMessage sendMessage(ChatMessage message) {
        message.setIsRead(0);
        message.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        chatMessageMapper.insert(message);
        return message;
    }

    public List<Map<String, Object>> getConversation(Long productId, Long customerId) {
        return chatMessageMapper.getConversation(productId, customerId);
    }

    public List<Map<String, Object>> getMerchantConversations(Long merchantId) {
        return chatMessageMapper.getMerchantConversations(merchantId);
    }

    public int getMerchantUnreadCount(Long merchantId) {
        return chatMessageMapper.getMerchantUnreadCount(merchantId);
    }

    public int markAsRead(Long productId, Long customerId, Long merchantId) {
        return chatMessageMapper.markAsRead(productId, customerId, merchantId);
    }

    public List<Map<String, Object>> getCustomerConversations(Long customerId) {
        return chatMessageMapper.getCustomerConversations(customerId);
    }

    public int getCustomerUnreadCount(Long customerId) {
        return chatMessageMapper.getCustomerUnreadCount(customerId);
    }

    public int markAsReadForCustomer(Long productId, Long customerId) {
        return chatMessageMapper.markAsReadForCustomer(productId, customerId);
    }

    public Map<String, Object> getUnreadNotification(Long merchantId) {
        Map<String, Object> result = new HashMap<>();
        
        int chatUnread = chatMessageMapper.getMerchantUnreadCount(merchantId);
        
        result.put("chatUnread", chatUnread);
        result.put("totalUnread", chatUnread);
        
        return result;
    }
}
