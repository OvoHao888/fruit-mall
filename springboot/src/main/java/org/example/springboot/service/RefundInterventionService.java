package org.example.springboot.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.example.springboot.common.Result;
import org.example.springboot.entity.Order;
import org.example.springboot.entity.Product;
import org.example.springboot.entity.RefundIntervention;
import org.example.springboot.entity.User;
import org.example.springboot.mapper.OrderMapper;
import org.example.springboot.mapper.ProductMapper;
import org.example.springboot.mapper.RefundInterventionMapper;
import org.example.springboot.mapper.UserMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class RefundInterventionService {
    private static final Logger LOGGER = LoggerFactory.getLogger(RefundInterventionService.class);

    @Autowired
    private RefundInterventionMapper refundInterventionMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private OrderService orderService;

    public Result<?> applyIntervention(RefundIntervention intervention) {
        try {
            Order order = orderMapper.selectById(intervention.getOrderId());
            if (order == null) {
                return Result.error("-1", "订单不存在");
            }

            if (order.getStatus() != 7) {
                return Result.error("-1", "只有退款失败的订单才能申请平台介入");
            }

            RefundIntervention existing = refundInterventionMapper.getByOrderId(intervention.getOrderId());
            if (existing != null) {
                return Result.error("-1", "该订单已申请过平台介入");
            }

            Product product = productMapper.selectById(order.getProductId());
            if (product == null) {
                return Result.error("-1", "商品不存在");
            }

            intervention.setUserId(order.getUserId());
            intervention.setMerchantId(product.getMerchantId());
            intervention.setProductId(order.getProductId());
            intervention.setProductName(product.getName());
            intervention.setOrderPrice(order.getTotalPrice());
            intervention.setStatus(0);
            intervention.setCreatedAt(Timestamp.valueOf(LocalDateTime.now()));

            int result = refundInterventionMapper.insert(intervention);
            if (result > 0) {
                LOGGER.info("申请平台介入成功，订单ID：{}", intervention.getOrderId());
                return Result.success(intervention);
            }
            return Result.error("-1", "申请平台介入失败");
        } catch (Exception e) {
            LOGGER.error("申请平台介入失败：{}", e.getMessage());
            return Result.error("-1", "申请平台介入失败：" + e.getMessage());
        }
    }

    public Result<?> getByUserId(Long userId) {
        try {
            LambdaQueryWrapper<RefundIntervention> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(RefundIntervention::getUserId, userId);
            queryWrapper.orderByDesc(RefundIntervention::getCreatedAt);
            List<RefundIntervention> list = refundInterventionMapper.selectList(queryWrapper);
            
            list.forEach(item -> {
                item.setProduct(productMapper.selectById(item.getProductId()));
                item.setMerchant(userMapper.selectById(item.getMerchantId()));
            });
            
            return Result.success(list);
        } catch (Exception e) {
            LOGGER.error("查询用户介入申请失败：{}", e.getMessage());
            return Result.error("-1", "查询失败：" + e.getMessage());
        }
    }

    public Result<?> getByOrderId(Long orderId) {
        try {
            RefundIntervention intervention = refundInterventionMapper.getByOrderId(orderId);
            if (intervention != null) {
                intervention.setProduct(productMapper.selectById(intervention.getProductId()));
                intervention.setMerchant(userMapper.selectById(intervention.getMerchantId()));
                intervention.setUser(userMapper.selectById(intervention.getUserId()));
                if (intervention.getAdminId() != null) {
                    intervention.setAdmin(userMapper.selectById(intervention.getAdminId()));
                }
            }
            return Result.success(intervention);
        } catch (Exception e) {
            LOGGER.error("查询订单介入申请失败：{}", e.getMessage());
            return Result.error("-1", "查询失败：" + e.getMessage());
        }
    }

    public Result<?> getList(Integer status, Integer currentPage, Integer size) {
        try {
            LambdaQueryWrapper<RefundIntervention> queryWrapper = new LambdaQueryWrapper<>();
            if (status != null) {
                queryWrapper.eq(RefundIntervention::getStatus, status);
            }
            queryWrapper.orderByDesc(RefundIntervention::getCreatedAt);

            Page<RefundIntervention> page = new Page<>(currentPage, size);
            Page<RefundIntervention> result = refundInterventionMapper.selectPage(page, queryWrapper);

            result.getRecords().forEach(item -> {
                item.setProduct(productMapper.selectById(item.getProductId()));
                item.setMerchant(userMapper.selectById(item.getMerchantId()));
                item.setUser(userMapper.selectById(item.getUserId()));
                if (item.getAdminId() != null) {
                    item.setAdmin(userMapper.selectById(item.getAdminId()));
                }
            });

            return Result.success(result);
        } catch (Exception e) {
            LOGGER.error("查询介入申请列表失败：{}", e.getMessage());
            return Result.error("-1", "查询失败：" + e.getMessage());
        }
    }

    public Result<?> getById(Long id) {
        try {
            Map<String, Object> detail = refundInterventionMapper.getByIdWithDetails(id);
            return Result.success(detail);
        } catch (Exception e) {
            LOGGER.error("查询介入申请详情失败：{}", e.getMessage());
            return Result.error("-1", "查询失败：" + e.getMessage());
        }
    }

    @Transactional
    public Result<?> handleIntervention(Long id, Integer status, Long adminId, String adminReply) {
        try {
            RefundIntervention intervention = refundInterventionMapper.selectById(id);
            if (intervention == null) {
                return Result.error("-1", "介入申请不存在");
            }

            if (intervention.getStatus() != 0) {
                return Result.error("-1", "该申请已处理");
            }

            int result = refundInterventionMapper.updateStatus(id, status, adminId, adminReply);
            if (result > 0) {
                Order order = orderMapper.selectById(intervention.getOrderId());
                if (order == null) {
                    return Result.error("-1", "订单不存在");
                }

                if (status == 1) {
                    order.setStatus(6);
                    order.setRefundStatus(3);
                    order.setRefundTime(Timestamp.valueOf(LocalDateTime.now()));
                    order.setRemark("平台介入退款：" + adminReply);
                    orderMapper.updateById(order);

                    Product product = productMapper.selectById(order.getProductId());
                    if (product != null) {
                        product.setStock(product.getStock() + order.getQuantity());
                        if (product.getSalesCount() >= order.getQuantity()) {
                            product.setSalesCount(product.getSalesCount() - order.getQuantity());
                        }
                        productMapper.updateById(product);
                    }

                    LOGGER.info("平台介入同意退款，订单ID：{}", intervention.getOrderId());
                } else {
                    order.setStatus(8);
                    order.setRefundStatus(5);
                    order.setRemark("平台拒绝退款：" + adminReply);
                    orderMapper.updateById(order);

                    LOGGER.info("平台介入拒绝退款，订单ID：{}", intervention.getOrderId());
                }

                return Result.success("处理成功");
            }
            return Result.error("-1", "处理失败");
        } catch (Exception e) {
            LOGGER.error("处理介入申请失败：{}", e.getMessage());
            return Result.error("-1", "处理失败：" + e.getMessage());
        }
    }
}
