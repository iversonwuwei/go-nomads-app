# 🔐 登录测试指南

## ✅ 测试账户

### 账户 1: Sarah Chen
- **用户名**: `sarah_chen`
- **邮箱**: `sarah.chen@nomads.com`
- **密码**: `123456`
- **位置**: Bangkok, Thailand
- **统计**: 23个国家, 856天游牧

### 账户 2: Alex Wong
- **用户名**: `alex_wong`
- **邮箱**: `alex.wong@nomads.com`
- **密码**: `123456`
- **位置**: Lisbon, Portugal
- **统计**: 18个国家, 612天游牧

### 账户 3: Emma Silva
- **用户名**: `emma_silva`
- **邮箱**: `emma.silva@nomads.com`
- **密码**: `123456`
- **位置**: Mexico City, Mexico
- **统计**: 15个国家, 420天游牧

## 📝 登录步骤

1. **打开应用** - 启动 df_admin_mobile 应用
2. **进入登录页面** - 如果不在登录页面，导航到登录
3. **选择密码登录** - 点击"密码登录"标签
4. **输入凭证**:
   - 第一个输入框（标签：手机号码）：输入 `sarah_chen` 或 `sarah.chen@nomads.com`
   - 第二个输入框（密码）：输入 `123456`
5. **点击登录按钮** - LOGIN
6. **查看结果**:
   - ✅ **成功**: 显示"欢迎回来！"提示，跳转到主页
   - ❌ **失败**: 显示"手机号或密码错误"提示，**不跳转**，停留在登录页面

## 🧪 测试场景

### 场景 1: 使用用户名登录 ✅
- 输入: `sarah_chen` / `123456`
- 预期: 登录成功，跳转到主页

### 场景 2: 使用邮箱登录 ✅
- 输入: `sarah.chen@nomads.com` / `123456`
- 预期: 登录成功，跳转到主页

### 场景 3: 错误的密码 ❌
- 输入: `sarah_chen` / `wrong_password`
- 预期: 显示"手机号或密码错误"，**不跳转**

### 场景 4: 不存在的用户 ❌
- 输入: `nonexistent_user` / `123456`
- 预期: 显示"手机号或密码错误"，**不跳转**

### 场景 5: 空输入 ❌
- 输入: ` ` / ` `
- 预期: 显示验证错误，**不跳转**

## 🔍 验证登录状态

### 方法 1: 查看 Profile 页面
1. 登录成功后
2. 导航到 Profile 页面（底部导航栏）
3. 查看显示的用户信息：
   - 应显示登录用户的真实数据（如 Sarah Chen）
   - 而不是示例数据（Alex Chen）

### 方法 2: 查看控制台日志
登录成功后，控制台应显示：
```
✅ 用户登录成功: ID=1, 用户名=sarah_chen
✅ 已加载用户资料: sarah_chen
```

登录失败时，控制台不会有这些日志。

## ⚠️ 注意事项

1. **输入框标签**: 虽然显示为"手机号码"，但实际上可以输入：
   - 用户名（如 `sarah_chen`）
   - 邮箱（如 `sarah.chen@nomads.com`）
   - 手机号（如果数据库有的话）

2. **密码**: 所有测试账户的密码都是 `123456`

3. **验证码登录**: 目前仅支持密码登录，验证码登录为演示功能

4. **第三方登录**: 微信、Apple、Facebook登录为演示功能

## 🐛 常见问题

### Q: 输入正确的用户名和密码但提示错误？
A: 检查输入是否有空格，确保使用正确的用户名格式（小写字母加下划线）

### Q: 登录后 Profile 还是显示示例数据？
A: 检查控制台是否有"✅ 用户登录成功"日志，如果没有说明登录未成功

### Q: 应用重启后需要重新登录？
A: 是的，当前版本未实现持久化存储，应用重启后需要重新登录

## 📊 数据库表结构

### user_accounts 表
- `id`: 主键
- `email`: 邮箱（唯一）
- `username`: 用户名（唯一）
- `password`: 密码（明文存储，仅用于测试）
- `created_at`: 创建时间
- `updated_at`: 更新时间

### user_profiles 表
- `account_id`: 外键关联 user_accounts
- `name`: 显示名称
- `bio`: 个人简介
- `avatar_url`: 头像URL
- `current_city`: 当前城市
- `current_country`: 当前国家
- `skills`: 技能（JSON数组）
- `interests`: 兴趣（JSON数组）
- `social_links`: 社交链接（JSON对象）
- `badges`: 徽章（JSON数组）
- `countries_visited`: 访问国家数
- `cities_lived`: 居住城市数
- `days_nomading`: 游牧天数
- `meetups_attended`: 参加聚会数
- `trips_completed`: 完成旅行数
- `travel_history`: 旅行历史（JSON数组）
- `joined_date`: 加入日期
- `is_verified`: 是否验证

## 🚀 下一步优化

- [ ] 添加"记住我"功能（使用 shared_preferences）
- [ ] 实现状态持久化
- [ ] 添加密码加密存储
- [ ] 实现验证码登录真实功能
- [ ] 添加第三方登录集成
- [ ] 添加登出功能UI
- [ ] 实现忘记密码流程
- [ ] 添加注册功能
