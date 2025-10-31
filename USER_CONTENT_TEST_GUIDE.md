# 用户城市内容 API 集成测试指南

## ✅ 已完成的工作

### 1. 数据库迁移
- ✅ 已在 Supabase 控制台手动执行
- 创建的表:
  - `user_city_photos` - 用户照片
  - `user_city_expenses` - 用户开支
  - `user_city_reviews` - 用户评价

### 2. 后端 API (CityService)
- ✅ 15 个 API 端点已部署
- 运行地址: `http://localhost:8002`
- 主要端点:
  - GET `/api/city/{cityId}/photos` - 获取城市照片
  - GET `/api/city/{cityId}/expenses` - 获取城市开支
  - GET `/api/city/{cityId}/reviews` - 获取城市评价
  - POST `/api/city/{cityId}/photos` - 添加照片
  - POST `/api/city/{cityId}/expenses` - 添加开支
  - POST `/api/city/{cityId}/reviews` - 添加评价

### 3. 前端集成 (Flutter)
- ✅ `CityDetailController` 增强
- ✅ `city_detail_page.dart` 三个标签页集成:
  - **Photos 标签**: 显示真实用户照片 + 模拟数据
  - **Reviews 标签**: 显示真实用户评价 + 模拟数据
  - **Cost 标签**: 显示社区开支 + 原始成本数据

---

## 🧪 测试步骤

### 准备工作
1. **确认后端服务运行中**:
   ```bash
   cd /Users/walden/Workspaces/WaldenProjects/go-noma/deployment
   ./deploy-services-local.sh
   ```
   验证: `curl http://localhost:8002/health`

2. **Flutter 应用已启动**:
   - 当前正在启动: `http://localhost:8080`
   - 等待浏览器自动打开

---

### 测试场景 1: Photos 标签 📷

#### 步骤:
1. 在应用中导航到任意城市详情页 (如: Chiang Mai)
2. 点击 **Photos** 标签
3. **验证内容**:
   - ✅ 应该看到网格布局的照片
   - ✅ 真实用户照片(如有)会显示在前面,带用户图标标记
   - ✅ 模拟照片数据显示在后面
   - ✅ 下拉刷新功能(向下拖动列表)

#### 测试操作:
4. **查看照片详情**:
   - 点击任意真实用户照片
   - 应该弹出对话框,显示:
     - 完整照片
     - 标题和描述
     - 位置信息
     - 上传日期(格式化的相对时间)

5. **添加照片**:
   - 点击右下角的 "+" 浮动按钮
   - 选择 "Share Photo"
   - 选择图片来源(Camera / Gallery)
   - ⚠️ **当前状态**: 使用占位符 URL (临时实现)
   - ✅ 应该调用 API 并刷新照片列表

6. **下拉刷新**:
   - 在照片列表顶部向下拖动
   - 应该显示加载指示器
   - 重新加载照片数据

---

### 测试场景 2: Reviews 标签 ⭐

#### 步骤:
1. 切换到 **Reviews** 标签
2. **验证内容**:
   - ✅ 应该看到评价列表
   - ✅ 真实用户评价显示在前面
     - 用户头像(显示 User ID 首字母)
     - 用户名称: "User {id}"
     - 评分星星
     - 标题和内容
     - 格式化的日期("Today", "2 days ago" 等)
   - ✅ 模拟评价数据显示在后面

#### 测试操作:
3. **添加评价**:
   - 点击右下角的 "+" 浮动按钮
   - 选择 "Share Review"
   - 填写评价表单:
     - 评分(星星)
     - 标题
     - 内容
     - (可选)上传照片
   - 提交后应该:
     - ✅ 调用 API 创建评价
     - ✅ 自动刷新评价列表
     - ✅ 显示成功提示

4. **下拉刷新**:
   - 在评价列表顶部向下拖动
   - 重新加载评价数据

---

### 测试场景 3: Cost 标签 💰

#### 步骤:
1. 切换到 **Cost** 标签
2. **验证内容**:
   - ✅ 顶部显示原始成本数据(如果有)
     - 总成本
     - 成本分项
   - ✅ 分隔线
   - ✅ **Community Expenses** 部分
     - 真实用户开支列表
     - 每条开支显示:
       - 分类图标(带颜色背景)
       - 分类名称
       - 描述和日期
       - 金额(带货币符号)

#### 测试操作:
3. **验证分类图标**:
   - 🍽️ Food: 橙色 (restaurant icon)
   - 🚗 Transportation: 蓝色 (car icon)
   - 🏨 Accommodation: 紫色 (hotel icon)
   - 🎯 Activities: 绿色 (activity icon)
   - 🛍️ Shopping: 粉色 (shopping bag icon)
   - ⚪ Other: 灰色 (more_horiz icon)

4. **添加开支**:
   - 点击右下角的 "+" 浮动按钮
   - 选择 "Share Cost"
   - 填写开支表单:
     - 分类(下拉选择)
     - 金额
     - 描述
   - 提交后应该:
     - ✅ 调用 API 创建开支
     - ✅ 自动刷新开支列表
     - ✅ 显示成功提示

5. **下拉刷新**:
   - 在成本列表顶部向下拖动
   - 重新加载开支数据

---

## 🔍 验证 API 调用

### 使用浏览器开发者工具:
1. 打开 Chrome DevTools (F12)
2. 切换到 **Network** 标签
3. 过滤: `XHR` 或 `Fetch`
4. 执行上述测试操作,观察:
   - API 请求 URL
   - 请求方法 (GET/POST/DELETE)
   - 请求参数
   - 响应数据

### 预期的 API 调用:

#### 初始加载城市详情时:
```
GET http://localhost:8002/api/city/{cityId}/photos
GET http://localhost:8002/api/city/{cityId}/expenses
GET http://localhost:8002/api/city/{cityId}/reviews
GET http://localhost:8002/api/city/{cityId}/user-content-stats
```

#### 添加照片时:
```
POST http://localhost:8002/api/city/{cityId}/photos
Body: {
  "url": "https://via.placeholder.com/...",
  "caption": "...",
  "location": "..."
}
```

#### 添加评价时:
```
POST http://localhost:8002/api/city/{cityId}/reviews
Body: {
  "rating": 5,
  "title": "...",
  "content": "...",
  "photos": [...]
}
```

#### 添加开支时:
```
POST http://localhost:8002/api/city/{cityId}/expenses
Body: {
  "category": "Food",
  "amount": 100.00,
  "currency": "USD",
  "description": "..."
}
```

---

## ⚠️ 已知限制

### 1. 图片上传 (临时实现)
- **当前**: 使用占位符 URL (`https://via.placeholder.com/...`)
- **原因**: 实际图片上传需要 Supabase Storage 或 CDN 配置
- **位置**: `/lib/pages/city_detail_page.dart`, `_pickAndUploadImage()` 方法 (第 2050 行)
- **待办**: 实现真实的图片上传到 Supabase Storage

### 2. 用户认证
- **当前**: API 使用模拟的用户 ID
- **待办**: 集成真实的用户认证系统

---

## 📊 成功指标

如果以下功能都正常工作,说明集成成功:

✅ **Photos 标签**:
- [ ] 显示真实用户照片(如果数据库中有数据)
- [ ] 显示模拟照片
- [ ] 下拉刷新正常工作
- [ ] 点击照片显示详情对话框
- [ ] 添加照片调用 API(即使使用占位符 URL)

✅ **Reviews 标签**:
- [ ] 显示真实用户评价(如果数据库中有数据)
- [ ] 显示模拟评价
- [ ] 日期格式化正确("Today", "2 days ago" 等)
- [ ] 下拉刷新正常工作
- [ ] 添加评价后自动刷新列表

✅ **Cost 标签**:
- [ ] 显示原始成本数据
- [ ] 显示社区开支列表(如果数据库中有数据)
- [ ] 分类图标和颜色正确显示
- [ ] 下拉刷新正常工作
- [ ] 添加开支后自动刷新列表

✅ **API 调用**:
- [ ] Network 标签中能看到 API 请求
- [ ] 请求 URL 正确(`http://localhost:8002/api/city/...`)
- [ ] 响应状态码 200 或 201
- [ ] 响应数据符合预期格式

---

## 🐛 故障排除

### 问题 1: API 调用失败 (Network Error)
**检查**:
- CityService 是否运行? `curl http://localhost:8002/health`
- 端口 8002 是否被占用?
- CORS 配置是否正确?

**解决**:
```bash
cd /Users/walden/Workspaces/WaldenProjects/go-noma/deployment
./deploy-services-local.sh
```

### 问题 2: 没有显示真实数据
**检查**:
- 数据库中是否有数据? (在 Supabase 控制台查询)
- API 响应是否为空数组?

**解决**:
- 使用 "添加" 功能创建一些测试数据
- 或在 Supabase 控制台手动插入测试数据

### 问题 3: 下拉刷新不工作
**检查**:
- 控制台是否有错误?
- RefreshIndicator 是否正确包裹列表?

**解决**:
- 检查 `city_detail_page.dart` 中的 RefreshIndicator 配置
- 确保 `onRefresh` 回调正确调用 controller 方法

---

## 📝 后续工作

1. **实现真实图片上传**:
   - 配置 Supabase Storage bucket
   - 实现图片压缩和上传逻辑
   - 替换占位符 URL

2. **用户认证集成**:
   - 集成 Supabase Auth 或其他认证服务
   - 使用真实用户 ID 替代模拟 ID

3. **错误处理增强**:
   - 网络错误提示
   - 空状态优化
   - 加载状态优化

4. **性能优化**:
   - 图片懒加载
   - 列表分页
   - 缓存策略

---

## 🎉 总结

本次集成已完成:
- ✅ 数据库迁移(手动执行)
- ✅ 后端 API 部署(CityService)
- ✅ 前端三个标签页集成
- ✅ 下拉刷新功能
- ✅ 添加内容功能(照片/评价/开支)
- ✅ 所有代码零编译错误

**当前状态**: 应用已启动,可以开始测试! 🚀

浏览器应该会自动打开 `http://localhost:8080`
