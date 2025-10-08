import 'package:flutter/material.dart';

/// 应用统一配色方案 - 极简性冷淡风格
/// 使用浅灰色系，避免纯黑色，营造舒适的视觉体验
class AppColors {
  AppColors._(); // 私有构造函数，防止实例化

  // ============ 主色调 ============
  /// 背景色 - 极浅灰
  static const Color background = Color(0xFFFAFAFA);
  
  /// 白色背景
  static const Color white = Colors.white;

  // ============ 文本颜色 ============
  /// 深灰色文本 - 主要文本
  static const Color textPrimary = Color(0xFF616161);
  
  /// 中灰色文本 - 强调文本
  static const Color textSecondary = Color(0xFF757575);
  
  /// 浅灰色文本 - 次要文本
  static const Color textTertiary = Color(0xFF9E9E9E);
  
  /// 白色文本
  static const Color textWhite = Colors.white;
  
  /// 白色文本 70% 不透明度
  static const Color textWhite70 = Color(0xB3FFFFFF);
  
  /// 白色文本 60% 不透明度
  static const Color textWhite60 = Color(0x99FFFFFF);

  // ============ 边框颜色 ============
  /// 主边框颜色
  static const Color border = Color(0xFFE0E0E0);
  
  /// 浅边框颜色
  static const Color borderLight = Color(0xFFEEEEEE);
  
  /// 白色边框 30% 不透明度
  static const Color borderWhite30 = Color(0x4DFFFFFF);

  // ============ 容器背景色 ============
  /// 深灰容器背景
  static const Color containerDark = Color(0xFF757575);
  
  /// 中灰容器背景
  static const Color containerMedium = Color(0xFF9E9E9E);
  
  /// 浅蓝灰容器背景
  static const Color containerBlueGrey = Color(0xFF90A4AE);
  
  /// 统一卡片背景色 - 中蓝灰(加深)
  static const Color cardBackground = Color(0xFF90A4AE);
  
  /// 极浅灰容器背景
  static const Color containerLight = Color(0xFFFAFAFA);
  
  /// 白色容器 15% 不透明度
  static const Color containerWhite15 = Color(0x26FFFFFF);

  // ============ 分割线颜色 ============
  /// 主分割线
  static const Color divider = Color(0xFFEEEEEE);
  
  /// 浅分割线
  static const Color dividerLight = Color(0xFFBDBDBD);

  // ============ 强调色 ============
  /// 蓝色强调色 - 选中/激活状态
  static const Color accent = Color(0xFF1976D2);
  
  /// 中灰强调色 - 选中/激活状态
  static const Color accentGrey = Color(0xFF757575);

  // ============ 图标颜色 ============
  /// 主图标颜色
  static const Color icon = Color(0xFF757575);
  
  /// 次要图标颜色
  static const Color iconSecondary = Color(0xFF9E9E9E);
  
  /// 浅图标颜色
  static const Color iconLight = Color(0xFFBDBDBD);
  
  /// 返回按钮颜色 - 深色背景用
  static const Color backButtonLight = Colors.white70;

  /// 返回按钮颜色 - 浅色背景用
  static const Color backButtonDark = Colors.black87;

  // ============ API卡片颜色 - 低饱和度多色方案 ============
  // 参考 Notion/Linear 的柔和色彩系统
  static const List<Color> apiCardColors = [
    Color(0xFF90A4AE), // 蓝灰 - 沉稳
    Color(0xFFA1887F), // 棕灰 - 温暖
    Color(0xFF81C784), // 绿灰 - 生机（低饱和）
    Color(0xFF64B5F6), // 天蓝 - 清新（低饱和）
    Color(0xFFFFB74D), // 橙灰 - 活力（低饱和）
    Color(0xFFBA68C8), // 紫灰 - 优雅（低饱和）
  ];

  // ============ 数据分类图标颜色 - 低饱和度多色方案 ============
  // 使用柔和色调增加视觉趣味性，同时保持专业感
  static const List<Color> dataCategoryColors = [
    Color(0xFF64B5F6), // 天蓝 - 房产
    Color(0xFF81C784), // 绿灰 - 企业
    Color(0xFFFFB74D), // 橙灰 - 产品
    Color(0xFFBA68C8), // 紫灰 - 个人
    Color(0xFF4FC3F7), // 亮蓝 - 金融（低饱和）
    Color(0xFF4DB6AC), // 青绿 - 电商（低饱和）
    Color(0xFFE57373), // 柔红 - 社交（低饱和）
    Color(0xFF9575CD), // 柔紫 - 位置（低饱和）
    Color(0xFFFFD54F), // 柔黄 - 生活（低饱和）
  ];

  // ============ 辅助方法 ============
  /// 获取API卡片颜色（循环使用）
  static Color getApiCardColor(int index) {
    return apiCardColors[index % apiCardColors.length];
  }

  /// 获取数据分类颜色（循环使用）
  static Color getDataCategoryColor(int index) {
    return dataCategoryColors[index % dataCategoryColors.length];
  }
}
