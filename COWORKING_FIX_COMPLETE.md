# Coworking 城市数据修复完成

## 问题描述
Coworking home 页面显示 Bali 有 1 个空间,但在列表页面中没有数据,这是因为数据库中城市ID映射错误。

## 根本原因
1. **数据库城市顺序**: database_initializer.dart 中城市按以下顺序插入:
   - ID 1 = Bangkok
   - ID 2 = Chiang Mai  
   - ID 3 = Canggu
   - ID 4 = Tokyo
   - ID 5 = Seoul
   - ID 6 = Lisbon
   - ID 7 = Mexico City
   - ID 8 = Singapore

2. **错误的 coworking 数据**:
   - ❌ Punspace 设置为 city_id=1 (Bangkok) → 应该是 Chiang Mai (ID=2)
   - ❌ Hubud 设置为 city_id=2 (Chiang Mai) → 应该是 Canggu (ID=3)  
   - ❌ Second Home Lisboa 设置为 city_id=3 (Canggu) → 应该是 Lisbon (ID=6)

3. **错误的控制器映射**: coworking_controller.dart 中城市ID映射也不正确

## 修复内容

### 1. database_initializer.dart
修正了 coworking_spaces 数据的 city_id:
- ✅ Punspace → city_id: 2 (Chiang Mai)
- ✅ Hubud → city_id: 3 (Canggu)
- ✅ Second Home Lisboa → city_id: 6 (Lisbon)

### 2. coworking_controller.dart  
修正了 `_getCityNameById()` 方法中的城市ID映射:
```dart
const cityMap = {
  1: 'Bangkok',      // 修正
  2: 'Chiang Mai',   // 修正
  3: 'Canggu',       // 修正
  4: 'Tokyo',
  5: 'Seoul',
  6: 'Lisbon',       // 修正
  7: 'Mexico City',
  8: 'Singapore',
};
```

### 3. main.dart
添加了强制重置数据库的参数:
```dart
await dbInitializer.initializeDatabase(forceReset: true);
```

### 4. database_initializer.dart
新增 `forceReset` 参数,支持清空并重新初始化数据库

## 如何使用

### ✅ 当前设置: forceReset = false (推荐)
数据库已设置为正常模式,只在首次运行时初始化,不会清空现有数据。

**首次运行时数据库会重新初始化**,之后的运行会保留数据:
```bash
flutter run
```

### 如果需要重置数据库
如果将来需要清空并重新初始化数据库,可以临时修改 `main.dart`:
```dart
// 临时设置为 true 重置数据
await dbInitializer.initializeDatabase(forceReset: true);
```
重置完成后记得改回 `false`。

## 预期结果
重新运行 app 后:
- ✅ Chiang Mai: 显示 1 个空间 (Punspace)
- ✅ Canggu: 显示 1 个空间 (Hubud)  
- ✅ Lisbon: 显示 1 个空间 (Second Home Lisboa)
- ✅ 其他城市: 不显示(coworking count = 0)
- ✅ Home 页面和 List 页面数据完全一致

## 注意事项
1. **forceReset: true** 会清空所有数据,包括用户、城市、meetups等
2. 修复完成后,建议将 `forceReset` 改为 `false`,避免每次启动都重置
3. 城市ID映射必须与 database_initializer.dart 中的插入顺序保持一致

## 测试步骤
1. 停止当前运行的 app
2. 重新运行 `flutter run`
3. 打开 Coworking home 页面,检查城市数量和名称
4. 点击每个城市卡片,验证列表页面显示正确的空间数据
5. 确认数量匹配

---
修复时间: 2025-10-15
修复文件: 
- lib/services/database_initializer.dart
- lib/controllers/coworking_controller.dart
- lib/main.dart
