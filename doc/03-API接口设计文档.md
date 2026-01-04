# 婚庆管家 - API接口设计文档

**项目名称**: 婚庆管家（Wedding Host Manager）  
**版本**: v1.0.0  
**创建日期**: 2025-12-31

---

## 一、接口规范

### 1.1 接口业务规则约定

- 所有业务规则由 Service 层统一校验
- Controller 层不包含业务判断逻辑
- 禁止在 Controller 中直接判断：
  - 服务类型
  - 档期冲突
  - 状态流转合法性

### 1.2 基础信息

- **Base URL**: `https://api.example.com/api/v1/`
- **API版本**: v1（路径中包含版本号，便于后续平滑升级）
- **请求格式**: JSON
- **响应格式**: JSON
- **字符编码**: UTF-8

**版本控制策略**:
- 当前版本：`/api/v1/`
- 未来版本：`/api/v2/`（向后兼容，旧版本继续支持）
- 版本号在路由层统一处理

### 1.3 请求头

| Header | 说明 | 必须 |
|--------|------|------|
| Content-Type | application/json | 是 |
| Authorization | Bearer {token} | 需认证接口 |

### 1.4 响应格式

**成功响应**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {}
}
```

**错误响应**:
```json
{
    "code": -1,
    "msg": "错误信息",
    "data": null
}
```

**分页响应**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [],
        "total": 100,
        "page": 1,
        "page_size": 10
    }
}
```

### 1.5 状态码定义（分层设计）

**成功状态码**:
| code | 说明 |
|------|------|
| 0 | 成功 |

**错误状态码分层（规范化）**:
| code范围 | 模块 | 说明 | 详细定义 |
|---------|------|------|---------|
| 0 | 成功 | 操作成功 | - |
| 1xxx | 参数错误 | 参数验证、格式错误 | 1001-1999 |
| 2xxx | 订单模块 | 订单相关错误 | 2001-2999 |
| 3xxx | 档期模块 | 档期相关错误 | 3001-3999 |
| 4xxx | 支付/退款模块 | 支付退款相关错误 | 4001-4999 |
| 5xxx | 评价模块 | 评价相关错误 | 5001-5999 |
| 6xxx | 动态模块 | 动态相关错误 | 6001-6999 |
| 7xxx | 服务提供者模块 | 服务提供者相关错误 | 7001-7999 |
| 8xxx | 内容模块 | 内容管理相关错误 | 8001-8999 |
| 9xxx | 系统级错误 | 系统异常、数据库错误等 | 9001-9999 |

**HTTP状态码**:
| code | 说明 |
|------|------|
| 401 | 未授权/Token失效 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 422 | 参数验证失败 |
| 500 | 服务器错误 |

**详细错误码列表（必须引用《10-异常与边界场景说明.md》）**:

**1xxx - 参数错误**:
| code | 说明 | 触发场景 | 错误码来源 |
|------|------|---------|-----------|
| 1001 | 参数错误 | 必填参数缺失、参数类型错误、参数值超出范围、参数格式错误 | 《10-异常与边界场景说明.md》1.1 |
| 1002 | 系统繁忙，请稍后重试 | 系统异常、数据库连接失败 | 《10-异常与边界场景说明.md》 |
| 1003 | 请求频率过高 | 请求频率超过限制 | 《10-异常与边界场景说明.md》 |

**2xxx - 订单模块**:
| code | 说明 | 触发场景 | 错误码来源 |
|------|------|---------|-----------|
| 2001 | 订单不存在 | order_id不存在 | 《10-异常与边界场景说明.md》2.2 |
| 2002 | 订单状态不允许此操作 | 状态非法流转、状态组合不合法 | 《10-异常与边界场景说明.md》1.2、《11-状态机定义文档.md》 |
| 2003 | 订单已过期 | 订单超时 | 《10-异常与边界场景说明.md》 |
| 2004 | 订单金额计算错误 | 订单金额计算异常 | 《10-异常与边界场景说明.md》 |
| 2005 | 订单重复创建 | 相同client_request_id重复提交 | 《10-异常与边界场景说明.md》1.3 |
| 2006 | 订单正在处理 | 并发审核冲突 | 《10-异常与边界场景说明.md》1.4 |

**3xxx - 档期模块**:
| code | 说明 | 触发场景 | 错误码来源 |
|------|------|---------|-----------|
| 3001 | 档期已被占用 | 时间段重叠冲突 | 《10-异常与边界场景说明.md》1.4、《00-系统设计总纲.md》 |
| 3002 | 档期不存在 | schedule_id不存在 | 《10-异常与边界场景说明.md》2.2 |
| 3003 | 档期状态不允许预约 | 档期状态为休息或已预订 | 《10-异常与边界场景说明.md》1.2 |

**4xxx - 支付/退款模块**:
| code | 说明 | 触发场景 | 错误码来源 |
|------|------|---------|-----------|
| 4001 | 支付凭证格式错误 | 支付凭证图片格式不正确 | 《10-异常与边界场景说明.md》 |
| 4002 | 退款金额超过订单金额 | 退款金额计算错误 | 《10-异常与边界场景说明.md》 |
| 4003 | 退款申请已存在 | 相同client_request_id重复申请 | 《10-异常与边界场景说明.md》1.3 |

**5xxx - 评价模块**:
| code | 说明 | 触发场景 | 错误码来源 |
|------|------|---------|-----------|
| 5001 | 评价已提交 | 同一订单重复提交评价 | 《10-异常与边界场景说明.md》1.3 |
| 5002 | 订单未完成，无法评价 | 订单状态不是已完成 | 《10-异常与边界场景说明.md》1.2 |

**6xxx - 动态模块**:
| code | 说明 | 触发场景 | 错误码来源 |
|------|------|---------|-----------|
| 6001 | 动态不存在 | dynamic_id不存在 | 《10-异常与边界场景说明.md》2.2 |
| 6002 | 动态已删除 | 动态已被逻辑删除 | 《10-异常与边界场景说明.md》2.2 |

**7xxx - 服务提供者模块**:
| code | 说明 | 触发场景 | 错误码来源 |
|------|------|---------|-----------|
| 7001 | 服务提供者不存在 | provider_id不存在 | 《10-异常与边界场景说明.md》2.2 |
| 7002 | 服务提供者已禁用 | 服务提供者status=0 | 《10-异常与边界场景说明.md》2.2 |
| 7003 | 套餐不存在 | package_id不存在 | 《10-异常与边界场景说明.md》2.2 |

**8xxx - 内容模块**:
| code | 说明 | 触发场景 | 错误码来源 |
|------|------|---------|-----------|
| 8001 | 公告不存在 | notice_id不存在 | 《10-异常与边界场景说明.md》2.2 |
| 8002 | 轮播图不存在 | banner_id不存在 | 《10-异常与边界场景说明.md》2.2 |

**9xxx - 系统级错误**:
| code | 说明 | 触发场景 | 错误码来源 |
|------|------|---------|-----------|
| 9001 | 数据库连接失败 | 数据库异常 | 《10-异常与边界场景说明.md》 |
| 9002 | 系统异常 | 未捕获的异常 | 《10-异常与边界场景说明.md》 |

**错误码使用规范**：
- 所有接口的错误响应必须引用错误码来源文档
- 新增错误码必须遵循分段规则
- 错误码定义必须包含：错误码、说明、模块、触发场景

---

## 二、小程序端接口（统一接口，按角色权限区分）

**说明**: 所有小程序接口统一使用 `/api/v1/` 前缀，通过角色权限中间件区分功能访问权限。

**接口版本策略**:
- 所有接口路径包含版本号：`/api/v1/`
- 版本升级时创建新版本：`/api/v2/`
- 旧版本保持兼容，至少支持3个月
- 版本号在路由层统一处理，通过中间件分发

**统一分页规则**:
- 所有列表接口支持分页
- 默认页码：1
- 默认每页数量：10
- 最大每页数量：50
- 分页参数：`page`（页码，从1开始）、`page_size`（每页数量，1-50）

**统一排序规则**:
- 所有列表接口支持排序
- 默认排序：按创建时间倒序（create_time DESC）
- 排序参数：`sort_type`（排序类型）或 `sort_field`+`sort_order`（排序字段+排序方向）
- 排序方向：`asc`（正序）、`desc`（倒序），默认`desc`

**幂等性说明**:
- 所有POST接口需明确是否支持幂等
- 支持幂等的接口：通过`client_request_id`参数实现
- 幂等键格式：建议使用UUID
- 幂等有效期：24小时（相同client_request_id在24小时内返回相同结果）

**角色类型**:
- `user`: 普通用户
- `host`: 主持人
- `admin`: 管理员（小程序端暂不使用）

### 2.1 认证接口

#### 2.1.1 微信登录

**接口**: `POST /api/v1/auth/login`

**描述**: 使用微信code登录，获取token

**幂等性**: ❌ 不支持幂等（每次登录生成新token）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| code | string | 是 | 微信登录code |

**请求示例**:
```json
{
    "code": "0a1b2c3d4e5f"
}
```

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "expires_in": 86400,
        "member_info": {
            "id": 1,
            "nickname": "用户昵称",
            "avatar": "https://...",
            "mobile": "",
            "is_provider": 0,
            "provider_id": 0,
            "role": "user"
        }
    }
}
```

**角色说明**:
- `role: "user"` - 普通用户
- `role: "host"` - 服务提供者（is_provider=1 且 provider_id>0，可能是主持人/跟拍/管家）
- `role: "admin"` - 管理员（小程序端暂不使用）

#### 2.1.2 获取手机号

**接口**: `POST /api/v1/auth/bindMobile`

**描述**: 绑定微信手机号

**幂等性**: ✅ 支持幂等（相同code返回相同手机号）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| code | string | 是 | 微信getPhoneNumber返回的code |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "mobile": "13800138000"
    }
}
```

#### 2.1.3 获取当前用户信息

**接口**: `GET /api/auth/info`

**描述**: 获取当前登录用户信息

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "nickname": "用户昵称",
        "avatar": "https://...",
        "mobile": "13800138000",
        "is_provider": 0,
        "provider_id": 0,
        "service_type": "",
        "role": "user"
    }
}
```

---

### 2.2 服务提供者接口（统一接口，支持多服务类型）

#### 2.2.1 获取服务类型列表

**接口**: `GET /api/provider/serviceTypes`

**描述**: 获取所有可用的服务类型

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": [
        {
            "type_code": "host",
            "type_name": "主持人",
            "icon": "https://...",
            "description": "婚礼主持人服务",
            "count": 20
        },
        {
            "type_code": "photographer",
            "type_name": "跟拍",
            "icon": "https://...",
            "description": "婚礼跟拍服务",
            "count": 15
        },
        {
            "type_code": "butler",
            "type_name": "管家",
            "icon": "https://...",
            "description": "婚礼管家服务",
            "count": 10
        }
    ]
}
```

#### 2.2.2 获取服务提供者列表（统一接口）

**接口**: `GET /api/v1/provider/list`

**描述**: 获取服务提供者列表（支持多服务类型筛选）

**分页规则**:
- 默认页码：1
- 默认每页数量：10
- 最大每页数量：50
- 分页参数：`page`（页码，从1开始）、`page_size`（每页数量）

**排序规则**:
- `default`: 默认排序（按sort字段，create_time倒序）
- `order_count`: 按订单数量倒序
- `score`: 按平均评分倒序
- `price`: 按最低价格正序
- 支持多字段排序：`sort_type=order_count,score`（先按订单量，再按评分）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| service_type | string | 否 | 服务类型：host/photographer/butler（不传=全部） | wedding_service_provider.service_type |
| page | int | 否 | 页码，默认1 | - |
| page_size | int | 否 | 每页数量，默认10，最大50 | - |
| keyword | string | 否 | 搜索关键词（姓名） | wedding_service_provider.realname（LIKE查询） |
| label_id | int | 否 | 标签ID筛选 | wedding_service_provider.label_ids（包含查询） |
| date | string | 否 | 日期筛选（检查档期）YYYY-MM-DD | wedding_service_provider_schedule.date |
| period | int | 否 | 场次筛选（1=早场，2=午场，3=晚场，4=全天） | wedding_service_provider_schedule.period |
| sort_type | string | 否 | 排序方式：default/order_count/score/price | 见排序规则说明 |
| price_min | float | 否 | 最低价格筛选（单位：元） | wedding_service_provider_service.price |
| price_max | float | 否 | 最高价格筛选（单位：元） | wedding_service_provider_service.price |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "service_type": "host",
                "service_type_name": "主持人",
                "realname": "张三",
                "headimg": "https://...",
                "signature": "资深婚礼主持人",
                "label_ids": "1,2",
                "labels": [
                    {"id": 1, "name": "资深主持"},
                    {"id": 2, "name": "婚礼策划"}
                ],
                "experience_years": 5,
                "order_count": 100,
                "review_count": 80,
                "avg_score": 4.9,
                "min_price": 2000.00,
                "is_available": true
            },
            {
                "id": 2,
                "service_type": "photographer",
                "service_type_name": "跟拍",
                "realname": "李四",
                "headimg": "https://...",
                "signature": "专业婚礼跟拍",
                "extension": {
                    "equipment": "佳能5D4, 索尼A7M3",
                    "style_tags": "纪实,唯美,电影感"
                },
                "order_count": 80,
                "review_count": 60,
                "avg_score": 4.8,
                "min_price": 3000.00,
                "is_available": true
            }
        ],
        "total": 50,
        "page": 1,
        "page_size": 10
    }
}
```

#### 2.2.3 获取服务提供者详情（统一接口）

**接口**: `GET /api/provider/info/{id}`

**描述**: 获取服务提供者详细信息（支持所有服务类型）

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "service_type": "host",
        "service_type_name": "主持人",
        "realname": "张三",
        "headimg": "https://...",
        "cover": "https://...",
        "signature": "资深婚礼主持人",
        "introduction": "个人介绍...",
        "sex": 1,
        "experience_years": 5,
        "labels": [
            {"id": 1, "name": "资深主持"}
        ],
        "order_count": 100,
        "review_count": 80,
        "avg_score": 4.9,
        "is_favorited": false,
        "packages": [
            {
                "id": 1,
                "title": "标准套餐",
                "description": "套餐描述",
                "price": 2000.00,
                "period_prices": {"1": 2000, "2": 2500, "3": 3000}  // 1=早场，2=午场，3=晚场
            }
        ],
        "addons": [
            {
                "id": 2,
                "title": "现场彩排",
                "description": "服务描述",
                "price": 500.00
            }
        ],
        // 扩展属性（从扩展表读取，根据service_type返回不同字段）
        "extension": {
            // 跟拍（photographer）特有字段
            "equipment": "佳能5D4、索尼A7R3",
            "style_tags": "纪实、唯美、复古",
            // 管家（butler）特有字段
            // "service_scope": "婚礼策划、现场执行",
            // "team_size": 5
        }
    }
}
```

#### 2.2.4 获取服务提供者档期（统一接口）

**接口**: `GET /api/provider/schedule/{id}`

**接口**: `GET /api/provider/schedule/{id}`

**描述**: 获取服务提供者某月的档期（支持所有服务类型）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| year | int | 否 | 年份，默认当前年 |
| month | int | 否 | 月份，默认当前月 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "year": 2025,
        "month": 1,
        "schedules": {
            "2025-01-15": {
                "1": {"status": 0, "price_adjust": 0},
                "2": {"status": 2, "price_adjust": 0},
                "3": {"status": 0, "price_adjust": 200}
            },
            "2025-01-20": {
                "1": {"status": 1, "price_adjust": 0},
                "2": {"status": 1, "price_adjust": 0},
                "3": {"status": 1, "price_adjust": 0}
            }
        }
    }
}
```

#### 2.2.5 获取标签列表（统一接口）

**接口**: `GET /api/provider/labels`

**描述**: 获取服务提供者标签列表（支持按服务类型筛选）

**权限要求**: 所有用户可访问（仅查询，不能修改）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| service_type | string | 否 | 服务类型：host/photographer/butler（不传=全部） |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": [
        {
            "id": 1, 
            "service_type": "host",
            "service_type_name": "主持人",
            "name": "资深主持", 
            "icon": "", 
            "color": "#FF6600",
            "type": "admin"
        },
        {
            "id": 2, 
            "service_type": "host",
            "service_type_name": "主持人",
            "name": "婚礼策划", 
            "icon": "", 
            "color": "#0066FF",
            "type": "admin"
        }
    ]
}
```

**说明**: 
- 此接口仅用于查询管理员标签列表，所有用户都可以访问
- 管理员标签的创建、编辑、删除只能由管理员在管理端操作
- 管理员标签由管理员在编辑服务提供者时设置，存储在 `label_ids` 字段
- 服务提供者可以自己设置自定义标签（见下方接口）
- 标签按服务类型区分，返回对应服务类型的标签列表

#### 2.2.5.1 获取服务提供者的标签（包含自定义标签）

**接口**: `GET /api/provider/labels/{provider_id}`

**描述**: 获取指定服务提供者的所有标签（管理员标签 + 自定义标签）

**权限要求**: 所有用户可访问

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "admin_labels": [
            {
                "id": 1,
                "name": "资深主持",
                "icon": "",
                "color": "#FF6600",
                "type": "admin"
            }
        ],
        "custom_labels": [
            {
                "name": "擅长户外婚礼",
                "color": "#FF6600",
                "create_time": 1705287600,
                "type": "custom"
            },
            {
                "name": "双语主持",
                "color": "#0066FF",
                "create_time": 1705287700,
                "type": "custom"
            }
        ],
        "all_labels": [
            {
                "id": 1,
                "name": "资深主持",
                "type": "admin"
            },
            {
                "name": "擅长户外婚礼",
                "type": "custom"
            }
        ]
    }
}
```

#### 2.2.5.2 设置自定义标签（服务提供者专用）

**接口**: `POST /api/v1/provider/customLabels`

**描述**: 服务提供者设置自己的自定义擅长标签

**权限要求**: 仅服务提供者角色可访问，且只能设置自己的标签

**幂等性**: ✅ 支持幂等（相同参数重复设置返回成功）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| custom_labels | array | 是 | 自定义标签数组，最多10个 |

**请求示例**:
```json
{
    "custom_labels": [
        {
            "name": "擅长户外婚礼",
            "color": "#FF6600"
        },
        {
            "name": "双语主持",
            "color": "#0066FF"
        }
    ]
}
```

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "custom_labels": [
            {
                "name": "擅长户外婚礼",
                "color": "#FF6600",
                "create_time": 1705287600
            },
            {
                "name": "双语主持",
                "color": "#0066FF",
                "create_time": 1705287700
            }
        ]
    }
}
```

**业务规则**:
- 每个服务提供者最多可设置10个自定义标签
- 自定义标签名称长度限制：2-20个字符
- 自定义标签颜色可选，不传则使用默认颜色
- 自定义标签仅用于展示，不影响搜索和筛选（搜索和筛选使用管理员标签）

#### 2.2.6 收藏/取消收藏（统一接口）

**接口**: `POST /api/v1/provider/favorite`

**描述**: 收藏或取消收藏服务提供者

**幂等性**: ✅ 支持幂等（相同provider_id重复操作返回相同结果）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| provider_id | int | 是 | 服务提供者ID |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "is_favorited": true
    }
}
```

#### 2.2.7 获取收藏列表（统一接口）

**接口**: `GET /api/provider/favorites`

**描述**: 获取我的收藏列表（支持按服务类型筛选）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| service_type | string | 否 | 服务类型筛选 |
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "service_type": "host",
                "service_type_name": "主持人",
                "realname": "张三",
                "headimg": "https://...",
                "signature": "资深婚礼主持人",
                "min_price": 2000.00
            }
        ],
        "total": 5
    }
}
```

#### 2.2.8 获取服务提供者DIY页面数据（统一接口）

**接口**: `GET /api/provider/diyPage/{provider_id}`

**描述**: 获取服务提供者详情页的DIY页面数据（小程序端渲染用，支持所有服务类型）

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "page_id": 1,
        "global": {
            "title": "主持人详情",
            "pageStartBgColor": "#F8F8F8",
            "pageEndBgColor": "",
            "pageGradientAngle": "to bottom",
            "bgUrl": ""
        },
        "components": [
            {
                "id": "unique_id_1",
                "componentName": "ProviderMediaCarousel",
                "componentTitle": "媒体轮播",
                "value": {
                    "height": 640,
                    "autoplay": true,
                    "interval": 5,
                    "list": []
                },
                "template": {
                    "margin": {
                        "top": 0,
                        "bottom": 10,
                        "both": 0
                    },
                    "componentStartBgColor": "#ffffff"
                }
            }
        ]
    }
}
```

**说明**:
- 如果主持人没有DIY页面，返回默认固定页面结构
- 如果DIY页面被禁用，返回默认固定页面结构

---

### 2.3 订单接口

**说明**: 订单状态修改均通过状态机服务处理，接口仅触发状态变更请求，不保证一定成功。

**状态变更接口设计**：
- **统一状态变更接口**：`POST /api/v1/order/{id}/transition`（推荐使用）
- **传统操作接口**：`POST /api/v1/order/approve`、`POST /api/v1/order/reject` 等（保留向后兼容）
- 传统接口内部调用统一状态变更接口，确保状态机规则一致

#### 2.3.1 创建订单

**接口**: `POST /api/v1/order/create`

**描述**: 创建预约订单（支持所有服务类型）

**幂等性**: 支持幂等，通过 `client_request_id` 参数实现

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| client_request_id | string | 是 | 客户端请求ID（用于幂等，建议使用UUID） |
| service_type | string | 是 | 服务类型：host/photographer/butler |
| provider_id | int | 是 | 服务提供者ID |
| reservation_date | string | 是 | 预约日期 YYYY-MM-DD |
| periods | array | 是 | 场次信息（不同服务类型场次定义不同） |
| addons | array | 否 | 增值服务 |
| contact_name | string | 是 | 联系人姓名 |
| contact_mobile | string | 是 | 联系电话 |
| wedding_venue | string | 否 | 婚礼场地 |
| remark | string | 否 | 备注 |

**请求示例**（主持人）:
```json
{
    "service_type": "host",
    "provider_id": 1,
    "reservation_date": "2025-03-15",
    "periods": [
        {"period": 2, "package_id": 1},
        {"period": 3, "package_id": 1}
    ],
    "addons": [
        {"id": 2, "apply_periods": [2, 3]}
    ],
    "contact_name": "李先生",
    "contact_mobile": "13800138000",
    "wedding_venue": "XX酒店",
    "remark": "请提前联系"
}
```

**请求示例**（跟拍）:
```json
{
    "service_type": "photographer",
    "provider_id": 2,
    "reservation_date": "2025-03-15",
    "periods": [
        {"period": 1, "package_id": 1}
    ],
    "contact_name": "王女士",
    "contact_mobile": "13900139000",
    "wedding_venue": "XX酒店",
    "remark": "需要双机位"
}
```

**请求示例**（管家）:
```json
{
    "service_type": "butler",
    "provider_id": 3,
    "reservation_date": "2025-03-15",
    "periods": [
        {"period": 1, "package_id": 1}
    ],
    "contact_name": "张先生",
    "contact_mobile": "13700137000",
    "wedding_venue": "XX酒店",
    "remark": "需要全程服务"
}
```

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "order_id": 1,
        "order_no": "WH202501150001",
        "total_amount": 6500.00
    }
}
```

#### 2.3.2 获取订单列表

**接口**: `GET /api/v1/order/list`

**描述**: 获取我的订单列表（支持按服务类型筛选）

**分页规则**: 同服务提供者列表接口

**排序规则**: 
- 默认：按创建时间倒序（create_time DESC）
- 支持：按预约日期倒序（reservation_date DESC）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| page | int | 否 | 页码，默认1 | - |
| page_size | int | 否 | 每页数量，默认10，最大50 | - |
| service_type | string | 否 | 服务类型筛选：host/photographer/butler | 通过provider_id关联wedding_service_provider.service_type |
| status | int | 否 | 订单状态筛选（0/1/2/3/4/5/-1/-2/-3/-4） | wedding_order.order_status |
| sort_type | string | 否 | 排序方式：default/date（默认/按日期） | 见排序规则说明 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "order_no": "WH202501150001",
                "provider_info": {
                    "id": 1,
                    "realname": "张三",
                    "headimg": "https://..."
                },
                "reservation_date": "2025-03-15",
                "periods": [
                    {"period": 2, "period_name": "午宴"}
                ],
                "total_amount": 6500.00,
                "order_status": 0,
                "order_status_name": "待审核",
                "create_time": 1705287600
            }
        ],
        "total": 10,
        "page": 1,
        "page_size": 10
    }
}
```

#### 2.3.3 获取订单详情

**接口**: `GET /api/order/info/{id}`

**描述**: 获取订单详细信息

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "order_no": "WH202501150001",
        "service_type": "host",
        "service_type_name": "主持人",
        "provider_info": {
            "id": 1,
            "realname": "张三",
            "headimg": "https://...",
            "mobile": "13800138000"
        },
        "reservation_date": "2025-03-15",
        "periods": [
            {
                "period": 2,
                "period_name": "午宴",
                "package_title": "标准套餐",
                "package_price": 2500.00,
                "price_adjust": 0
            }
        ],
        "addons": [
            {
                "title": "现场彩排",
                "price": 500.00,
                "apply_periods": "2,3",
                "total_price": 1000.00
            }
        ],
        "total_amount": 6500.00,
        "payment_amount": 6500.00,
        "payment_voucher": "",
        "payment_time": 0,
        "order_status": 0,
        "order_status_name": "待审核",
        "contact_name": "李先生",
        "contact_mobile": "13800138000",
        "wedding_venue": "XX酒店",
        "remark": "请提前联系",
        "reject_reason": "",
        "is_reviewed": 0,
        "create_time": 1705287600,
        "status_logs": [
            {
                "from_status": 0,
                "to_status": 0,
                "operator_name": "系统",
                "reason": "订单创建",
                "create_time": 1705287600
            }
        ]
    }
}
```

#### 2.3.4 统一状态变更接口（推荐）

**接口**: `POST /api/v1/order/{id}/transition`

**描述**: 统一的状态变更接口，通过状态机校验和执行状态流转

**幂等性**: ✅ 支持幂等（相同状态重复变更返回成功）

**权限要求**: 根据action不同，需要不同角色权限（见状态机定义）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| action | string | 是 | 操作动作：APPROVE/REJECT/CANCEL/COMPLETE/APPLY_REFUND |
| reason | string | 否 | 变更原因 |
| remark | string | 否 | 备注 |

**支持的action**：
| action | 目标状态 | 允许角色 | 说明 |
|--------|---------|---------|------|
| APPROVE | CONFIRMED(1) | provider | 同意订单 |
| REJECT | REJECTED(10) | provider | 拒绝订单 |
| CANCEL | CANCELLED(11) | user | 取消订单 |
| COMPLETE | FINISHED(4) | provider | 确认完成 |
| APPLY_REFUND | refund_status=APPLY(1) | user | 申请退款 |

**请求示例**:
```json
{
    "action": "APPROVE",
    "reason": "同意订单",
    "remark": ""
}
```

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "order_id": 1,
        "order_no": "WH202501150001",
        "order_status": 1,
        "order_status_name": "已同意",
        "payment_status": 0,
        "payment_status_name": "未付款",
        "refund_status": 0,
        "refund_status_name": "无退款"
    }
}
```

**错误响应**:
```json
{
    "code": 2002,
    "msg": "订单状态不允许此操作，当前状态：已取消，允许操作：无",
    "data": {
        "current_status": 11,
        "current_status_name": "已取消",
        "allowed_actions": []
    }
}
```

**优势**：
- 状态扩展不导致接口爆炸
- 权限判断集中化（通过状态机定义）
- 合法性自动校验（前置条件、状态组合）
- 统一异常处理

**向后兼容**：
- 现有接口（`/api/v1/order/approve`、`/api/v1/order/reject` 等）保留
- 现有接口内部调用统一状态变更接口
- 前端可逐步迁移到新接口

#### 2.3.5 取消订单

**接口**: `POST /api/v1/order/cancel`

**描述**: 用户取消订单（内部调用统一状态变更接口）

**幂等性**: ✅ 支持幂等（已取消的订单重复取消返回成功）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| order_id | int | 是 | 订单ID |
| reason | string | 否 | 取消原因 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": null
}
```

**说明**: 此接口内部调用 `POST /api/v1/order/{id}/transition`，action=CANCEL

#### 2.3.6 申请退款

**接口**: `POST /api/v1/order/refund`

**描述**: 申请退款（支持整单退款和部分退款）。内部调用统一状态变更接口更新退款状态。

**幂等性**: ✅ 支持幂等，通过 `member_id + client_request_id` 联合唯一索引实现（防止跨用户重放攻击）

**说明**: 此接口内部调用 `POST /api/v1/order/{id}/transition`，action=APPLY_REFUND（更新refund_status）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| client_request_id | string | 是 | 客户端请求ID（用于幂等，建议使用UUID） |
| order_id | int | 是 | 订单ID |
| refund_type | int | 是 | 退款类型：1=整单退款，2=部分退款 |
| refund_items | array | 否 | 退款明细（部分退款时必填） |
| reason | string | 是 | 退款原因 |

**请求示例**（整单退款）:
```json
{
    "client_request_id": "uuid-xxx",
    "order_id": 1,
    "refund_type": 1,
    "reason": "婚礼取消"
}
```

**请求示例**（部分退款）:
```json
{
    "client_request_id": "uuid-xxx",
    "order_id": 1,
    "refund_type": 2,
    "refund_items": [
        {
            "type": "period",
            "period_id": 1
        },
        {
            "type": "addon",
            "addon_id": 2
        }
    ],
    "reason": "只需要早场，午场和增值服务不需要了"
}
```

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "refund_no": "RF202501150001",
        "refund_type": 2,
        "refund_type_name": "部分退款",
        "refund_amount": 3500.00,
        "refund_items": [
            {
                "type": "period",
                "period_id": 1,
                "period": 2,
                "period_name": "午场",
                "refund_amount": 2500.00
            },
            {
                "type": "addon",
                "addon_id": 2,
                "service_title": "现场彩排",
                "refund_amount": 1000.00
            }
        ]
    }
}
```

**业务规则**:
- 整单退款（refund_type=1）：
  - 退款金额 = 订单实付金额
  - 不需要填写 `refund_items`
- 部分退款（refund_type=2）：
  - 必须填写 `refund_items`，指定要退款的场次或增值服务
  - 退款金额 = 所有退款项的金额总和
  - 退款后，订单状态仍为"待服务(3)"，但已退款的项目不再提供服务
  - 部分退款后，订单的 `total_amount` 会相应减少
- 只有"待服务(3)"状态的订单可以申请退款
- 部分退款后，已退款的场次档期会被释放
  - **档期释放逻辑**：
    - 解析退款申请的 `refund_items` JSON字段
    - 对于 `type="period"` 的退款项，通过 `period_id` 找到对应的 `wedding_order_period` 记录
    - 根据订单的 `reservation_date` 和 `order_period` 中的场次信息，反向查找对应的档期记录（通过 `provider_id + date + start_time + end_time` 匹配）
    - 将对应档期记录的 `order_id` 置为 0，`status` 置为 0（空闲）
    - **重要**：只释放 `refund_items` 里指定的场次档期，未退款的场次档期保持已预订状态

---

### 2.4 评价接口

#### 2.4.1 提交评价

**接口**: `POST /api/v1/review/add`

**描述**: 对订单进行评价

**幂等性**: ✅ 支持幂等（相同order_id重复提交返回已存在评价）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| order_id | int | 是 | 订单ID | wedding_review.order_id |
| score | int | 是 | 评分1-5 | wedding_review.score |
| content | string | 是 | 评价内容 | wedding_review.content |
| images | array | 否 | 图片列表 | wedding_review.images（JSON） |
| is_anonymous | int | 否 | 是否匿名0/1 | wedding_review.is_anonymous |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| order_id | int | 是 | 订单ID |
| score | int | 是 | 评分1-5 |
| content | string | 是 | 评价内容 |
| images | array | 否 | 图片列表 |
| is_anonymous | int | 否 | 是否匿名0/1 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "review_id": 1
    }
}
```

#### 2.4.2 获取服务提供者评价列表

**接口**: `GET /api/review/list`

**描述**: 获取服务提供者的评价列表（支持所有服务类型）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| provider_id | int | 是 | 服务提供者ID |
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "member_info": {
                    "nickname": "用***户",
                    "avatar": "https://..."
                },
                "score": 5,
                "content": "非常满意...",
                "images": ["https://..."],
                "reply_content": "感谢您的认可",
                "reply_time": 1705287600,
                "create_time": 1705287600
            }
        ],
        "total": 80,
        "page": 1,
        "page_size": 10,
        "statistics": {
            "total_count": 80,
            "avg_score": 4.9,
            "score_distribution": {
                "5": 70,
                "4": 8,
                "3": 2,
                "2": 0,
                "1": 0
            }
        }
    }
}
```

---

### 2.5 动态接口

#### 2.5.1 获取动态列表

**接口**: `GET /api/dynamic/list`

**描述**: 获取动态列表

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |
| provider_id | int | 否 | 服务提供者ID筛选 |
| category_id | int | 否 | 分类ID筛选 |
| type | int | 否 | 类型筛选 1=图文,2=视频 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "provider_info": {
                    "id": 1,
                    "realname": "张三",
                    "headimg": "https://..."
                },
                "type": 1,
                "content": "今天的婚礼现场...",
                "images": ["https://...", "https://..."],
                "video": "",
                "video_cover": "",
                "view_count": 1000,
                "like_count": 100,
                "comment_count": 20,
                "is_liked": false,
                "create_time": 1705287600
            }
        ],
        "total": 100,
        "page": 1,
        "page_size": 10
    }
}
```

#### 2.5.2 获取动态详情

**接口**: `GET /api/dynamic/info/{id}`

**描述**: 获取动态详情

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "host_info": {
            "id": 1,
            "realname": "张三",
            "headimg": "https://...",
            "signature": "资深主持人"
        },
        "category": {"id": 1, "name": "婚礼现场"},
        "type": 1,
        "content": "今天的婚礼现场...",
        "images": ["https://...", "https://..."],
        "video": "",
        "video_cover": "",
        "view_count": 1001,
        "like_count": 100,
        "comment_count": 20,
        "share_count": 10,
        "is_liked": false,
        "create_time": 1705287600
    }
}
```

#### 2.5.3 点赞/取消点赞

**接口**: `POST /api/v1/dynamic/like`

**描述**: 点赞或取消点赞

**幂等性**: ✅ 支持幂等（重复点赞/取消返回当前状态）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| dynamic_id | int | 是 | 动态ID | wedding_dynamic_like.dynamic_id |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| dynamic_id | int | 是 | 动态ID |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "is_liked": true,
        "like_count": 101
    }
}
```

#### 2.5.4 获取评论列表

**接口**: `GET /api/dynamic/comments`

**描述**: 获取动态评论列表

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| dynamic_id | int | 是 | 动态ID |
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "member_info": {
                    "nickname": "用户A",
                    "avatar": "https://..."
                },
                "content": "太棒了！",
                "like_count": 5,
                "is_liked": false,
                "create_time": 1705287600,
                "replies": [
                    {
                        "id": 2,
                        "member_info": {"nickname": "张三"},
                        "reply_to": {"nickname": "用户A"},
                        "content": "谢谢支持！",
                        "create_time": 1705287700
                    }
                ]
            }
        ],
        "total": 20,
        "page": 1,
        "page_size": 10
    }
}
```

#### 2.5.5 发表评论

**接口**: `POST /api/v1/dynamic/comment`

**描述**: 发表评论

**幂等性**: ❌ 不支持幂等（每次提交创建新评论）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| dynamic_id | int | 是 | 动态ID | wedding_dynamic_comment.dynamic_id |
| content | string | 是 | 评论内容 | wedding_dynamic_comment.content |
| parent_id | int | 否 | 父评论ID（回复时） | wedding_dynamic_comment.parent_id |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| dynamic_id | int | 是 | 动态ID |
| content | string | 是 | 评论内容 |
| parent_id | int | 否 | 父评论ID（回复时） |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "comment_id": 3
    }
}
```

---

### 2.6 工作台接口（主持人专用）

#### 2.6.1 获取工作台数据

**接口**: `GET /api/console/index`

**描述**: 获取主持人工作台统计数据

**权限要求**: 仅主持人角色可访问

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "today_stats": {
            "new_orders": 3,
            "pending_orders": 5,
            "today_service": 1
        },
        "month_stats": {
            "order_count": 15,
            "total_amount": 45000.00,
            "review_count": 10,
            "avg_score": 4.9
        },
        "recent_orders": [
            {
                "id": 1,
                "order_no": "WH202501150001",
                "contact_name": "李先生",
                "reservation_date": "2025-01-20",
                "order_status": 0
            }
        ],
        "schedule_overview": {
            "booked_count": 8,
            "rest_count": 2,
            "available_count": 20
        }
    }
}
```

### 2.7 订单管理接口（主持人专用）

#### 2.7.1 获取我的订单列表（主持人视角）

**接口**: `GET /api/order/myList`

**描述**: 获取主持人的订单列表（仅显示该主持人的订单）

**权限要求**: 仅主持人角色可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |
| status | int | 否 | 状态筛选 |
| date_start | string | 否 | 开始日期 |
| date_end | string | 否 | 结束日期 |

#### 2.7.2 同意订单

**接口**: `POST /api/v1/order/approve`

**描述**: 服务提供者同意用户预约（内部调用统一状态变更接口）

**幂等性**: ✅ 支持幂等（已同意的订单重复同意返回成功）

**权限要求**: 仅服务提供者角色可访问，且只能操作自己的订单

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| order_id | int | 是 | 订单ID |
| remark | string | 否 | 备注 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": null
}
```

**说明**: 此接口内部调用 `POST /api/v1/order/{id}/transition`，action=APPROVE

#### 2.7.3 拒绝订单

**接口**: `POST /api/v1/order/reject`

**描述**: 服务提供者拒绝用户预约（内部调用统一状态变更接口）

**幂等性**: ✅ 支持幂等（已拒绝的订单重复拒绝返回成功）

**权限要求**: 仅服务提供者角色可访问，且只能操作自己的订单

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| order_id | int | 是 | 订单ID |
| reason | string | 是 | 拒绝原因 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": null
}
```

**说明**: 此接口内部调用 `POST /api/v1/order/{id}/transition`，action=REJECT

#### 2.7.4 确认服务完成

**接口**: `POST /api/v1/order/complete`

**描述**: 服务提供者确认服务完成（内部调用统一状态变更接口）

**幂等性**: ✅ 支持幂等（已完成的订单重复确认返回成功）

**权限要求**: 仅服务提供者角色可访问，且只能操作自己的订单

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| order_id | int | 是 | 订单ID |

**说明**: 此接口内部调用 `POST /api/v1/order/{id}/transition`，action=COMPLETE

### 2.8 档期管理接口（主持人专用）

#### 2.8.1 获取我的档期日历

**接口**: `GET /api/schedule/calendar`

**描述**: 获取主持人自己的档期日历

**权限要求**: 仅主持人角色可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| year | int | 否 | 年份 |
| month | int | 否 | 月份 |

#### 2.8.2 设置档期

**接口**: `POST /api/v1/schedule/set`

**描述**: 服务提供者设置自己的档期状态

**幂等性**: ✅ 支持幂等（相同参数重复设置返回成功）

**权限要求**: 仅服务提供者角色可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| date | string | 是 | 日期 YYYY-MM-DD | wedding_service_provider_schedule.date |
| period | int | 是 | 场次 1/2/3/4 | wedding_service_provider_schedule.period |
| status | int | 是 | 状态 0=空闲，1=休息 | wedding_service_provider_schedule.status |
| price_adjust | float | 否 | 价格调整（单位：元） | wedding_service_provider_schedule.price_adjust |
| remark | string | 否 | 备注 | wedding_service_provider_schedule.remark |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| date | string | 是 | 日期 |
| period | int | 是 | 场次 |
| status | int | 是 | 状态 0=空闲,1=休息 |
| price_adjust | float | 否 | 价格调整 |
| remark | string | 否 | 备注 |

#### 2.8.3 批量设置档期

**接口**: `POST /api/v1/schedule/batchSet`

**描述**: 服务提供者批量设置档期

**幂等性**: ✅ 支持幂等（相同参数重复设置返回成功）

**权限要求**: 仅服务提供者角色可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| dates | array | 是 | 日期数组 | wedding_service_provider_schedule.date |
| periods | array | 是 | 场次数组 | wedding_service_provider_schedule.period |
| status | int | 是 | 状态 0=空闲，1=休息 | wedding_service_provider_schedule.status |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| dates | array | 是 | 日期数组 |
| periods | array | 是 | 场次数组 |
| status | int | 是 | 状态 |

### 2.9 动态管理接口（主持人专用）

#### 2.9.1 发布动态

**接口**: `POST /api/v1/dynamic/publish`

**描述**: 服务提供者发布动态

**幂等性**: ❌ 不支持幂等（每次提交创建新动态）

**权限要求**: 仅服务提供者角色可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| category_id | int | 是 | 分类ID | wedding_dynamic.category_id |
| type | int | 是 | 类型 1=图文，2=视频 | wedding_dynamic.type |
| content | string | 是 | 内容 | wedding_dynamic.content |
| images | array | 否 | 图片列表（JSON） | wedding_dynamic.images |
| video | string | 否 | 视频地址 | wedding_dynamic.video |
| video_cover | string | 否 | 视频封面 | wedding_dynamic.video_cover |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| category_id | int | 是 | 分类ID |
| type | int | 是 | 类型 1=图文,2=视频 |
| content | string | 是 | 内容 |
| images | array | 否 | 图片列表（图文时） |
| video | string | 否 | 视频地址（视频时） |
| video_cover | string | 否 | 视频封面 |

#### 2.9.2 获取我的动态

**接口**: `GET /api/dynamic/myList`

**描述**: 获取我发布的动态列表

**权限要求**: 仅主持人角色可访问

#### 2.9.3 删除动态

**接口**: `POST /api/v1/dynamic/delete`

**描述**: 服务提供者删除自己发布的动态

**幂等性**: ✅ 支持幂等（已删除的动态重复删除返回成功）

**权限要求**: 仅服务提供者角色可访问，且只能删除自己的动态

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| dynamic_id | int | 是 | 动态ID | wedding_dynamic.id |

### 2.10 评价管理接口（主持人专用）

#### 2.10.1 获取我的评价列表

**接口**: `GET /api/review/myList`

**描述**: 获取我的评价列表（主持人视角）

**权限要求**: 仅主持人角色可访问

#### 2.10.2 回复评价

**接口**: `POST /api/v1/review/reply`

**描述**: 服务提供者回复评价

**幂等性**: ✅ 支持幂等（已回复的评价重复回复覆盖原回复）

**权限要求**: 仅服务提供者角色可访问，且只能回复自己的评价

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| review_id | int | 是 | 评价ID | wedding_review.id |
| content | string | 是 | 回复内容 | wedding_review.reply_content |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| review_id | int | 是 | 评价ID |
| content | string | 是 | 回复内容 |

### 2.11 消息接口

#### 2.11.1 获取消息列表

**接口**: `GET /api/message/list`

**描述**: 获取我的消息列表

**权限要求**: 需要登录

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |
| type | string | 否 | 消息类型筛选 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "type": "order_status",
                "title": "订单状态更新",
                "content": "您的订单已同意，请等待付款确认",
                "link_type": "order",
                "link_id": 1,
                "is_read": 0,
                "send_time": 1705287600
            }
        ],
        "total": 10,
        "unread_count": 3
    }
}
```

#### 2.11.2 标记消息已读

**接口**: `POST /api/v1/message/read`

**描述**: 标记消息为已读

**幂等性**: ✅ 支持幂等（已读的消息重复标记返回成功）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| message_id | int | 是 | 消息ID | wedding_message.id |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| message_id | int | 是 | 消息ID（0=全部标记为已读） |

#### 2.11.3 获取未读消息数

**接口**: `GET /api/message/unreadCount`

**描述**: 获取未读消息数量

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "count": 3
    }
}
```

### 2.12 分享接口

#### 2.12.1 分享记录

**接口**: `POST /api/v1/share/record`

**描述**: 记录分享行为

**幂等性**: ❌ 不支持幂等（每次分享记录一次）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| share_type | string | 是 | 分享类型：provider/dynamic/order | wedding_share_log.share_type |
| target_id | int | 是 | 目标ID | wedding_share_log.target_id |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| share_type | string | 是 | 分享类型：host/dynamic/order |
| share_id | int | 是 | 分享对象ID |
| share_channel | string | 是 | 分享渠道：wechat/friend/moments |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": null
}
```

#### 2.12.2 获取分享数据

**接口**: `GET /api/share/data`

**描述**: 获取分享卡片数据

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| share_type | string | 是 | 分享类型 |
| share_id | int | 是 | 分享对象ID |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "title": "主持人：张三",
        "desc": "资深婚礼主持人",
        "image": "https://...",
        "path": "/pages/host/detail?id=1"
    }
}
```

### 2.13 订单接口增强

#### 2.13.1 上传付款凭证

**接口**: `POST /api/v1/order/uploadPaymentVoucher`

**描述**: 用户上传付款凭证（可选）

**幂等性**: ✅ 支持幂等（重复上传覆盖原凭证）

**权限要求**: 仅普通用户，且只能上传自己的订单

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| order_id | int | 是 | 订单ID | wedding_order.id |
| voucher | string | 是 | 付款凭证图片URL | wedding_order.user_payment_voucher |

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| order_id | int | 是 | 订单ID |
| voucher | string | 是 | 付款凭证图片URL |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": null
}
```

---

## 三、管理端接口（PC端）

### 4.1 认证接口

#### 4.1.1 管理员登录

**接口**: `POST /admin/auth/login`

**描述**: 管理员登录（增强安全验证，防止撞库攻击）

**安全机制**:
1. **登录失败次数限制**：5次失败后锁定30分钟
2. **IP白名单验证**：如果管理员设置了IP白名单，验证登录IP
3. **2FA双因素认证**：如果管理员启用了2FA，需要验证TOTP码
4. **登录日志记录**：记录所有登录尝试（成功/失败）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |
| totp_code | string | 否 | 2FA验证码（启用2FA时必填） |

**响应示例**（成功）:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "expires_in": 86400,
        "admin_info": {
            "id": 1,
            "username": "admin",
            "realname": "管理员",
            "role": "admin",
            "two_factor_enabled": 0
        }
    }
}
```

**响应示例**（需要2FA验证）:
```json
{
    "code": 0,
    "msg": "需要2FA验证",
    "data": {
        "require_2fa": true,
        "temp_token": "temp_token_xxx"
    }
}
```

**错误响应**:
```json
{
    "code": 6001,
    "msg": "账号已被锁定，请30分钟后重试",
    "data": {
        "lock_time": 1800,
        "unlock_time": 1704067200
    }
}
```
```json
{
    "code": 6002,
    "msg": "登录失败次数过多，账号已锁定",
    "data": null
}
```
```json
{
    "code": 6003,
    "msg": "IP地址不在白名单中",
    "data": null
}
```
```json
{
    "code": 6004,
    "msg": "2FA验证码错误",
    "data": null
}
```
```json
{
    "code": 6005,
    "msg": "用户名或密码错误",
    "data": null
}
```

**登录流程**:
1. 验证账号是否被锁定（`login_lock_time > 当前时间`）
2. 验证IP白名单（如果设置了）
3. 验证用户名和密码
4. 如果启用2FA，验证TOTP码
5. 登录成功：重置失败次数，更新最后登录时间和IP，记录登录日志
6. 登录失败：增加失败次数，达到5次后锁定30分钟，记录登录日志

**错误码说明**:
- 6001: 账号已被锁定
- 6002: 登录失败次数过多
- 6003: IP地址不在白名单中
- 6004: 2FA验证码错误
- 6005: 用户名或密码错误

#### 4.1.2 启用2FA

**接口**: `POST /admin/auth/enable2FA`

**描述**: 启用2FA双因素认证

**请求参数**: 无

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "secret": "JBSWY3DPEHPK3PXP",
        "qr_code_url": "https://api.qrserver.com/v1/create-qr-code/?data=otpauth://totp/..."
    }
}
```

#### 4.1.3 禁用2FA

**接口**: `POST /admin/auth/disable2FA`

**描述**: 禁用2FA双因素认证（需要验证密码）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| password | string | 是 | 当前密码（用于验证身份） |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": null
}
```

#### 4.1.4 设置IP白名单

**接口**: `POST /admin/auth/setIpWhitelist`

**描述**: 设置IP白名单（可选，空数组表示不限制）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| ip_list | array | 是 | IP地址列表，如：["192.168.1.1", "10.0.0.0/8"] |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": null
}
```

#### 4.1.5 获取登录日志

**接口**: `GET /admin/auth/loginLog`

**描述**: 获取登录日志（用于安全审计）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |
| username | string | 否 | 用户名 |
| login_ip | string | 否 | 登录IP |
| login_result | int | 否 | 登录结果：0=失败，1=成功 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "admin_id": 1,
                "username": "admin",
                "login_ip": "192.168.1.100",
                "login_result": 1,
                "fail_reason": "",
                "create_time": 1704067200
            }
        ],
        "total": 100
    }
}
```

### 4.2 服务提供者管理接口（统一接口，支持所有服务类型）

#### 4.2.1 获取服务提供者列表

**接口**: `GET /admin/provider/list`

**权限要求**: 仅管理员可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| service_type | string | 否 | 服务类型：host/photographer/butler（不传=全部） |
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |
| keyword | string | 否 | 搜索关键词 |

#### 4.2.2 添加服务提供者

**接口**: `POST /admin/provider/add`

**权限要求**: 仅管理员可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| service_type | string | 是 | 服务类型：host/photographer/butler |
| member_id | int | 是 | 关联会员ID |
| realname | string | 是 | 真实姓名 |
| mobile | string | 是 | 手机号码 |
| label_ids | string | 否 | 标签ID，逗号分隔（**仅管理员可设置**） |
| ... | ... | ... | 其他字段 |

**说明**: 标签只能由管理员设置，服务提供者不能自己设置标签。

#### 4.2.3 编辑服务提供者

**接口**: `POST /admin/provider/edit`

**权限要求**: 仅管理员可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| id | int | 是 | 服务提供者ID |
| label_ids | string | 否 | 管理员标签ID，逗号分隔（**仅管理员可设置**） |
| ... | ... | ... | 其他字段 |

**说明**: 
- 管理员在编辑服务提供者时，可以设置或修改管理员标签（label_ids）
- 标签会根据服务类型自动筛选，只显示对应服务类型的标签
- 自定义标签（custom_labels）由服务提供者自己通过小程序端接口设置，管理员不能修改

#### 4.2.4 删除服务提供者

**接口**: `POST /admin/provider/delete`

**权限要求**: 仅管理员可访问

### 4.2.5 标签管理接口

#### 4.2.5.1 获取标签列表

**接口**: `GET /admin/provider/label/list`

**权限要求**: 仅管理员可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| service_type | string | 否 | 服务类型：host/photographer/butler（不传=全部） |
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "service_type": "host",
                "service_type_name": "主持人",
                "name": "资深主持",
                "icon": "https://...",
                "color": "#FF6600",
                "sort": 1,
                "status": 1
            },
            {
                "id": 2,
                "service_type": "photographer",
                "service_type_name": "跟拍",
                "name": "单机位",
                "icon": "https://...",
                "color": "#0066FF",
                "sort": 1,
                "status": 1
            }
        ],
        "total": 20,
        "page": 1,
        "page_size": 10
    }
}
```

#### 4.2.5.2 添加标签

**接口**: `POST /admin/provider/label/add`

**权限要求**: 仅管理员可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| service_type | string | 是 | 服务类型：host/photographer/butler（空=通用标签） |
| name | string | 是 | 标签名称 |
| icon | string | 否 | 标签图标 |
| color | string | 否 | 标签颜色 |
| sort | int | 否 | 排序 |

**说明**: 
- `service_type`为空时表示通用标签，所有服务类型都可以使用
- `service_type`不为空时，该标签仅适用于指定服务类型

#### 4.2.5.3 编辑标签

**接口**: `POST /admin/provider/label/edit`

**权限要求**: 仅管理员可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| id | int | 是 | 标签ID |
| service_type | string | 是 | 服务类型 |
| name | string | 是 | 标签名称 |
| icon | string | 否 | 标签图标 |
| color | string | 否 | 标签颜色 |
| sort | int | 否 | 排序 |
| status | int | 否 | 状态：0=禁用，1=正常 |

#### 4.2.5.4 删除标签

**接口**: `POST /admin/provider/label/delete`

**权限要求**: 仅管理员可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| id | int | 是 | 标签ID |

**说明**: 删除标签前需要检查是否有服务提供者正在使用该标签。


### 4.3 订单管理接口

#### 4.3.1 获取订单列表

**接口**: `GET /admin/order/list`

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |
| order_no | string | 否 | 订单编号 |
| provider_id | int | 否 | 服务提供者ID |
| service_type | string | 否 | 服务类型：host/photographer/butler |
| status | int | 否 | 订单状态 |
| date_start | string | 否 | 开始日期 |
| date_end | string | 否 | 结束日期 |

#### 4.3.2 确认付款

**接口**: `POST /admin/order/confirmPayment`

**描述**: 管理员确认付款，上传付款凭证

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| order_id | int | 是 | 订单ID |
| payment_voucher | string | 是 | 付款凭证图片URL |
| payment_amount | float | 是 | 付款金额 |
| remark | string | 否 | 付款备注 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": null
}
```

#### 4.3.3 确认退款

**接口**: `POST /admin/order/confirmRefund`

**描述**: 管理员确认退款，上传退款凭证

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| order_id | int | 是 | 订单ID |
| refund_voucher | string | 是 | 退款凭证图片URL |
| refund_amount | float | 是 | 退款金额 |
| remark | string | 否 | 退款备注 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": null
}
```

**业务规则**:
- 只有退款状态为"已同意(2)"的退款申请可以确认
- 确认退款后：
  - 更新订单的 `refund_status` 为"已完成(4)"
  - 更新订单的 `payment_status`：部分退款为"部分退款(2)"，全额退款为"已退款(3)"
  - **释放档期（部分退款时）**：
    - 解析退款申请的 `refund_items` JSON字段
    - 对于 `type="period"` 的退款项，通过 `period_id` 找到对应的 `wedding_order_period` 记录
    - 根据订单的 `reservation_date` 和 `order_period` 中的场次信息，反向查找对应的档期记录（通过 `provider_id + date + start_time + end_time` 匹配）
    - 将对应档期记录的 `order_id` 置为 0，`status` 置为 0（空闲）
    - **重要**：只释放 `refund_items` 里指定的场次档期，未退款的场次档期保持已预订状态
  - 发送通知给用户

#### 4.3.4 审核改期申请

**接口**: `POST /admin/order/auditChangeDate`

**描述**: 管理员审核改期申请

**权限要求**: 仅管理员可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| order_id | int | 是 | 订单ID |
| status | int | 是 | 审核结果：1=同意，2=拒绝 |
| change_date_fee | float | 否 | 改期费（同意时，如果不传则使用系统计算的费用） |
| price_difference | float | 否 | 补差价（同意时，如果不传则使用系统计算的差价） |
| reject_reason | string | 否 | 拒绝原因（拒绝时必填） |
| remark | string | 否 | 备注 |

**响应示例**（同意）:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "order_id": 1,
        "order_status": 7,
        "order_status_name": "已改期",
        "old_reservation_date": "2025-03-15",
        "new_reservation_date": "2025-03-20",
        "change_date_fee": 200.00,
        "price_difference": 500.00,
        "total_amount": 7200.00
    }
}
```

**响应示例**（拒绝）:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "order_id": 1,
        "order_status": 3,
        "order_status_name": "待服务",
        "reject_reason": "新日期档期已被占用"
    }
}
```

**业务规则**:
- 只有"改期申请中(6)"状态的订单可以审核
- 同意改期：
  - 更新订单的 `reservation_date` 为新日期
  - 更新订单的 `old_reservation_date` 为原日期
  - 更新订单的 `total_amount` = `original_amount` + `change_date_fee` + `price_difference`
  - 更新订单的 `change_date_fee` 和 `price_difference`
  - 释放原日期的档期，锁定新日期的档期
  - 订单状态变为"已改期(7)"，然后自动流转回"待服务(3)"
- 拒绝改期：
  - 订单状态恢复为"待服务(3)"
  - 记录拒绝原因

### 4.4 退款管理接口

#### 4.4.1 获取退款列表

**接口**: `GET /admin/refund/list`

#### 4.4.2 审核退款

**接口**: `POST /admin/refund/audit`

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| refund_id | int | 是 | 退款ID |
| status | int | 是 | 1=同意,2=拒绝 |
| remark | string | 否 | 备注 |

### 4.5 评价管理接口

#### 4.5.1 获取评价列表

**接口**: `GET /admin/review/list`

#### 4.5.2 审核评价

**接口**: `POST /admin/review/audit`

### 4.6 动态管理接口

#### 4.6.1 获取动态列表

**接口**: `GET /admin/dynamic/list`

#### 4.6.2 审核动态

**接口**: `POST /admin/dynamic/audit`

### 4.7 配置管理接口

#### 4.7.1 获取配置

**接口**: `GET /admin/config/get`

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| key | string | 是 | 配置键 |

#### 4.7.2 保存配置

**接口**: `POST /admin/config/save`

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| key | string | 是 | 配置键 |
| value | object | 是 | 配置值 |

### 4.8 DIY页面装修接口

#### 4.8.1 获取DIY组件列表

**接口**: `GET /admin/diy/components`

**描述**: 获取可用的DIY组件列表（从组件注册表动态加载）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| page_type | string | 否 | 页面类型：PROVIDER_DETAIL（不传=全部） |
| category | string | 否 | 组件分类：basic/media/info/interaction（不传=全部） |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "categories": [
            {
                "category": "basic",
                "title": "基础组件",
                "list": [
                    {
                        "id": 1,
                        "component_name": "ProviderMediaCarousel",
                        "component_title": "媒体轮播",
                        "icon": "iconfont icon-carousel",
                        "description": "支持图片和视频轮播",
                        "preview_image": "https://...",
                        "config_schema": {
                            "type": "object",
                            "properties": {
                                "height": {
                                    "type": "number",
                                    "title": "高度",
                                    "default": 640
                                },
                                "autoplay": {
                                    "type": "boolean",
                                    "title": "自动播放",
                                    "default": true
                                }
                            }
                        },
                        "default_value": {
                            "height": 640,
                            "autoplay": true,
                            "interval": 5,
                            "list": []
                        }
                    },
                    {
                        "id": 2,
                        "component_name": "ProviderInfo",
                        "component_title": "服务提供者信息",
                        "icon": "iconfont icon-info",
                        "description": "展示服务提供者基本信息",
                        "preview_image": "https://...",
                        "config_schema": {...},
                        "default_value": {...}
                    }
                ]
            }
        ]
    }
}
```

**说明**: 
- 组件列表从 `wedding_diy_component` 表动态加载
- 前端根据 `config_schema` 动态生成配置表单
- 新增组件只需在后台添加组件记录，无需修改前后端代码

#### 4.8.2 注册DIY组件

**接口**: `POST /admin/diy/component/add`

**描述**: 注册新的DIY组件（支持动态扩展）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| component_name | string | 是 | 组件名称（唯一，如：ProviderMediaCarousel） |
| component_title | string | 是 | 组件标题（显示名称） |
| category | string | 是 | 组件分类：basic/media/info/interaction |
| icon | string | 是 | 组件图标 |
| description | string | 否 | 组件描述 |
| page_type | string | 否 | 适用页面类型（空=通用） |
| config_schema | object | 是 | 配置项结构（JSON Schema格式） |
| default_value | object | 是 | 默认配置值（JSON对象） |
| preview_image | string | 否 | 预览图 |
| sort | int | 否 | 排序 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 10,
        "component_name": "ProviderVideo",
        "component_title": "视频展示"
    }
}
```

#### 4.8.3 更新DIY组件

**接口**: `POST /admin/diy/component/update`

**描述**: 更新DIY组件信息

**请求参数**: 同注册接口，增加 `id` 参数

#### 4.8.4 删除DIY组件

**接口**: `POST /admin/diy/component/delete`

**描述**: 删除DIY组件（软删除，已使用的组件不能删除）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| id | int | 是 | 组件ID |

#### 4.8.5 获取DIY页面数据

**接口**: `GET /admin/diy/page/{id}`

**描述**: 获取DIY页面数据（用于编辑）

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "title": "服务提供者详情页",
        "name": "PROVIDER_DETAIL_1_default",
        "type": "PROVIDER_DETAIL",
        "mode": "diy",
                "provider_id": 1,
        "value": {
            "global": {
                "title": "服务提供者详情",
                "pageStartBgColor": "#F8F8F8"
            },
            "value": [
                {
                    "id": "xxx",
                    "componentName": "HostMediaCarousel",
                    "componentTitle": "媒体轮播",
                    "value": {},
                    "template": {}
                }
            ]
        }
    }
}
```

#### 4.8.3 保存DIY页面

**接口**: `POST /admin/diy/page/save`

**描述**: 保存DIY页面数据

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| id | int | 否 | 页面ID（编辑时） |
| title | string | 是 | 页面标题 |
| name | string | 是 | 页面标识 |
| type | string | 是 | 页面类型 |
| provider_id | int | 否 | 服务提供者ID |
| value | object | 是 | 页面数据（JSON） |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1
    }
}
```

#### 4.8.4 获取服务提供者DIY页面列表

**接口**: `GET /admin/diy/pages`

**描述**: 获取服务提供者的DIY页面列表（支持所有服务类型）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| provider_id | int | 是 | 服务提供者ID |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "title": "服务提供者详情页",
                "name": "PROVIDER_DETAIL_1_default",
                "is_current": 1,
                "create_time": 1705287600,
                "update_time": 1705287600
            }
        ],
        "current_page_id": 1
    }
}
```

#### 4.8.5 切换服务提供者使用的DIY页面

**接口**: `POST /admin/diy/page/switch`

**描述**: 切换服务提供者使用的DIY页面（支持所有服务类型）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| provider_id | int | 是 | 服务提供者ID |
| page_id | int | 是 | DIY页面ID |

#### 4.8.6 删除DIY页面

**接口**: `POST /admin/diy/page/delete`

**描述**: 删除DIY页面

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| id | int | 是 | 页面ID |

#### 4.8.7 预览DIY页面

**接口**: `GET /admin/diy/page/preview/{id}`

**描述**: 获取预览URL

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "preview_url": "https://miniapp.example.com/pages/provider/detail?type=PROVIDER_DETAIL&id=1&mode=decorate"
    }
}
```

### 4.9 消息管理接口

#### 4.9.1 获取消息列表

**接口**: `GET /admin/message/list`

**描述**: 获取系统消息列表

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |
| type | string | 否 | 消息类型 |
| member_id | int | 否 | 会员ID |

#### 4.9.2 发送消息

**接口**: `POST /admin/message/send`

**描述**: 发送系统消息

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| member_id | int | 否 | 会员ID（0=全体用户） |
| type | string | 是 | 消息类型 |
| title | string | 是 | 消息标题 |
| content | string | 是 | 消息内容 |
| link_type | string | 否 | 链接类型 |
| link_id | int | 否 | 链接ID |

### 4.10 内容管理接口

#### 4.10.1 公告管理

**接口**: `GET /admin/content/notice/list` - 获取公告列表
**接口**: `POST /admin/content/notice/add` - 添加公告
**接口**: `POST /admin/content/notice/edit` - 编辑公告
**接口**: `POST /admin/content/notice/delete` - 删除公告

#### 4.10.2 轮播图管理

**接口**: `GET /admin/content/banner/list` - 获取轮播图列表
**接口**: `POST /admin/content/banner/add` - 添加轮播图
**接口**: `POST /admin/content/banner/edit` - 编辑轮播图
**接口**: `POST /admin/content/banner/delete` - 删除轮播图

**请求参数**（添加/编辑）:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| title | string | 是 | 标题 |
| image | string | 是 | 图片地址 |
| link_type | string | 否 | 链接类型 |
| link_id | int | 否 | 链接ID |
| link_url | string | 否 | 链接地址 |
| position | string | 是 | 位置：home/index/provider_detail |
| sort | int | 否 | 排序 |
| start_time | int | 否 | 开始时间 |
| end_time | int | 否 | 结束时间 |

### 4.11 订单超时管理接口

#### 4.11.1 获取超时配置

**接口**: `GET /admin/order/timeoutConfig`

**描述**: 获取订单超时配置

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "pending_timeout_hours": 48,
        "payment_timeout_hours": 72,
        "auto_reject_enabled": true,
        "auto_cancel_enabled": true
    }
}
```

#### 4.11.2 保存超时配置

**接口**: `POST /admin/order/timeoutConfig`

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| pending_timeout_hours | int | 是 | 待审核超时小时数 |
| payment_timeout_hours | int | 是 | 已同意未付款超时小时数 |
| auto_reject_enabled | int | 是 | 是否自动拒绝 |
| auto_cancel_enabled | int | 是 | 是否自动取消 |

#### 4.11.3 获取超时日志

**接口**: `GET /admin/order/timeoutLog`

**描述**: 获取订单超时处理日志

### 4.12 统计接口

#### 4.12.1 获取仪表盘数据

**接口**: `GET /admin/statistics/dashboard`

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "today": {
            "order_count": 10,
            "order_amount": 35000.00,
            "new_members": 5,
            "new_reviews": 3
        },
        "total": {
            "provider_count": 20,
            "order_count": 500,
            "member_count": 1000,
            "review_count": 400
        },
        "trend": {
            "dates": ["2025-01-01", "2025-01-02", "..."],
            "order_counts": [5, 8, 10, "..."],
            "amounts": [15000, 24000, 30000, "..."]
        }
    }
}
```

#### 4.12.2 订单统计

**接口**: `GET /admin/statistics/order`

**描述**: 获取订单统计数据

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| date_start | string | 否 | 开始日期 |
| date_end | string | 否 | 结束日期 |
| provider_id | int | 否 | 服务提供者ID |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "total_count": 500,
        "total_amount": 1500000.00,
        "status_distribution": {
            "0": 10,
            "1": 20,
            "2": 30,
            "3": 15,
            "4": 400
        },
        "daily_stats": [
            {"date": "2025-01-01", "count": 5, "amount": 15000},
            {"date": "2025-01-02", "count": 8, "amount": 24000}
        ]
    }
}
```

#### 4.12.3 主持人统计

**接口**: `GET /admin/statistics/host`

**描述**: 获取主持人统计数据

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "provider_list": [
            {
                "provider_id": 1,
                "realname": "张三",
                "order_count": 100,
                "total_amount": 300000.00,
                "avg_score": 4.9,
                "response_rate": 95.5
            }
        ],
        "rankings": {
            "order_count": [],
            "total_amount": [],
            "avg_score": []
        }
    }
}
```

#### 4.12.4 会员统计

**接口**: `GET /admin/statistics/member`

**描述**: 获取会员统计数据

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "total_count": 1000,
        "new_today": 5,
        "new_this_month": 50,
        "active_count": 200,
        "repeat_rate": 15.5
    }
}
```

---

## 五、公共接口

### 5.1 文件上传

**接口**: `POST /api/v1/upload/image`

**描述**: 上传图片/视频（增强安全验证）

**请求格式**: multipart/form-data

**安全验证机制**:
1. **文件扩展名白名单**：只允许指定扩展名
2. **MIME类型检测**：检查Content-Type，防止伪装
3. **文件内容验证**：检查文件魔数（文件头），防止伪装扩展名
4. **图片真实性验证**：使用GD库或ImageMagick验证是否为真实图片
5. **视频真实性验证**：使用FFmpeg验证是否为真实视频
6. **禁止可执行文件**：禁止上传.php, .jsp, .asp, .exe等可执行文件

**文件限制**:
| 类型 | 允许格式 | 允许MIME类型 | 文件魔数 | 最大大小 | 最大尺寸 | 说明 |
|-----|---------|------------|---------|---------|---------|------|
| avatar | jpg, jpeg, png, webp | image/jpeg, image/png, image/webp | JPEG: FF D8 FF<br>PNG: 89 50 4E 47<br>WebP: 52 49 46 46 | 2MB | 800x800px | 头像 |
| cover | jpg, jpeg, png, webp | image/jpeg, image/png, image/webp | 同上 | 5MB | 1920x1080px | 封面图 |
| dynamic | jpg, jpeg, png, webp | image/jpeg, image/png, image/webp | 同上 | 5MB | 1920x1080px | 动态图片 |
| voucher | jpg, jpeg, png | image/jpeg, image/png | JPEG: FF D8 FF<br>PNG: 89 50 4E 47 | 5MB | 1920x1080px | 付款/退款凭证 |
| review | jpg, jpeg, png, webp | image/jpeg, image/png, image/webp | 同上 | 5MB | 1920x1080px | 评价图片 |

**视频限制**（动态视频）:
| 类型 | 允许格式 | 允许MIME类型 | 文件魔数 | 最大大小 | 最大时长 | 最大分辨率 | 说明 |
|-----|---------|------------|---------|---------|---------|-----------|------|
| dynamic_video | mp4, mov | video/mp4, video/quicktime | MP4: 00 00 00 20 66 74 79 70<br>MOV: 00 00 00 20 66 74 79 70 | 100MB | 5分钟 | 1920x1080px | 动态视频 |

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| file | file | 是 | 图片/视频文件 |
| type | string | 是 | 类型：avatar/cover/dynamic/voucher/review/dynamic_video |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "url": "https://cdn.example.com/images/xxx.jpg",
        "path": "/images/xxx.jpg",
        "size": 102400,
        "width": 800,
        "height": 600,
        "mime_type": "image/jpeg"
    }
}
```

**错误响应**:
```json
{
    "code": 1001,
    "msg": "文件格式不支持，仅支持 jpg, jpeg, png, webp",
    "data": null
}
```
```json
{
    "code": 1002,
    "msg": "文件MIME类型不匹配，疑似伪装文件",
    "data": null
}
```
```json
{
    "code": 1003,
    "msg": "文件内容验证失败，不是有效的图片文件",
    "data": null
}
```
```json
{
    "code": 1004,
    "msg": "禁止上传可执行文件",
    "data": null
}
```
```json
{
    "code": 1005,
    "msg": "文件大小超过限制，最大 5MB",
    "data": null
}
```

**安全验证流程**:
1. 检查文件扩展名是否在白名单中
2. 检查MIME类型是否匹配扩展名
3. 读取文件前几个字节，检查文件魔数（文件头）
4. 对于图片：使用GD库或ImageMagick尝试打开图片，验证是否为真实图片
5. 对于视频：使用FFmpeg验证是否为真实视频
6. 检查文件大小、尺寸等限制
7. 生成唯一文件名，避免文件名冲突和路径遍历攻击
8. 保存文件到安全目录（不在Web根目录下，或配置不允许执行脚本）

**代码示例**:
```php
// 文件上传安全验证
class UploadSecurity
{
    // 文件魔数映射
    private static $fileSignatures = [
        'jpg' => ['FF D8 FF'],
        'jpeg' => ['FF D8 FF'],
        'png' => ['89 50 4E 47'],
        'webp' => ['52 49 46 46'],
        'mp4' => ['00 00 00 20 66 74 79 70'],
        'mov' => ['00 00 00 20 66 74 79 70']
    ];
    
    // MIME类型映射
    private static $mimeTypes = [
        'jpg' => ['image/jpeg'],
        'jpeg' => ['image/jpeg'],
        'png' => ['image/png'],
        'webp' => ['image/webp'],
        'mp4' => ['video/mp4'],
        'mov' => ['video/quicktime']
    ];
    
    // 禁止的扩展名（可执行文件）
    private static $forbiddenExtensions = ['php', 'jsp', 'asp', 'aspx', 'exe', 'sh', 'bat', 'cmd'];
    
    public function validateFile($file, $type)
    {
        // 1. 检查扩展名
        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        if (in_array($ext, self::$forbiddenExtensions)) {
            throw new Exception('禁止上传可执行文件', 1004);
        }
        
        // 2. 检查MIME类型
        $mimeType = $file['type'];
        if (!in_array($mimeType, self::$mimeTypes[$ext] ?? [])) {
            throw new Exception('文件MIME类型不匹配，疑似伪装文件', 1002);
        }
        
        // 3. 检查文件魔数
        $fileContent = file_get_contents($file['tmp_name'], false, null, 0, 16);
        $hex = bin2hex($fileContent);
        $signatures = self::$fileSignatures[$ext] ?? [];
        $matched = false;
        foreach ($signatures as $signature) {
            if (stripos($hex, str_replace(' ', '', $signature)) === 0) {
                $matched = true;
                break;
            }
        }
        if (!$matched) {
            throw new Exception('文件内容验证失败，不是有效的文件', 1003);
        }
        
        // 4. 验证图片真实性（使用GD库）
        if (in_array($ext, ['jpg', 'jpeg', 'png', 'webp'])) {
            $imageInfo = @getimagesize($file['tmp_name']);
            if ($imageInfo === false) {
                throw new Exception('文件内容验证失败，不是有效的图片文件', 1003);
            }
        }
        
        // 5. 验证视频真实性（使用FFmpeg）
        if (in_array($ext, ['mp4', 'mov'])) {
            // 使用FFmpeg验证视频
            // exec("ffprobe -v error -show_format {$file['tmp_name']}", $output, $return);
            // if ($return !== 0) {
            //     throw new Exception('文件内容验证失败，不是有效的视频文件', 1003);
            // }
        }
        
        return true;
    }
}
```

### 5.2 获取配置

**接口**: `GET /api/config/basic`

**描述**: 获取基础配置

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "site_name": "婚庆管家",
        "site_logo": "https://...",
        "contact_phone": "400-xxx-xxxx",
        "service_time": "9:00-18:00"
    }
}
```

### 5.3 获取公告列表

**接口**: `GET /api/content/notice/list`

**描述**: 获取公告列表

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "title": "系统公告",
                "content": "公告内容...",
                "cover": "https://...",
                "link_type": "url",
                "link_url": "https://...",
                "publish_time": 1705287600
            }
        ],
        "total": 10
    }
}
```

### 5.4 获取轮播图列表

**接口**: `GET /api/content/banner/list`

**描述**: 获取轮播图列表

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| position | string | 是 | 位置：home/index/provider_detail |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": [
        {
            "id": 1,
            "title": "轮播图标题",
            "image": "https://...",
            "link_type": "host",
            "link_id": 1,
            "link_url": "/pages/host/detail?id=1"
        }
    ]
}
```

---

## 六、购物车接口

### 6.1 添加商品到购物车

**接口**: `POST /api/v1/cart/add`

**描述**: 添加服务项目到购物车

**幂等性**: ✅ 支持幂等（相同provider_id+date+period重复添加更新数量）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| provider_id | int | 是 | 服务提供者ID | wedding_cart.provider_id |
| reservation_date | string | 是 | 预约日期 | wedding_cart.reservation_date |
| periods | array | 是 | 场次信息 | wedding_cart.periods（JSON） |
| package_id | int | 是 | 套餐ID | wedding_cart.package_id |
| addons | array | 否 | 增值服务 | wedding_cart.addons（JSON） |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| service_type | string | 是 | 服务类型：host/photographer/butler |
| provider_id | int | 是 | 服务提供者ID |
| reservation_date | string | 是 | 预约日期 YYYY-MM-DD |
| package_id | int | 是 | 套餐ID |
| periods | array | 是 | 场次数组 [1,2,3] |
| addon_ids | array | 否 | 增值服务ID数组 |
| remark | string | 否 | 备注 |

**请求示例**（单个服务）:
```json
{
    "item_type": 1,
    "service_type": "host",
    "provider_id": 1,
    "reservation_date": "2025-03-15",
    "package_id": 1,
    "periods": [1, 2],
    "addon_ids": [2, 3],
    "remark": "请提前联系"
}
```

**请求示例**（组合套餐）:
```json
{
    "item_type": 2,
    "combo_id": 1,
    "reservation_date": "2025-03-15",
    "remark": "请提前联系"
}
```

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "cart_id": 1,
        "cart_count": 5,
        "cart_total": 12500.00
    }
}
```

### 6.2 获取购物车列表

**接口**: `GET /api/cart/list`

**描述**: 获取当前用户的购物车列表

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "list": [
            {
                "id": 1,
                "item_type": 1,
                "item_type_name": "单个服务",
                "service_type": "host",
                "service_type_name": "主持人",
                "provider_id": 1,
                "provider_name": "张三",
                "provider_headimg": "https://...",
                "reservation_date": "2025-03-15",
                "package_id": 1,
                "package_title": "标准套餐",
                "package_price": 2000.00,
                "periods": [1, 2],
                "period_names": "早场,午场",
                "period_prices": {"1": 2000, "2": 2500},
                "addon_ids": [2],
                "addon_names": "现场彩排",
                "addon_prices": {"2": 500},
                "subtotal": 7000.00,
                "remark": "请提前联系",
                "is_valid": 1,
                "invalid_reason": ""
            },
            {
                "id": 2,
                "item_type": 2,
                "item_type_name": "组合套餐",
                "combo_id": 1,
                "combo_title": "主持人+跟拍套餐",
                "combo_description": "超值组合，优惠500元",
                "combo_cover": "https://...",
                "original_price": 12000.00,
                "combo_price": 11500.00,
                "discount_amount": 500.00,
                "reservation_date": "2025-03-15",
                "subtotal": 11500.00,
                "items": [
                    {
                        "service_type": "host",
                        "service_type_name": "主持人",
                        "provider_id": 1,
                        "provider_name": "张三",
                        "package_id": 1,
                        "periods": [2],
                        "original_price": 2500.00,
                        "combo_price": 2500.00
                    },
                    {
                        "service_type": "photographer",
                        "service_type_name": "跟拍",
                        "provider_id": 2,
                        "provider_name": "李四",
                        "package_id": 3,
                        "periods": [2],
                        "original_price": 9500.00,
                        "combo_price": 9000.00
                    }
                ],
                "is_valid": 1,
                "invalid_reason": ""
            }
        ],
        "total_count": 5,
        "total_amount": 12500.00,
        "valid_count": 5,
        "valid_amount": 12500.00,
        "invalid_count": 0
    }
}
```

### 6.3 更新购物车项

**接口**: `POST /api/v1/cart/update`

**描述**: 更新购物车项（修改场次、套餐、增值服务等）

**幂等性**: ✅ 支持幂等（相同cart_id重复更新返回成功）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| cart_id | int | 是 | 购物车项ID | wedding_cart.id |
| periods | array | 否 | 场次信息 | wedding_cart.periods（JSON） |
| package_id | int | 否 | 套餐ID | wedding_cart.package_id |
| addons | array | 否 | 增值服务 | wedding_cart.addons（JSON） |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| cart_id | int | 是 | 购物车项ID |
| package_id | int | 否 | 套餐ID |
| periods | array | 否 | 场次数组 |
| addon_ids | array | 否 | 增值服务ID数组 |
| remark | string | 否 | 备注 |

### 6.4 删除购物车项

**接口**: `POST /api/v1/cart/delete`

**描述**: 删除购物车项

**幂等性**: ✅ 支持幂等（已删除的项重复删除返回成功）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| cart_id | int | 是 | 购物车项ID | wedding_cart.id |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| cart_ids | array | 是 | 购物车项ID数组 |

### 6.5 清空购物车

**接口**: `POST /api/v1/cart/clear`

**描述**: 清空当前用户的购物车

**幂等性**: ✅ 支持幂等（已清空的购物车重复清空返回成功）

**请求参数**: 无

### 6.6 校验购物车

**接口**: `POST /api/v1/cart/validate`

**描述**: 校验购物车中所有项的可用性（档期、价格等）

**幂等性**: ❌ 不支持幂等（每次校验返回最新状态）

**请求参数**: 无（校验当前用户的购物车）

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "valid_items": [1, 2, 3],
        "invalid_items": [
            {
                "cart_id": 4,
                "reason": "档期已被预订",
                "provider_name": "李四",
                "reservation_date": "2025-03-15",
                "period": "早场"
            }
        ],
        "price_changed_items": [
            {
                "cart_id": 5,
                "old_price": 2000.00,
                "new_price": 2200.00,
                "reason": "套餐价格已调整"
            }
        ]
    }
}
```

### 6.7 批量结算（创建订单）

**接口**: `POST /api/v1/cart/checkout`

**描述**: 批量结算购物车，创建多个订单

**幂等性**: ✅ 支持幂等（通过client_request_id，相同请求返回已创建订单）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 | 数据库字段映射 |
|-------|------|------|------|---------------|
| client_request_id | string | 是 | 客户端请求ID（用于幂等） | - |
| contact_name | string | 是 | 联系人姓名 | wedding_order.contact_name |
| contact_mobile | string | 是 | 联系电话 | wedding_order.contact_mobile |
| wedding_venue | string | 否 | 婚礼场地 | wedding_order.wedding_venue |
| remark | string | 否 | 备注 | wedding_order.remark |
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| cart_ids | array | 否 | 要结算的购物车项ID数组（不传=全部） |
| contact_name | string | 是 | 联系人姓名 |
| contact_mobile | string | 是 | 联系电话 |
| wedding_venue | string | 否 | 婚礼场地 |
| remark | string | 否 | 备注 |

**请求示例**:
```json
{
    "cart_ids": [1, 2, 3, 4],
    "contact_name": "李先生",
    "contact_mobile": "13800138000",
    "wedding_venue": "XX酒店",
    "remark": "请提前联系"
}
```

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "orders": [
            {
                "order_id": 1,
                "order_no": "WH202501150001",
                "service_type": "host",
                "service_type_name": "主持人",
                "provider_name": "张三",
                "reservation_date": "2025-03-15",
                "total_amount": 7000.00
            },
            {
                "order_id": 2,
                "order_no": "WH202501150002",
                "service_type": "photographer",
                "service_type_name": "跟拍",
                "provider_name": "李四",
                "reservation_date": "2025-03-15",
                "total_amount": 5000.00
            }
        ],
        "total_orders": 2,
        "total_amount": 12000.00
    }
}
```

**业务逻辑**:
1. 校验购物车项可用性（档期、价格等）
2. 按服务提供者+日期分组
3. 为每组创建订单
4. 创建订单场次明细
5. 创建订单增值服务明细
6. 锁定档期
7. 清空已结算的购物车项
8. 返回订单列表

---

**文档版本**: v1.0.0  
**最后更新**: 2025-12-31

