# 数字游民指南 SQLite 缓存实现

## 📋 需求
1. **切换城市时清除旧指南**: 防止显示之前城市的指南数据
2. **SQLite 缓存机制**: 
   - 生成成功后保存到本地数据库
   - 使用 `cityId` 作为唯一标识
   - 新生成会覆盖旧数据
   - 页面加载时优先从缓存读取

---

## 🛠️ 实现步骤

### 1. 数据库表设计 (database_service.dart)

#### 新增表: `digital_nomad_guides`
```sql
CREATE TABLE digital_nomad_guides (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  city_id TEXT NOT NULL UNIQUE,          -- 城市ID (唯一标识)
  city_name TEXT NOT NULL,
  overview TEXT,                         -- 概览
  best_areas TEXT,                       -- 最佳区域 (JSON 数组)
  visa_info TEXT,                        -- 签证信息 (JSON 对象)
  workspace_recommendations TEXT,        -- 工作空间推荐 (JSON 数组)
  tips TEXT,                            -- 实用建议 (JSON 数组)
  essential_info TEXT,                  -- 必要信息 (JSON 对象)
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

#### 索引
```sql
CREATE INDEX idx_guides_city ON digital_nomad_guides(city_id);
```

---

### 2. CRUD 方法 (DatabaseService)

#### `saveGuide(Map<String, dynamic> guideJson)`
- 支持 PascalCase 和 camelCase 字段
- 使用 `ConflictAlgorithm.replace` 实现覆盖
- 自动序列化复杂字段 (List, Map)

#### `loadGuide(String cityId)`
- 根据 cityId 查询
- 反序列化 JSON 字段
- 返回 camelCase 格式的 Map

#### `deleteGuide(String cityId)`
- 删除指定城市的指南

---

### 3. Controller 修改 (city_detail_controller.dart)

#### 问题1修复: 切换城市时清除旧指南
```dart
Future<void> loadCityData() async {
  // ✅ 切换城市时,清除旧的 guide 数据
  guide.value = null;
  
  isLoading.value = true;
  // ...其他加载逻辑
}
```

#### 问题2实现: SQLite 缓存机制

**加载阶段** (页面初始化):
```dart
Future<void> _loadGuideFromCache() async {
  if (currentCityId.value.isEmpty) return;

  try {
    final dbService = DatabaseService();
    final cachedGuideJson = await dbService.loadGuide(currentCityId.value);

    if (cachedGuideJson != null) {
      guide.value = DigitalNomadGuide.fromJson(cachedGuideJson);
      print('✅ 已从 SQLite 加载缓存的 Guide');
    } else {
      print('ℹ️ SQLite 中无缓存,等待用户手动生成');
    }
  } catch (e) {
    print('❌ 从 SQLite 加载失败: $e');
    // 失败不影响页面加载
  }
}
```

**生成阶段** (AI 生成成功后):
```dart
// 解析 Guide 数据
guide.value = DigitalNomadGuide.fromJson(guideData);

// 💾 保存到 SQLite (使用 cityId 作为唯一标识)
try {
  final dbService = DatabaseService();
  await dbService.saveGuide(guideData);
  print('💾 Guide 已保存到 SQLite 缓存');
} catch (e) {
  print('⚠️ 保存到 SQLite 失败,但不影响显示: $e');
}
```

---

## 📊 数据流程

```
┌─────────────────────────────────────────────────────────────┐
│                      用户进入城市详情                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
              ┌────────────────┐
              │  清除旧 guide   │ ← 问题1修复
              │ guide.value=null│
              └────────┬───────┘
                       │
                       ▼
              ┌────────────────────┐
              │ 从 SQLite 加载缓存  │ ← 问题2实现
              └────────┬───────────┘
                       │
            ┌──────────┴──────────┐
            │                     │
         有缓存                 无缓存
            │                     │
            ▼                     ▼
     ┌──────────┐         ┌────────────┐
     │ 显示指南  │         │ 显示生成按钮│
     └──────────┘         └──────┬─────┘
                                 │
                          用户点击"生成"
                                 │
                                 ▼
                     ┌───────────────────┐
                     │  AI 异步任务生成   │
                     └───────┬───────────┘
                             │
                          生成成功
                             │
                             ▼
                  ┌──────────────────────┐
                  │  保存到 SQLite        │ ← 问题2实现
                  │ (覆盖旧数据 if exists)│
                  └──────────┬───────────┘
                             │
                             ▼
                      ┌──────────────┐
                      │   显示指南    │
                      └──────────────┘
```

---

## ✅ 测试验证

### 场景1: 首次访问城市
1. 进入城市详情页 → Guide Tab
2. 预期: 显示"Generate Digital Nomad Guide"按钮
3. 点击生成 → 成功后显示内容
4. 日志: `💾 Guide 已保存到 SQLite 缓存`

### 场景2: 重新访问相同城市
1. 返回城市列表
2. 重新进入同一城市 → Guide Tab
3. 预期: **立即显示缓存的指南**(无需重新生成)
4. 日志: `✅ 已从 SQLite 加载缓存的 Guide`

### 场景3: 切换到不同城市
1. 从城市A切换到城市B
2. 预期: **城市A的指南消失**,显示城市B的数据或生成按钮
3. 日志: 
   - 进入时: `guide.value = null` (清除)
   - 如果B有缓存: `✅ 已从 SQLite 加载缓存`
   - 如果B无缓存: `ℹ️ SQLite 中无缓存,等待用户手动生成`

### 场景4: 重新生成指南
1. 在已有指南的城市点击"AI 重新生成"
2. 生成新内容成功
3. 预期: **新指南覆盖旧指南**(SQLite 中的记录被 REPLACE)
4. 日志: `💾 Guide 已保存到 SQLite 缓存`
5. 下次访问应显示新内容

---

## 🔧 技术细节

### 字段命名兼容性
- **后端返回**: PascalCase (`CityId`, `Overview`, `BestAreas`)
- **前端模型**: camelCase (`cityId`, `overview`, `bestAreas`)
- **数据库存储**: snake_case (`city_id`, `overview`, `best_areas`)

### 数据序列化
- **复杂类型** (List, Map) 存储为 JSON 字符串
- **读取时自动反序列化**为 Dart 对象
- **兼容两种命名风格**:
  ```dart
  'city_id': guideJson['cityId'] ?? guideJson['CityId']
  ```

### 数据库版本升级
- **当前版本**: 6
- **升级逻辑**: `_onUpgrade()` 中判断 `oldVersion < 6`
- **向后兼容**: 使用 `CREATE TABLE IF NOT EXISTS`

---

## 📝 修改文件清单

1. **database_service.dart**
   - ✅ 升级版本到 6
   - ✅ 创建 `digital_nomad_guides` 表
   - ✅ 添加 `saveGuide()` 方法
   - ✅ 添加 `loadGuide()` 方法
   - ✅ 添加 `deleteGuide()` 方法
   - ✅ 添加序列化/反序列化辅助方法

2. **city_detail_controller.dart**
   - ✅ 导入 `DatabaseService`
   - ✅ 修改 `loadCityData()` - 清除旧 guide
   - ✅ 新增 `_loadGuideFromCache()` - 从 SQLite 加载
   - ✅ 修改 `generateGuideWithAIAsync()` - 保存到 SQLite

---

## 🚀 后续优化建议

1. **性能优化**
   - 考虑添加内存缓存 (避免频繁读取 SQLite)
   - 批量预加载热门城市的指南

2. **用户体验**
   - 显示指南的生成时间 (from `updated_at`)
   - 提供"刷新指南"功能 (主动重新生成)
   - 缓存过期策略 (例如30天自动过期)

3. **数据管理**
   - 添加清除所有缓存的功能 (设置页面)
   - 显示缓存占用空间
   - 导出/导入指南数据

---

## 📚 相关文档
- `AI_TRAVEL_GUIDE_IMPLEMENTATION.md` - Guide 功能实现总览
- `ASYNC_TASK_QUEUE_IMPLEMENTATION.md` - 异步队列实现
- `city_detail_model.dart` - 数据模型定义

---

**✅ 实现完成时间**: 2025-11-03
**🔧 数据库版本**: 6
**📦 涉及表**: `digital_nomad_guides`
