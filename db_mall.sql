/*
 Navicat Premium Data Transfer

 Source Server         : test
 Source Server Type    : MySQL
 Source Server Version : 80040 (8.0.40)
 Source Host           : localhost:3306
 Source Schema         : db_mall

 Target Server Type    : MySQL
 Target Server Version : 80040 (8.0.40)
 File Encoding         : 65001

 Date: 09/03/2026 19:09:21
*/

SET NAMES utf8mb4;

-- 建库与选库：原导出文件缺少这两句，直接导入会报 "No database selected"
CREATE DATABASE IF NOT EXISTS `db_mall`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE `db_mall`;

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for address
-- ----------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '地址ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详细地址',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `receiver` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人姓名',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `address_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收货地址表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of address
-- ----------------------------
INSERT INTO `address` VALUES (1, 4, '13800138001', '北京市朝阳区某街道1号', '2026-02-05 10:46:11', '2026-02-07 21:07:56', '123');
INSERT INTO `address` VALUES (2, 4, '13800138002', '北京市海淀区某街道2号', '2026-02-07 10:46:11', '2026-02-07 18:23:04', '456');
INSERT INTO `address` VALUES (3, 5, '13800138003', '上海市浦东新区某街道3号', '2026-02-07 10:46:11', '2026-02-07 10:46:11', NULL);
INSERT INTO `address` VALUES (4, 2, '13800138004', '广州市天河区某街道4号', '2026-02-07 10:46:11', '2026-02-07 10:46:11', NULL);
INSERT INTO `address` VALUES (5, 3, '13800138005', '深圳市南山区某街道5号', '2026-02-07 10:46:11', '2026-02-07 10:46:11', NULL);

-- ----------------------------
-- Table structure for appraisal
-- ----------------------------
DROP TABLE IF EXISTS `appraisal`;
CREATE TABLE `appraisal`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '申请用户ID',
  `image_url` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '鉴定图片URL',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `status` int NULL DEFAULT 0 COMMENT '状态: 0待鉴定, 1真品, 2赝品',
  `result_comment` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '鉴定意见',
  `admin_id` bigint NULL DEFAULT NULL COMMENT '鉴定管理员ID',
  `appraisal_time` datetime NULL DEFAULT NULL COMMENT '鉴定时间',
  `code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '唯一鉴定编号',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '商品鉴定表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of appraisal
-- ----------------------------
INSERT INTO `appraisal` VALUES (1, 2, '/file/c14c97c85d3d4459b4f4ad4987504f27.png', '2026-01-14 20:18:13', 0, NULL, NULL, NULL, '2011412533154877440');

-- ----------------------------
-- Table structure for article
-- ----------------------------
DROP TABLE IF EXISTS `article`;
CREATE TABLE `article`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资讯标题',
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资讯内容',
  `summary` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '资讯摘要',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图片URL',
  `view_count` int NULL DEFAULT 0 COMMENT '浏览量',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态(0下架,1上架)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of article
-- ----------------------------
INSERT INTO `article` VALUES (6, '品质保障', '<p>所有商品均为官方正品，支持防伪查询，如遇假货可申请假一赔十</p>', '商品品质与正品保障', '/img/1770459106505.png', 1, 1, '2026-02-07 18:11:48', '2026-02-07 18:11:48');

-- ----------------------------
-- Table structure for carousel_item
-- ----------------------------
DROP TABLE IF EXISTS `carousel_item`;
CREATE TABLE `carousel_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '轮播图片URL',
  `tag` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标签文本',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '描述文本',
  `product_id` bigint NULL DEFAULT 0 COMMENT '商品id',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序顺序',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '首页轮播图表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of carousel_item
-- ----------------------------
INSERT INTO `carousel_item` VALUES (7, '/img/1773049561467.jpg', '', '今日优惠', '', 38, 0, 1);
INSERT INTO `carousel_item` VALUES (8, '/img/1773049584829.webp', '', '新鲜车厘子到货', '', 36, 0, 1);
INSERT INTO `carousel_item` VALUES (9, '/img/1773049629000.jpg', '', '水果捞也是水果', '', 44, 0, 1);

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '购物车ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` int NOT NULL DEFAULT 1 COMMENT '商品数量',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `product_id`(`product_id` ASC) USING BTREE,
  CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cart_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '购物车表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cart
-- ----------------------------
INSERT INTO `cart` VALUES (40, 4, 1, 2, '2026-03-05 10:00:00', '2026-03-05 10:00:00');
INSERT INTO `cart` VALUES (41, 4, 2, 1, '2026-03-05 10:05:00', '2026-03-05 10:05:00');
INSERT INTO `cart` VALUES (42, 5, 1, 3, '2026-03-06 15:20:00', '2026-03-06 15:20:00');
INSERT INTO `cart` VALUES (43, 5, 2, 2, '2026-03-06 15:25:00', '2026-03-06 15:25:00');
INSERT INTO `cart` VALUES (44, 4, 42, 2, '2026-03-09 19:02:29', '2026-03-09 19:02:29');
INSERT INTO `cart` VALUES (45, 4, 39, 1, '2026-03-09 19:02:34', '2026-03-09 19:02:34');

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '分类描述',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '限时特价', '', '2026-02-07 10:46:11', '2026-03-09 16:54:47', 'el-icon-apple');
INSERT INTO `category` VALUES (2, '进口水果', '', '2026-02-07 10:46:11', '2026-03-09 16:54:17', 'el-icon-cherry');
INSERT INTO `category` VALUES (3, '时令鲜果', '', '2026-02-07 10:46:11', '2026-03-09 16:55:21', 'el-icon-watermelon');
INSERT INTO `category` VALUES (4, '水果捞', '', '2026-02-07 10:46:11', '2026-03-09 16:55:45', 'el-icon-dessert');
INSERT INTO `category` VALUES (5, '果蔬制品', '', '2026-02-07 10:46:11', '2026-03-09 16:55:53', 'el-icon-milk-tea');

-- ----------------------------
-- Table structure for chat_message
-- ----------------------------
DROP TABLE IF EXISTS `chat_message`;
CREATE TABLE `chat_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `customer_id` bigint NOT NULL COMMENT '顾客ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `sender_id` bigint NOT NULL COMMENT '发送者ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `is_read` tinyint NULL DEFAULT 0 COMMENT '是否已读(0未读,1已读)',
  `type` int NULL DEFAULT 1 COMMENT '消息类型(1咨询消息,2订单消息)',
  `related_order_id` bigint NULL DEFAULT NULL COMMENT '关联订单ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_product_customer`(`product_id` ASC, `customer_id` ASC) USING BTREE,
  INDEX `idx_merchant`(`merchant_id` ASC) USING BTREE,
  INDEX `idx_sender`(`sender_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '聊天消息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of chat_message
-- ----------------------------
INSERT INTO `chat_message` VALUES (1, 1, 4, 2, 4, '你好，请问红富士苹果还有货吗？', 1, 1, NULL, '2026-03-01 10:00:00');
INSERT INTO `chat_message` VALUES (2, 1, 4, 2, 2, '您好，有的，目前库存充足', 1, 1, NULL, '2026-03-01 10:05:00');
INSERT INTO `chat_message` VALUES (3, 1, 4, 2, 4, '好的，我下单3斤', 1, 2, 102, '2026-03-01 14:20:00');
INSERT INTO `chat_message` VALUES (4, 1, 4, 2, 2, '已收到订单，正在为您打包', 1, 2, 102, '2026-03-01 14:25:00');
INSERT INTO `chat_message` VALUES (5, 2, 5, 2, 5, '香蕉新鲜吗？什么时候到货？', 0, 1, NULL, '2026-03-05 09:00:00');
INSERT INTO `chat_message` VALUES (6, 1, 4, 2, 4, '苹果收到啦，很甜！', 1, 1, NULL, '2026-02-20 15:30:00');
INSERT INTO `chat_message` VALUES (7, 2, 5, 2, 2, '今天下午发货，明天上午到', 0, 1, NULL, '2026-03-05 09:10:00');
INSERT INTO `chat_message` VALUES (8, 42, 4, 3, 4, '你好', 1, 1, NULL, '2026-03-09 19:05:21');
INSERT INTO `chat_message` VALUES (9, 42, 4, 3, 3, '你好', 1, 1, NULL, '2026-03-09 19:05:34');

-- ----------------------------
-- Table structure for dict_item
-- ----------------------------
DROP TABLE IF EXISTS `dict_item`;
CREATE TABLE `dict_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `dict_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '关联的字典类型code',
  `item_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典项的键',
  `item_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典项的值',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '字典项的描述',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `item_key`(`item_key` ASC) USING BTREE,
  INDEX `dict_type_code`(`dict_type_code` ASC) USING BTREE,
  CONSTRAINT `dict_item_ibfk_1` FOREIGN KEY (`dict_type_code`) REFERENCES `sys_dict` (`dict_type_code`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 321 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统字典项表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of dict_item
-- ----------------------------
INSERT INTO `dict_item` VALUES (1, 'icon', 'user', 'el-icon-user1', NULL, '2026-02-06 23:06:45', '2026-02-07 14:40:17');
INSERT INTO `dict_item` VALUES (2, 'icon', 'house', 'el-icon-house', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (3, 'icon', 'menu', 'el-icon-menu', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (4, 'icon', 's-custom', 'el-icon-s-custom', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (5, 'icon', 's-grid', 'el-icon-s-grid', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (6, 'icon', 'document', 'el-icon-document', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (7, 'icon', 'coffee', 'el-icon-coffee', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (8, 'icon', 's-marketing', 'el-icon-s-marketing', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (9, 'icon', 'phone-outline', 'el-icon-phone-outline', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (10, 'icon', 'platform-eleme', 'el-icon-platform-eleme', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (11, 'icon', 'eleme', 'el-icon-eleme', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (12, 'icon', 'delete-solid', 'el-icon-delete-solid', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (13, 'icon', 'delete', 'el-icon-delete', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (14, 'icon', 's-tools', 'el-icon-s-tools', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (15, 'icon', 'setting', 'el-icon-setting', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (16, 'icon', 'user-solid', 'el-icon-user-solid', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (17, 'icon', 'phone', 'el-icon-phone', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (18, 'icon', 'more', 'el-icon-more', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (19, 'icon', 'more-outline', 'el-icon-more-outline', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (20, 'icon', 'star-on', 'el-icon-star-on', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (21, 'icon', 'star-off', 'el-icon-star-off', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (22, 'icon', 's-goods', 'el-icon-s-goods', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (23, 'icon', 'goods', 'el-icon-goods', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (24, 'icon', 'warning', 'el-icon-warning', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (25, 'icon', 'warning-outline', 'el-icon-warning-outline', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (26, 'icon', 'question', 'el-icon-question', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (27, 'icon', 'info', 'el-icon-info', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (28, 'icon', 'remove', 'el-icon-remove', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (29, 'icon', 'circle-plus', 'el-icon-circle-plus', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (30, 'icon', 'success', 'el-icon-success', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (31, 'icon', 'error', 'el-icon-error', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (32, 'icon', 'zoom-in', 'el-icon-zoom-in', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (33, 'icon', 'zoom-out', 'el-icon-zoom-out', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (34, 'icon', 'remove-outline', 'el-icon-remove-outline', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (35, 'icon', 'circle-plus-outline', 'el-icon-circle-plus-outline', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (36, 'icon', 'circle-check', 'el-icon-circle-check', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (37, 'icon', 'circle-close', 'el-icon-circle-close', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (38, 'icon', 's-help', 'el-icon-s-help', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (39, 'icon', 'help', 'el-icon-help', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (40, 'icon', 'minus', 'el-icon-minus', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (41, 'icon', 'plus', 'el-icon-plus', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (42, 'icon', 'check', 'el-icon-check', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (43, 'icon', 'close', 'el-icon-close', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (44, 'icon', 'picture', 'el-icon-picture', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (45, 'icon', 'picture-outline', 'el-icon-picture-outline', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (46, 'icon', 'picture-outline-round', 'el-icon-picture-outline-round', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (47, 'icon', 'upload', 'el-icon-upload', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (48, 'icon', 'upload2', 'el-icon-upload2', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (49, 'icon', 'download', 'el-icon-download', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (50, 'icon', 'camera-solid', 'el-icon-camera-solid', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (51, 'icon', 'camera', 'el-icon-camera', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (52, 'icon', 'video-camera-solid', 'el-icon-video-camera-solid', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (53, 'icon', 'video-camera', 'el-icon-video-camera', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (54, 'icon', 'message-solid', 'el-icon-message-solid', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (55, 'icon', 'bell', 'el-icon-bell', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (56, 'icon', 's-cooperation', 'el-icon-s-cooperation', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (57, 'icon', 's-order', 'el-icon-s-order', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (58, 'icon', 's-platform', 'el-icon-s-platform', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (59, 'icon', 's-fold', 'el-icon-s-fold', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (60, 'icon', 's-unfold', 'el-icon-s-unfold', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (61, 'icon', 's-operation', 'el-icon-s-operation', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (62, 'icon', 's-promotion', 'el-icon-s-promotion', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (63, 'icon', 's-home', 'el-icon-s-home', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (64, 'icon', 's-release', 'el-icon-s-release', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (65, 'icon', 's-ticket', 'el-icon-s-ticket', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (66, 'icon', 's-management', 'el-icon-s-management', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (67, 'icon', 's-open', 'el-icon-s-open', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (68, 'icon', 's-shop', 'el-icon-s-shop', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (69, 'icon', 's-flag', 'el-icon-s-flag', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (70, 'icon', 's-comment', 'el-icon-s-comment', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (71, 'icon', 's-finance', 'el-icon-s-finance', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (72, 'icon', 's-claim', 'el-icon-s-claim', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (73, 'icon', 's-opportunity', 'el-icon-s-opportunity', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (74, 'icon', 's-data', 'el-icon-s-data', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (75, 'icon', 's-check', 'el-icon-s-check', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (76, 'icon', 'share', 'el-icon-share', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (77, 'icon', 'd-caret', 'el-icon-d-caret', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (78, 'icon', 'caret-left', 'el-icon-caret-left', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (79, 'icon', 'caret-right', 'el-icon-caret-right', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (80, 'icon', 'caret-bottom', 'el-icon-caret-bottom', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (81, 'icon', 'caret-top', 'el-icon-caret-top', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (82, 'icon', 'bottom-left', 'el-icon-bottom-left', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (83, 'icon', 'bottom-right', 'el-icon-bottom-right', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (84, 'icon', 'back', 'el-icon-back', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (85, 'icon', 'right', 'el-icon-right', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (86, 'icon', 'bottom', 'el-icon-bottom', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (87, 'icon', 'top', 'el-icon-top', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (88, 'icon', 'top-left', 'el-icon-top-left', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (89, 'icon', 'top-right', 'el-icon-top-right', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (90, 'icon', 'arrow-left', 'el-icon-arrow-left', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (91, 'icon', 'arrow-right', 'el-icon-arrow-right', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (92, 'icon', 'arrow-down', 'el-icon-arrow-down', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (93, 'icon', 'arrow-up', 'el-icon-arrow-up', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (94, 'icon', 'd-arrow-left', 'el-icon-d-arrow-left', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (95, 'icon', 'd-arrow-right', 'el-icon-d-arrow-right', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (96, 'icon', 'video-pause', 'el-icon-video-pause', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (97, 'icon', 'video-play', 'el-icon-video-play', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (98, 'icon', 'refresh', 'el-icon-refresh', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (99, 'icon', 'refresh-right', 'el-icon-refresh-right', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (100, 'icon', 'refresh-left', 'el-icon-refresh-left', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (101, 'icon', 'finished', 'el-icon-finished', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (102, 'icon', 'sort', 'el-icon-sort', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (103, 'icon', 'sort-up', 'el-icon-sort-up', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (104, 'icon', 'sort-down', 'el-icon-sort-down', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (105, 'icon', 'rank', 'el-icon-rank', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (106, 'icon', 'loading', 'el-icon-loading', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (107, 'icon', 'view', 'el-icon-view', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (108, 'icon', 'c-scale-to-original', 'el-icon-c-scale-to-original', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (109, 'icon', 'date', 'el-icon-date', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (110, 'icon', 'edit', 'el-icon-edit', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (111, 'icon', 'edit-outline', 'el-icon-edit-outline', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (112, 'icon', 'folder', 'el-icon-folder', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (113, 'icon', 'folder-opened', 'el-icon-folder-opened', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (114, 'icon', 'folder-add', 'el-icon-folder-add', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (115, 'icon', 'folder-remove', 'el-icon-folder-remove', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (116, 'icon', 'folder-delete', 'el-icon-folder-delete', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (117, 'icon', 'folder-checked', 'el-icon-folder-checked', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (118, 'icon', 'tickets', 'el-icon-tickets', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (119, 'icon', 'document-remove', 'el-icon-document-remove', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (120, 'icon', 'document-delete', 'el-icon-document-delete', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (121, 'icon', 'document-copy', 'el-icon-document-copy', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (122, 'icon', 'document-checked', 'el-icon-document-checked', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (123, 'icon', 'document-add', 'el-icon-document-add', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (124, 'icon', 'printer', 'el-icon-printer', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (125, 'icon', 'paperclip', 'el-icon-paperclip', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (126, 'icon', 'takeaway-box', 'el-icon-takeaway-box', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (127, 'icon', 'search', 'el-icon-search', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (128, 'icon', 'monitor', 'el-icon-monitor', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (129, 'icon', 'attract', 'el-icon-attract', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (130, 'icon', 'mobile', 'el-icon-mobile', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (131, 'icon', 'scissors', 'el-icon-scissors', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (132, 'icon', 'umbrella', 'el-icon-umbrella', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (133, 'icon', 'headset', 'el-icon-headset', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (134, 'icon', 'brush', 'el-icon-brush', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (135, 'icon', 'mouse', 'el-icon-mouse', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (136, 'icon', 'coordinate', 'el-icon-coordinate', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (137, 'icon', 'magic-stick', 'el-icon-magic-stick', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (138, 'icon', 'reading', 'el-icon-reading', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (139, 'icon', 'data-line', 'el-icon-data-line', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (140, 'icon', 'data-board', 'el-icon-data-board', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (141, 'icon', 'pie-chart', 'el-icon-pie-chart', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (142, 'icon', 'data-analysis', 'el-icon-data-analysis', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (143, 'icon', 'collection-tag', 'el-icon-collection-tag', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (144, 'icon', 'film', 'el-icon-film', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (145, 'icon', 'suitcase', 'el-icon-suitcase', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (146, 'icon', 'suitcase-1', 'el-icon-suitcase-1', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (147, 'icon', 'receiving', 'el-icon-receiving', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (148, 'icon', 'collection', 'el-icon-collection', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (149, 'icon', 'files', 'el-icon-files', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (150, 'icon', 'notebook-1', 'el-icon-notebook-1', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (151, 'icon', 'notebook-2', 'el-icon-notebook-2', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (152, 'icon', 'toilet-paper', 'el-icon-toilet-paper', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (153, 'icon', 'office-building', 'el-icon-office-building', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (154, 'icon', 'school', 'el-icon-school', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (155, 'icon', 'table-lamp', 'el-icon-table-lamp', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (156, 'icon', 'no-smoking', 'el-icon-no-smoking', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (157, 'icon', 'smoking', 'el-icon-smoking', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (158, 'icon', 'shopping-cart-full', 'el-icon-shopping-cart-full', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (159, 'icon', 'shopping-cart-1', 'el-icon-shopping-cart-1', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (160, 'icon', 'shopping-cart-2', 'el-icon-shopping-cart-2', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (161, 'icon', 'shopping-bag-1', 'el-icon-shopping-bag-1', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (162, 'icon', 'shopping-bag-2', 'el-icon-shopping-bag-2', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (163, 'icon', 'sold-out', 'el-icon-sold-out', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (164, 'icon', 'sell', 'el-icon-sell', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (165, 'icon', 'present', 'el-icon-present', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (166, 'icon', 'box', 'el-icon-box', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (167, 'icon', 'bank-card', 'el-icon-bank-card', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (168, 'icon', 'money', 'el-icon-money', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (169, 'icon', 'coin', 'el-icon-coin', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (170, 'icon', 'wallet', 'el-icon-wallet', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (171, 'icon', 'discount', 'el-icon-discount', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (172, 'icon', 'price-tag', 'el-icon-price-tag', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (173, 'icon', 'news', 'el-icon-news', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (174, 'icon', 'guide', 'el-icon-guide', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (175, 'icon', 'male', 'el-icon-male', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (176, 'icon', 'female', 'el-icon-female', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (177, 'icon', 'thumb', 'el-icon-thumb', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (178, 'icon', 'cpu', 'el-icon-cpu', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (179, 'icon', 'link', 'el-icon-link', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (180, 'icon', 'connection', 'el-icon-connection', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (181, 'icon', 'open', 'el-icon-open', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (182, 'icon', 'turn-off', 'el-icon-turn-off', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (183, 'icon', 'set-up', 'el-icon-set-up', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (184, 'icon', 'chat-round', 'el-icon-chat-round', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (185, 'icon', 'chat-line-round', 'el-icon-chat-line-round', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (186, 'icon', 'chat-square', 'el-icon-chat-square', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (187, 'icon', 'chat-dot-round', 'el-icon-chat-dot-round', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (188, 'icon', 'chat-dot-square', 'el-icon-chat-dot-square', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (189, 'icon', 'chat-line-square', 'el-icon-chat-line-square', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (190, 'icon', 'message', 'el-icon-message', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (191, 'icon', 'postcard', 'el-icon-postcard', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (192, 'icon', 'position', 'el-icon-position', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (193, 'icon', 'turn-off-microphone', 'el-icon-turn-off-microphone', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (194, 'icon', 'microphone', 'el-icon-microphone', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (195, 'icon', 'close-notification', 'el-icon-close-notification', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (196, 'icon', 'bangzhu', 'el-icon-bangzhu', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (197, 'icon', 'time', 'el-icon-time', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (198, 'icon', 'odometer', 'el-icon-odometer', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (199, 'icon', 'crop', 'el-icon-crop', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (200, 'icon', 'aim', 'el-icon-aim', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (201, 'icon', 'switch-button', 'el-icon-switch-button', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (202, 'icon', 'full-screen', 'el-icon-full-screen', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (203, 'icon', 'copy-document', 'el-icon-copy-document', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (204, 'icon', 'mic', 'el-icon-mic', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (205, 'icon', 'stopwatch', 'el-icon-stopwatch', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (206, 'icon', 'medal-1', 'el-icon-medal-1', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (207, 'icon', 'medal', 'el-icon-medal', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (208, 'icon', 'trophy', 'el-icon-trophy', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (209, 'icon', 'trophy-1', 'el-icon-trophy-1', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (210, 'icon', 'first-aid-kit', 'el-icon-first-aid-kit', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (211, 'icon', 'discover', 'el-icon-discover', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (212, 'icon', 'place', 'el-icon-place', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (213, 'icon', 'location', 'el-icon-location', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (214, 'icon', 'location-outline', 'el-icon-location-outline', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (215, 'icon', 'location-information', 'el-icon-location-information', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (216, 'icon', 'add-location', 'el-icon-add-location', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (217, 'icon', 'delete-location', 'el-icon-delete-location', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (218, 'icon', 'map-location', 'el-icon-map-location', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (219, 'icon', 'alarm-clock', 'el-icon-alarm-clock', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (220, 'icon', 'timer', 'el-icon-timer', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (221, 'icon', 'watch-1', 'el-icon-watch-1', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (222, 'icon', 'watch', 'el-icon-watch', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (223, 'icon', 'lock', 'el-icon-lock', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (224, 'icon', 'unlock', 'el-icon-unlock', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (225, 'icon', 'key', 'el-icon-key', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (226, 'icon', 'service', 'el-icon-service', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (227, 'icon', 'mobile-phone', 'el-icon-mobile-phone', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (228, 'icon', 'bicycle', 'el-icon-bicycle', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (229, 'icon', 'truck', 'el-icon-truck', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (230, 'icon', 'ship', 'el-icon-ship', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (231, 'icon', 'basketball', 'el-icon-basketball', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (232, 'icon', 'football', 'el-icon-football', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (233, 'icon', 'soccer', 'el-icon-soccer', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (234, 'icon', 'baseball', 'el-icon-baseball', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (235, 'icon', 'wind-power', 'el-icon-wind-power', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (236, 'icon', 'light-rain', 'el-icon-light-rain', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (237, 'icon', 'lightning', 'el-icon-lightning', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (238, 'icon', 'heavy-rain', 'el-icon-heavy-rain', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (239, 'icon', 'sunrise', 'el-icon-sunrise', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (240, 'icon', 'sunrise-1', 'el-icon-sunrise-1', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (241, 'icon', 'sunset', 'el-icon-sunset', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (242, 'icon', 'sunny', 'el-icon-sunny', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (243, 'icon', 'cloudy', 'el-icon-cloudy', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (244, 'icon', 'partly-cloudy', 'el-icon-partly-cloudy', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (245, 'icon', 'cloudy-and-sunny', 'el-icon-cloudy-and-sunny', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (246, 'icon', 'moon', 'el-icon-moon', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (247, 'icon', 'moon-night', 'el-icon-moon-night', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (248, 'icon', 'dish', 'el-icon-dish', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (249, 'icon', 'dish-1', 'el-icon-dish-1', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (250, 'icon', 'food', 'el-icon-food', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (251, 'icon', 'chicken', 'el-icon-chicken', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (252, 'icon', 'fork-spoon', 'el-icon-fork-spoon', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (253, 'icon', 'knife-fork', 'el-icon-knife-fork', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (254, 'icon', 'burger', 'el-icon-burger', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (255, 'icon', 'tableware', 'el-icon-tableware', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (256, 'icon', 'sugar', 'el-icon-sugar', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (257, 'icon', 'dessert', 'el-icon-dessert', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (258, 'icon', 'ice-cream', 'el-icon-ice-cream', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (259, 'icon', 'hot-water', 'el-icon-hot-water', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (260, 'icon', 'water-cup', 'el-icon-water-cup', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (261, 'icon', 'coffee-cup', 'el-icon-coffee-cup', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (262, 'icon', 'cold-drink', 'el-icon-cold-drink', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (263, 'icon', 'goblet', 'el-icon-goblet', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (264, 'icon', 'goblet-full', 'el-icon-goblet-full', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (265, 'icon', 'goblet-square', 'el-icon-goblet-square', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (266, 'icon', 'goblet-square-full', 'el-icon-goblet-square-full', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (267, 'icon', 'refrigerator', 'el-icon-refrigerator', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (268, 'icon', 'grape', 'el-icon-grape', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (269, 'icon', 'watermelon', 'el-icon-watermelon', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (270, 'icon', 'cherry', 'el-icon-cherry', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (271, 'icon', 'apple', 'el-icon-apple', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (272, 'icon', 'pear', 'el-icon-pear', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (273, 'icon', 'orange', 'el-icon-orange', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (274, 'icon', 'ice-tea', 'el-icon-ice-tea', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (275, 'icon', 'ice-drink', 'el-icon-ice-drink', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (276, 'icon', 'milk-tea', 'el-icon-milk-tea', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (277, 'icon', 'potato-strips', 'el-icon-potato-strips', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (278, 'icon', 'lollipop', 'el-icon-lollipop', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (279, 'icon', 'ice-cream-square', 'el-icon-ice-cream-square', NULL, '2026-02-06 23:06:45', '2026-02-06 23:06:45');
INSERT INTO `dict_item` VALUES (284, 'icon', 'el-icon-grape', 'el-icon-grape', '葡萄', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (285, 'icon', 'el-icon-watermelon', 'el-icon-watermelon', '西瓜', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (286, 'icon', 'el-icon-cherry', 'el-icon-cherry', '樱桃', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (287, 'icon', 'el-icon-apple', 'el-icon-apple', '苹果', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (288, 'icon', 'el-icon-pear', 'el-icon-pear', '梨', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (289, 'icon', 'el-icon-orange', 'el-icon-orange', '橘子', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (290, 'icon', 'el-icon-coffee', 'el-icon-coffee', '咖啡', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (291, 'icon', 'el-icon-ice-tea', 'el-icon-ice-tea', '冰茶', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (292, 'icon', 'el-icon-ice-drink', 'el-icon-ice-drink', '冷饮', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (293, 'icon', 'el-icon-milk-tea', 'el-icon-milk-tea', '奶茶', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (294, 'icon', 'el-icon-potato-strips', 'el-icon-potato-strips', '薯条', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (295, 'icon', 'el-icon-lollipop', 'el-icon-lollipop', '棒棒糖', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (296, 'icon', 'el-icon-ice-cream-square', 'el-icon-ice-cream-square', '雪糕', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (297, 'icon', 'el-icon-ice-cream-round', 'el-icon-ice-cream-round', '冰淇淋', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (298, 'icon', 'el-icon-dish', 'el-icon-dish', '菜肴', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (299, 'icon', 'el-icon-dish-1', 'el-icon-dish-1', '菜肴1', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (300, 'icon', 'el-icon-tableware', 'el-icon-tableware', '餐具', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (301, 'icon', 'el-icon-knife-fork', 'el-icon-knife-fork', '餐饮', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (302, 'icon', 'el-icon-sugar', 'el-icon-sugar', '糖果', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (303, 'icon', 'el-icon-shopping-bag-1', 'el-icon-shopping-bag-1', '购物袋', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (304, 'icon', 'el-icon-shopping-bag-2', 'el-icon-shopping-bag-2', '购物袋2', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (305, 'icon', 'el-icon-shopping-cart-full', 'el-icon-shopping-cart-full', '购物车满', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (306, 'icon', 'el-icon-shopping-cart-1', 'el-icon-shopping-cart-1', '购物车1', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (307, 'icon', 'el-icon-shopping-cart-2', 'el-icon-shopping-cart-2', '购物车2', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (308, 'icon', 'el-icon-present', 'el-icon-present', '礼物', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (309, 'icon', 'el-icon-box', 'el-icon-box', '盒子', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (310, 'icon', 'el-icon-goods', 'el-icon-goods', '商品', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (311, 'icon', 'el-icon-s-shop', 'el-icon-s-shop', '门店', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (312, 'icon', 'el-icon-s-goods', 'el-icon-s-goods', '商品管理', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (313, 'icon', 'el-icon-food', 'el-icon-food', '食品', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (314, 'icon', 'el-icon-refrigerator', 'el-icon-refrigerator', '冷冻', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (315, 'icon', 'el-icon-truck', 'el-icon-truck', '物流', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (316, 'icon', 'el-icon-location-outline', 'el-icon-location-outline', '定位', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (317, 'icon', 'el-icon-time', 'el-icon-time', '时间', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (318, 'icon', 'el-icon-date', 'el-icon-date', '日期', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (319, 'icon', 'el-icon-picture-outline', 'el-icon-picture-outline', '图片', '2026-02-04 19:27:37', '2026-02-04 19:27:37');
INSERT INTO `dict_item` VALUES (320, 'icon', 'el-icon-star-on', 'el-icon-star-on', '收藏', '2026-02-04 19:27:37', '2026-02-04 19:27:37');

-- ----------------------------
-- Table structure for favorite
-- ----------------------------
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '收藏状态:0取消,1收藏',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `product_id`(`product_id` ASC) USING BTREE,
  CONSTRAINT `favorite_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `favorite_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 82 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品收藏表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of favorite
-- ----------------------------
INSERT INTO `favorite` VALUES (79, 4, 37, 1, '2026-03-09 19:02:16', '2026-03-09 19:02:16');
INSERT INTO `favorite` VALUES (80, 4, 2, 1, '2026-03-09 19:02:17', '2026-03-09 19:02:17');
INSERT INTO `favorite` VALUES (81, 4, 39, 1, '2026-03-09 19:02:20', '2026-03-09 19:02:20');

-- ----------------------------
-- Table structure for logistics
-- ----------------------------
DROP TABLE IF EXISTS `logistics`;
CREATE TABLE `logistics`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '物流ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `receiver_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货人电话',
  `receiver_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货地址',
  `company_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物流公司名称',
  `tracking_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物流单号',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '物流状态:0待发货,1已发货,2已签收,3已取消',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `expected_arrival_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_tracking_number`(`tracking_number` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物流信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of logistics
-- ----------------------------
INSERT INTO `logistics` VALUES (19, 140, '456', '13800138002', '北京市海淀区某街道2号', '顺丰快递', 'sf111111111', 1, '2026-03-09 19:06:07', '2026-03-09 19:06:07', '2026-03-10 00:00:00');

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '公告标签',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (33, '新鲜水果预售开启！', '本周新鲜水果预售活动开始啦！包括：\n1. 陕西洛川苹果 5斤装 特惠价39.9元\n2. 四川蒲江猕猴桃 12个装 特惠价29.9元\n3. 海南小台农芒果 3斤装 特惠价45.8元\n预售时间：2026-02-07至2026-03-25，提前下单享受优惠！', '2026-02-06 08:00:00', '预售,特惠');
INSERT INTO `notice` VALUES (34, '平台质量管理公告', '为保证农产品质量，平台已开展春季质量检查行动：\n1. 所有入驻商家需提供最新食品经营许可证\n2. 农产品抽检频率提升至每周两次\n3. 生鲜类商品运输全程冷链配送\n请广大用户放心购买！', '2026-02-06 10:30:00', '质量管理,公告');
INSERT INTO `notice` VALUES (36, '物流配送通知', '因春季天气多变，部分地区可能出现配送延迟。我们已增加配送人员，确保生鲜商品及时送达。如遇极端天气，客服会第一时间联系您！感谢理解！', '2026-02-07 14:00:00', '物流,通知');

-- ----------------------------
-- Table structure for order
-- ----------------------------
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `total_price` decimal(10, 2) NOT NULL COMMENT '订单总价',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '订单状态:0待支付,1已支付,2已发货,3已完成,4已取消,5退款中,6已退款,7退款失败,8平台拒绝退款',
  `last_status` tinyint NOT NULL DEFAULT 0 COMMENT '上一个订单状态',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单备注',
  `refund_time` timestamp NULL DEFAULT NULL COMMENT '退款时间',
  `refund_status` tinyint NULL DEFAULT 0 COMMENT '退款状态:0无退款,1申请退款,2退款中,3已退款,4退款失败,5平台拒绝退款',
  `refund_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退款原因',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` int NOT NULL COMMENT '购买数量',
  `price` decimal(10, 2) NOT NULL COMMENT '商品单价',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `recv_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '地址信息',
  `recv_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系方式',
  `recv_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'NULL',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `product_id`(`product_id` ASC) USING BTREE,
  INDEX `idx_order_user`(`user_id` ASC) USING BTREE COMMENT '订单用户索引',
  CONSTRAINT `order_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `order_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 141 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of order
-- ----------------------------
INSERT INTO `order` VALUES (137, 4, 20.00, 1, 0, NULL, NULL, 0, NULL, 36, 1, 20.00, '2026-03-09 19:02:44', '2026-03-09 19:02:44', '北京市朝阳区某街道1号', '13800138001', '123');
INSERT INTO `order` VALUES (138, 4, 3.00, 0, 0, NULL, NULL, 0, NULL, 38, 1, 3.00, '2026-03-09 19:03:09', '2026-03-09 19:03:09', '北京市朝阳区某街道1号', '13800138001', '123');
INSERT INTO `order` VALUES (139, 4, 20.00, 8, 5, '平台拒绝退款：？', '2026-03-09 19:04:26', 5, '发货太慢', 42, 1, 20.00, '2026-03-09 19:03:43', '2026-03-09 19:03:43', '北京市朝阳区某街道1号', '13800138001', '123');
INSERT INTO `order` VALUES (140, 4, 20.00, 6, 5, '平台介入退款：1', '2026-03-09 19:07:42', 3, '商品质量问题', 42, 1, 20.00, '2026-03-09 19:05:45', '2026-03-09 19:05:45', '北京市海淀区某街道2号', '13800138002', '456');

-- ----------------------------
-- Table structure for product
-- ----------------------------
DROP TABLE IF EXISTS `product`;
CREATE TABLE `product`  (
  `place_of_origin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '产地',
  `is_discount` tinyint NULL DEFAULT NULL COMMENT '是否开启折扣',
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称',
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '商品描述',
  `price` decimal(10, 2) NOT NULL COMMENT '商品价格',
  `stock` int NOT NULL DEFAULT 0 COMMENT '库存数量',
  `category_id` bigint NOT NULL COMMENT '分类ID',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品图片URL',
  `sales_count` int NOT NULL DEFAULT 0 COMMENT '销量',
  `merchant_id` bigint NOT NULL COMMENT '农户ID',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '商品状态:0下架,1上架',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `discount_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '折扣价格',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `farmer_id`(`merchant_id` ASC) USING BTREE,
  INDEX `idx_product_name`(`name` ASC) USING BTREE COMMENT '商品名称索引',
  CONSTRAINT `product_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 45 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of product
-- ----------------------------
INSERT INTO `product` VALUES ('山东省烟台市', 1, 1, '红富士苹果', '<p>山东栖霞红富士苹果，甜度高</p>', 6.00, 1000, 1, '/img/1738583441855.png', 505, 2, 1, '2026-02-07 10:46:11', '2026-02-06 18:03:52', 3.99);
INSERT INTO `product` VALUES ('广西壮族自治区', 1, 2, '香蕉', '<p>高山大香蕉当季新鲜水果青皮香蕉现摘香甜需催熟甜蕉甜香蕉香甜</p>', 6.00, 100, 3, '/img/1770465491710.png', 0, 3, 1, '2026-02-07 19:58:23', '2026-02-07 19:58:23', 3.99);
INSERT INTO `product` VALUES ('智利', 0, 36, '车厘子', '<p>智利车厘子</p>', 20.00, 49, 2, '/img/1773047261567.png', 1, 2, 1, '2026-03-09 17:07:46', '2026-03-09 17:07:46', 0.00);
INSERT INTO `product` VALUES ('河南', 0, 37, '水蜜桃', '<p><br></p>', 5.00, 20, 3, '/img/1773047806055.png', 0, 2, 1, '2026-03-09 17:16:50', '2026-03-09 17:16:50', 0.00);
INSERT INTO `product` VALUES ('山东', 1, 38, '皇冠梨', '<p><br></p>', 5.00, 10, 1, '/img/1773047938228.png', 0, 2, 1, '2026-03-09 17:19:11', '2026-03-09 17:19:11', 3.00);
INSERT INTO `product` VALUES ('甘肃', 0, 39, '麒麟西瓜', '<p><br></p>', 2.00, 100, 3, '/img/1773048168565.png', 0, 2, 1, '2026-03-09 17:22:59', '2026-03-09 17:22:59', 0.00);
INSERT INTO `product` VALUES ('广西', 0, 40, '荔枝', '<p><br></p>', 10.00, 200, 3, '/img/1773048535660.png', 0, 2, 1, '2026-03-09 17:29:07', '2026-03-09 17:29:07', 0.00);
INSERT INTO `product` VALUES ('河南', 0, 41, '香蕉片', '<p><br></p>', 15.00, 100, 5, '/img/1773048772387.png', 0, 3, 1, '2026-03-09 17:32:57', '2026-03-09 17:32:57', 0.00);
INSERT INTO `product` VALUES ('河南', 0, 42, '草莓果酱', '<p>丘比草莓果酱</p>', 20.00, 49, 5, '/img/1773048900844.png', 1, 3, 1, '2026-03-09 17:35:19', '2026-03-09 17:35:19', 0.00);
INSERT INTO `product` VALUES ('海南', 0, 43, '芒果', '<p><br></p>', 10.00, 100, 3, '/img/1773048972207.png', 0, 3, 1, '2026-03-09 17:36:42', '2026-03-09 17:36:42', 0.00);
INSERT INTO `product` VALUES ('本地', 0, 44, '酸奶水果捞', '<p><br></p>', 15.00, 20, 4, '/img/1773049161072.png', 0, 3, 1, '2026-03-09 17:39:25', '2026-03-09 17:39:25', 0.00);

-- ----------------------------
-- Table structure for refund_intervention
-- ----------------------------
DROP TABLE IF EXISTS `refund_intervention`;
CREATE TABLE `refund_intervention`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '介入申请ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `product_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品名称',
  `order_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '订单金额',
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '申请原因',
  `images` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片证据(JSON数组)',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态:0待处理,1已通过,2已拒绝',
  `admin_id` bigint NULL DEFAULT NULL COMMENT '处理管理员ID',
  `admin_reply` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '管理员回复',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '退款介入申请表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of refund_intervention
-- ----------------------------
INSERT INTO `refund_intervention` VALUES (1, 140, 4, 3, 42, '草莓果酱', 20.00, '过期了。。。。。。。', '[]', 1, 7, '1', '2026-03-09 19:07:00', '2026-03-09 19:07:42');
INSERT INTO `refund_intervention` VALUES (2, 139, 4, 3, 42, '草莓果酱', 20.00, '1111111111', '[]', 2, 7, '？', '2026-03-09 19:07:59', '2026-03-09 19:08:11');

-- ----------------------------
-- Table structure for review
-- ----------------------------
DROP TABLE IF EXISTS `review`;
CREATE TABLE `review`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评价ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `rating` tinyint NOT NULL COMMENT '评分(1-5星)',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '评价内容',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '评价状态:0待审核,1已通过,2已拒绝',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_review_product`(`product_id` ASC) USING BTREE COMMENT '评价商品索引',
  CONSTRAINT `review_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `review_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品评价表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of review
-- ----------------------------

-- ----------------------------
-- Table structure for stock_in
-- ----------------------------
DROP TABLE IF EXISTS `stock_in`;
CREATE TABLE `stock_in`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '入库ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` int NOT NULL COMMENT '入库数量',
  `unit_price` decimal(10, 2) NOT NULL COMMENT '单价',
  `total_price` decimal(10, 2) NOT NULL COMMENT '总价',
  `supplier` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '供应商',
  `stock_date` date NOT NULL COMMENT '入库日期',
  `operator_id` bigint NOT NULL COMMENT '操作人ID',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态:0-作废,1-正常',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '入库记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of stock_in
-- ----------------------------

-- ----------------------------
-- Table structure for stock_out
-- ----------------------------
DROP TABLE IF EXISTS `stock_out`;
CREATE TABLE `stock_out`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '出库ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` int NOT NULL COMMENT '出库数量',
  `unit_price` decimal(10, 2) NOT NULL COMMENT '单价',
  `total_price` decimal(10, 2) NOT NULL COMMENT '总价',
  `type` tinyint NOT NULL COMMENT '出库类型:1-销售出库,2-损耗出库,3-其他出库',
  `customer_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户姓名',
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单号',
  `operator_id` bigint NOT NULL COMMENT '操作人ID',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态:0-作废,1-正常',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '出库记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of stock_out
-- ----------------------------

-- ----------------------------
-- Table structure for sys_dict
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict`;
CREATE TABLE `sys_dict`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `dict_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典编码',
  `dict_type_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '描述',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_dict_type_code`(`dict_type_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统字典表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict
-- ----------------------------
INSERT INTO `sys_dict` VALUES (1, 'icon', '图标', '系统图标字典表', 0, '2026-02-06 21:53:19', '2026-02-06 21:53:19');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `role` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '菜单角色',
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜单路径',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜单图标',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '描述',
  `pid` int NULL DEFAULT NULL COMMENT '菜单父id',
  `page_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '页面路径',
  `sort_num` int NULL DEFAULT NULL COMMENT '排序',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 77 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN,MERCHANT', 1, '数据概览', '/showView', 'el-icon-s-data', '系统数据统计', NULL, 'ShowView', 1);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN,MERCHANT', 2, '个人中心', NULL, 'el-icon-user', '用户个人信息管理', NULL, NULL, 2);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN,MERCHANT', 3, '基本信息', '/personInfo', 'el-icon-info', NULL, 2, 'PersonInfo', 1);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN,MERCHANT', 4, '修改密码', '/password', 'el-icon-lock', NULL, 2, 'Password', 2);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN,MERCHANT', 10, '商品管理', NULL, 'el-icon-shopping-bag-1', '商品相关管理', NULL, NULL, 3);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN,MERCHANT', 11, '产品列表', '/productManager', 'el-icon-shopping-cart-full', NULL, 10, 'ProductManager', 1);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN', 12, '商品分类', '/categoryManager', 'el-icon-folder', NULL, 10, 'CategoryManager', 2);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN,MERCHANT', 20, '交易管理', NULL, 'el-icon-shopping-cart-2', '订单相关管理', NULL, NULL, 4);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN,MERCHANT', 21, '订单列表', '/orderManager', 'el-icon-document', NULL, 20, 'OrderManager', 1);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN', 22, '购物车', '/cartManager', 'el-icon-shopping-cart-1', NULL, 20, 'CartManager', 2);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN,MERCHANT', 23, '商品评价', '/reviewManager', 'el-icon-chat-dot-square', NULL, 20, 'ReviewManager', 3);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN', 30, '系统管理', NULL, 'el-icon-setting', '系统相关配置', NULL, NULL, 5);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN', 31, '用户管理', '/userManager', 'el-icon-user', NULL, 30, 'UserManager', 1);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN', 32, '公告管理', '/notices', 'el-icon-bell', NULL, 30, 'NoticeList', 2);
INSERT INTO `sys_menu` VALUES ('FARMER,ADMIN,SUPER_ADMIN', 33, '轮播图', '/carouselManager', 'el-icon-picture', NULL, 30, 'CarouselManager', 3);
INSERT INTO `sys_menu` VALUES ('SUPER_ADMIN', 40, '开发配置', NULL, 'el-icon-s-tools', '系统开发配置', NULL, NULL, 6);
INSERT INTO `sys_menu` VALUES ('SUPER_ADMIN', 41, '菜单管理', '/menu', 'el-icon-menu', NULL, 40, 'Menu', 1);
INSERT INTO `sys_menu` VALUES ('SUPER_ADMIN', 42, '图标库', '/iconItem', 'el-icon-picture-outline-round', NULL, 40, 'IconItem', 2);
INSERT INTO `sys_menu` VALUES ('SUPER_ADMIN,ADMIN,MERCHANT', 70, '物流管理', '/logisticsManager', 'el-icon-shopping-cart-1', '', 20, 'LogisticsManager', 1);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN,MERCHANT', 71, '库存管理', NULL, 'el-icon-tableware', NULL, NULL, NULL, 8);
INSERT INTO `sys_menu` VALUES ('SUPER_ADMIN,ADMIN,MERCHANT', 72, '入库管理', '/stockInManager', 'el-icon-more', '', 71, 'StockInManager', 0);
INSERT INTO `sys_menu` VALUES ('SUPER_ADMIN,ADMIN,MERCHANT', 73, '出库管理', '/stockOutManager', 'el-icon-check', '', 71, 'StockOutManager', 0);
INSERT INTO `sys_menu` VALUES ('MERCHANT', 75, '顾客咨询', '/customerChat', 'el-icon-chat-dot-round', '顾客咨询管理', 20, 'CustomerChat', 4);
INSERT INTO `sys_menu` VALUES ('ADMIN,SUPER_ADMIN', 76, '交易纠纷', '/refundIntervention', 'el-icon-warning', '交易纠纷管理', 20, 'RefundIntervention', 5);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `business_license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '营业执照',
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '真实姓名',
  `role` enum('SUPER_ADMIN','ADMIN','USER','MERCHANT') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'USER' COMMENT '用户角色',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '电子邮箱',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '账号状态(0禁用,1启用)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  INDEX `idx_user_username`(`username` ASC) USING BTREE COMMENT '用户名索引'
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (NULL, 1, 'Sadmin', '$2a$10$rLSOIEHVdA8OxuofPJUmNe.zEJHicLJ.0QyH00YHtWDslBNcJA4W2', '系统管理员', 'SUPER_ADMIN', 'admin@example.com', 1, '2026-02-07 10:46:11', '2026-02-07 11:26:45');
INSERT INTO `user` VALUES ('/img/1746233584273.jpeg', 2, 'mercant1', '$2a$10$rLSOIEHVdA8OxuofPJUmNe.zEJHicLJ.0QyH00YHtWDslBNcJA4W2', '商家1', 'MERCHANT', 'farmer1@example.com', 1, '2026-02-07 10:46:11', '2026-02-04 21:15:51');
INSERT INTO `user` VALUES (NULL, 3, 'mercant2', '$2a$10$rLSOIEHVdA8OxuofPJUmNe.zEJHicLJ.0QyH00YHtWDslBNcJA4W2', '商家2', 'MERCHANT', 'farmer2@example.com', 1, '2026-02-07 10:46:11', '2026-02-04 22:12:50');
INSERT INTO `user` VALUES (NULL, 4, 'user', '$2a$10$rLSOIEHVdA8OxuofPJUmNe.zEJHicLJ.0QyH00YHtWDslBNcJA4W2', '王小明', 'USER', 'user1@example.com', 1, '2026-02-07 10:46:11', '2026-02-07 11:45:18');
INSERT INTO `user` VALUES (NULL, 5, 'user2', '$2a$10$rLSOIEHVdA8OxuofPJUmNe.zEJHicLJ.0QyH00YHtWDslBNcJA4W2', '李小红', 'USER', 'user2@example.com', 1, '2026-02-07 10:46:11', '2026-02-07 00:13:23');
INSERT INTO `user` VALUES (NULL, 7, 'admin', '$2a$10$rLSOIEHVdA8OxuofPJUmNe.zEJHicLJ.0QyH00YHtWDslBNcJA4W2', '管理员1', 'ADMIN', 'admin@qq.com', 1, '2026-02-07 20:22:32', '2026-02-07 00:13:24');
INSERT INTO `user` VALUES (NULL, 11, 'mdxd', '$2a$10$npiJ7M.FFQtS9VBIT16s7OPyxVm6LGNKWECucGOijWvnCSyPZw4.K', '老王', 'MERCHANT', '123@123.com', 1, '2026-03-09 17:55:59', '2026-03-09 17:55:59');

SET FOREIGN_KEY_CHECKS = 1;
