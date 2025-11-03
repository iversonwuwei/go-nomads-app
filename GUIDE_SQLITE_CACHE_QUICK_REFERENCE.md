# Guide SQLite 缓存 - 快速参考

## 🎯 核心功能

### 1. 切换城市清除旧数据
```dart
// city_detail_controller.dart - loadCityData()
guide.value = null; // ✅ 防止显示旧城市的指南
```

### 2. 加载时优先读取缓存
```dart
// 自动调用 _loadGuideFromCache()
final cachedGuideJson = await dbService.loadGuide(currentCityId.value);
if (cachedGuideJson != null) {
  guide.value = DigitalNomadGuide.fromJson(cachedGuideJson);
}
```

### 3. 生成成功后自动保存
```dart
// generateGuideWithAIAsync() 中
guide.value = DigitalNomadGuide.fromJson(guideData);
await dbService.saveGuide(guideData); // 💾 覆盖旧数据
```

---

## 📊 数据库表

```sql
CREATE TABLE digital_nomad_guides (
  city_id TEXT NOT NULL UNIQUE,  -- 主键
  city_name TEXT NOT NULL,
  overview TEXT,
  best_areas TEXT,              -- JSON 数组
  visa_info TEXT,               -- JSON 对象
  workspace_recommendations TEXT,
  tips TEXT,
  essential_info TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

---

## 🛠️ API 方法

### DatabaseService

```dart
// 保存或覆盖 (使用 REPLACE 策略)
await dbService.saveGuide(guideJson);

// 加载
final guideJson = await dbService.loadGuide(cityId);

// 删除
await dbService.deleteGuide(cityId);
```

---

## 🔄 数据流

```
进入城市详情
    ↓
清除旧 guide (guide.value = null)
    ↓
从 SQLite 加载缓存
    ├─ 有缓存 → 显示内容
    └─ 无缓存 → 显示"生成"按钮
            ↓
        用户点击生成
            ↓
        AI 异步任务
            ↓
        生成成功 → 保存到 SQLite (覆盖)
            ↓
        显示新内容
```

---

## 🧪 测试场景

| 场景 | 预期行为 | 日志关键词 |
|------|----------|-----------|
| 首次访问城市 | 显示生成按钮 | `SQLite 中无缓存` |
| 重新访问已生成 | 立即显示缓存 | `从 SQLite 加载缓存` |
| 切换城市 | 清除旧数据 | `guide.value = null` |
| 重新生成 | 覆盖旧指南 | `Guide 已保存到 SQLite` |

---

## 📝 关键日志

```
✅ 已从 SQLite 加载缓存的 Guide: cityId=xxx
ℹ️ SQLite 中无缓存,等待用户手动生成
💾 Guide 已保存到 SQLite 缓存
⚠️ 保存到 SQLite 失败,但不影响显示: xxx
```

---

## 🔧 故障排查

### Q: 切换城市后还显示旧指南?
**A**: 检查 `loadCityData()` 是否正确执行 `guide.value = null`

### Q: 缓存不生效?
**A**: 
1. 检查数据库版本是否升级到 6
2. 查看日志是否有 `💾 Guide 已保存到 SQLite`
3. 确认 `cityId` 参数正确

### Q: 数据解析失败?
**A**: 检查 `city_detail_model.dart` 的 `fromJson()` 是否支持 PascalCase 字段

---

## 📂 相关文件

- `lib/services/database_service.dart` - 数据库服务
- `lib/controllers/city_detail_controller.dart` - Controller
- `lib/models/city_detail_model.dart` - 数据模型
- `GUIDE_SQLITE_CACHE.md` - 详细文档

---

**数据库版本**: 6  
**表名**: `digital_nomad_guides`  
**唯一键**: `city_id`
