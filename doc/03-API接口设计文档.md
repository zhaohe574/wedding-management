# 婚庆管家 - API接口设计文档

**项目名称**: 婚庆管家（Wedding Host Manager）  
**版本**: v1.0.0  
**创建日期**: 2025-12-31

---

## 一、接口规范

### 1.1 基础信息

- **Base URL**: `https://api.example.com/`
- **请求格式**: JSON
- **响应格式**: JSON
- **字符编码**: UTF-8

### 1.2 请求头

| Header | 说明 | 必须 |
|--------|------|------|
| Content-Type | application/json | 是 |
| Authorization | Bearer {token} | 需认证接口 |

### 1.3 响应格式

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

### 1.4 状态码定义

| code | 说明 |
|------|------|
| 0 | 成功 |
| -1 | 通用错误 |
| 401 | 未授权/Token失效 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 422 | 参数验证失败 |
| 500 | 服务器错误 |

---

## 二、小程序端接口（统一接口，按角色权限区分）

**说明**: 所有小程序接口统一使用 `/api/` 前缀，通过角色权限中间件区分功能访问权限。

**角色类型**:
- `user`: 普通用户
- `host`: 主持人
- `admin`: 管理员（小程序端暂不使用）

### 2.1 认证接口

#### 2.1.1 微信登录

**接口**: `POST /api/auth/login`

**描述**: 使用微信code登录，获取token

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

**接口**: `POST /api/auth/bindMobile`

**描述**: 绑定微信手机号

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

**接口**: `GET /api/provider/list`

**描述**: 获取服务提供者列表（支持多服务类型筛选）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| service_type | string | 否 | 服务类型：host/photographer/butler（不传=全部） |
| page | int | 否 | 页码，默认1 |
| page_size | int | 否 | 每页数量，默认10 |
| keyword | string | 否 | 搜索关键词（姓名） |
| label_id | int | 否 | 标签ID筛选 |
| date | string | 否 | 日期筛选（检查档期）YYYY-MM-DD |
| period | int | 否 | 场次筛选（不同服务类型场次定义不同） |
| sort_type | string | 否 | 排序方式：default/order_count/score/price |
| price_min | float | 否 | 最低价格筛选 |
| price_max | float | 否 | 最高价格筛选 |

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
                "equipment": "佳能5D4, 索尼A7M3",
                "style_tags": "纪实,唯美,电影感",
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
        // 跟拍特有字段
        "equipment": "",
        "style_tags": "",
        // 管家特有字段
        "service_scope": "",
        "team_size": 0
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
            "color": "#FF6600"
        },
        {
            "id": 2, 
            "service_type": "host",
            "service_type_name": "主持人",
            "name": "婚礼策划", 
            "icon": "", 
            "color": "#0066FF"
        }
    ]
}
```

**说明**: 
- 此接口仅用于查询标签列表，所有用户都可以访问
- 标签的创建、编辑、删除只能由管理员在管理端操作
- 服务提供者不能自己设置标签，标签由管理员在编辑服务提供者时设置
- 标签按服务类型区分，返回对应服务类型的标签列表

#### 2.2.6 收藏/取消收藏（统一接口）

**接口**: `POST /api/provider/favorite`

**描述**: 收藏或取消收藏服务提供者

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
                "componentName": "HostMediaCarousel",
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

#### 2.3.1 创建订单

**接口**: `POST /api/order/create`

**描述**: 创建预约订单（支持所有服务类型）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
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

**接口**: `GET /api/order/list`

**描述**: 获取我的订单列表（支持按服务类型筛选）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |
| service_type | string | 否 | 服务类型筛选：host/photographer/butler |
| status | int | 否 | 订单状态筛选 |

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
                "host_info": {
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

#### 2.3.4 取消订单

**接口**: `POST /api/order/cancel`

**描述**: 用户取消订单

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

#### 2.3.5 申请退款

**接口**: `POST /api/order/refund`

**描述**: 申请退款

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| order_id | int | 是 | 订单ID |
| reason | string | 是 | 退款原因 |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "refund_no": "RF202501150001"
    }
}
```

---

### 2.4 评价接口

#### 2.4.1 提交评价

**接口**: `POST /api/review/add`

**描述**: 对订单进行评价

**请求参数**:
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
                "host_info": {
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

**接口**: `POST /api/dynamic/like`

**描述**: 点赞或取消点赞

**请求参数**:
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

**接口**: `POST /api/dynamic/comment`

**描述**: 发表评论

**请求参数**:
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

**接口**: `POST /api/order/approve`

**描述**: 主持人同意用户预约

**权限要求**: 仅主持人角色可访问，且只能操作自己的订单

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

#### 2.7.3 拒绝订单

**接口**: `POST /api/order/reject`

**描述**: 主持人拒绝用户预约

**权限要求**: 仅主持人角色可访问，且只能操作自己的订单

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

#### 2.7.4 确认服务完成

**接口**: `POST /api/order/complete`

**描述**: 主持人确认服务完成

**权限要求**: 仅主持人角色可访问，且只能操作自己的订单

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| order_id | int | 是 | 订单ID |

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

**接口**: `POST /api/schedule/set`

**描述**: 主持人设置自己的档期状态

**权限要求**: 仅主持人角色可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| date | string | 是 | 日期 |
| period | int | 是 | 场次 |
| status | int | 是 | 状态 0=空闲,1=休息 |
| price_adjust | float | 否 | 价格调整 |
| remark | string | 否 | 备注 |

#### 2.8.3 批量设置档期

**接口**: `POST /api/schedule/batchSet`

**描述**: 主持人批量设置档期

**权限要求**: 仅主持人角色可访问

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| dates | array | 是 | 日期数组 |
| periods | array | 是 | 场次数组 |
| status | int | 是 | 状态 |

### 2.9 动态管理接口（主持人专用）

#### 2.9.1 发布动态

**接口**: `POST /api/dynamic/publish`

**描述**: 主持人发布动态

**权限要求**: 仅主持人角色可访问

**请求参数**:
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

**接口**: `POST /api/dynamic/delete`

**描述**: 主持人删除自己发布的动态

**权限要求**: 仅主持人角色可访问，且只能删除自己的动态

### 2.10 评价管理接口（主持人专用）

#### 2.10.1 获取我的评价列表

**接口**: `GET /api/review/myList`

**描述**: 获取我的评价列表（主持人视角）

**权限要求**: 仅主持人角色可访问

#### 2.10.2 回复评价

**接口**: `POST /api/review/reply`

**描述**: 主持人回复评价

**权限要求**: 仅主持人角色可访问，且只能回复自己的评价

**请求参数**:
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

**接口**: `POST /api/message/read`

**描述**: 标记消息为已读

**请求参数**:
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

**接口**: `POST /api/share/record`

**描述**: 记录分享行为

**请求参数**:
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

**接口**: `POST /api/order/uploadPaymentVoucher`

**描述**: 用户上传付款凭证（可选）

**权限要求**: 仅普通用户，且只能上传自己的订单

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

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |

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
| label_ids | string | 否 | 标签ID，逗号分隔（**仅管理员可设置**） |
| ... | ... | ... | 其他字段 |

**说明**: 管理员在编辑服务提供者时，可以设置或修改标签。标签会根据服务类型自动筛选，只显示对应服务类型的标签。

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

**描述**: 获取可用的DIY组件列表

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "categories": [
            {
                "title": "基础组件",
                "list": [
                    {
                        "componentName": "HostMediaCarousel",
                        "title": "媒体轮播",
                        "icon": "iconfont icon...",
                        "path": "edit-host-media-carousel"
                    },
                    {
                        "componentName": "HostInfo",
                        "title": "主持人信息",
                        "icon": "iconfont icon...",
                        "path": "edit-host-info"
                    }
                ]
            }
        ]
    }
}
```

#### 4.8.2 获取DIY页面数据

**接口**: `GET /admin/diy/page/{id}`

**描述**: 获取DIY页面数据（用于编辑）

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "id": 1,
        "title": "主持人详情页",
        "name": "HOST_DETAIL_1_default",
        "type": "HOST_DETAIL",
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
        "preview_url": "https://miniapp.example.com/pages/host/detail?type=HOST_DETAIL&id=1&mode=decorate"
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
| position | string | 是 | 位置：home/index/host_detail |
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
            "host_count": 20,
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
        "host_list": [
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

**接口**: `POST /api/upload/image`

**描述**: 上传图片

**请求格式**: multipart/form-data

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| file | file | 是 | 图片文件 |
| type | string | 否 | 类型：avatar/cover/dynamic/voucher |

**响应示例**:
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "url": "https://cdn.example.com/images/xxx.jpg",
        "path": "/images/xxx.jpg"
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
| position | string | 是 | 位置：home/index/host_detail |

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

**接口**: `POST /api/cart/add`

**描述**: 添加服务项目到购物车

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| service_type | string | 是 | 服务类型：host/photographer/butler |
| provider_id | int | 是 | 服务提供者ID |
| reservation_date | string | 是 | 预约日期 YYYY-MM-DD |
| package_id | int | 是 | 套餐ID |
| periods | array | 是 | 场次数组 [1,2,3] |
| addon_ids | array | 否 | 增值服务ID数组 |
| remark | string | 否 | 备注 |

**请求示例**:
```json
{
    "service_type": "host",
    "provider_id": 1,
    "reservation_date": "2025-03-15",
    "package_id": 1,
    "periods": [1, 2],
    "addon_ids": [2, 3],
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

**接口**: `POST /api/cart/update`

**描述**: 更新购物车项（修改场次、套餐、增值服务等）

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| cart_id | int | 是 | 购物车项ID |
| package_id | int | 否 | 套餐ID |
| periods | array | 否 | 场次数组 |
| addon_ids | array | 否 | 增值服务ID数组 |
| remark | string | 否 | 备注 |

### 6.4 删除购物车项

**接口**: `POST /api/cart/delete`

**描述**: 删除购物车项

**请求参数**:
| 参数名 | 类型 | 必须 | 说明 |
|-------|------|------|------|
| cart_ids | array | 是 | 购物车项ID数组 |

### 6.5 清空购物车

**接口**: `POST /api/cart/clear`

**描述**: 清空当前用户的购物车

### 6.6 校验购物车

**接口**: `POST /api/cart/validate`

**描述**: 校验购物车中所有项的可用性（档期、价格等）

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

**接口**: `POST /api/cart/checkout`

**描述**: 批量结算购物车，创建多个订单

**请求参数**:
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

