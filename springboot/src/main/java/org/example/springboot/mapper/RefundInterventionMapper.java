package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.example.springboot.entity.RefundIntervention;

import java.util.List;
import java.util.Map;

@Mapper
public interface RefundInterventionMapper extends BaseMapper<RefundIntervention> {

    @Select("SELECT ri.*, " +
            "u.id as user_id, u.username as user_username, u.name as user_name, " +
            "m.id as merchant_id, m.username as merchant_username, m.name as merchant_name, " +
            "p.id as product_id, p.name as product_name, p.image_url as product_image_url, " +
            "a.id as admin_id, a.username as admin_username, a.name as admin_name " +
            "FROM refund_intervention ri " +
            "LEFT JOIN user u ON ri.user_id = u.id " +
            "LEFT JOIN user m ON ri.merchant_id = m.id " +
            "LEFT JOIN product p ON ri.product_id = p.id " +
            "LEFT JOIN user a ON ri.admin_id = a.id " +
            "WHERE ri.status = #{status} " +
            "ORDER BY ri.created_at DESC")
    List<Map<String, Object>> getByStatus(@Param("status") Integer status);

    @Select("SELECT ri.*, " +
            "u.id as user_id, u.username as user_username, u.name as user_name, " +
            "m.id as merchant_id, m.username as merchant_username, m.name as merchant_name, " +
            "p.id as product_id, p.name as product_name, p.image_url as product_image_url, " +
            "a.id as admin_id, a.username as admin_username, a.name as admin_name " +
            "FROM refund_intervention ri " +
            "LEFT JOIN user u ON ri.user_id = u.id " +
            "LEFT JOIN user m ON ri.merchant_id = m.id " +
            "LEFT JOIN product p ON ri.product_id = p.id " +
            "LEFT JOIN user a ON ri.admin_id = a.id " +
            "ORDER BY ri.created_at DESC")
    List<Map<String, Object>> getAllWithDetails();

    @Select("SELECT ri.*, " +
            "u.id as user_id, u.username as user_username, u.name as user_name, " +
            "m.id as merchant_id, m.username as merchant_username, m.name as merchant_name, " +
            "p.id as product_id, p.name as product_name, p.image_url as product_image_url, " +
            "a.id as admin_id, a.username as admin_username, a.name as admin_name " +
            "FROM refund_intervention ri " +
            "LEFT JOIN user u ON ri.user_id = u.id " +
            "LEFT JOIN user m ON ri.merchant_id = m.id " +
            "LEFT JOIN product p ON ri.product_id = p.id " +
            "LEFT JOIN user a ON ri.admin_id = a.id " +
            "WHERE ri.id = #{id}")
    Map<String, Object> getByIdWithDetails(@Param("id") Long id);

    @Select("SELECT * FROM refund_intervention WHERE order_id = #{orderId}")
    RefundIntervention getByOrderId(@Param("orderId") Long orderId);

    @Update("UPDATE refund_intervention SET status = #{status}, admin_id = #{adminId}, admin_reply = #{adminReply}, updated_at = NOW() WHERE id = #{id}")
    int updateStatus(@Param("id") Long id, @Param("status") Integer status, @Param("adminId") Long adminId, @Param("adminReply") String adminReply);
}
