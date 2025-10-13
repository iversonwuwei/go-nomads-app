# Cost Sharing Feature Implementation 💰

## 📋 概述
为 City Detail 页面的 Cost Tab 实现了完整的费用分享功能，用户可以分享在特定城市的生活成本信息。

## ✨ 核心功能

### 1. 货币选择 💱
- 支持 15 种主流货币
- 包括：USD, EUR, GBP, JPY, CNY, THB, SGD, AUD, CAD, INR, KRW, MYR, VND, IDR, PHP
- 每种货币都有对应的符号显示
- 实时切换货币单位

### 2. 费用分类 📊
支持 10 个主要费用类别：

| 类别 | 图标 | 说明 |
|------|------|------|
| Accommodation | 🏠 | 月租或酒店费用 |
| Food & Dining | 🍽️ | 餐饮和杂货 |
| Transportation | 🚗 | 公共交通和出租车 |
| Entertainment | 🎬 | 电影和娱乐活动 |
| Fitness & Gym | 💪 | 健身房会员 |
| Coworking Space | 💼 | 办公空间租赁 |
| Utilities | 💡 | 水电网费 |
| Healthcare | 🏥 | 医疗和保险 |
| Shopping | 🛍️ | 购物和个人用品 |
| Other Expenses | 📝 | 其他杂项费用 |

### 3. 费用输入 💵
- 每个类别都有独立的输入框
- 支持小数点后两位
- 实时输入验证
- 可选填写（至少填写一个类别）
- 自动计算总费用

### 4. 总费用显示 🧮
- 实时计算所有类别的总和
- 美观的渐变背景展示
- 大字号突出显示总金额
- 计算器图标装饰

### 5. 备注功能 📝
- 可选的备注输入（最多 500 字符）
- 4 行文本输入框
- 提供额外信息说明的空间

## 🎨 UI 设计

### 页面布局
```
AppBar
├── 关闭按钮
├── 标题 "Share Costs"
└── 城市名称副标题

Body (Scrollable)
├── 货币选择器
│   ├── 标题 💱 Currency
│   └── 下拉选择框
│
├── 费用分类 Cost Breakdown
│   ├── 10 个费用输入框
│   └── 每个都有图标、标题、提示文本
│
├── 总费用显示
│   ├── 渐变背景
│   ├── 总金额大字号显示
│   └── 计算器图标
│
└── 备注区域
    └── 多行文本输入

Bottom Bar (Fixed)
└── 提交按钮 "Share Cost Information"
```

### 颜色方案
- 主色调：红色 `#FF4458`
- 渐变：`#FF4458` → `#FF6B7A`
- 输入框焦点：红色边框
- 背景：白色和浅灰色

### 交互设计
- 货币切换立即更新所有货币符号
- 输入金额实时更新总费用
- 提交时显示加载状态
- 表单验证提示
- 成功提交后显示 snackbar 并返回

## 📱 用户流程

### 1. 进入页面
```
City Detail Page → Cost Tab → Share 按钮 → Add Cost Page
```

### 2. 填写费用
1. 选择货币（默认 USD）
2. 填写各项费用（至少一项）
3. 查看实时计算的总费用
4. 可选填写备注
5. 点击提交按钮

### 3. 提交反馈
- 验证至少填写一个费用项
- 显示加载指示器
- 模拟 API 调用（2 秒）
- 成功后返回并显示提示

## 🛠️ 技术实现

### 文件结构
```
lib/pages/
└── add_cost_page.dart          # 新建：费用分享页面
└── city_detail_page.dart       # 修改：添加导航到新页面
```

### 核心代码

#### 1. 货币数据结构
```dart
final List<Map<String, String>> _currencies = [
  {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
  {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
  // ... 更多货币
];
```

#### 2. 费用类别控制器
```dart
final Map<String, TextEditingController> _controllers = {
  'accommodation': TextEditingController(),
  'food': TextEditingController(),
  // ... 更多类别
};
```

#### 3. 总费用计算
```dart
double get _totalCost {
  double total = 0;
  _controllers.forEach((key, controller) {
    if (controller.text.isNotEmpty) {
      total += double.tryParse(controller.text) ?? 0;
    }
  });
  return total;
}
```

#### 4. 输入验证
```dart
inputFormatters: [
  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
],
```

### 状态管理
- 使用 `GetX` 进行状态管理
- `RxBool _isSubmitting` 管理提交状态
- `setState()` 更新货币和总费用

### 表单验证
- 至少填写一个费用类别
- 数字格式验证（最多 2 位小数）
- 备注长度限制（500 字符）

## 🔄 导航集成

### 修改点
`city_detail_page.dart` 中的 `_showShareCostDialog()` 方法：

```dart
// 之前：显示 Dialog
void _showShareCostDialog() {
  Get.dialog(...); // 显示 "Coming Soon" 对话框
}

// 之后：导航到新页面
void _showShareCostDialog() {
  Get.to(
    () => AddCostPage(
      cityId: widget.cityId,
      cityName: widget.cityName,
    ),
  );
}
```

## 📊 数据提交

### 提交数据结构
```dart
Map<String, dynamic> costData = {
  'cityId': widget.cityId,
  'currency': _selectedCurrency,
  'costs': {
    'accommodation': 1200.50,
    'food': 800.00,
    // ... 其他有值的类别
  },
  'notes': '备注内容',
  'total': 2000.50,
};
```

### API 集成（待实现）
```dart
// 当前：模拟 API 调用
await Future.delayed(const Duration(seconds: 2));

// 将来：实际 API 调用
// await apiService.submitCost(costData);
```

## 🎯 使用场景

### 典型使用流程
1. **数字游民** 分享在泰国清迈的月度生活成本
2. **远程工作者** 记录在葡萄牙里斯本的各项开支
3. **旅行者** 提供在日本东京的短期生活费用参考
4. **长期居民** 更新城市的最新生活成本信息

### 数据用途
- 帮助其他用户了解城市生活成本
- 为旅行计划提供预算参考
- 建立全球城市成本数据库
- 社区协作共建数据

## 📝 待改进项

### 功能增强
- [ ] 添加月份选择（记录时间变化）
- [ ] 支持更多货币
- [ ] 添加费用类别自定义
- [ ] 费用对比功能
- [ ] 历史记录查看
- [ ] 数据可视化图表

### 优化项
- [ ] 离线数据保存
- [ ] 批量导入功能
- [ ] 费用模板保存
- [ ] 多人协作记录
- [ ] 汇率自动转换

## 🔧 维护说明

### 依赖包
- `flutter/material.dart` - UI 组件
- `flutter/services.dart` - 输入格式化
- `get/get.dart` - 状态管理和导航

### 注意事项
1. 确保货币符号正确显示
2. 输入验证避免非法字符
3. 总费用计算精度（2 位小数）
4. 提交状态的正确处理
5. 内存管理（dispose controllers）

## 📅 版本历史

### v1.0.0 (2025-10-13)
- ✅ 实现基础费用分享功能
- ✅ 支持 15 种货币
- ✅ 10 个费用类别输入
- ✅ 实时总费用计算
- ✅ 备注功能
- ✅ 表单验证
- ✅ 提交状态管理
- ✅ 成功反馈提示

---

**Created:** 2025-10-13  
**Last Updated:** 2025-10-13  
**Status:** ✅ Completed
