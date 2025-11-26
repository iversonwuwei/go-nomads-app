# City Detail 指南 Tab AI 生成与本地缓存完整实现

## 概述
完整实现了 city detail 页面指南 tab 的 AI 生成、SSE 流式推送和本地 sqlite 持久化功能。

## 实现功能

### 1. 本地持久化 (SQLite)
**文件**: `lib/services/database/digital_nomad_guide_dao.dart`
- 创建了 `DigitalNomadGuideDao` 用于管理城市指南的本地存储
- 支持完整的 CRUD 操作：
  - `saveGuide()`: 保存或更新指南
  - `getGuide()`: 根据城市ID获取指南
  - `hasGuide()`: 检查指南是否存在
  - `deleteGuide()`: 删除指定城市指南
  - `isGuideExpired()`: 检查指南是否过期（默认30天）
  - `deleteExpiredGuides()`: 批量删除过期指南
- 包含索引优化以加速查询

### 2. 流式 SSE 数据获取
**文件**: 
- `lib/services/http_service.dart`
- `lib/features/ai/infrastructure/repositories/ai_repository.dart`

#### HttpService 新增功能
- 添加 `getServerSentEvents()` 方法支持 SSE 流
- 自动处理认证 token 和用户 ID headers
- 解析 `data:` 格式的 SSE 事件流

#### AiRepository 实现
- 完整实现 `generateDigitalNomadGuideStream()`
- 支持的事件类型：
  - `start`: 开始生成
  - `progress`: 进度更新（消息 + 百分比）
  - `success`: 生成完成（包含完整指南数据）
  - `error`: 生成失败
- 自动解析后端返回的 JSON 数据并转换为领域实体

### 3. 本地缓存优先策略
**文件**: `lib/features/ai/presentation/controllers/ai_state_controller.dart`

#### 新增状态管理
- `isLoadingGuide`: 从本地加载中
- `isGuideFromCache`: 是否来自缓存

#### 核心方法
**`loadCityGuide()`** - 智能加载策略
```dart
流程:
1. 优先从 sqlite 读取本地缓存
2. 检查缓存是否过期（默认30天）
3. 缓存有效 → 直接返回
4. 缓存无效/不存在 → 调用 SSE 流式生成
5. 生成成功后自动保存到 sqlite
```

**`generateDigitalNomadGuideStream()`** - 流式生成
- 实时更新进度和消息
- 生成完成后自动保存到本地
- 错误处理和状态重置

**辅助方法**
- `deleteCachedGuide()`: 删除指定城市的本地指南
- `clearAllCachedGuides()`: 清空所有本地指南

### 4. UI 优化
**文件**: `lib/pages/city_detail_page.dart`

#### `_buildGuideTab()` 更新
- 页面加载时自动调用 `loadCityGuide()` 优先从本地读取
- 区分加载状态和生成状态的 UI 提示
- 显示实时进度信息（消息 + 百分比）

#### `_buildGuideContent()` 优化
- 添加缓存状态显示卡片
  - 本地缓存：蓝色背景 + 离线图标
  - 最新生成：绿色背景 + 云端图标
- 一键刷新按钮（强制重新生成）
- 保留所有原有的指南内容展示

### 5. 数据库表结构
**文件**: `lib/services/database_service.dart`

更新 `digital_nomad_guides` 表结构：
```sql
CREATE TABLE digital_nomad_guides (
  city_id TEXT PRIMARY KEY,
  city_name TEXT NOT NULL,
  overview TEXT NOT NULL,
  visa_info TEXT NOT NULL,
  best_areas TEXT NOT NULL,
  workspace_recommendations TEXT NOT NULL,
  tips TEXT NOT NULL,
  essential_info TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
```

索引：
- `idx_guides_city_id`: 按城市ID索引
- `idx_guides_updated_at`: 按更新时间倒序索引

## 数据流程

### 用户首次访问指南 Tab
```
1. 用户点击指南 tab
2. 自动调用 loadCityGuide()
3. 检查 sqlite 本地缓存
4. 无缓存 → 调用 SSE 流式生成
5. 显示实时进度（消息 + 百分比）
6. 生成完成 → 自动保存到 sqlite
7. 显示指南内容（标记为"最新生成"）
```

### 用户再次访问指南 Tab
```
1. 用户点击指南 tab
2. 自动调用 loadCityGuide()
3. 检查 sqlite 本地缓存
4. 有缓存且未过期 → 直接加载
5. 显示指南内容（标记为"本地缓存"）
6. 用户可点击"刷新"强制重新生成
```

### 用户主动刷新
```
1. 用户点击"刷新"按钮
2. 调用 loadCityGuide(forceRefresh: true)
3. 跳过本地缓存检查
4. 直接调用 SSE 流式生成
5. 显示实时进度
6. 生成完成 → 覆盖本地缓存
7. 显示更新后的指南内容
```

## 技术特性

### 错误处理
- SSE 连接失败自动重试机制
- 解析错误不中断整个流，继续处理下一个事件
- 保存失败不影响主流程，仅记录日志
- UI 层显示友好的错误提示

### 性能优化
- 本地缓存优先，减少网络请求
- 索引优化加速数据库查询
- 流式生成提供实时反馈
- 自动过期清理避免数据冗余

### 日志追踪
所有关键步骤都有详细日志输出：
- `✅` 成功操作
- `⚠️` 警告信息
- `❌` 错误信息
- `🔄` SSE 事件
- `📡` 网络请求
- `📖` 本地加载

## 后端 API 要求

### SSE 流式接口
**端点**: `POST /ai/digital-nomad-guide/stream`

**请求体**:
```json
{
  "cityId": "string",
  "cityName": "string"
}
```

**SSE 事件格式**:
```
data: {"type": "start"}

data: {"type": "progress", "data": {"message": "分析城市数据...", "progress": 20}}

data: {"type": "success", "data": { /* DigitalNomadGuide JSON */ }}

data: {"type": "error", "data": {"message": "生成失败原因"}}
```

### DigitalNomadGuide JSON 结构
```json
{
  "cityId": "string",
  "cityName": "string",
  "overview": "string",
  "visaInfo": {
    "type": "string",
    "duration": 0,
    "requirements": "string",
    "cost": 0.0,
    "process": "string"
  },
  "bestAreas": [
    {
      "name": "string",
      "description": "string",
      "entertainmentScore": 0.0,
      "entertainmentDescription": "string",
      "tourismScore": 0.0,
      "tourismDescription": "string",
      "economyScore": 0.0,
      "economyDescription": "string",
      "cultureScore": 0.0,
      "cultureDescription": "string"
    }
  ],
  "workspaceRecommendations": ["string"],
  "tips": ["string"],
  "essentialInfo": {
    "key": "value"
  }
}
```

## 测试要点

1. **本地缓存读取**
   - 首次访问应触发 AI 生成
   - 再次访问应从本地加载
   - 缓存状态正确显示

2. **强制刷新**
   - 点击刷新按钮应重新生成
   - 本地缓存应被覆盖
   - 状态标记更新为"最新生成"

3. **SSE 流式推送**
   - 进度消息实时更新
   - 百分比正确显示
   - 最终结果正确渲染

4. **错误处理**
   - 网络错误有友好提示
   - 解析错误不崩溃
   - 保存失败不影响显示

5. **缓存过期**
   - 30天后自动重新生成
   - 过期指南可被清理

## 文件清单

### 新增文件
- `lib/services/database/digital_nomad_guide_dao.dart`

### 修改文件
- `lib/services/http_service.dart` - 添加 SSE 支持
- `lib/services/database_service.dart` - 更新表结构
- `lib/features/ai/infrastructure/repositories/ai_repository.dart` - 实现流式生成
- `lib/features/ai/presentation/controllers/ai_state_controller.dart` - 本地缓存优先
- `lib/pages/city_detail_page.dart` - UI 优化

## 未来优化建议

1. **智能预加载**: 用户浏览城市列表时预加载热门城市指南
2. **差量更新**: 仅更新变化的部分而非整体重新生成
3. **离线模式**: 完全离线也能查看已缓存的指南
4. **用户反馈**: 允许用户对指南内容进行评分和反馈
5. **多语言支持**: 根据用户语言偏好生成不同语言的指南
6. **个性化推荐**: 基于用户兴趣和历史调整指南内容

## 完成时间
2025年11月11日

## 开发者
GitHub Copilot
