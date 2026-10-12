package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.sql.Timestamp;
import java.util.List;

@Data
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String username;
    /**
     * 口令哈希。
     *
     * 只允许反序列化（注册/登录时接收口令），禁止序列化输出 ——
     * 否则凡是返回 User 的接口（/api/user/page、/api/user/username/{name} …）
     * 都会把 bcrypt 哈希一并返回，等于把改密前的凭据交给任何人。
     *
     * 注意：不能用 @JsonIgnore。那样入参也收不到口令，注册接口会直接坏掉。
     */
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;
    private String name;
    private String role;
    private String email;
    private Integer status;
    private String businessLicense;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    @TableField(exist = false)
    private List<Menu> menuList;
    @TableField(exist = false)
    private String token;
}
