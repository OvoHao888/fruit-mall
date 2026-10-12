package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.example.springboot.entity.ChatMessage;

import java.util.List;
import java.util.Map;

@Mapper
public interface ChatMessageMapper extends BaseMapper<ChatMessage> {

    @Select("SELECT cm.*, " +
            "c.id as customer_id, c.username as customer_username, c.name as customer_name, " +
            "m.id as merchant_id, m.username as merchant_username, m.name as merchant_name, " +
            "p.id as product_id, p.name as product_name, p.image_url as product_image_url, " +
            "s.id as sender_id, s.username as sender_username, s.name as sender_name " +
            "FROM chat_message cm " +
            "LEFT JOIN user c ON cm.customer_id = c.id " +
            "LEFT JOIN user m ON cm.merchant_id = m.id " +
            "LEFT JOIN product p ON cm.product_id = p.id " +
            "LEFT JOIN user s ON cm.sender_id = s.id " +
            "WHERE cm.product_id = #{productId} AND cm.customer_id = #{customerId} " +
            "ORDER BY cm.created_at ASC")
    List<Map<String, Object>> getConversation(@Param("productId") Long productId, @Param("customerId") Long customerId);

    @Select("SELECT t.product_id, t.customer_id, t.merchant_id, " +
            "c.username as customer_username, c.name as customer_name, " +
            "p.name as product_name, p.image_url as product_image_url, " +
            "t.content as last_message, t.created_at as last_message_time, " +
            "COALESCE(unread.unread_count, 0) as unread_count " +
            "FROM chat_message t " +
            "INNER JOIN (SELECT product_id, customer_id, MAX(created_at) as max_created_at " +
            "FROM chat_message WHERE merchant_id = #{merchantId} " +
            "GROUP BY product_id, customer_id) latest " +
            "ON t.product_id = latest.product_id AND t.customer_id = latest.customer_id " +
            "AND t.created_at = latest.max_created_at " +
            "LEFT JOIN user c ON t.customer_id = c.id " +
            "LEFT JOIN product p ON t.product_id = p.id " +
            "LEFT JOIN (SELECT product_id, customer_id, COUNT(*) as unread_count FROM chat_message " +
            "WHERE merchant_id = #{merchantId} AND sender_id != #{merchantId} AND is_read = 0 " +
            "GROUP BY product_id, customer_id) unread " +
            "ON t.product_id = unread.product_id AND t.customer_id = unread.customer_id " +
            "WHERE t.merchant_id = #{merchantId} " +
            "ORDER BY t.created_at DESC")
    List<Map<String, Object>> getMerchantConversations(@Param("merchantId") Long merchantId);

    @Select("SELECT COUNT(*) FROM chat_message " +
            "WHERE merchant_id = #{merchantId} AND sender_id != #{merchantId} AND is_read = 0")
    int getMerchantUnreadCount(@Param("merchantId") Long merchantId);

    @Update("UPDATE chat_message SET is_read = 1 " +
            "WHERE product_id = #{productId} AND customer_id = #{customerId} AND merchant_id = #{merchantId} AND sender_id != #{merchantId}")
    int markAsRead(@Param("productId") Long productId, @Param("customerId") Long customerId, @Param("merchantId") Long merchantId);

    @Select("SELECT t.product_id, t.customer_id, t.merchant_id, " +
            "m.username as merchant_username, m.name as merchant_name, " +
            "p.name as product_name, p.image_url as product_image_url, " +
            "t.content as last_message, t.created_at as last_message_time, " +
            "COALESCE(unread.unread_count, 0) as unread_count " +
            "FROM chat_message t " +
            "INNER JOIN (SELECT product_id, customer_id, MAX(created_at) as max_created_at " +
            "FROM chat_message WHERE customer_id = #{customerId} " +
            "GROUP BY product_id, customer_id) latest " +
            "ON t.product_id = latest.product_id AND t.customer_id = latest.customer_id " +
            "AND t.created_at = latest.max_created_at " +
            "LEFT JOIN user m ON t.merchant_id = m.id " +
            "LEFT JOIN product p ON t.product_id = p.id " +
            "LEFT JOIN (SELECT product_id, customer_id, COUNT(*) as unread_count FROM chat_message " +
            "WHERE customer_id = #{customerId} AND sender_id != #{customerId} AND is_read = 0 " +
            "GROUP BY product_id, customer_id) unread " +
            "ON t.product_id = unread.product_id AND t.customer_id = unread.customer_id " +
            "WHERE t.customer_id = #{customerId} " +
            "ORDER BY t.created_at DESC")
    List<Map<String, Object>> getCustomerConversations(@Param("customerId") Long customerId);

    @Select("SELECT COUNT(*) FROM chat_message " +
            "WHERE customer_id = #{customerId} AND sender_id != #{customerId} AND is_read = 0")
    int getCustomerUnreadCount(@Param("customerId") Long customerId);

    @Update("UPDATE chat_message SET is_read = 1 " +
            "WHERE product_id = #{productId} AND customer_id = #{customerId} AND sender_id != #{customerId}")
    int markAsReadForCustomer(@Param("productId") Long productId, @Param("customerId") Long customerId);
}
