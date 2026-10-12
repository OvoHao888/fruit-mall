package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@TableName("refund_intervention")
public class RefundIntervention {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orderId;
    private Long userId;
    private Long merchantId;
    private Long productId;
    private String productName;
    private BigDecimal orderPrice;
    private String reason;
    private String images;
    private Integer status;
    private Long adminId;
    private String adminReply;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    @TableField(exist = false)
    private User user;
    @TableField(exist = false)
    private User merchant;
    @TableField(exist = false)
    private Product product;
    @TableField(exist = false)
    private Order order;
    @TableField(exist = false)
    private User admin;
}
