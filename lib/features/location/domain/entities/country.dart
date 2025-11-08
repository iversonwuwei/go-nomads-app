// Re-export Country entity from existing country module
// 从现有 country 模块重新导出，保持统一的 location 命名空间
import 'package:df_admin_mobile/features/country/domain/entities/country_option.dart';

export 'package:df_admin_mobile/features/country/domain/entities/country_option.dart';

typedef Country = CountryOption;
