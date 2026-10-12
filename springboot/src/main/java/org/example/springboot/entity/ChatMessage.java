package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.sql.Timestamp;

@Data
public class ChatMessage {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long productId;
    private Long customerId;
    private Long merchantId;
    private Long senderId;
    private String content;
    private Integer isRead;
    private Integer type;
    private Long relatedOrderId;
    private Timestamp createdAt;

    @TableField(exist = false)
    private User customer;

    @TableField(exist = false)
    private User merchant;

    @TableField(exist = false)
    private Product product;

    @TableField(exist = false)
    private User sender;
}
