package org.example.springboot.controller;

import org.example.springboot.common.Result;
import org.example.springboot.entity.RefundIntervention;
import org.example.springboot.service.RefundInterventionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/refund-intervention")
public class RefundInterventionController {
    private static final Logger LOGGER = LoggerFactory.getLogger(RefundInterventionController.class);

    @Autowired
    private RefundInterventionService refundInterventionService;

    @PostMapping
    public Result<?> applyIntervention(@RequestBody RefundIntervention intervention) {
        LOGGER.info("申请平台介入：orderId={}", intervention.getOrderId());
        return refundInterventionService.applyIntervention(intervention);
    }

    @GetMapping("/user/{userId}")
    public Result<?> getByUserId(@PathVariable Long userId) {
        LOGGER.info("查询用户介入申请：userId={}", userId);
        return refundInterventionService.getByUserId(userId);
    }

    @GetMapping("/order/{orderId}")
    public Result<?> getByOrderId(@PathVariable Long orderId) {
        LOGGER.info("查询订单介入申请：orderId={}", orderId);
        return refundInterventionService.getByOrderId(orderId);
    }

    @GetMapping("/list")
    public Result<?> getList(
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer currentPage,
            @RequestParam(defaultValue = "10") Integer size) {
        LOGGER.info("查询介入申请列表：status={}, currentPage={}, size={}", status, currentPage, size);
        return refundInterventionService.getList(status, currentPage, size);
    }

    @GetMapping("/{id}")
    public Result<?> getById(@PathVariable Long id) {
        LOGGER.info("查询介入申请详情：id={}", id);
        return refundInterventionService.getById(id);
    }

    @PutMapping("/handle")
    public Result<?> handleIntervention(
            @RequestParam Long id,
            @RequestParam Integer status,
            @RequestParam Long adminId,
            @RequestParam(required = false) String adminReply) {
        LOGGER.info("处理介入申请：id={}, status={}, adminId={}", id, status, adminId);
        return refundInterventionService.handleIntervention(id, status, adminId, adminReply);
    }
}
