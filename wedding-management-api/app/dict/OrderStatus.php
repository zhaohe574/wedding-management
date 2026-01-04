<?php
/**
 * 订单状态枚举类
 * 
 * 自动生成自《08-数据字段字典.md》和《11-状态机定义文档.md》
 * 禁止直接修改，如需修改请更新文档后重新生成
 */

namespace app\dict;

/**
 * 订单业务主状态枚举
 */
class OrderStatus
{
    // 业务主状态
    const CREATED = 0;      // 待审核
    const CONFIRMED = 1;    // 已同意
    const SERVING = 3;      // 待服务
    const FINISHED = 4;     // 已完成
    const REJECTED = 10;    // 已拒绝
    const CANCELLED = 11;   // 已取消
    const CLOSED = 13;      // 已关闭

    /**
     * 获取所有状态
     * @return array
     */
    public static function getAll()
    {
        return [
            self::CREATED => '待审核',
            self::CONFIRMED => '已同意',
            self::SERVING => '待服务',
            self::FINISHED => '已完成',
            self::REJECTED => '已拒绝',
            self::CANCELLED => '已取消',
            self::CLOSED => '已关闭',
        ];
    }

    /**
     * 获取状态名称
     * @param int $status
     * @return string
     */
    public static function getName($status)
    {
        $all = self::getAll();
        return $all[$status] ?? '未知状态';
    }

    /**
     * 是否为终态
     * @param int $status
     * @return bool
     */
    public static function isFinal($status)
    {
        return in_array($status, [
            self::FINISHED,
            self::REJECTED,
            self::CANCELLED,
            self::CLOSED
        ]);
    }

    /**
     * 验证状态值是否合法
     * @param int $status
     * @return bool
     */
    public static function isValid($status)
    {
        return array_key_exists($status, self::getAll());
    }
}

/**
 * 订单支付状态枚举
 */
class PaymentStatus
{
    const UNPAID = 0;              // 未付款
    const PAID = 1;                // 已付款
    const PARTIAL_REFUND = 2;      // 部分退款
    const FULL_REFUND = 3;         // 已退款

    /**
     * 获取所有状态
     * @return array
     */
    public static function getAll()
    {
        return [
            self::UNPAID => '未付款',
            self::PAID => '已付款',
            self::PARTIAL_REFUND => '部分退款',
            self::FULL_REFUND => '已退款',
        ];
    }

    /**
     * 获取状态名称
     * @param int $status
     * @return string
     */
    public static function getName($status)
    {
        $all = self::getAll();
        return $all[$status] ?? '未知状态';
    }

    /**
     * 验证状态值是否合法
     * @param int $status
     * @return bool
     */
    public static function isValid($status)
    {
        return array_key_exists($status, self::getAll());
    }
}

/**
 * 订单退款状态枚举
 */
class RefundStatus
{
    const NONE = 0;         // 无退款
    const APPLY = 1;        // 退款申请中
    const APPROVED = 2;     // 退款已同意
    const REJECTED = 3;     // 退款已拒绝
    const COMPLETED = 4;   // 退款已完成

    /**
     * 获取所有状态
     * @return array
     */
    public static function getAll()
    {
        return [
            self::NONE => '无退款',
            self::APPLY => '退款申请中',
            self::APPROVED => '退款已同意',
            self::REJECTED => '退款已拒绝',
            self::COMPLETED => '退款已完成',
        ];
    }

    /**
     * 获取状态名称
     * @return string
     */
    public static function getName($status)
    {
        $all = self::getAll();
        return $all[$status] ?? '未知状态';
    }

    /**
     * 验证状态值是否合法
     * @param int $status
     * @return bool
     */
    public static function isValid($status)
    {
        return array_key_exists($status, self::getAll());
    }
}

