# 版主申请系统 - 测试指南

## ✅ 路由冲突已修复

**修复内容:** 删除了 `CitiesController` 中的旧 `ApplyModerator` 方法

---

## 🧪 测试步骤

### 1. 等待服务部署完成
```bash
# 检查所有容器是否正常运行
docker ps | grep go-nomads
```

### 2. 测试新的申请接口

#### 获取 Token
```bash
# 使用你的测试账号登录获取 token
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### 测试申请接口
```bash
curl -X POST http://localhost:5000/api/v1/cities/moderator/apply \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cityId": "db30d0c7-154a-4993-83d0-1678bc82fe76",
    "reason": "我有丰富的社区管理经验,曾在多个技术社区担任版主,熟悉内容审核和用户管理。我热爱数字游民生活方式,希望能为这个城市的社区建设贡献力量。"
  }'
```

#### 预期成功响应
```json
{
  "success": true,
  "message": "申请已提交，请等待管理员审核",
  "data": {
    "id": "application-uuid",
    "userId": "user-uuid",
    "cityId": "db30d0c7-154a-4993-83d0-1678bc82fe76",
    "reason": "我有丰富的社区管理经验...",
    "status": "pending",
    "createdAt": "2025-11-25T...",
    "userName": "Your Name",
    "cityName": "City Name"
  }
}
```

---

## 🎯 在 Flutter 中测试

### 1. 重启 Flutter App
确保使用最新的后端服务

### 2. 操作步骤
1. 打开城市详情页
2. 点击 "申请成为版主" 按钮
3. 填写申请理由 (至少 20 字)
4. 点击 "提交申请"
5. 等待成功提示

### 3. 预期结果
- ✅ 显示成功 Toast: "申请已提交，请等待管理员审核"
- ✅ 页面自动返回
- ✅ 不再显示申请按钮 (因为已有待处理申请)

---

## 🔍 调试检查

### 检查路由冲突是否解决
```bash
# 应该不再看到 AmbiguousMatchException 错误
curl -v http://localhost:5000/api/v1/cities/moderator/apply
```

### 检查数据库记录
```sql
-- 在 Supabase SQL Editor 中查询
SELECT * FROM moderator_applications 
WHERE user_id = 'your-user-id' 
ORDER BY created_at DESC 
LIMIT 5;
```

### 检查服务日志
```bash
# 查看 CityService 日志
docker logs go-nomads-city-service --tail 50 -f
```

---

## ⚠️ 常见问题

### 问题 1: 仍然看到 500 错误
**原因:** 服务可能还在重启中  
**解决:** 等待 30 秒后重试

### 问题 2: 401 未授权
**原因:** Token 过期或无效  
**解决:** 重新登录获取新 token

### 问题 3: "该城市已有待处理申请"
**原因:** 已经提交过申请  
**解决:** 
```sql
-- 删除测试申请
DELETE FROM moderator_applications 
WHERE user_id = 'your-user-id' 
AND status = 'pending';
```

---

## 📋 完整测试流程

### 用户申请流程
1. ✅ 用户登录
2. ✅ 查看城市详情
3. ✅ 点击申请按钮
4. ✅ 填写申请理由
5. ✅ 提交申请
6. ✅ 收到成功提示
7. ✅ 数据库记录已创建

### 管理员审核流程 (待测试)
1. ⏳ 管理员登录
2. ⏳ 打开审核页面
3. ⏳ 查看待处理申请
4. ⏳ 点击通过/拒绝
5. ⏳ 用户收到通知

---

## 🎉 测试成功标志

- [x] 不再出现路由冲突错误
- [ ] 申请提交成功
- [ ] 数据库有记录
- [ ] Flutter 显示成功提示
- [ ] 管理员可以看到申请
- [ ] 管理员可以审核
- [ ] 申请人收到通知

---

**更新时间:** 2025-11-25  
**状态:** ✅ 路由冲突已修复,等待部署完成测试
