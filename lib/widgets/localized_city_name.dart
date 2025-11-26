import 'package:flutter/material.dart';

import 'package:df_admin_mobile/utils/city_name_helper.dart';

/// 本地化城市名称Widget
/// 自动将英文城市名称转换为当前语言的显示名称
class LocalizedCityName extends StatefulWidget {
  final String cityName;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const LocalizedCityName({
    super.key,
    required this.cityName,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  State<LocalizedCityName> createState() => _LocalizedCityNameState();
}

class _LocalizedCityNameState extends State<LocalizedCityName> {
  String? _localizedName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalizedName();
  }

  @override
  void didUpdateWidget(LocalizedCityName oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityName != widget.cityName) {
      _loadLocalizedName();
    }
  }

  Future<void> _loadLocalizedName() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    // 获取当前语言
    final locale = Localizations.localeOf(context).languageCode;

    // 加载城市名称映射
    if (!CityNameHelper.isLoaded ||
        CityNameHelper.currentLocale != locale) {
      await CityNameHelper.loadCityNames(locale);
    }

    if (!mounted) return;

    setState(() {
      _localizedName = CityNameHelper.getLocalizedCityName(widget.cityName);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 加载中显示原始名称
      return Text(
        widget.cityName,
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        textAlign: widget.textAlign,
      );
    }

    return Text(
      _localizedName ?? widget.cityName,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: widget.textAlign,
    );
  }
}

/// 同步版本的本地化城市名称Widget
/// 要求在使用前已经调用过 CityNameHelper.loadCityNames()
class LocalizedCityNameSync extends StatelessWidget {
  final String cityName;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const LocalizedCityNameSync({
    super.key,
    required this.cityName,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final localizedName = CityNameHelper.getLocalizedCityName(cityName);

    return Text(
      localizedName,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
