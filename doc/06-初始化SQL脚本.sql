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
DROP TABLE IF EXISTS `wedding_service_type`;
CREATE TABLE `wedding_service_type` (
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
DROP TABLE IF EXISTS `wedding_service_provider`;
CREATE TABLE `wedding_service_provider` (
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
    `label_ids` varchar(255) NOT NULL DEFAULT '' COMMENT '标签ID，逗号分隔',
    `experience_years` int(10) NOT NULL DEFAULT 0 COMMENT '从业年限',
    `diy_page_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联DIY页面ID',
    
    -- 跟拍特有字段
    `equipment` varchar(500) NOT NULL DEFAULT '' COMMENT '设备清单（跟拍用）',
    `style_tags` varchar(255) NOT NULL DEFAULT '' COMMENT '风格标签（跟拍用）',
    
    -- 管家特有字段
    `service_scope` varchar(500) NOT NULL DEFAULT '' COMMENT '服务范围（管家用）',
    `team_size` int(10) NOT NULL DEFAULT 1 COMMENT '团队人数（管家用）',
    
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
    `sort` int(10) NOT NULL DEFAULT 0 COMMENT '排序',
    `order_count` int(10) NOT NULL DEFAULT 0 COMMENT '订单数量（缓存）',
    `review_count` int(10) NOT NULL DEFAULT 0 COMMENT '评价数量（缓存）',
    `avg_score` decimal(3,2) NOT NULL DEFAULT 5.00 COMMENT '平均评分（缓存）',
    `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否删除：0=否，1=是',
    PRIMARY KEY (`id`),
    KEY `idx_member_id` (`member_id`),
    KEY `idx_service_type` (`service_type`),
    KEY `idx_status` (`status`),
    KEY `idx_diy_page_id` (`diy_page_id`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务提供者表（统一表）';

-- 服务提供者标签表
DROP TABLE IF EXISTS `wedding_service_provider_label`;
CREATE TABLE `wedding_service_provider_label` (
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
DROP TABLE IF EXISTS `wedding_service_provider_service`;
CREATE TABLE `wedding_service_provider_service` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID',
    `type` tinyint(1) NOT NULL DEFAULT 1 COMMENT '类型：1=基础套餐，2=增值服务',
    `title` varchar(100) NOT NULL DEFAULT '' COMMENT '服务名称',
    `description` varchar(500) NOT NULL DEFAULT '' COMMENT '服务描述',
    `price` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '价格',
    `period_prices` text COMMENT '场次价格配置（JSON）',
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
DROP TABLE IF EXISTS `wedding_service_provider_schedule`;
CREATE TABLE `wedding_service_provider_schedule` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID',
    `date` date NOT NULL COMMENT '日期',
    `period` tinyint(1) NOT NULL DEFAULT 1 COMMENT '场次：1=早场（早司仪），2=午场（午宴），3=晚场（晚宴）（所有服务类型统一）',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=空闲，1=休息，2=已预订',
    `price_adjust` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '价格调整',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联订单ID',
    `remark` varchar(255) NOT NULL DEFAULT '' COMMENT '备注',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_provider_date_period` (`provider_id`, `date`, `period`),
    KEY `idx_date` (`date`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务提供者档期表';

-- 服务提供者收藏表
DROP TABLE IF EXISTS `wedding_service_provider_favorite`;
CREATE TABLE `wedding_service_provider_favorite` (
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
DROP TABLE IF EXISTS `wedding_order`;
CREATE TABLE `wedding_order` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_no` varchar(32) NOT NULL DEFAULT '' COMMENT '订单编号',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '会员ID',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID',
    `service_type` varchar(50) NOT NULL DEFAULT 'host' COMMENT '服务类型：host/photographer/butler',
    `reservation_date` date NOT NULL COMMENT '预约日期',
    
    -- 金额相关
    `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '订单总额',
    
    -- 订单状态
    `order_status` tinyint(2) NOT NULL DEFAULT 0 COMMENT '订单状态',
    
    -- 联系信息
    `contact_name` varchar(50) NOT NULL DEFAULT '' COMMENT '联系人姓名',
    `contact_mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '联系电话',
    `wedding_venue` varchar(255) NOT NULL DEFAULT '' COMMENT '婚礼场地',
    `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '用户备注',
    
    -- 审核相关
    `approve_time` int(11) NOT NULL DEFAULT 0 COMMENT '审核时间',
    `reject_reason` varchar(500) NOT NULL DEFAULT '' COMMENT '拒绝原因',
    
    -- 付款相关（管理员操作）
    `payment_voucher` varchar(500) NOT NULL DEFAULT '' COMMENT '付款凭证图片',
    `payment_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '实付金额',
    `payment_time` int(11) NOT NULL DEFAULT 0 COMMENT '付款确认时间',
    `payment_operator_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '付款确认人ID',
    `payment_remark` varchar(500) NOT NULL DEFAULT '' COMMENT '付款备注',
    
    -- 退款相关（管理员操作）
    `refund_voucher` varchar(500) NOT NULL DEFAULT '' COMMENT '退款凭证图片',
    `refund_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '退款金额',
    `refund_time` int(11) NOT NULL DEFAULT 0 COMMENT '退款确认时间',
    `refund_operator_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '退款确认人ID',
    `refund_remark` varchar(500) NOT NULL DEFAULT '' COMMENT '退款备注',
    
    -- 完成相关
    `complete_time` int(11) NOT NULL DEFAULT 0 COMMENT '完成时间',
    `cancel_time` int(11) NOT NULL DEFAULT 0 COMMENT '取消时间',
    `cancel_reason` varchar(500) NOT NULL DEFAULT '' COMMENT '取消原因',
    
    -- 评价相关
    `is_reviewed` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否已评价：0=否，1=是',
    
    -- 快照数据
    `service_snapshot` text COMMENT '服务信息快照（JSON）',
    
    -- 其他
    `is_manual` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否手动创建：0=否，1=是',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_member_id` (`member_id`),
    KEY `idx_provider_id` (`provider_id`),
    KEY `idx_service_type` (`service_type`),
    KEY `idx_order_status` (`order_status`),
    KEY `idx_reservation_date` (`reservation_date`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约订单表';

-- 订单场次明细表
DROP TABLE IF EXISTS `wedding_order_period`;
CREATE TABLE `wedding_order_period` (
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
DROP TABLE IF EXISTS `wedding_order_option`;
CREATE TABLE `wedding_order_option` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单ID',
    `service_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务ID',
    `service_title` varchar(100) NOT NULL DEFAULT '' COMMENT '服务名称（快照）',
    `service_price` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '服务单价（快照）',
    `apply_periods` varchar(50) NOT NULL DEFAULT '' COMMENT '应用场次（逗号分隔）',
    `period_count` int(10) NOT NULL DEFAULT 1 COMMENT '场次数量',
    `total_price` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '小计金额',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单增值服务表';

-- 订单状态日志表
DROP TABLE IF EXISTS `wedding_order_status_log`;
CREATE TABLE `wedding_order_status_log` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单ID',
    `order_no` varchar(32) NOT NULL DEFAULT '' COMMENT '订单编号',
    `from_status` tinyint(2) NOT NULL DEFAULT 0 COMMENT '原状态',
    `to_status` tinyint(2) NOT NULL DEFAULT 0 COMMENT '新状态',
    `operator_type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '操作人类型：0=系统，1=管理员，2=会员，3=服务提供者',
    `operator_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作人ID',
    `operator_name` varchar(50) NOT NULL DEFAULT '' COMMENT '操作人名称',
    `reason` varchar(500) NOT NULL DEFAULT '' COMMENT '变更原因',
    `remark` varchar(500) NOT NULL DEFAULT '' COMMENT '备注',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单状态日志表';

-- ============================================================
-- 4. 评价相关表
-- ============================================================

-- 评价表
DROP TABLE IF EXISTS `wedding_review`;
CREATE TABLE `wedding_review` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单ID',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '会员ID',
    `score` tinyint(1) NOT NULL DEFAULT 5 COMMENT '评分（1-5）',
    `content` text COMMENT '评价内容',
    `images` text COMMENT '评价图片（JSON数组）',
    `reply_content` text COMMENT '服务提供者回复',
    `reply_time` int(11) NOT NULL DEFAULT 0 COMMENT '回复时间',
    `is_anonymous` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否匿名：0=否，1=是',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=待审核，1=显示，2=隐藏',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_provider_id` (`provider_id`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_member_id` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评价表';

-- ============================================================
-- 5. 退款相关表
-- ============================================================

-- 退款申请表
DROP TABLE IF EXISTS `wedding_refund_apply`;
CREATE TABLE `wedding_refund_apply` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `refund_no` varchar(32) NOT NULL DEFAULT '' COMMENT '退款单号',
    `order_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单ID',
    `order_no` varchar(32) NOT NULL DEFAULT '' COMMENT '订单编号',
    `member_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '会员ID',
    `refund_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '申请退款金额',
    `refund_reason` varchar(500) NOT NULL DEFAULT '' COMMENT '退款原因',
    `refund_type` tinyint(1) NOT NULL DEFAULT 1 COMMENT '退款类型：1=用户申请，2=管理员操作',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=待审核，1=已同意，2=已拒绝，3=已完成',
    `audit_time` int(11) NOT NULL DEFAULT 0 COMMENT '审核时间',
    `audit_remark` varchar(500) NOT NULL DEFAULT '' COMMENT '审核备注',
    `complete_time` int(11) NOT NULL DEFAULT 0 COMMENT '完成时间',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_refund_no` (`refund_no`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_member_id` (`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退款申请表';

-- ============================================================
-- 6. 动态相关表
-- ============================================================

-- 动态表
DROP TABLE IF EXISTS `wedding_dynamic`;
CREATE TABLE `wedding_dynamic` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '服务提供者ID',
    `category_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '分类ID',
    `type` tinyint(1) NOT NULL DEFAULT 1 COMMENT '类型：1=图文，2=视频',
    `content` text COMMENT '动态内容',
    `images` text COMMENT '图片列表（JSON数组）',
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
    `is_deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否删除：0=否，1=是',
    PRIMARY KEY (`id`),
    KEY `idx_provider_id` (`provider_id`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_status` (`status`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态表';

-- 动态分类表
DROP TABLE IF EXISTS `wedding_dynamic_category`;
CREATE TABLE `wedding_dynamic_category` (
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
DROP TABLE IF EXISTS `wedding_dynamic_comment`;
CREATE TABLE `wedding_dynamic_comment` (
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
DROP TABLE IF EXISTS `wedding_dynamic_like`;
CREATE TABLE `wedding_dynamic_like` (
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
DROP TABLE IF EXISTS `wedding_member`;
CREATE TABLE `wedding_member` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `openid` varchar(64) NOT NULL DEFAULT '' COMMENT '微信OpenID',
    `unionid` varchar(64) NOT NULL DEFAULT '' COMMENT '微信UnionID',
    `nickname` varchar(50) NOT NULL DEFAULT '' COMMENT '昵称',
    `avatar` varchar(500) NOT NULL DEFAULT '' COMMENT '头像',
    `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号',
    `sex` tinyint(1) NOT NULL DEFAULT 0 COMMENT '性别：0=未知，1=男，2=女',
    `is_provider` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否服务提供者：0=否，1=是',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联服务提供者ID',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
    `last_login_time` int(11) NOT NULL DEFAULT 0 COMMENT '最后登录时间',
    `last_login_ip` varchar(50) NOT NULL DEFAULT '' COMMENT '最后登录IP',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_openid` (`openid`),
    KEY `idx_mobile` (`mobile`),
    KEY `idx_provider_id` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员表';

-- 管理员表
DROP TABLE IF EXISTS `wedding_admin`;
CREATE TABLE `wedding_admin` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `username` varchar(50) NOT NULL DEFAULT '' COMMENT '用户名',
    `password` varchar(255) NOT NULL DEFAULT '' COMMENT '密码',
    `realname` varchar(50) NOT NULL DEFAULT '' COMMENT '真实姓名',
    `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '手机号',
    `avatar` varchar(500) NOT NULL DEFAULT '' COMMENT '头像',
    `role` varchar(50) NOT NULL DEFAULT 'admin' COMMENT '角色',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=正常',
    `last_login_time` int(11) NOT NULL DEFAULT 0 COMMENT '最后登录时间',
    `last_login_ip` varchar(50) NOT NULL DEFAULT '' COMMENT '最后登录IP',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员表';

-- 系统配置表
DROP TABLE IF EXISTS `wedding_config`;
CREATE TABLE `wedding_config` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `key` varchar(100) NOT NULL DEFAULT '' COMMENT '配置键',
    `value` text COMMENT '配置值',
    `description` varchar(255) NOT NULL DEFAULT '' COMMENT '配置说明',
    `create_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
    `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

-- DIY页面表
DROP TABLE IF EXISTS `wedding_diy_page`;
CREATE TABLE `wedding_diy_page` (
    `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `title` varchar(100) NOT NULL DEFAULT '' COMMENT '页面标题',
    `name` varchar(100) NOT NULL DEFAULT '' COMMENT '页面标识（唯一）',
    `type` varchar(50) NOT NULL DEFAULT 'PROVIDER_DETAIL' COMMENT '页面类型：PROVIDER_DETAIL=服务提供者详情页',
    `mode` varchar(20) NOT NULL DEFAULT 'diy' COMMENT '页面模式：diy=自定义，fixed=固定',
    `provider_id` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联服务提供者ID（PROVIDER_DETAIL类型时）',
    `value` longtext COMMENT '页面数据（JSON格式，包含组件配置）',
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
-- 8. 初始数据
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
('basic_config', '{"site_name":"婚庆管家","site_logo":"","contact_phone":"","service_time":"9:00-18:00"}', '基础配置', UNIX_TIMESTAMP()),
('order_config', '{"auto_cancel_hours":24}', '订单配置', UNIX_TIMESTAMP()),
('review_config', '{"need_audit":false}', '评价配置', UNIX_TIMESTAMP()),
('dynamic_config', '{"need_audit":true}', '动态配置', UNIX_TIMESTAMP());

-- 插入默认标签（按服务类型，仅管理员可管理）
-- 主持人标签
INSERT INTO `wedding_service_provider_label` (`service_type`, `name`, `icon`, `color`, `sort`, `status`, `create_time`) VALUES 
('host', '资深主持', '', '#FF6600', 1, 1, UNIX_TIMESTAMP()),
('host', '婚礼策划', '', '#4ECDC4', 2, 1, UNIX_TIMESTAMP()),
('host', '双语主持', '', '#45B7D1', 3, 1, UNIX_TIMESTAMP()),
('host', '户外婚礼', '', '#96CEB4', 4, 1, UNIX_TIMESTAMP()),
('host', '中式婚礼', '', '#FFEAA7', 5, 1, UNIX_TIMESTAMP()),
('host', '西式婚礼', '', '#DDA0DD', 6, 1, UNIX_TIMESTAMP());

-- 跟拍标签
INSERT INTO `wedding_service_provider_label` (`service_type`, `name`, `icon`, `color`, `sort`, `status`, `create_time`) VALUES 
('photographer', '单机位', '', '#0066FF', 1, 1, UNIX_TIMESTAMP()),
('photographer', '双机位', '', '#0099FF', 2, 1, UNIX_TIMESTAMP()),
('photographer', '多机位', '', '#00CCFF', 3, 1, UNIX_TIMESTAMP()),
('photographer', '航拍', '', '#00FFFF', 4, 1, UNIX_TIMESTAMP()),
('photographer', '纪实风格', '', '#FF6600', 5, 1, UNIX_TIMESTAMP()),
('photographer', '唯美风格', '', '#FF99CC', 6, 1, UNIX_TIMESTAMP());

-- 管家标签
INSERT INTO `wedding_service_provider_label` (`service_type`, `name`, `icon`, `color`, `sort`, `status`, `create_time`) VALUES 
('butler', '迎宾服务', '', '#66CC99', 1, 1, UNIX_TIMESTAMP()),
('butler', '现场协调', '', '#99CC66', 2, 1, UNIX_TIMESTAMP()),
('butler', '收尾服务', '', '#CC9966', 3, 1, UNIX_TIMESTAMP()),
('butler', '全程服务', '', '#9966CC', 4, 1, UNIX_TIMESTAMP());

-- 插入默认动态分类
INSERT INTO `wedding_dynamic_category` (`name`, `sort`, `status`, `create_time`) VALUES 
('婚礼现场', 1, 1, UNIX_TIMESTAMP()),
('幕后花絮', 2, 1, UNIX_TIMESTAMP()),
('新人好评', 3, 1, UNIX_TIMESTAMP()),
('行业资讯', 4, 1, UNIX_TIMESTAMP()),
('个人分享', 5, 1, UNIX_TIMESTAMP());

-- ============================================================
-- 脚本执行完成
-- ============================================================
