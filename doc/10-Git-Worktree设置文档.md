# Git Worktree 设置文档

**项目名称**: 婚庆管家（Wedding Host Manager）  
**文档版本**: v1.1.0  
**创建日期**: 2025-01-06  
**最后更新**: 2025-01-06

---

## ⚠️ 状态说明

**当前状态**: Worktree 已移除

**移除日期**: 2025-01-06

**说明**: 所有创建的 worktree 已被移除，当前仅保留主工作树（main 分支）。

---

## 一、Worktree 配置说明

### 1.1 历史 Worktree 结构（已移除）

**日期**: 2025-01-06

**配置**: 使用 Git Worktree 实现多分支并行开发（已取消）

**历史 Worktree 列表**:
- **主工作树**: `D:/2025-10-31/wedding-management` → `main` 分支 ✅ 保留
- **后端工作树**: `D:/2025-10-31/wedding-management-backend` → `backend-dev` 分支 ❌ 已移除
- **管理前端工作树**: `D:/2025-10-31/wedding-management-admin` → `admin-frontend-dev` 分支 ❌ 已移除
- **小程序前端工作树**: `D:/2025-10-31/wedding-management-miniapp` → `miniapp-dev` 分支 ❌ 已移除

### 1.2 技术说明

**Git Worktree 限制**:
- Worktree 不能是主仓库的子目录
- Worktree 必须与主仓库在同一级别或更高级别
- 每个 worktree 包含完整的仓库内容

**当前实现**:
- 根目录（wedding-management）使用 `main` 分支
- 三个独立的 worktree 目录分别使用对应的开发分支
- 每个 worktree 都是完整的仓库副本，可以独立工作

---

## 二、目录结构

### 2.1 实际目录布局

```
D:/2025-10-31/
├── wedding-management/              [main 分支]
│   ├── doc/
│   ├── wedding-management-api/
│   ├── wedding-management-admin/
│   └── wedding-management-miniapp/
│
├── wedding-management-backend/       [backend-dev 分支]
│   ├── doc/
│   ├── wedding-management-api/
│   ├── wedding-management-admin/
│   └── wedding-management-miniapp/
│
├── wedding-management-admin/         [admin-frontend-dev 分支]
│   ├── doc/
│   ├── wedding-management-api/
│   ├── wedding-management-admin/
│   └── wedding-management-miniapp/
│
└── wedding-management-miniapp/       [miniapp-dev 分支]
    ├── doc/
    ├── wedding-management-api/
    ├── wedding-management-admin/
    └── wedding-management-miniapp/
```

### 2.2 使用说明

**主工作树（main 分支）**:
- 路径: `D:/2025-10-31/wedding-management`
- 用途: 根分支，用于合并和发布
- 包含所有三个子项目

**后端工作树（backend-dev 分支）**:
- 路径: `D:/2025-10-31/wedding-management-backend`
- 用途: 后端 API 开发
- 重点关注: `wedding-management-api/` 目录

**管理前端工作树（admin-frontend-dev 分支）**:
- 路径: `D:/2025-10-31/wedding-management-admin`
- 用途: 管理后台前端开发
- 重点关注: `wedding-management-admin/` 目录

**小程序前端工作树（miniapp-dev 分支）**:
- 路径: `D:/2025-10-31/wedding-management-miniapp`
- 用途: 小程序前端开发
- 重点关注: `wedding-management-miniapp/` 目录

---

## 三、常用操作

### 3.1 查看 Worktree 列表

```bash
cd D:/2025-10-31/wedding-management
git worktree list
```

### 3.2 切换到不同的工作树

**后端开发**:
```bash
cd D:/2025-10-31/wedding-management-backend
# 现在在 backend-dev 分支上工作
```

**管理前端开发**:
```bash
cd D:/2025-10-31/wedding-management-admin
# 现在在 admin-frontend-dev 分支上工作
```

**小程序前端开发**:
```bash
cd D:/2025-10-31/wedding-management-miniapp
# 现在在 miniapp-dev 分支上工作
```

### 3.3 添加新的 Worktree

```bash
cd D:/2025-10-31/wedding-management
git worktree add ../新目录名 分支名
```

### 3.4 移除 Worktree

```bash
cd D:/2025-10-31/wedding-management
git worktree remove ../目录名
```

### 3.5 清理已删除的 Worktree

```bash
cd D:/2025-10-31/wedding-management
git worktree prune
```

---

## 四、工作流程

### 4.1 开发流程

1. **选择对应的工作树目录**
   - 后端开发 → `wedding-management-backend`
   - 管理前端开发 → `wedding-management-admin`
   - 小程序前端开发 → `wedding-management-miniapp`

2. **在工作树中开发**
   - 正常进行代码修改
   - 提交更改到对应分支
   - 推送到远端

3. **合并到主分支**
   - 在主工作树（wedding-management）中
   - 切换到 main 分支
   - 合并对应的开发分支

### 4.2 注意事项

- ⚠️ 每个 worktree 都是独立的，修改不会自动同步
- ⚠️ 提交和推送需要在对应的工作树目录中进行
- ⚠️ 合并操作建议在主工作树中进行
- ⚠️ 删除 worktree 目录前，先使用 `git worktree remove` 命令

---

## 五、优势与限制

### 5.1 优势

- ✅ 可以同时在不同分支上工作，无需频繁切换
- ✅ 每个分支有独立的工作目录，互不干扰
- ✅ 可以并行开发多个功能模块
- ✅ 提高开发效率

### 5.2 限制

- ⚠️ Worktree 不能是主仓库的子目录
- ⚠️ 每个 worktree 包含完整的仓库内容（占用更多磁盘空间）
- ⚠️ 需要手动管理多个工作目录

---

## 六、维护建议

### 6.1 定期清理

- 定期检查未使用的 worktree
- 及时移除不再需要的 worktree
- 使用 `git worktree prune` 清理无效引用

### 6.2 同步更新

- 定期从远端拉取最新代码
- 保持各分支与远端同步
- 及时合并到主分支

---

## 七、操作记录

### 7.1 Worktree 创建记录

**日期**: 2025-01-06

**操作**: 创建三个 worktree 用于并行开发

**创建的 Worktree**:
1. `wedding-management-backend` → `backend-dev` 分支
2. `wedding-management-admin` → `admin-frontend-dev` 分支
3. `wedding-management-miniapp` → `miniapp-dev` 分支

### 7.2 Worktree 移除记录

**日期**: 2025-01-06

**操作**: 移除所有创建的 worktree

**移除的 Worktree**:
1. ✅ `wedding-management-backend` 已移除
2. ✅ `wedding-management-admin` 已移除
3. ✅ `wedding-management-miniapp` 已移除

**移除命令**:
```bash
git worktree remove ../wedding-management-backend
git worktree remove ../wedding-management-admin
git worktree remove ../wedding-management-miniapp
git worktree prune
```

**当前状态**: 仅保留主工作树（main 分支）

---

**最后更新**: 2025-01-06

