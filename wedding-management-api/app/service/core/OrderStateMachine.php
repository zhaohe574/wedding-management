<?php
/**
 * 订单状态机服务
 * 
 * 负责订单状态流转的校验、执行和日志记录
 * 遵循《11-状态机定义文档.md》的状态迁移规则
 */

namespace app\service\core;

use app\model\Order;
use app\model\OrderStatusLog;
use think\facade\Db;
use think\facade\Log;

class OrderStateMachine
{
    // 业务主状态常量
    const STATUS_CREATED = 0;      // 待审核
    const STATUS_CONFIRMED = 1;    // 已同意
    const STATUS_SERVING = 3;      // 待服务
    const STATUS_FINISHED = 4;     // 已完成
    const STATUS_REJECTED = 10;    // 已拒绝
    const STATUS_CANCELLED = 11;   // 已取消
    const STATUS_CLOSED = 13;      // 已关闭

    // 支付状态常量
    const PAYMENT_UNPAID = 0;              // 未付款
    const PAYMENT_PAID = 1;                // 已付款
    const PAYMENT_PARTIAL_REFUND = 2;      // 部分退款
    const PAYMENT_FULL_REFUND = 3;         // 已退款

    // 退款状态常量
    const REFUND_NONE = 0;         // 无退款
    const REFUND_APPLY = 1;        // 退款申请中
    const REFUND_APPROVED = 2;     // 退款已同意
    const REFUND_REJECTED = 3;     // 退款已拒绝
    const REFUND_COMPLETED = 4;    // 退款已完成

    // 操作人类型常量
    const OPERATOR_SYSTEM = 0;     // 系统
    const OPERATOR_ADMIN = 1;      // 管理员
    const OPERATOR_MEMBER = 2;     // 会员
    const OPERATOR_PROVIDER = 3;   // 服务提供者

    /**
     * 状态迁移定义
     * FROM => [TO => [ALLOWED_ROLE, 前置条件检查函数, 后置动作函数]]
     */
    private static $transitions = [
        // 业务主状态迁移
        self::STATUS_CREATED => [
            self::STATUS_CONFIRMED => [
                'role' => ['provider'],
                'precondition' => 'checkCreatedToConfirmed',
                'postaction' => 'onConfirmed'
            ],
            self::STATUS_REJECTED => [
                'role' => ['provider'],
                'precondition' => 'checkCreatedToRejected',
                'postaction' => 'onRejected'
            ],
            self::STATUS_CANCELLED => [
                'role' => ['user'],
                'precondition' => 'checkCreatedToCancelled',
                'postaction' => 'onCancelled'
            ],
            self::STATUS_CLOSED => [
                'role' => ['admin'],
                'precondition' => 'checkCreatedToClosed',
                'postaction' => 'onClosed'
            ]
        ],
        self::STATUS_CONFIRMED => [
            self::STATUS_SERVING => [
                'role' => ['system'],
                'precondition' => 'checkConfirmedToServing',
                'postaction' => 'onServing'
            ],
            self::STATUS_CANCELLED => [
                'role' => ['user'],
                'precondition' => 'checkConfirmedToCancelled',
                'postaction' => 'onCancelled'
            ],
            self::STATUS_CLOSED => [
                'role' => ['admin'],
                'precondition' => 'checkConfirmedToClosed',
                'postaction' => 'onClosed'
            ]
        ],
        self::STATUS_SERVING => [
            self::STATUS_FINISHED => [
                'role' => ['provider'],
                'precondition' => 'checkServingToFinished',
                'postaction' => 'onFinished'
            ],
            self::STATUS_CLOSED => [
                'role' => ['admin'],
                'precondition' => 'checkServingToClosed',
                'postaction' => 'onClosed'
            ]
        ]
    ];

    /**
     * 支付状态迁移定义
     */
    private static $paymentTransitions = [
        self::PAYMENT_UNPAID => [
            self::PAYMENT_PAID => [
                'role' => ['admin'],
                'precondition' => 'checkUnpaidToPaid',
                'postaction' => 'onPaid'
            ]
        ],
        self::PAYMENT_PAID => [
            self::PAYMENT_PARTIAL_REFUND => [
                'role' => ['admin'],
                'precondition' => 'checkPaidToPartialRefund',
                'postaction' => 'onPartialRefund'
            ],
            self::PAYMENT_FULL_REFUND => [
                'role' => ['admin'],
                'precondition' => 'checkPaidToFullRefund',
                'postaction' => 'onFullRefund'
            ]
        ]
    ];

    /**
     * 退款状态迁移定义
     */
    private static $refundTransitions = [
        self::REFUND_NONE => [
            self::REFUND_APPLY => [
                'role' => ['user'],
                'precondition' => 'checkNoneToApply',
                'postaction' => 'onRefundApply'
            ]
        ],
        self::REFUND_APPLY => [
            self::REFUND_APPROVED => [
                'role' => ['admin'],
                'precondition' => 'checkApplyToApproved',
                'postaction' => 'onRefundApproved'
            ],
            self::REFUND_REJECTED => [
                'role' => ['admin'],
                'precondition' => 'checkApplyToRejected',
                'postaction' => 'onRefundRejected'
            ]
        ],
        self::REFUND_APPROVED => [
            self::REFUND_COMPLETED => [
                'role' => ['admin'],
                'precondition' => 'checkApprovedToCompleted',
                'postaction' => 'onRefundCompleted'
            ]
        ]
    ];

    /**
     * 合法状态组合定义
     */
    private static $validCombinations = [
        [self::STATUS_CREATED, self::PAYMENT_UNPAID, self::REFUND_NONE],
        [self::STATUS_CONFIRMED, self::PAYMENT_UNPAID, self::REFUND_NONE],
        [self::STATUS_CONFIRMED, self::PAYMENT_PAID, self::REFUND_NONE], // 临时状态，应自动流转
        [self::STATUS_SERVING, self::PAYMENT_PAID, self::REFUND_NONE],
        [self::STATUS_SERVING, self::PAYMENT_PAID, self::REFUND_APPLY],
        [self::STATUS_SERVING, self::PAYMENT_PAID, self::REFUND_APPROVED],
        [self::STATUS_SERVING, self::PAYMENT_PAID, self::REFUND_REJECTED],
        [self::STATUS_SERVING, self::PAYMENT_PARTIAL_REFUND, self::REFUND_COMPLETED],
        [self::STATUS_SERVING, self::PAYMENT_FULL_REFUND, self::REFUND_COMPLETED], // 临时状态，应流转为CANCELLED
        [self::STATUS_FINISHED, self::PAYMENT_PAID, self::REFUND_NONE],
        [self::STATUS_REJECTED, self::PAYMENT_UNPAID, self::REFUND_NONE],
        [self::STATUS_CANCELLED, self::PAYMENT_UNPAID, self::REFUND_NONE],
        [self::STATUS_CANCELLED, self::PAYMENT_PAID, self::REFUND_COMPLETED],
        [self::STATUS_CLOSED, self::PAYMENT_UNPAID, self::REFUND_NONE],
    ];

    /**
     * 订单状态迁移
     * 
     * @param int $orderId 订单ID
     * @param int $toStatus 目标状态
     * @param string $operatorRole 操作人角色（user/provider/admin/system）
     * @param int $operatorId 操作人ID
     * @param string $reason 变更原因
     * @param array $extraData 额外数据
     * @return bool
     * @throws \Exception
     */
    public function transition($orderId, $toStatus, $operatorRole, $operatorId, $reason = '', $extraData = [])
    {
        Db::startTrans();
        try {
            // 1. 锁定订单记录
            $order = Order::where('id', $orderId)->lock(true)->find();
            if (!$order) {
                throw new \Exception('订单不存在', 2001);
            }

            $fromStatus = $order->order_status;

            // 2. 检查是否为终态
            if ($this->isFinalStatus($fromStatus)) {
                throw new \Exception('订单已终态，不可再流转', 2002);
            }

            // 3. 检查状态迁移是否允许
            if (!isset(self::$transitions[$fromStatus][$toStatus])) {
                throw new \Exception("状态不允许从 {$fromStatus} 流转到 {$toStatus}", 2002);
            }

            $transition = self::$transitions[$fromStatus][$toStatus];

            // 4. 检查权限
            if (!in_array($operatorRole, $transition['role'])) {
                throw new \Exception('无权限执行此操作', 403);
            }

            // 5. 检查前置条件
            if (isset($transition['precondition'])) {
                $preconditionMethod = $transition['precondition'];
                if (method_exists($this, $preconditionMethod)) {
                    $this->$preconditionMethod($order, $extraData);
                }
            }

            // 6. 检查状态组合合法性
            $this->validateStatusCombination($toStatus, $order->payment_status, $order->refund_status);

            // 7. 执行状态变更
            $order->order_status = $toStatus;
            $order->is_final_status = $this->isFinalStatus($toStatus) ? 1 : 0;
            $order->update_time = time();
            $order->save();

            // 8. 记录状态日志
            $this->logStatusChange($order, $fromStatus, $toStatus, $operatorRole, $operatorId, $reason);

            // 9. 执行后置动作
            if (isset($transition['postaction'])) {
                $postactionMethod = $transition['postaction'];
                if (method_exists($this, $postactionMethod)) {
                    $this->$postactionMethod($order, $extraData);
                }
            }

            Db::commit();
            return true;
        } catch (\Exception $e) {
            Db::rollback();
            Log::error('订单状态迁移失败', [
                'order_id' => $orderId,
                'from_status' => $fromStatus ?? null,
                'to_status' => $toStatus,
                'error' => $e->getMessage()
            ]);
            throw $e;
        }
    }

    /**
     * 支付状态迁移
     */
    public function transitionPayment($orderId, $toPaymentStatus, $operatorRole, $operatorId, $reason = '', $extraData = [])
    {
        Db::startTrans();
        try {
            $order = Order::where('id', $orderId)->lock(true)->find();
            if (!$order) {
                throw new \Exception('订单不存在', 2001);
            }

            $fromPaymentStatus = $order->payment_status;

            // 检查状态迁移是否允许
            if (!isset(self::$paymentTransitions[$fromPaymentStatus][$toPaymentStatus])) {
                throw new \Exception("支付状态不允许从 {$fromPaymentStatus} 流转到 {$toPaymentStatus}", 2002);
            }

            $transition = self::$paymentTransitions[$fromPaymentStatus][$toPaymentStatus];

            // 检查权限
            if (!in_array($operatorRole, $transition['role'])) {
                throw new \Exception('无权限执行此操作', 403);
            }

            // 检查前置条件
            if (isset($transition['precondition'])) {
                $preconditionMethod = $transition['precondition'];
                if (method_exists($this, $preconditionMethod)) {
                    $this->$preconditionMethod($order, $extraData);
                }
            }

            // 检查状态组合合法性
            $this->validateStatusCombination($order->order_status, $toPaymentStatus, $order->refund_status);

            // 执行状态变更
            $order->payment_status = $toPaymentStatus;
            $order->update_time = time();
            $order->save();

            // 记录状态日志
            $this->logStatusChange($order, $fromPaymentStatus, $toPaymentStatus, $operatorRole, $operatorId, $reason, 'payment');

            // 执行后置动作
            if (isset($transition['postaction'])) {
                $postactionMethod = $transition['postaction'];
                if (method_exists($this, $postactionMethod)) {
                    $this->$postactionMethod($order, $extraData);
                }
            }

            Db::commit();
            return true;
        } catch (\Exception $e) {
            Db::rollback();
            throw $e;
        }
    }

    /**
     * 退款状态迁移
     */
    public function transitionRefund($orderId, $toRefundStatus, $operatorRole, $operatorId, $reason = '', $extraData = [])
    {
        Db::startTrans();
        try {
            $order = Order::where('id', $orderId)->lock(true)->find();
            if (!$order) {
                throw new \Exception('订单不存在', 2001);
            }

            $fromRefundStatus = $order->refund_status;

            // 检查状态迁移是否允许
            if (!isset(self::$refundTransitions[$fromRefundStatus][$toRefundStatus])) {
                throw new \Exception("退款状态不允许从 {$fromRefundStatus} 流转到 {$toRefundStatus}", 2002);
            }

            $transition = self::$refundTransitions[$fromRefundStatus][$toRefundStatus];

            // 检查权限
            if (!in_array($operatorRole, $transition['role'])) {
                throw new \Exception('无权限执行此操作', 403);
            }

            // 检查前置条件
            if (isset($transition['precondition'])) {
                $preconditionMethod = $transition['precondition'];
                if (method_exists($this, $preconditionMethod)) {
                    $this->$preconditionMethod($order, $extraData);
                }
            }

            // 检查状态组合合法性
            $this->validateStatusCombination($order->order_status, $order->payment_status, $toRefundStatus);

            // 执行状态变更
            $order->refund_status = $toRefundStatus;
            $order->update_time = time();
            $order->save();

            // 记录状态日志
            $this->logStatusChange($order, $fromRefundStatus, $toRefundStatus, $operatorRole, $operatorId, $reason, 'refund');

            // 执行后置动作
            if (isset($transition['postaction'])) {
                $postactionMethod = $transition['postaction'];
                if (method_exists($this, $postactionMethod)) {
                    $this->$postactionMethod($order, $extraData);
                }
            }

            Db::commit();
            return true;
        } catch (\Exception $e) {
            Db::rollback();
            throw $e;
        }
    }

    /**
     * 检查是否为终态
     */
    private function isFinalStatus($status)
    {
        return in_array($status, [
            self::STATUS_FINISHED,
            self::STATUS_REJECTED,
            self::STATUS_CANCELLED,
            self::STATUS_CLOSED
        ]);
    }

    /**
     * 验证状态组合合法性
     */
    private function validateStatusCombination($orderStatus, $paymentStatus, $refundStatus)
    {
        $combination = [$orderStatus, $paymentStatus, $refundStatus];
        
        // 检查是否为合法组合
        $isValid = false;
        foreach (self::$validCombinations as $validCombination) {
            if ($combination === $validCombination) {
                $isValid = true;
                break;
            }
        }

        if (!$isValid) {
            throw new \Exception('状态组合不合法', 2002);
        }
    }

    /**
     * 记录状态变更日志
     */
    private function logStatusChange($order, $fromStatus, $toStatus, $operatorRole, $operatorId, $reason, $statusType = 'order')
    {
        $operatorTypeMap = [
            'user' => self::OPERATOR_MEMBER,
            'provider' => self::OPERATOR_PROVIDER,
            'admin' => self::OPERATOR_ADMIN,
            'system' => self::OPERATOR_SYSTEM
        ];

        $operatorType = $operatorTypeMap[$operatorRole] ?? self::OPERATOR_SYSTEM;

        OrderStatusLog::create([
            'order_id' => $order->id,
            'order_no' => $order->order_no,
            'from_status' => $fromStatus,
            'to_status' => $toStatus,
            'operator_type' => $operatorType,
            'operator_id' => $operatorId,
            'operator_name' => $this->getOperatorName($operatorRole, $operatorId),
            'reason' => $reason,
            'remark' => "状态类型: {$statusType}",
            'create_time' => time()
        ]);
    }

    /**
     * 获取操作人名称
     */
    private function getOperatorName($operatorRole, $operatorId)
    {
        // TODO: 根据角色和ID获取操作人名称
        return $operatorRole . '_' . $operatorId;
    }

    // ========== 前置条件检查方法 ==========

    private function checkCreatedToConfirmed($order, $extraData)
    {
        if ($order->order_status != self::STATUS_CREATED) {
            throw new \Exception('订单状态不正确', 2002);
        }
        if ($order->payment_status != self::PAYMENT_UNPAID) {
            throw new \Exception('订单支付状态不正确', 2002);
        }
    }

    private function checkCreatedToRejected($order, $extraData)
    {
        if ($order->order_status != self::STATUS_CREATED) {
            throw new \Exception('订单状态不正确', 2002);
        }
    }

    private function checkCreatedToCancelled($order, $extraData)
    {
        if ($order->order_status != self::STATUS_CREATED) {
            throw new \Exception('订单状态不正确', 2002);
        }
    }

    private function checkCreatedToClosed($order, $extraData)
    {
        if ($order->order_status != self::STATUS_CREATED) {
            throw new \Exception('订单状态不正确', 2002);
        }
    }

    private function checkConfirmedToServing($order, $extraData)
    {
        if ($order->order_status != self::STATUS_CONFIRMED) {
            throw new \Exception('订单状态不正确', 2002);
        }
        if ($order->payment_status != self::PAYMENT_PAID) {
            throw new \Exception('订单未付款，不能流转为待服务', 2002);
        }
    }

    private function checkConfirmedToCancelled($order, $extraData)
    {
        if ($order->order_status != self::STATUS_CONFIRMED) {
            throw new \Exception('订单状态不正确', 2002);
        }
        if ($order->payment_status != self::PAYMENT_UNPAID) {
            throw new \Exception('已付款订单不能取消', 2002);
        }
    }

    private function checkConfirmedToClosed($order, $extraData)
    {
        if ($order->order_status != self::STATUS_CONFIRMED) {
            throw new \Exception('订单状态不正确', 2002);
        }
    }

    private function checkServingToFinished($order, $extraData)
    {
        if ($order->order_status != self::STATUS_SERVING) {
            throw new \Exception('订单状态不正确', 2002);
        }
    }

    private function checkServingToClosed($order, $extraData)
    {
        if ($order->order_status != self::STATUS_SERVING) {
            throw new \Exception('订单状态不正确', 2002);
        }
    }

    private function checkUnpaidToPaid($order, $extraData)
    {
        if ($order->payment_status != self::PAYMENT_UNPAID) {
            throw new \Exception('支付状态不正确', 2002);
        }
        if ($order->order_status != self::STATUS_CONFIRMED) {
            throw new \Exception('订单状态不正确', 2002);
        }
    }

    private function checkPaidToPartialRefund($order, $extraData)
    {
        if ($order->payment_status != self::PAYMENT_PAID) {
            throw new \Exception('支付状态不正确', 2002);
        }
        if ($order->refund_status != self::REFUND_APPROVED) {
            throw new \Exception('退款状态不正确', 2002);
        }
    }

    private function checkPaidToFullRefund($order, $extraData)
    {
        if ($order->payment_status != self::PAYMENT_PAID) {
            throw new \Exception('支付状态不正确', 2002);
        }
        if ($order->refund_status != self::REFUND_COMPLETED) {
            throw new \Exception('退款状态不正确', 2002);
        }
    }

    private function checkNoneToApply($order, $extraData)
    {
        if ($order->refund_status != self::REFUND_NONE) {
            throw new \Exception('退款状态不正确', 2002);
        }
        if ($order->order_status != self::STATUS_SERVING) {
            throw new \Exception('订单状态不正确', 2002);
        }
        if ($order->payment_status != self::PAYMENT_PAID) {
            throw new \Exception('订单未付款，不能申请退款', 2002);
        }
    }

    private function checkApplyToApproved($order, $extraData)
    {
        if ($order->refund_status != self::REFUND_APPLY) {
            throw new \Exception('退款状态不正确', 2002);
        }
    }

    private function checkApplyToRejected($order, $extraData)
    {
        if ($order->refund_status != self::REFUND_APPLY) {
            throw new \Exception('退款状态不正确', 2002);
        }
    }

    private function checkApprovedToCompleted($order, $extraData)
    {
        if ($order->refund_status != self::REFUND_APPROVED) {
            throw new \Exception('退款状态不正确', 2002);
        }
    }

    // ========== 后置动作方法 ==========

    private function onConfirmed($order, $extraData)
    {
        // 发送通知给用户
        // TODO: 实现通知逻辑
    }

    private function onRejected($order, $extraData)
    {
        // 释放档期
        // TODO: 实现档期释放逻辑
        
        // 发送通知给用户
        // TODO: 实现通知逻辑
    }

    private function onCancelled($order, $extraData)
    {
        // 释放档期
        // TODO: 实现档期释放逻辑
        
        // 发送通知
        // TODO: 实现通知逻辑
    }

    private function onClosed($order, $extraData)
    {
        // 释放档期
        // TODO: 实现档期释放逻辑
        
        // 发送通知
        // TODO: 实现通知逻辑
    }

    private function onServing($order, $extraData)
    {
        // 发送通知给用户和服务提供者
        // TODO: 实现通知逻辑
    }

    private function onFinished($order, $extraData)
    {
        // 发送通知给用户，允许评价
        // TODO: 实现通知逻辑
    }

    private function onPaid($order, $extraData)
    {
        // 自动流转为待服务
        if ($order->order_status == self::STATUS_CONFIRMED) {
            $this->transition($order->id, self::STATUS_SERVING, 'system', 0, '付款后自动流转');
        }
    }

    private function onPartialRefund($order, $extraData)
    {
        // 发送通知
        // TODO: 实现通知逻辑
    }

    private function onFullRefund($order, $extraData)
    {
        // 发送通知
        // TODO: 实现通知逻辑
        
        // 可选：流转为已取消
        // TODO: 根据业务规则决定是否自动取消订单
    }

    private function onRefundApply($order, $extraData)
    {
        // 发送通知给管理员
        // TODO: 实现通知逻辑
    }

    private function onRefundApproved($order, $extraData)
    {
        // 发送通知给用户
        // TODO: 实现通知逻辑
    }

    private function onRefundRejected($order, $extraData)
    {
        // 发送通知给用户
        // TODO: 实现通知逻辑
    }

    private function onRefundCompleted($order, $extraData)
    {
        // 更新支付状态
        // TODO: 根据退款金额决定是部分退款还是全额退款
        
        // 释放档期（部分退款时）
        // TODO: 实现档期释放逻辑
        
        // 发送通知
        // TODO: 实现通知逻辑
    }
}

