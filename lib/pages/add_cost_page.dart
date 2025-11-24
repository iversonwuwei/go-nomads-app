import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/repositories/iuser_city_content_repository.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AddCostPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const AddCostPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<AddCostPage> createState() => _AddCostPageState();
}

class _AddCostPageState extends State<AddCostPage> {
  final _formKey = GlobalKey<FormState>();
  final RxBool _isSubmitting = false.obs;

  // Currency selection
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _validateCityId();
  }

  /// 验证 cityId 是否为有效的 UUID 格式
  void _validateCityId() {
    if (widget.cityId.isEmpty || !_isValidUuid(widget.cityId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppToast.error(
          '城市ID无效,无法提交费用',
          title: '错误',
        );
        Get.back();
      });
    }
  }

  /// 检查是否为有效的 UUID 格式
  bool _isValidUuid(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }

  // Get localized currency list
  List<Map<String, String>> _getCurrencies(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'code': 'USD', 'symbol': '\$', 'name': l10n.currencyUSD},
      {'code': 'EUR', 'symbol': '€', 'name': l10n.currencyEUR},
      {'code': 'GBP', 'symbol': '£', 'name': l10n.currencyGBP},
      {'code': 'JPY', 'symbol': '¥', 'name': l10n.currencyJPY},
      {'code': 'CNY', 'symbol': '¥', 'name': l10n.currencyCNY},
      {'code': 'THB', 'symbol': '฿', 'name': l10n.currencyTHB},
      {'code': 'SGD', 'symbol': 'S\$', 'name': l10n.currencySGD},
      {'code': 'AUD', 'symbol': 'A\$', 'name': l10n.currencyAUD},
      {'code': 'CAD', 'symbol': 'C\$', 'name': l10n.currencyCAD},
      {'code': 'INR', 'symbol': '₹', 'name': l10n.currencyINR},
      {'code': 'KRW', 'symbol': '₩', 'name': l10n.currencyKRW},
      {'code': 'MYR', 'symbol': 'RM', 'name': l10n.currencyMYR},
      {'code': 'VND', 'symbol': '₫', 'name': l10n.currencyVND},
      {'code': 'IDR', 'symbol': 'Rp', 'name': l10n.currencyIDR},
      {'code': 'PHP', 'symbol': '₱', 'name': l10n.currencyPHP},
    ];
  }

  // Cost category controllers
  final Map<String, TextEditingController> _controllers = {
    'accommodation': TextEditingController(),
    'food': TextEditingController(),
    'transportation': TextEditingController(),
    'entertainment': TextEditingController(),
    'gym': TextEditingController(),
    'coworking': TextEditingController(),
    'utilities': TextEditingController(),
    'healthcare': TextEditingController(),
    'shopping': TextEditingController(),
    'other': TextEditingController(),
  };

  // Cost categories with icons
  List<Map<String, dynamic>> _getCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'key': 'accommodation',
        'name': l10n.accommodation,
        'icon': '🏠',
        'hint': l10n.monthlyRent
      },
      {
        'key': 'food',
        'name': l10n.foodDining,
        'icon': '🍽️',
        'hint': l10n.groceriesRestaurants
      },
      {
        'key': 'transportation',
        'name': l10n.transportation,
        'icon': '🚗',
        'hint': l10n.publicTransport
      },
      {
        'key': 'entertainment',
        'name': l10n.entertainment,
        'icon': '🎬',
        'hint': l10n.moviesActivities
      },
      {
        'key': 'gym',
        'name': l10n.gym,
        'icon': '💪',
        'hint': l10n.gymMembership
      },
      {
        'key': 'coworking',
        'name': l10n.coworkingSpace,
        'icon': '💼',
        'hint': l10n.workspaceRental
      },
      {
        'key': 'utilities',
        'name': l10n.utilities,
        'icon': '💡',
        'hint': l10n.electricityWater
      },
      {
        'key': 'healthcare',
        'name': l10n.healthcare,
        'icon': '🏥',
        'hint': l10n.medicalInsurance
      },
      {
        'key': 'shopping',
        'name': l10n.shopping,
        'icon': '🛍️',
        'hint': l10n.clothesPersonal
      },
      {
        'key': 'other',
        'name': l10n.otherExpenses,
        'icon': '📝',
        'hint': l10n.miscellaneous
      },
    ];
  }

  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  String _getCurrencySymbol(BuildContext context) {
    final currencies = _getCurrencies(context);
    return currencies
        .firstWhere((c) => c['code'] == _selectedCurrency)['symbol']!;
  }

  double get _totalCost {
    double total = 0;
    _controllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        total += double.tryParse(controller.text) ?? 0;
      }
    });
    return total;
  }

  void _submitCost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if at least one cost is entered
    bool hasAnyCost = _controllers.values.any((c) => c.text.isNotEmpty);
    if (!hasAnyCost) {
      final l10n = AppLocalizations.of(context)!;
      AppToast.error(
        l10n.pleaseEnterCost,
        title: l10n.error,
      );
      return;
    }

    _isSubmitting.value = true;

    try {
      final repository = Get.find<IUserCityContentRepository>();

      // 提交每个非空的费用项
      final List<UserCityExpense> addedExpenses = [];

      for (var entry in _controllers.entries) {
        final controller = entry.value;
        if (controller.text.isNotEmpty) {
          final amount = double.parse(controller.text);

          // 映射类别名称到 ExpenseCategory 枚举
          final category = _mapToExpenseCategory(entry.key);

          final result = await repository.addCityExpense(
            cityId: widget.cityId,
            category: category,
            amount: amount,
            currency: _selectedCurrency,
            description: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            date: DateTime.now(),
          );

          switch (result) {
            case Success(:final data):
              addedExpenses.add(data);
            case Failure(:final exception):
              throw exception;
          }
        }
      }

      _isSubmitting.value = false;

      // Show success message
      final l10n = AppLocalizations.of(context)!;
      Get.back(result: {
        'success': true,
        'expenses': addedExpenses,
      });

      AppToast.success(
        l10n.costShared,
        title: l10n.success,
      );
    } catch (e) {
      _isSubmitting.value = false;

      final l10n = AppLocalizations.of(context)!;
      AppToast.error(
        'Failed to submit expenses: $e',
        title: l10n.error,
      );
      print('❌ 提交费用失败: $e');
    }
  }

  // 映射表单类别到 ExpenseCategory 枚举
  ExpenseCategory _mapToExpenseCategory(String key) {
    switch (key) {
      case 'food':
        return ExpenseCategory.food;
      case 'transportation':
        return ExpenseCategory.transport;
      case 'accommodation':
        return ExpenseCategory.accommodation;
      case 'entertainment':
      case 'gym':
      case 'coworking':
      case 'utilities':
      case 'healthcare':
        return ExpenseCategory.activity;
      case 'shopping':
        return ExpenseCategory.shopping;
      default:
        return ExpenseCategory.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.xmark, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthlyCost,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.cityName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Currency Selector
                    _buildCurrencySelector(),
                    const SizedBox(height: 24),

                    // Cost Categories
                    _buildCostCategories(),
                    const SizedBox(height: 24),

                    // Total Display
                    _buildTotalDisplay(),
                    const SizedBox(height: 24),

                    // Notes Section
                    _buildNotesSection(),
                    const SizedBox(height: 100), // Space for submit button
                  ],
                ),
              ),
            ),

            // Submit Button (Fixed at bottom)
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Builder(builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final currencies = _getCurrencies(context);
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '💱',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.selectCurrency,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCurrency,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              items: currencies.map((currency) {
                return DropdownMenuItem<String>(
                  value: currency['code'],
                  child: Row(
                    children: [
                      Text(
                        currency['symbol']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${currency['code']} - ${currency['name']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCostCategories() {
    return Builder(builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final categories = _getCategories(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.monthlyCost,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.shareExperience,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map((category) => _buildCostInputField(category)),
        ],
      );
    });
  }

  Widget _buildCostInputField(Map<String, dynamic> category) {
    return Builder(builder: (context) {
      final currencySymbol = _getCurrencySymbol(context);
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  category['icon'],
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  category['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controllers[category['key']],
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: category['hint'],
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixText: '$currencySymbol ',
                prefixStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFFF4458), width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}), // Update total
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTotalDisplay() {
    return Builder(builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final currencySymbol = _getCurrencySymbol(context);
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF4458).withValues(alpha: 0.1),
              const Color(0xFFFF4458).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: const Color(0xFFFF4458).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalMonthly,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currencySymbol ${_totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4458),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                FontAwesomeIcons.calculator,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNotesSection() {
    return Builder(builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '📝',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.additionalNotes,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: l10n.additionalCostInfo,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFFF4458), width: 2),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSubmitButton() {
    return Builder(builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting.value ? null : _submitCost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cityPrimary,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          l10n.submitCost,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              )),
        ),
      );
    });
  }
}
