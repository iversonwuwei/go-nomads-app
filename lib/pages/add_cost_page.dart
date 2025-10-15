import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../generated/app_localizations.dart';
import '../widgets/app_toast.dart';

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
  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
    {'code': 'THB', 'symbol': '฿', 'name': 'Thai Baht'},
    {'code': 'SGD', 'symbol': 'S\$', 'name': 'Singapore Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'KRW', 'symbol': '₩', 'name': 'South Korean Won'},
    {'code': 'MYR', 'symbol': 'RM', 'name': 'Malaysian Ringgit'},
    {'code': 'VND', 'symbol': '₫', 'name': 'Vietnamese Dong'},
    {'code': 'IDR', 'symbol': 'Rp', 'name': 'Indonesian Rupiah'},
    {'code': 'PHP', 'symbol': '₱', 'name': 'Philippine Peso'},
  ];

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
  final List<Map<String, dynamic>> _categories = [
    {
      'key': 'accommodation',
      'name': 'Accommodation',
      'icon': '🏠',
      'hint': 'Monthly rent or hotel'
    },
    {
      'key': 'food',
      'name': 'Food & Dining',
      'icon': '🍽️',
      'hint': 'Groceries, restaurants'
    },
    {
      'key': 'transportation',
      'name': 'Transportation',
      'icon': '🚗',
      'hint': 'Public transport, taxi'
    },
    {
      'key': 'entertainment',
      'name': 'Entertainment',
      'icon': '🎬',
      'hint': 'Movies, activities'
    },
    {
      'key': 'gym',
      'name': 'Fitness & Gym',
      'icon': '💪',
      'hint': 'Gym membership, sports'
    },
    {
      'key': 'coworking',
      'name': 'Coworking Space',
      'icon': '💼',
      'hint': 'Workspace rental'
    },
    {
      'key': 'utilities',
      'name': 'Utilities',
      'icon': '💡',
      'hint': 'Electricity, water, internet'
    },
    {
      'key': 'healthcare',
      'name': 'Healthcare',
      'icon': '🏥',
      'hint': 'Medical, insurance'
    },
    {
      'key': 'shopping',
      'name': 'Shopping',
      'icon': '🛍️',
      'hint': 'Clothes, personal items'
    },
    {
      'key': 'other',
      'name': 'Other Expenses',
      'icon': '📝',
      'hint': 'Miscellaneous costs'
    },
  ];

  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  String get _currencySymbol {
    return _currencies
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

    // Prepare cost data
    Map<String, dynamic> costData = {
      'cityId': widget.cityId,
      'currency': _selectedCurrency,
      'costs': {},
      'notes': _notesController.text.trim(),
      'total': _totalCost,
    };

    _controllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        costData['costs'][key] = double.parse(controller.text);
      }
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _isSubmitting.value = false;

    // Show success message
    final l10n = AppLocalizations.of(context)!;
    Get.back(result: true);
    AppToast.success(
      l10n.costShared,
      title: l10n.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthlyCost,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.cityName,
              style: TextStyle(
                color: Colors.grey[600],
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
              items: _currencies.map((currency) {
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
          ..._categories.map((category) => _buildCostInputField(category)),
        ],
      );
    });
  }

  Widget _buildCostInputField(Map<String, dynamic> category) {
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: category['hint'],
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixText: '$_currencySymbol ',
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
  }

  Widget _buildTotalDisplay() {
    return Builder(builder: (context) {
      final l10n = AppLocalizations.of(context)!;
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
                  '$_currencySymbol ${_totalCost.toStringAsFixed(2)}',
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
                Icons.calculate,
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
              hintText:
                  'Add any additional information about your living costs...',
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
                    backgroundColor: const Color(0xFFFF4458),
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
