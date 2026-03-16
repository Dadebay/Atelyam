import 'package:atelyam/app/modules/business_view/views/business_currency_controller.dart';
import 'package:atelyam/app/modules/business_view/views/finance/controllers/finance_controller.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final BusinessCurrencyController _currencyController = Get.find<BusinessCurrencyController>();

  String? _selectedCategory;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {'key': 'expense_category_fabric', 'name': 'Fabric & Materials', 'icon': HugeIcons.strokeRoundedTextCreation},
    {'key': 'expense_category_rent', 'name': 'Rent', 'icon': HugeIcons.strokeRoundedHome01},
    {'key': 'expense_category_utilities', 'name': 'Utilities', 'icon': HugeIcons.strokeRoundedFlashOff},
    {'key': 'expense_category_transport', 'name': 'Transport', 'icon': HugeIcons.strokeRoundedDeliveryTruck01},
    {'key': 'expense_category_equipment', 'name': 'Equipment', 'icon': HugeIcons.strokeRoundedMachineRobot},
    {'key': 'expense_category_other', 'name': 'Other', 'icon': HugeIcons.strokeRoundedMore01},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      showSnackBar('error'.tr, 'select_category_error'.tr, ColorConstants.redColor);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = Get.find<FinanceController>();
      await controller.addExpense(
        title: _titleController.text.trim(),
        category: _selectedCategory!,
        amount: double.parse(_amountController.text.trim()),
      );
      Get.back(result: true);
    } catch (e) {
      // Error handled in controller
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(IconlyLight.arrow_left_circle, color: Colors.black87),
        ),
        title: Text(
          'add_expense'.tr,
          style: TextStyle(
            fontFamily: Fonts.gilroy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                _buildLabel('expense_title'.tr),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hint: 'expense_hint'.tr,
                  validator: (v) => v == null || v.trim().isEmpty ? 'errorEmpty'.tr : null,
                ),

                const SizedBox(height: 20),

                // Category selection
                _buildLabel('category'.tr),
                const SizedBox(height: 12),
                _buildCategoryGrid(),

                const SizedBox(height: 20),

                // Amount input with currency selector
                _buildLabel('amount_tmt'.tr),
                const SizedBox(height: 8),
                Obx(() => _buildAmountField()),

                const SizedBox(height: 30),

                // Submit button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: Fonts.gilroy,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: Fonts.gilroy,
            color: Colors.grey.shade400,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorConstants.kSecondaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat['name'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? ColorConstants.kSecondaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? ColorConstants.kSecondaryColor : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ColorConstants.kSecondaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat['icon'] as IconData,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  (cat['key'] as String).tr,
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: TextStyle(
            fontFamily: Fonts.gilroy,
            color: Colors.grey.shade400,
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ColorConstants.kSecondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _currencyController.currency.value.symbol,
              style: TextStyle(
                fontFamily: Fonts.gilroy,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorConstants.kSecondaryColor,
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorConstants.kSecondaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'errorEmpty'.tr;
          if (double.tryParse(v) == null) return 'invalid_amount'.tr;
          if (double.parse(v) <= 0) return 'amount_must_be_positive'.tr;
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.kSecondaryColor,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: ColorConstants.kSecondaryColor.withOpacity(0.4),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'add_expense'.tr,
                style: TextStyle(
                  fontFamily: Fonts.gilroy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
