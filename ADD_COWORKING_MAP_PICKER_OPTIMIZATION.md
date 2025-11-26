# 添加共享办公空间 - 地图选择位置功能优化

## 修改日期
2025-01-17

## 需求描述
在 `add_coworking_page.dart` 页面中，优化"在地图上选择位置"按钮的功能：
1. 用户点击按钮时，将地址字段的内容作为搜索关键词传递给地图组件
2. 地图组件根据地址自动进行POI搜索并定位
3. 用户可以在地图上自由选择位置
4. 用户点击确定后，**只更新名称字段**（共享办公空间名称），其他字段（地址、经纬度等）保持不变

## 修改内容

### 1. Flutter 层修改

#### 1.1 `add_coworking_page.dart`
**位置**: `_buildLocationPicker()` 方法 (约第787行)

**修改内容**:
```dart
onTap: () async {
  // 获取当前地址字段的内容作为搜索关键词
  final addressQuery = _addressController.text.trim();
  
  final result = await Get.to(() => AmapNativePickerPage(
    initialLatitude: _latitude != 0 ? _latitude : null,
    initialLongitude: _longitude != 0 ? _longitude : null,
    searchQuery: addressQuery.isNotEmpty ? addressQuery : null,
  ));
  
  if (result != null && result is Map<String, dynamic>) {
    setState(() {
      // 更新经纬度
      _latitude = result['latitude'] ?? 0.0;
      _longitude = result['longitude'] ?? 0.0;
      
      // 只更新名称字段（如果有POI名称的话）
      if (result['name'] != null && result['name'].toString().isNotEmpty) {
        _nameController.text = result['name'];
      }
    });
  }
}
```

**关键变化**:
- ✅ 传递 `searchQuery` 参数（地址字段内容）
- ✅ 只更新 `_nameController.text`（名称字段）
- ❌ 不再更新 `_addressController.text`（地址字段）

#### 1.2 `amap_native_picker_page.dart`
**修改1**: 添加 `searchQuery` 参数
```dart
class AmapNativePickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? searchQuery;  // 新增

  const AmapNativePickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.searchQuery,  // 新增
  });
```

**修改2**: 传递搜索关键词给原生服务
```dart
final result = await AmapNativeService.instance.openMapPicker(
  initialLatitude: widget.initialLatitude,
  initialLongitude: widget.initialLongitude,
  searchQuery: widget.searchQuery,  // 新增
);
```

#### 1.3 `amap_native_service.dart`
**修改1**: 添加 `searchQuery` 参数
```dart
Future<Map<String, dynamic>?> openMapPicker({
  double? initialLatitude,
  double? initialLongitude,
  String? searchQuery,  // 新增
}) async {
  // ...
  if (searchQuery != null && searchQuery.isNotEmpty) {
    arguments['searchQuery'] = searchQuery;
    print('🔍 搜索关键词: $searchQuery');
  }
  // ...
}
```

**修改2**: 返回结果中添加 `name` 字段
```dart
final convertedResult = {
  'latitude': result['latitude'] as double,
  'longitude': result['longitude'] as double,
  'address': result['address'] as String? ?? '',
  'name': result['name'] as String?,  // 新增
  'city': result['city'] as String?,
  'province': result['province'] as String?,
};
```

### 2. Android 原生层修改

#### 2.1 `MainActivity.kt`
**修改1**: 传递 `searchQuery` 参数给地图选择器
```kotlin
private fun openMapPicker(arguments: Any?, result: MethodChannel.Result) {
    pendingResult = result
    
    val intent = Intent(this, AmapMapPickerActivity::class.java)
    
    // 传递初始坐标和搜索关键词
    if (arguments is Map<*, *>) {
        val initialLat = arguments["initialLatitude"] as? Double
        val initialLng = arguments["initialLongitude"] as? Double
        val searchQuery = arguments["searchQuery"] as? String  // 新增
        
        if (initialLat != null && initialLng != null) {
            intent.putExtra(AmapMapPickerActivity.KEY_INITIAL_LATITUDE, initialLat)
            intent.putExtra(AmapMapPickerActivity.KEY_INITIAL_LONGITUDE, initialLng)
        }
        
        // 新增：传递搜索关键词
        if (searchQuery != null && searchQuery.isNotEmpty()) {
            intent.putExtra(AmapMapPickerActivity.KEY_SEARCH_QUERY, searchQuery)
        }
    }
    
    startActivityForResult(intent, MAP_PICKER_REQUEST_CODE)
}
```

**修改2**: 返回结果中添加 `name` 字段
```kotlin
override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    
    if (requestCode == MAP_PICKER_REQUEST_CODE) {
        if (resultCode == Activity.RESULT_OK && data != null) {
            val latitude = data.getDoubleExtra(AmapMapPickerActivity.KEY_RESULT_LATITUDE, 0.0)
            val longitude = data.getDoubleExtra(AmapMapPickerActivity.KEY_RESULT_LONGITUDE, 0.0)
            val address = data.getStringExtra(AmapMapPickerActivity.KEY_RESULT_ADDRESS) ?: ""
            val name = data.getStringExtra(AmapMapPickerActivity.KEY_RESULT_NAME) ?: ""  // 新增
            val city = data.getStringExtra(AmapMapPickerActivity.KEY_RESULT_CITY) ?: ""
            val province = data.getStringExtra(AmapMapPickerActivity.KEY_RESULT_PROVINCE) ?: ""
            
            val resultData = mapOf(
                "latitude" to latitude,
                "longitude" to longitude,
                "address" to address,
                "name" to name,  // 新增
                "city" to city,
                "province" to province
            )
            
            pendingResult?.success(resultData)
        }
        // ...
    }
}
```

#### 2.2 `AmapMapPickerActivity.kt`

**修改1**: 添加常量和变量
```kotlin
companion object {
    const val KEY_SEARCH_QUERY = "searchQuery"  // 新增
    const val KEY_RESULT_NAME = "name"  // 新增
    // ... 其他常量
}

private var currentName: String = ""  // 新增
```

**修改2**: onCreate 中自动执行搜索
```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    // ... 初始化代码
    
    // 如果有搜索关键词，自动执行搜索
    val searchQuery = intent.getStringExtra(KEY_SEARCH_QUERY)
    if (!searchQuery.isNullOrEmpty()) {
        searchInput.setText(searchQuery)
        performSearch(searchQuery)
    }
}
```

**修改3**: 选择POI时保存名称
```kotlin
private fun selectSearchResult(poi: PoiItem) {
    val latLng = LatLng(poi.latLonPoint.latitude, poi.latLonPoint.longitude)
    
    // 保存POI名称和地址
    currentName = poi.title  // 新增
    currentAddress = poi.snippet ?: poi.title
    
    // 更新UI显示
    addressLabel.text = currentAddress
    
    // ... 其他逻辑
}
```

**修改4**: 用户手动拖动地图时清除POI名称
```kotlin
override fun onCameraChangeFinish(cameraPosition: CameraPosition?) {
    // ... 动画代码
    
    // 用户拖动地图结束，清除POI名称
    currentName = ""  // 新增
    cameraPosition?.target?.let { latLng ->
        reverseGeocode(latLng)
    }
}
```

**修改5**: 返回结果时包含名称
```kotlin
private fun confirmLocation() {
    val center = aMap.cameraPosition.target
    val resultIntent = Intent().apply {
        putExtra(KEY_RESULT_LATITUDE, center.latitude)
        putExtra(KEY_RESULT_LONGITUDE, center.longitude)
        putExtra(KEY_RESULT_ADDRESS, currentAddress)
        putExtra(KEY_RESULT_NAME, currentName)  // 新增
        putExtra(KEY_RESULT_CITY, currentCity)
        putExtra(KEY_RESULT_PROVINCE, currentProvince)
    }
    setResult(Activity.RESULT_OK, resultIntent)
    finish()
}
```

## 功能流程

### 场景1: 用户已填写地址后选择位置
```
1. 用户在"地址"字段输入: "北京市朝阳区国贸"
2. 点击"在地图上选择位置"按钮
3. 地图打开，搜索框自动填入"北京市朝阳区国贸"
4. 自动执行POI搜索，显示相关结果列表
5. 用户点击某个POI（如"国贸大厦"）
   - 地图移动到该POI位置
   - currentName = "国贸大厦"
   - currentAddress = "北京市朝阳区建国门外大街1号"
6. 用户点击"确定"按钮
7. 返回add_coworking_page:
   - 名称字段 = "国贸大厦" ✅ 更新
   - 地址字段 = "北京市朝阳区国贸" ✅ 保持不变
   - 经纬度 = (39.909187, 116.397451) ✅ 更新
```

### 场景2: 用户点击POI后又手动拖动地图
```
1. 用户选择POI "国贸大厦"
   - currentName = "国贸大厦"
2. 用户手动拖动地图到附近其他位置
   - onCameraChangeFinish 触发
   - currentName = "" （清空POI名称）
3. 用户点击"确定"按钮
4. 返回add_coworking_page:
   - 名称字段 = 保持原值（因为currentName为空）
   - 地址字段 = 保持不变
   - 经纬度 = 新位置的坐标 ✅ 更新
```

### 场景3: 用户未填写地址直接选择位置
```
1. 地址字段为空
2. 点击"在地图上选择位置"按钮
3. 地图打开，显示默认位置（上次选择的位置或北京天安门）
4. 用户手动拖动地图选择位置
5. 点击"确定"按钮
6. 返回add_coworking_page:
   - 名称字段 = 保持原值（因为没有POI名称）
   - 地址字段 = 保持不变
   - 经纬度 = 用户选择的坐标 ✅ 更新
```

## 关键设计决策

### 为什么只更新名称字段？
1. **保留用户输入**: 用户可能已经精心编辑了地址字段，不应该被覆盖
2. **名称来源可靠**: POI名称通常是官方的、准确的商业名称
3. **避免混淆**: 自动更新地址可能导致地址与实际位置不匹配

### 为什么手动拖动地图时清除POI名称？
1. **位置不匹配**: 用户拖动到新位置，原POI名称不再适用
2. **避免误导**: 保留旧POI名称会误导用户以为当前位置是该POI
3. **可选更新**: 如果用户不想更新名称，可以选择不点击POI，直接拖动地图

## 测试建议

### 测试用例1: 地址搜索定位
- [ ] 在地址字段输入"北京国贸"
- [ ] 点击地图选择按钮
- [ ] 确认搜索框自动填入"北京国贸"
- [ ] 确认自动显示搜索结果
- [ ] 选择一个POI
- [ ] 确认名称字段被更新为POI名称
- [ ] 确认地址字段保持不变

### 测试用例2: 手动拖动地图
- [ ] 选择一个POI（名称字段应被更新）
- [ ] 手动拖动地图到其他位置
- [ ] 点击确定
- [ ] 确认名称字段保持原值（POI名称已清除）
- [ ] 确认经纬度已更新

### 测试用例3: 空地址字段
- [ ] 地址字段保持空白
- [ ] 点击地图选择按钮
- [ ] 确认搜索框为空
- [ ] 手动拖动地图选择位置
- [ ] 点击确定
- [ ] 确认名称字段保持原值
- [ ] 确认经纬度已更新

## 相关文件

### Flutter 文件
- `lib/pages/add_coworking_page.dart` - 添加共享办公空间页面
- `lib/pages/amap_native_picker_page.dart` - 地图选择器页面
- `lib/services/amap_native_service.dart` - 高德地图原生服务

### Android 文件
- `android/app/src/main/kotlin/com/example/df_admin_mobile/MainActivity.kt` - 主Activity
- `android/app/src/main/kotlin/com/example/df_admin_mobile/AmapMapPickerActivity.kt` - 地图选择器Activity

## 后续优化建议

1. **地址验证**: 在保存前验证地址与选择的经纬度是否匹配
2. **智能提示**: 如果用户手动拖动地图，提示是否要更新地址字段
3. **历史记录**: 保存最近选择的POI，方便快速重选
4. **离线支持**: 缓存常用地址的POI数据，提升搜索速度
5. **多语言支持**: 支持英文地址搜索和POI名称显示
