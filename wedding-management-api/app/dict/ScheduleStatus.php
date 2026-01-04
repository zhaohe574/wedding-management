<?php
/**
 * 档期状态枚举类
 * 
 * 自动生成自《08-数据字段字典.md》和《11-状态机定义文档.md》
 * 禁止直接修改，如需修改请更新文档后重新生成
 */

namespace app\dict;

/**
 * 档期状态枚举
 */
class ScheduleStatus
{
    const FREE = 0;     // 空闲
    const REST = 1;     // 休息
    const BOOKED = 2;  // 已预订

    /**
     * 获取所有状态
     * @return array
     */
    public static function getAll()
    {
        return [
            self::FREE => '空闲',
            self::REST => '休息',
            self::BOOKED => '已预订',
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

    /**
     * 是否可预约
     * @param int $status
     * @return bool
     */
    public static function canBook($status)
    {
        return $status === self::FREE;
    }
}

