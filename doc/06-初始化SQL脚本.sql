-- ============================================================
-- 婚庆管家 - 数据库初始化脚本
-- 版本: v1.0.0
-- 创建日期: 2025-12-31
-- ============================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `Wedding_management` 
DEFAULT CHARACTER SET utf8mb4 
DEFAULT COLLATE utf8mb4_general_ci;

USE `Wedding_management`;

-- ============================================================
-- 1. 服务类型表
-- ============================================================
CREATE TABLE IF NOT EXISTS `wedding_service_type` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `type_code` varchar(50) NOT NULL DEFAULT '' COMMENT '类型代码：host/photographer/butler',
    `type_name` varchar(50) NOT NULL DEFAULT '' COMMENT '类型名称：主持人/跟拍/管家',
    `icon` varchar(500) NOT NULL DEFAULT '' COMMENT '类型图标',
    `description` varchar(255) NOT NULL DEFAULT '' COMMENT '类型描述',
    `sort` int(10) NOT NULL DEFAULT 0 COMMENT '排序',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_type_code` (`type_code`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务类型表';

-- ============================================================
-- 2. 服务提供者相关表
-- ============================================================

-- 服务提供者表（统一表）
CREATE TABLE IF NOT EXISTS `wedding_service_provider` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联会员ID',
    `service_type` varchar(50) NOT NULL DEFAULT 'host' COMMENT '服务类型：host/photographer/butler',
    `provider_no` varchar(32) NOT NULL DEFAULT '' COMMENT '服务提供者编号',
    `realname` varchar(50) NOT NULL DEFAULT '' COMMENT '真实姓名',
    `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号码',
    `wechat` varchar(50) NOT NULL DEFAULT '' COMMENT '微信号',
    `headimg` varchar(500) NOT NULL DEFAULT '' COMMENT '头像',
    `cover` varchar(500) NOT NULL DEFAULT '' COMMENT '封面图',
    `sex` tinyint(1) NOT NULL DEFAULT 0 COMMENT '性别：0=保密，1=男，2=女',
    `birthday` varchar(20) NOT NULL DEFAULT '' COMMENT '出生日期',
    `id_card` varchar(30) NOT NULL DEFAULT '' COMMENT '身份证号',
    `signature` varchar(255) NOT NULL DEFAULT '' COMMENT '个性签名',
    `introduction` text COMMENT '个人介绍',
    `label_ids` varchar(255) NOT NULL DEFAULT '' COMMENT '管理员标签ID，逗号分隔（仅管理员可设置）',
    `custom_labels` text COMMENT '自定义标签（JSON数组），服务提供者自己设置的擅长标签' CHECK (JSON_VALID(`custom_labels`)),
    `experience_years` int(10) NOT NULL DEFAULT 0 COMMENT '从业年限',
    `diy_page_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联DIY页面ID',
    
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
    `sort` int(10) NOT NULL DEFAULT 0 COMMENT '排序',
    `order_count` int(10) NOT NULL DEFAULT 0 COMMENT '订单数量（缓存）',
    `review_count` int(10) NOT NULL DEFAULT 0 COMMENT '评价数量（缓存）',
    `avg_score` decimal(3,2) NOT NULL DEFAULT 5.00 COMMENT '平均评分（缓存）',
    `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否删除：0=否，1=是（用于快速查询）',
    `deleted_at` int(11) NOT NULL DEFAULT 0 COMMENT '删除时间（时间戳，用于追溯删除时间）',
    PRIMARY KEY (`id`),
    KEY `idx_member_id` (`member_id`),
    KEY `idx_service_type` (`service_type`),
    KEY `idx_status` (`status`),
    KEY `idx_diy_page_id` (`diy_page_id`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务提供者表（统一表）';

-- 服务提供者标签表
CREATE TABLE IF NOT EXISTS `wedding_service_provider_label` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `service_type` varchar(50) NOT NULL DEFAULT '' COMMENT '服务类型：host/photographer/butler（空=通用标签，所有服务类型可用）',
    `name` varchar(50) NOT NULL DEFAULT '' COMMENT '标签名称',
    `icon` varchar(255) NOT NULL DEFAULT '' COMMENT '标签图标',
    `color` varchar(20) NOT NULL DEFAULT '' COMMENT '标签颜色',
    `sort` int(10) NOT NULL DEFAULT 0 COMMENT '排序',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_service_type` (`service_type`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务提供者标签表（仅管理员可管理）';

-- 服务提供者服务表
CREATE TABLE IF NOT EXISTS `wedding_service_provider_service` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID',
    `type` tinyint(1) NOT NULL DEFAULT 1 COMMENT '类型：1=基础套餐，2=增值服务',
    `title` varchar(100) NOT NULL DEFAULT '' COMMENT '服务名称',
    `description` varchar(500) NOT NULL DEFAULT '' COMMENT '服务描述',
    `price` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '价格（单位：元）',
    `period_prices` text COMMENT '场次价格配置（JSON）' CHECK (JSON_VALID(`period_prices`)),
    `available_periods` varchar(50) NOT NULL DEFAULT '' COMMENT '可用场次（逗号分隔）',
    `booking_mode` tinyint(1) NOT NULL DEFAULT 1 COMMENT '预定模式：1=分场次，2=全天',
    `sort` int(10) NOT NULL DEFAULT 0 COMMENT '排序',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_provider_id` (`provider_id`),
    KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务提供者服务表';

-- 服务提供者档期表
CREATE TABLE IF NOT EXISTS `wedding_service_provider_schedule` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID',
    `date` date NOT NULL COMMENT '日期',
    `period` tinyint(1) NOT NULL DEFAULT 1 COMMENT '场次：1=早场（早司仪），2=午场（午宴），3=晚场（晚宴），4=全天（所有服务类型统一）' CHECK (`period` IN (1, 2, 3, 4)),
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=空闲，1=休息，2=已预订' CHECK (`status` IN (0, 1, 2)),
    `price_adjust` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '价格调整（单位：元）',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联订单ID',
    `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_provider_date_time` (`provider_id`, `date`, `start_time`, `end_time`),
    KEY `idx_date` (`date`),
    KEY `idx_status` (`status`),
    KEY `idx_provider_date_status` (`provider_id`, `date`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务提供者档期表';

-- 档期互斥检查触发器（防止period=4与period=1,2,3冲突）
-- 注意：MySQL触发器不能直接阻止INSERT，需要通过SIGNAL抛出错误
DELIMITER $$

CREATE TRIGGER `trg_schedule_mutual_exclusion_before_insert`
BEFORE INSERT ON `wedding_service_provider_schedule`
FOR EACH ROW
BEGIN
    DECLARE conflict_count INT DEFAULT 0;
    
    -- 如果插入的是全天(period=4)，检查是否已有1,2,3场次
    IF NEW.period = 4 THEN
        SELECT COUNT(*) INTO conflict_count
        FROM `wedding_service_provider_schedule`
        WHERE `provider_id` = NEW.provider_id
          AND `date` = NEW.date
          AND `period` IN (1, 2, 3)
          AND `status` = 2; -- 已预订状态
        
        IF conflict_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '全天档期与分场次档期互斥，该日期已有分场次预订';
        END IF;
    END IF;
    
    -- 如果插入的是1,2,3场次，检查是否已有全天(period=4)
    IF NEW.period IN (1, 2, 3) THEN
        SELECT COUNT(*) INTO conflict_count
        FROM `wedding_service_provider_schedule`
        WHERE `provider_id` = NEW.provider_id
          AND `date` = NEW.date
          AND `period` = 4
          AND `status` = 2; -- 已预订状态
        
        IF conflict_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '分场次档期与全天档期互斥，该日期已有全天预订';
        END IF;
    END IF;
END$$

DELIMITER ;

-- 服务提供者收藏表
CREATE TABLE IF NOT EXISTS `wedding_service_provider_favorite` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '会员ID',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_member_provider` (`member_id`, `provider_id`),
    KEY `idx_provider_id` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务提供者收藏表';

-- ============================================================
-- 3. 订单相关表
-- ============================================================

-- 预约订单表
CREATE TABLE IF NOT EXISTS `wedding_order` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_no` varchar(32) NOT NULL DEFAULT '' COMMENT '订单编号',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '会员ID',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID（通过关联获取service_type，避免冗余）',
    `reservation_date` date NOT NULL COMMENT '预约日期',
    `client_request_id` varchar(64) NOT NULL DEFAULT '' COMMENT '客户端请求ID（幂等键）',
    
    -- 金额相关
    `total_amount` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '订单总额（单位：元）',
    `original_amount` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '原始订单金额（单位：元，用于改期时计算差价）',
    `change_date_fee` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '改期费（单位：元）',
    `price_difference` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '补差价（单位：元，正数=需补，负数=需退）',
    
    -- 订单状态
    `order_status` smallint(4) NOT NULL DEFAULT 0 COMMENT '订单状态' CHECK (`order_status` >= 0 AND `order_status` <= 20),
    `is_final_status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否终态：0=否，1=是（用于快速判断）',
    
    -- 联系信息
    `contact_name` varchar(50) NOT NULL DEFAULT '' COMMENT '联系人姓名',
    `contact_mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '联系电话',
    `wedding_venue` varchar(255) NOT NULL DEFAULT '' COMMENT '婚礼场地',
    `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '用户备注',
    
    -- 审核相关
    `approve_time` int(11) NOT NULL DEFAULT 0 COMMENT '审核时间',
    `reject_reason` varchar(500) NOT NULL DEFAULT '' COMMENT '拒绝原因',
    
    -- 付款相关
    `user_payment_voucher` varchar(500) NOT NULL DEFAULT '' COMMENT '用户上传的付款凭证图片',
    `payment_voucher` varchar(500) NOT NULL DEFAULT '' COMMENT '管理员确认的付款凭证图片',
    `payment_amount` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '实付金额（单位：元）',
    `payment_time` int(11) NOT NULL DEFAULT 0 COMMENT '付款确认时间',
    `payment_operator_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '付款确认人ID',
    `payment_remark` varchar(500) NOT NULL DEFAULT '' COMMENT '付款备注',
    
    -- 退款相关（管理员操作）
    `refund_voucher` varchar(500) NOT NULL DEFAULT '' COMMENT '退款凭证图片',
    `refund_amount` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '退款金额（单位：元）',
    `refund_time` int(11) NOT NULL DEFAULT 0 COMMENT '退款确认时间',
    `refund_operator_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '退款确认人ID',
    `refund_remark` varchar(500) NOT NULL DEFAULT '' COMMENT '退款备注',
    
    -- 完成相关
    `complete_time` int(11) NOT NULL DEFAULT 0 COMMENT '完成时间',
    `cancel_time` int(11) NOT NULL DEFAULT 0 COMMENT '取消时间',
    `cancel_reason` varchar(500) NOT NULL DEFAULT '' COMMENT '取消原因',
    
    -- 改期相关
    `change_date_apply_time` int(11) NOT NULL DEFAULT 0 COMMENT '改期申请时间',
    `change_date_approve_time` int(11) NOT NULL DEFAULT 0 COMMENT '改期审核时间',
    `change_date_reject_time` int(11) NOT NULL DEFAULT 0 COMMENT '改期拒绝时间',
    `change_date_reject_reason` varchar(500) NOT NULL DEFAULT '' COMMENT '改期拒绝原因',
    `old_reservation_date` date DEFAULT NULL COMMENT '原预约日期（改期前）',
    `new_reservation_date` date DEFAULT NULL COMMENT '新预约日期（改期后）',
    `change_date_operator_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '改期操作人ID（管理员）',
    `change_date_remark` varchar(500) NOT NULL DEFAULT '' COMMENT '改期备注',
    
    -- 评价相关
    `is_reviewed` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否已评价：0=否，1=是',
    
    -- 快照数据
    `service_snapshot` text COMMENT '服务信息快照（JSON）',
    `service_snapshot_json` json GENERATED ALWAYS AS (JSON_EXTRACT(`service_snapshot`, '$')) VIRTUAL COMMENT '服务信息快照JSON生成列（用于索引）',
    
    -- 其他
    `is_manual` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否手动创建：0=否，1=是',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    UNIQUE KEY `uk_member_client_request_id` (`member_id`, `client_request_id`),
    KEY `idx_member_id` (`member_id`),
    KEY `idx_provider_id` (`provider_id`),
    KEY `idx_order_status` (`order_status`),
    KEY `idx_reservation_date` (`reservation_date`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约订单表';

-- 订单场次明细表
CREATE TABLE IF NOT EXISTS `wedding_order_period` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单ID',
    `period` tinyint(1) NOT NULL DEFAULT 1 COMMENT '场次：1=早场（早司仪），2=午场（午宴），3=晚场（晚宴）',
    `package_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '套餐ID',
    `package_title` varchar(100) NOT NULL DEFAULT '' COMMENT '套餐名称（快照）',
    `package_price` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '套餐价格（快照）',
    `price_adjust` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '档期价格调整',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单场次明细表';

-- 订单增值服务表
CREATE TABLE IF NOT EXISTS `wedding_order_option` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单ID',
    `service_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务ID',
    `service_title` varchar(100) NOT NULL DEFAULT '' COMMENT '服务名称（快照）',
    `service_price` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '服务单价（快照，单位：元）',
    `apply_periods` varchar(50) NOT NULL DEFAULT '' COMMENT '应用场次（逗号分隔）',
    `period_count` int(10) NOT NULL DEFAULT 1 COMMENT '场次数量',
    `total_price` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '小计金额（单位：元）',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单增值服务表';

-- 订单状态日志表（分区表，按月分区）
CREATE TABLE IF NOT EXISTS `wedding_order_status_log` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单ID',
    `order_no` varchar(32) NOT NULL DEFAULT '' COMMENT '订单编号',
    `from_status` smallint(4) NOT NULL DEFAULT 0 COMMENT '原状态',
    `to_status` smallint(4) NOT NULL DEFAULT 0 COMMENT '新状态',
    `operator_type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '操作人类型：0=系统，1=管理员，2=会员，3=服务提供者',
    `operator_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作人ID',
    `operator_name` varchar(50) NOT NULL DEFAULT '' COMMENT '操作人名称',
    `reason` varchar(500) NOT NULL DEFAULT '' COMMENT '变更原因',
    `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`, `create_time`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单状态日志表（分区表）'
PARTITION BY RANGE (`create_time`) (
    PARTITION p202501 VALUES LESS THAN (UNIX_TIMESTAMP('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (UNIX_TIMESTAMP('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (UNIX_TIMESTAMP('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (UNIX_TIMESTAMP('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (UNIX_TIMESTAMP('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (UNIX_TIMESTAMP('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (UNIX_TIMESTAMP('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (UNIX_TIMESTAMP('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (UNIX_TIMESTAMP('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (UNIX_TIMESTAMP('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (UNIX_TIMESTAMP('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (UNIX_TIMESTAMP('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- ============================================================
-- 4. 评价相关表
-- ============================================================

-- 评价表
CREATE TABLE IF NOT EXISTS `wedding_review` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单ID',
    `service_type` varchar(50) NOT NULL DEFAULT 'host' COMMENT '服务类型：host/photographer/butler',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '会员ID',
    `score` tinyint(1) NOT NULL DEFAULT 5 COMMENT '评分（1-5）',
    `content` text COMMENT '评价内容',
    `images` text COMMENT '评价图片（JSON数组）' CHECK (JSON_VALID(`images`)),
    `reply_content` text COMMENT '服务提供者回复',
    `reply_time` int(11) NOT NULL DEFAULT 0 COMMENT '回复时间',
    `is_anonymous` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否匿名：0=否，1=是',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=待审核，1=显示，2=隐藏',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_service_type` (`service_type`),
    KEY `idx_provider_id` (`provider_id`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_member_id` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评价表';

-- ============================================================
-- 5. 退款相关表
-- ============================================================

-- 退款申请表（支持整单退款和部分退款）
CREATE TABLE IF NOT EXISTS `wedding_refund_apply` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `refund_no` varchar(32) NOT NULL DEFAULT '' COMMENT '退款单号',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单ID',
    `order_no` varchar(32) NOT NULL DEFAULT '' COMMENT '订单编号',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '会员ID',
    `client_request_id` varchar(64) NOT NULL DEFAULT '' COMMENT '客户端请求ID（幂等键）',
    `refund_type` tinyint(1) NOT NULL DEFAULT 1 COMMENT '退款类型：1=整单退款，2=部分退款',
    `refund_amount` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '申请退款金额（单位：元，自动计算）',
    `refund_items` text COMMENT '退款明细（JSON数组，部分退款时使用）' CHECK (JSON_VALID(`refund_items`)),
    `refund_reason` varchar(500) NOT NULL DEFAULT '' COMMENT '退款原因',
    `apply_type` tinyint(1) NOT NULL DEFAULT 1 COMMENT '申请类型：1=用户申请，2=管理员操作',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=待审核，1=已同意，2=已拒绝，3=已完成',
    `audit_time` int(11) NOT NULL DEFAULT 0 COMMENT '审核时间',
    `audit_remark` varchar(500) NOT NULL DEFAULT '' COMMENT '审核备注',
    `complete_time` int(11) NOT NULL DEFAULT 0 COMMENT '完成时间',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_refund_no` (`refund_no`),
    UNIQUE KEY `uk_member_client_request_id` (`member_id`, `client_request_id`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_member_id` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退款申请表（支持整单退款和部分退款）';

-- ============================================================
-- 6. 动态相关表
-- ============================================================

-- 动态表
CREATE TABLE IF NOT EXISTS `wedding_dynamic` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `service_type` varchar(50) NOT NULL DEFAULT 'host' COMMENT '服务类型：host/photographer/butler',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID',
    `category_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '分类ID',
    `type` tinyint(1) NOT NULL DEFAULT 1 COMMENT '类型：1=图文，2=视频',
    `content` text COMMENT '动态内容',
    `images` text COMMENT '图片列表（JSON数组）' CHECK (JSON_VALID(`images`)),
    `video` varchar(500) NOT NULL DEFAULT '' COMMENT '视频地址',
    `video_cover` varchar(500) NOT NULL DEFAULT '' COMMENT '视频封面',
    `video_duration` int(10) NOT NULL DEFAULT 0 COMMENT '视频时长（秒）',
    `view_count` int(10) NOT NULL DEFAULT 0 COMMENT '浏览量',
    `like_count` int(10) NOT NULL DEFAULT 0 COMMENT '点赞数',
    `comment_count` int(10) NOT NULL DEFAULT 0 COMMENT '评论数',
    `share_count` int(10) NOT NULL DEFAULT 0 COMMENT '分享数',
    `is_top` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否置顶：0=否，1=是',
    `top_time` int(11) NOT NULL DEFAULT 0 COMMENT '置顶时间',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=待审核，1=已发布，2=已拒绝，3=已下架',
    `reject_reason` varchar(500) NOT NULL DEFAULT '' COMMENT '拒绝原因',
    `audit_time` int(11) NOT NULL DEFAULT 0 COMMENT '审核时间',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否删除：0=否，1=是（用于快速查询）',
    `deleted_at` int(11) NOT NULL DEFAULT 0 COMMENT '删除时间（时间戳，用于追溯删除时间）',
    PRIMARY KEY (`id`),
    KEY `idx_service_type` (`service_type`),
    KEY `idx_provider_id` (`provider_id`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_status` (`status`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态表';

-- 动态分类表
CREATE TABLE IF NOT EXISTS `wedding_dynamic_category` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `name` varchar(50) NOT NULL DEFAULT '' COMMENT '分类名称',
    `icon` varchar(255) NOT NULL DEFAULT '' COMMENT '分类图标',
    `sort` int(10) NOT NULL DEFAULT 0 COMMENT '排序',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态分类表';

-- 动态评论表
CREATE TABLE IF NOT EXISTS `wedding_dynamic_comment` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `dynamic_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '动态ID',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '评论人ID',
    `parent_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '父评论ID（0=一级评论）',
    `reply_to_member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '回复的用户ID',
    `content` text COMMENT '评论内容',
    `like_count` int(10) NOT NULL DEFAULT 0 COMMENT '点赞数',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=待审核，1=已发布，2=已拒绝',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否删除：0=否，1=是',
    PRIMARY KEY (`id`),
    KEY `idx_dynamic_id` (`dynamic_id`),
    KEY `idx_member_id` (`member_id`),
    KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态评论表';

-- 动态点赞表
CREATE TABLE IF NOT EXISTS `wedding_dynamic_like` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `dynamic_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '动态ID',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '会员ID',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_dynamic_member` (`dynamic_id`, `member_id`),
    KEY `idx_member_id` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态点赞表';

-- ============================================================
-- 7. 用户与系统表
-- ============================================================

-- 会员表
CREATE TABLE IF NOT EXISTS `wedding_member` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `openid` varchar(64) NOT NULL DEFAULT '' COMMENT '微信OpenID',
    `unionid` varchar(64) NOT NULL DEFAULT '' COMMENT '微信UnionID',
    `nickname` varchar(50) NOT NULL DEFAULT '' COMMENT '昵称',
    `avatar` varchar(500) NOT NULL DEFAULT '' COMMENT '头像',
    `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号',
    `sex` tinyint(1) NOT NULL DEFAULT 0 COMMENT '性别：0=未知，1=男，2=女',
    `is_provider` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否服务提供者：0=否，1=是',
    `service_type` varchar(50) NOT NULL DEFAULT '' COMMENT '服务类型：host/photographer/butler',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联服务提供者ID',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
    `last_login_time` int(11) NOT NULL DEFAULT 0 COMMENT '最后登录时间',
    `last_login_ip` varchar(50) NOT NULL DEFAULT '' COMMENT '最后登录IP',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_openid` (`openid`),
    KEY `idx_mobile` (`mobile`),
    KEY `idx_service_type` (`service_type`),
    KEY `idx_provider_id` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员表';

-- 管理员表（增强登录安全）
CREATE TABLE IF NOT EXISTS `wedding_admin` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `username` varchar(50) NOT NULL DEFAULT '' COMMENT '用户名',
    `password` varchar(255) NOT NULL DEFAULT '' COMMENT '密码（bcrypt加密）',
    `realname` varchar(50) NOT NULL DEFAULT '' COMMENT '真实姓名',
    `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号',
    `avatar` varchar(500) NOT NULL DEFAULT '' COMMENT '头像',
    `role` varchar(50) NOT NULL DEFAULT 'admin' COMMENT '角色',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
    
    -- 登录安全相关
    `login_fail_count` int(10) NOT NULL DEFAULT 0 COMMENT '登录失败次数',
    `login_lock_time` int(11) NOT NULL DEFAULT 0 COMMENT '登录锁定时间（时间戳，0=未锁定）',
    `last_login_time` int(11) NOT NULL DEFAULT 0 COMMENT '最后登录时间',
    `last_login_ip` varchar(50) NOT NULL DEFAULT '' COMMENT '最后登录IP',
    
    -- 2FA双因素认证（可选）
    `two_factor_enabled` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否启用2FA：0=否，1=是',
    `two_factor_secret` varchar(255) NOT NULL DEFAULT '' COMMENT '2FA密钥（加密存储）',
    `two_factor_backup_codes` text COMMENT '2FA备用码（JSON数组，加密存储）' CHECK (JSON_VALID(`two_factor_backup_codes`)),
    
    -- IP白名单（可选）
    `ip_whitelist` text COMMENT 'IP白名单（JSON数组，空=不限制）' CHECK (JSON_VALID(`ip_whitelist`)),
    
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否删除：0=否，1=是',
    `deleted_at` int(11) NOT NULL DEFAULT 0 COMMENT '删除时间（时间戳）',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员表';

-- 管理员登录日志表
CREATE TABLE IF NOT EXISTS `wedding_admin_login_log` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `admin_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '管理员ID（0=用户名不存在）',
    `username` varchar(50) NOT NULL DEFAULT '' COMMENT '登录用户名',
    `login_ip` varchar(50) NOT NULL DEFAULT '' COMMENT '登录IP',
    `user_agent` varchar(500) NOT NULL DEFAULT '' COMMENT 'User-Agent',
    `login_result` tinyint(1) NOT NULL DEFAULT 0 COMMENT '登录结果：0=失败，1=成功',
    `fail_reason` varchar(255) NOT NULL DEFAULT '' COMMENT '失败原因：wrong_password/account_locked/ip_not_allowed/2fa_failed',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_admin_id` (`admin_id`),
    KEY `idx_username` (`username`),
    KEY `idx_login_ip` (`login_ip`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员登录日志表';

-- 系统配置表
CREATE TABLE IF NOT EXISTS `wedding_config` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `key` varchar(100) NOT NULL DEFAULT '' COMMENT '配置键',
    `value` text COMMENT '配置值' CHECK (JSON_VALID(`value`)),
    `description` varchar(255) NOT NULL DEFAULT '' COMMENT '配置说明',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

-- DIY组件注册表（支持动态注册新组件）
CREATE TABLE IF NOT EXISTS `wedding_diy_component` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `component_name` varchar(100) NOT NULL DEFAULT '' COMMENT '组件名称（唯一，如：ProviderMediaCarousel）',
    `component_title` varchar(100) NOT NULL DEFAULT '' COMMENT '组件标题（显示名称，如：媒体轮播）',
    `category` varchar(50) NOT NULL DEFAULT 'basic' COMMENT '组件分类：basic=基础组件，media=媒体组件，info=信息组件，interaction=交互组件',
    `icon` varchar(255) NOT NULL DEFAULT '' COMMENT '组件图标（图标字体类名或图片URL）',
    `description` varchar(500) NOT NULL DEFAULT '' COMMENT '组件描述',
    `page_type` varchar(50) NOT NULL DEFAULT '' COMMENT '适用页面类型：PROVIDER_DETAIL=服务提供者详情页（空=通用）',
    `config_schema` text COMMENT '配置项结构（JSON Schema格式，定义组件的配置项）' CHECK (JSON_VALID(`config_schema`)),
    `default_value` text COMMENT '默认配置值（JSON对象，组件的默认配置）' CHECK (JSON_VALID(`default_value`)),
    `preview_image` varchar(500) NOT NULL DEFAULT '' COMMENT '预览图',
    `sort` int(10) NOT NULL DEFAULT 0 COMMENT '排序',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=启用',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_component_name` (`component_name`),
    KEY `idx_category` (`category`),
    KEY `idx_page_type` (`page_type`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='DIY组件注册表（支持动态注册新组件）';

-- DIY页面表
CREATE TABLE IF NOT EXISTS `wedding_diy_page` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `title` varchar(100) NOT NULL DEFAULT '' COMMENT '页面标题',
    `name` varchar(100) NOT NULL DEFAULT '' COMMENT '页面标识（唯一）',
    `type` varchar(50) NOT NULL DEFAULT 'PROVIDER_DETAIL' COMMENT '页面类型：PROVIDER_DETAIL=服务提供者详情页',
    `mode` varchar(20) NOT NULL DEFAULT 'diy' COMMENT '页面模式：diy=自定义，fixed=固定',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联服务提供者ID（PROVIDER_DETAIL类型时）',
    `value` longtext COMMENT '页面数据（JSON格式，包含组件配置）' CHECK (JSON_VALID(`value`)),
    `cover` varchar(500) NOT NULL DEFAULT '' COMMENT '页面封面图',
    `preview` varchar(500) NOT NULL DEFAULT '' COMMENT '页面预览图',
    `is_default` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否默认模板：0=否，1=是',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=启用',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name` (`name`),
    KEY `idx_provider_id` (`provider_id`),
    KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='DIY页面表';

-- ============================================================
-- 8. 消息与内容管理表
-- ============================================================

-- 消息表
CREATE TABLE IF NOT EXISTS `wedding_message` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '接收会员ID（0=全体用户）',
    `type` varchar(50) NOT NULL DEFAULT '' COMMENT '消息类型：order_status/order_timeout/review_reply/system_notice',
    `title` varchar(255) NOT NULL DEFAULT '' COMMENT '消息标题',
    `content` text COMMENT '消息内容',
    `link_type` varchar(50) NOT NULL DEFAULT '' COMMENT '链接类型：order/dynamic/host/none',
    `link_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '链接ID',
    `link_url` varchar(500) NOT NULL DEFAULT '' COMMENT '链接地址',
    `is_read` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否已读：0=否，1=是（针对全体消息）',
    `read_count` int(10) NOT NULL DEFAULT 0 COMMENT '已读人数（针对全体消息）',
    `send_time` int(11) NOT NULL DEFAULT 0 COMMENT '发送时间',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_member_id` (`member_id`),
    KEY `idx_type` (`type`),
    KEY `idx_send_time` (`send_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息表';

-- 消息已读记录表
CREATE TABLE IF NOT EXISTS `wedding_message_read` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `message_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '消息ID',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '会员ID',
    `read_time` int(11) NOT NULL DEFAULT 0 COMMENT '阅读时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_message_member` (`message_id`, `member_id`),
    KEY `idx_member_id` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息已读记录表';

-- 公告表
CREATE TABLE IF NOT EXISTS `wedding_notice` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `title` varchar(255) NOT NULL DEFAULT '' COMMENT '公告标题',
    `content` text COMMENT '公告内容',
    `cover` varchar(500) NOT NULL DEFAULT '' COMMENT '封面图',
    `link_type` varchar(50) NOT NULL DEFAULT '' COMMENT '链接类型：url/none',
    `link_url` varchar(500) NOT NULL DEFAULT '' COMMENT '链接地址',
    `target_type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '目标用户：0=所有用户，1=普通用户，2=主持人',
    `is_top` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否置顶：0=否，1=是',
    `top_time` int(11) NOT NULL DEFAULT 0 COMMENT '置顶时间',
    `view_count` int(10) NOT NULL DEFAULT 0 COMMENT '查看次数',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=启用',
    `publish_time` int(11) NOT NULL DEFAULT 0 COMMENT '发布时间',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_status` (`status`),
    KEY `idx_publish_time` (`publish_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告表';

-- 轮播图表
CREATE TABLE IF NOT EXISTS `wedding_banner` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `title` varchar(255) NOT NULL DEFAULT '' COMMENT '标题',
    `image` varchar(500) NOT NULL DEFAULT '' COMMENT '图片地址',
    `link_type` varchar(50) NOT NULL DEFAULT '' COMMENT '链接类型：url/host/dynamic/none',
    `link_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '链接ID',
    `link_url` varchar(500) NOT NULL DEFAULT '' COMMENT '链接地址',
    `position` varchar(50) NOT NULL DEFAULT 'home' COMMENT '位置：home/index/provider_detail',
    `sort` int(10) NOT NULL DEFAULT 0 COMMENT '排序',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=启用',
    `start_time` int(11) NOT NULL DEFAULT 0 COMMENT '开始时间',
    `end_time` int(11) NOT NULL DEFAULT 0 COMMENT '结束时间',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_position` (`position`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='轮播图表';

-- 分享记录表
CREATE TABLE IF NOT EXISTS `wedding_share_log` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '分享人ID',
    `share_type` varchar(50) NOT NULL DEFAULT '' COMMENT '分享类型：host/dynamic/order',
    `share_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '分享对象ID',
    `share_channel` varchar(50) NOT NULL DEFAULT '' COMMENT '分享渠道：wechat/friend/moments',
    `share_count` int(10) NOT NULL DEFAULT 1 COMMENT '分享次数',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_member_id` (`member_id`),
    KEY `idx_share_type` (`share_type`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分享记录表';

-- 订单超时日志表（分区表，按月分区）
CREATE TABLE IF NOT EXISTS `wedding_order_timeout_log` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单ID',
    `order_no` varchar(32) NOT NULL DEFAULT '' COMMENT '订单编号',
    `timeout_type` varchar(50) NOT NULL DEFAULT '' COMMENT '超时类型：pending_timeout/payment_timeout',
    `timeout_hours` int(10) NOT NULL DEFAULT 0 COMMENT '超时小时数',
    `old_status` smallint(4) NOT NULL DEFAULT 0 COMMENT '原状态',
    `new_status` smallint(4) NOT NULL DEFAULT 0 COMMENT '新状态',
    `action` varchar(50) NOT NULL DEFAULT '' COMMENT '处理动作：auto_reject/auto_cancel/notify',
    `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`, `create_time`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_timeout_type` (`timeout_type`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单超时日志表（分区表）'
PARTITION BY RANGE (`create_time`) (
    PARTITION p202501 VALUES LESS THAN (UNIX_TIMESTAMP('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (UNIX_TIMESTAMP('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (UNIX_TIMESTAMP('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (UNIX_TIMESTAMP('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (UNIX_TIMESTAMP('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (UNIX_TIMESTAMP('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (UNIX_TIMESTAMP('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (UNIX_TIMESTAMP('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (UNIX_TIMESTAMP('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (UNIX_TIMESTAMP('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (UNIX_TIMESTAMP('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (UNIX_TIMESTAMP('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 购物车表
CREATE TABLE IF NOT EXISTS `wedding_cart` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '会员ID',
    `item_type` tinyint(1) NOT NULL DEFAULT 1 COMMENT '商品类型：1=单个服务，2=组合套餐',
    `service_type` varchar(50) NOT NULL DEFAULT 'host' COMMENT '服务类型：host/photographer/butler（item_type=1时）',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID（item_type=1时）',
    `combo_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '组合套餐ID（item_type=2时）',
    `reservation_date` date NOT NULL COMMENT '预约日期',
    `package_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '套餐ID（item_type=1时）',
    `periods` varchar(50) NOT NULL DEFAULT '' COMMENT '场次（逗号分隔）',
    `addon_ids` varchar(255) NOT NULL DEFAULT '' COMMENT '增值服务ID（逗号分隔）',
    `subtotal` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '小计金额（单位：元）',
    `is_valid` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否有效：0=否，1=是',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_member_id` (`member_id`),
    KEY `idx_item_type` (`item_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车表';

-- 组合套餐表
CREATE TABLE IF NOT EXISTS `wedding_combo_package` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `title` varchar(100) NOT NULL DEFAULT '' COMMENT '套餐名称',
    `description` varchar(500) NOT NULL DEFAULT '' COMMENT '套餐描述',
    `cover` varchar(500) NOT NULL DEFAULT '' COMMENT '套餐封面图',
    `original_price` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '原价总和（单位：元）',
    `combo_price` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '组合套餐价格（单位：元）',
    `discount_amount` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '优惠金额（单位：元）',
    `discount_rate` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '优惠比例（%）',
    `sort` int(10) NOT NULL DEFAULT 0 COMMENT '排序',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_status` (`status`),
    KEY `idx_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='组合套餐表';

-- 组合套餐明细表
CREATE TABLE IF NOT EXISTS `wedding_combo_package_item` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `combo_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '组合套餐ID',
    `service_type` varchar(50) NOT NULL DEFAULT '' COMMENT '服务类型：host/photographer/butler',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID',
    `package_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '套餐ID（服务提供者的基础套餐）',
    `periods` varchar(50) NOT NULL DEFAULT '' COMMENT '场次（逗号分隔，如：1,2）',
    `original_price` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '原价（单位：元）',
    `combo_price` decimal(12,4) NOT NULL DEFAULT 0.0000 COMMENT '组合价（单位：元）',
    `sort` int(10) NOT NULL DEFAULT 0 COMMENT '排序',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_combo_id` (`combo_id`),
    KEY `idx_provider_id` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='组合套餐明细表';

-- ============================================================
-- 9. 补充索引（优化查询性能）
-- ============================================================

**索引设计说明**:
- 主键索引：所有表使用自增ID作为主键
- 唯一索引：用于保证数据唯一性（订单编号、退款单号、客户端请求ID等）
- 普通索引：用于常用查询字段（member_id、provider_id、order_status等）
- 联合索引：用于组合查询条件（最左前缀原则）
- 前缀索引：用于长文本字段（label_ids字段使用前缀索引）

**唯一约束说明**:
- uk_order_no：订单编号唯一，防止重复订单号
- uk_member_client_request_id：用户ID+客户端请求ID联合唯一，实现幂等性（防止跨用户重放攻击）
- uk_provider_date_time：档期唯一，防止时间段重叠冲突（基于 provider_id, date, start_time, end_time）
- uk_refund_no：退款单号唯一，防止重复退款单号

**外键约束说明**:
- 不使用数据库外键约束（性能考虑）
- 通过应用层保证数据一致性
- 关联关系通过字段注释说明

**索引清单**:

-- 服务提供者表索引
-- idx_service_type_status: 用于按服务类型和状态筛选（最常用查询）
-- idx_service_type_sort: 用于按服务类型和排序值排序
-- idx_service_type_score: 用于按服务类型和评分排序
-- idx_service_type_order_count: 用于按服务类型和订单量排序
-- idx_label_ids: 前缀索引（100字符），用于标签搜索
ALTER TABLE `wedding_service_provider` 
ADD INDEX `idx_service_type_status` (`service_type`, `status`),
ADD INDEX `idx_service_type_sort` (`service_type`, `sort`),
ADD INDEX `idx_service_type_score` (`service_type`, `avg_score`),
ADD INDEX `idx_service_type_order_count` (`service_type`, `order_count`),
ADD INDEX `idx_label_ids` (`label_ids`(100));

-- 订单表索引
-- idx_provider_status: 用于服务提供者查看自己的订单（按状态筛选）
-- idx_member_status: 用于用户查看自己的订单（按状态筛选）
-- idx_date_status: 用于按预约日期和状态查询
-- idx_create_time_status: 用于订单超时查询（重要，定时任务使用）
ALTER TABLE `wedding_order`
ADD INDEX `idx_provider_status` (`provider_id`, `order_status`),
ADD INDEX `idx_member_status` (`member_id`, `order_status`),
ADD INDEX `idx_date_status` (`reservation_date`, `order_status`),
ADD INDEX `idx_create_time_status` (`create_time`, `order_status`);

-- 档期表索引
-- idx_provider_date: 用于查询某个服务提供者的档期日历
-- idx_date_status: 用于按日期和状态查询可用档期
-- idx_date_period_status: 用于档期查询（最常用，支持日期+场次+状态组合查询）
-- uk_provider_date_time: 唯一索引，防止时间段重叠冲突（并发控制关键，基于 provider_id, date, start_time, end_time）
ALTER TABLE `wedding_service_provider_schedule`
ADD INDEX `idx_provider_date` (`provider_id`, `date`),
ADD INDEX `idx_date_status` (`date`, `status`),
ADD INDEX `idx_date_period_status` (`date`, `period`, `status`);

-- 评价表索引
ALTER TABLE `wedding_review`
ADD INDEX `idx_service_type_provider` (`service_type`, `provider_id`),
ADD INDEX `idx_provider_status` (`provider_id`, `status`),
ADD INDEX `idx_create_time` (`create_time`);

-- 动态表索引
ALTER TABLE `wedding_dynamic`
ADD INDEX `idx_service_type_status` (`service_type`, `status`),
ADD INDEX `idx_provider_status` (`provider_id`, `status`),
ADD INDEX `idx_category_status` (`category_id`, `status`),
ADD INDEX `idx_create_time_status` (`create_time`, `status`);

-- ============================================================
-- 10. 初始数据
-- ============================================================

-- 插入默认服务类型
INSERT INTO `wedding_service_type` (`type_code`, `type_name`, `icon`, `description`, `sort`, `status`, `create_time`) VALUES
('host', '主持人', '', '婚礼主持人服务', 1, 1, UNIX_TIMESTAMP()),
('photographer', '跟拍', '', '婚礼跟拍服务', 2, 1, UNIX_TIMESTAMP()),
('butler', '管家', '', '婚礼管家服务', 3, 1, UNIX_TIMESTAMP());

-- 插入默认管理员（密码：123456）
INSERT INTO `wedding_admin` (`username`, `password`, `realname`, `role`, `status`, `create_time`) 
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '超级管理员', 'super_admin', 1, UNIX_TIMESTAMP());

-- 插入默认配置
INSERT INTO `wedding_config` (`key`, `value`, `description`, `create_time`) VALUES 
('basic_config', '{"site_name":"婚庆管家","site_logo":"","contact_phone":"","service_time":"9:00-18:00","copyright":"© 2025 婚庆管家 All Rights Reserved"}', '基础配置', UNIX_TIMESTAMP()),
('order_config', '{"auto_cancel_hours":24,"timeout_reject_hours":48,"payment_timeout_hours":72}', '订单配置', UNIX_TIMESTAMP()),
('review_config', '{"need_audit":false,"min_content_length":10,"max_images":9}', '评价配置', UNIX_TIMESTAMP()),
('dynamic_config', '{"need_audit":true,"max_images":9,"max_video_size":100,"max_video_duration":300}', '动态配置', UNIX_TIMESTAMP()),
('message_config', '{"enable_notify":true,"order_status_notify":true,"review_reply_notify":true}', '消息配置', UNIX_TIMESTAMP()),
('payment_config', '{"payment_methods":["wechat","alipay"],"refund_days":7}', '支付配置', UNIX_TIMESTAMP()),
('subscribe_message_templates', '{"order_status":{"template_id":"","title":"订单状态更新","description":"订单状态变更通知"},"order_timeout":{"template_id":"","title":"订单超时提醒","description":"订单即将超时提醒"},"review_reply":{"template_id":"","title":"评价回复通知","description":"收到评价回复通知"}}', '微信订阅消息模板配置', UNIX_TIMESTAMP());

-- 插入默认标签（按服务类型，仅管理员可管理）
-- 主持人标签
INSERT INTO `wedding_service_provider_label` (`service_type`, `name`, `icon`, `color`, `sort`, `status`, `create_time`) VALUES 
('host', '资深主持', '', '#FF6600', 1, 1, UNIX_TIMESTAMP()),
('host', '婚礼策划', '', '#4ECDC4', 2, 1, UNIX_TIMESTAMP()),
('host', '双语主持', '', '#45B7D1', 3, 1, UNIX_TIMESTAMP()),
('host', '户外婚礼', '', '#96CEB4', 4, 1, UNIX_TIMESTAMP()),
('host', '中式婚礼', '', '#FFEAA7', 5, 1, UNIX_TIMESTAMP()),
('host', '西式婚礼', '', '#DDA0DD', 6, 1, UNIX_TIMESTAMP()),
('host', '浪漫温馨', '', '#FFB6C1', 7, 1, UNIX_TIMESTAMP()),
('host', '庄重大气', '', '#9370DB', 8, 1, UNIX_TIMESTAMP()),
('host', '活泼轻松', '', '#FFD700', 9, 1, UNIX_TIMESTAMP()),
('host', '10年+经验', '', '#FF4500', 10, 1, UNIX_TIMESTAMP());

-- 跟拍标签
INSERT INTO `wedding_service_provider_label` (`service_type`, `name`, `icon`, `color`, `sort`, `status`, `create_time`) VALUES 
('photographer', '单机位', '', '#0066FF', 1, 1, UNIX_TIMESTAMP()),
('photographer', '双机位', '', '#0099FF', 2, 1, UNIX_TIMESTAMP()),
('photographer', '多机位', '', '#00CCFF', 3, 1, UNIX_TIMESTAMP()),
('photographer', '航拍', '', '#00FFFF', 4, 1, UNIX_TIMESTAMP()),
('photographer', '纪实风格', '', '#FF6600', 5, 1, UNIX_TIMESTAMP()),
('photographer', '唯美风格', '', '#FF99CC', 6, 1, UNIX_TIMESTAMP()),
('photographer', '电影风格', '', '#8B008B', 7, 1, UNIX_TIMESTAMP()),
('photographer', '自然光', '', '#FFD700', 8, 1, UNIX_TIMESTAMP()),
('photographer', '夜景拍摄', '', '#191970', 9, 1, UNIX_TIMESTAMP()),
('photographer', '延时摄影', '', '#FF1493', 10, 1, UNIX_TIMESTAMP());

-- 管家标签
INSERT INTO `wedding_service_provider_label` (`service_type`, `name`, `icon`, `color`, `sort`, `status`, `create_time`) VALUES 
('butler', '迎宾服务', '', '#66CC99', 1, 1, UNIX_TIMESTAMP()),
('butler', '现场协调', '', '#99CC66', 2, 1, UNIX_TIMESTAMP()),
('butler', '收尾服务', '', '#CC9966', 3, 1, UNIX_TIMESTAMP()),
('butler', '全程服务', '', '#9966CC', 4, 1, UNIX_TIMESTAMP()),
('butler', '流程把控', '', '#FF6347', 5, 1, UNIX_TIMESTAMP()),
('butler', '应急处理', '', '#32CD32', 6, 1, UNIX_TIMESTAMP()),
('butler', '团队协作', '', '#1E90FF', 7, 1, UNIX_TIMESTAMP()),
('butler', '贴心服务', '', '#FF69B4', 8, 1, UNIX_TIMESTAMP());

-- 插入默认动态分类
INSERT INTO `wedding_dynamic_category` (`name`, `sort`, `status`, `create_time`) VALUES 
('婚礼现场', 1, 1, UNIX_TIMESTAMP()),
('幕后花絮', 2, 1, UNIX_TIMESTAMP()),
('新人好评', 3, 1, UNIX_TIMESTAMP()),
('行业资讯', 4, 1, UNIX_TIMESTAMP()),
('个人分享', 5, 1, UNIX_TIMESTAMP());

-- 插入示例轮播图数据（可选，可根据实际需求修改）
INSERT INTO `wedding_banner` (`title`, `image`, `link_type`, `link_id`, `link_url`, `position`, `sort`, `status`, `start_time`, `end_time`, `create_time`, `update_time`) VALUES 
('首页轮播图1', '', 'none', 0, '', 'home', 1, 1, 0, 0, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('首页轮播图2', '', 'none', 0, '', 'home', 2, 1, 0, 0, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('首页轮播图3', '', 'none', 0, '', 'home', 3, 1, 0, 0, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- 插入示例公告数据（可选）
INSERT INTO `wedding_notice` (`title`, `content`, `cover`, `link_type`, `link_url`, `target_type`, `is_top`, `status`, `publish_time`, `create_time`, `update_time`) VALUES 
('欢迎使用婚庆管家系统', '欢迎使用婚庆管家系统，我们将为您提供专业的婚礼服务。', '', 'none', '', 0, 1, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('系统使用说明', '请仔细阅读系统使用说明，以便更好地使用我们的服务。', '', 'none', '', 0, 0, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- ============================================================
-- 11. 统计指标表
-- ============================================================

-- 日统计表
CREATE TABLE IF NOT EXISTS `wedding_stat_daily` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `stat_date` date NOT NULL COMMENT '统计日期',
    `service_type` varchar(50) NOT NULL DEFAULT '' COMMENT '服务类型：host/photographer/butler（空=全部）',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID（0=全部）',
    
    -- 订单统计
    `order_count` int(10) NOT NULL DEFAULT 0 COMMENT '订单数量',
    `order_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT '订单金额（单位：元）',
    `completed_count` int(10) NOT NULL DEFAULT 0 COMMENT '已完成订单数',
    `completed_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT '已完成订单金额（单位：元）',
    
    -- 转化率
    `conversion_rate` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '转化率（%）',
    
    -- 评价统计
    `review_count` int(10) NOT NULL DEFAULT 0 COMMENT '评价数量',
    `avg_score` decimal(3,2) NOT NULL DEFAULT 0.00 COMMENT '平均评分',
    
    -- 用户统计
    `new_member_count` int(10) NOT NULL DEFAULT 0 COMMENT '新增会员数',
    `active_member_count` int(10) NOT NULL DEFAULT 0 COMMENT '活跃会员数',
    `repeat_order_count` int(10) NOT NULL DEFAULT 0 COMMENT '复购订单数',
    `repeat_rate` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '复购率（%）',
    
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_date_service_provider` (`stat_date`, `service_type`, `provider_id`),
    KEY `idx_stat_date` (`stat_date`),
    KEY `idx_service_type` (`service_type`),
    KEY `idx_provider_id` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='日统计表';

-- ============================================================
-- 脚本执行完成
-- ============================================================
