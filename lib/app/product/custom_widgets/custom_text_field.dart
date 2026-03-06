import 'package:atelyam/app/modules/auth_view/controllers/auth_controller.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  final String labelName;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode requestfocusNode;
  final bool? borderRadius;
  final IconData? prefixIcon;
  final Color? customColor;
  final int? maxLine;
  final bool? showLabel;
  const CustomTextField({
    required this.labelName,
    required this.controller,
    required this.focusNode,
    required this.requestfocusNode,
    this.borderRadius,
    this.maxLine,
    this.prefixIcon,
    this.showLabel,
    this.customColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color defaultColor = customColor ?? ColorConstants.whiteMainColor;
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: TextFormField(
        style: TextStyle(
          color: Colors.black,
          fontSize: AppFontSizes.getFontSize(4.5),
          fontWeight: FontWeight.w600,
        ),
        cursorColor: defaultColor,
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'errorEmpty'.tr;
          }
          return null;
        },
        onEditingComplete: () {
          requestfocusNode.requestFocus();
        },
        keyboardType: TextInputType.text,
        maxLines: maxLine ?? 1,
        focusNode: focusNode,
        textInputAction: TextInputAction.done,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(
                    prefixIcon,
                    color: Colors.grey.shade400,
                    size: AppFontSizes.getFontSize(7),
                  ),
                )
              : null,
          hintText: labelName.tr,
          labelText: showLabel == true ? labelName.tr : null,
          labelStyle: TextStyle(
            color: defaultColor,
            fontFamily: Fonts.gilroy,
            fontSize: AppFontSizes.getFontSize(4.5),
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: defaultColor,
            fontFamily: Fonts.gilroy,
            fontSize: AppFontSizes.getFontSize(4.5),
            fontWeight: FontWeight.w600,
          ),
          floatingLabelAlignment: FloatingLabelAlignment.start,
          contentPadding: EdgeInsets.only(left: 30, top: 18, bottom: 15, right: 10),
          isDense: true,
          alignLabelWithHint: true,
          border: _buildOutlineInputBorder(borderColor: defaultColor),
          enabledBorder: _buildOutlineInputBorder(borderColor: defaultColor),
          focusedBorder: _buildOutlineInputBorder(
            borderColor: ColorConstants.kSecondaryColor,
          ),
          focusedErrorBorder: _buildOutlineInputBorder(borderColor: defaultColor),
          errorBorder: _buildOutlineInputBorder(borderColor: Colors.red),
        ),
      ),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder({Color? borderColor}) {
    final borderRadiusValue = borderRadius == null
        ? BorderRadii.borderRadius5
        : borderRadius == false
            ? BorderRadii.borderRadius5
            : BorderRadii.borderRadius20;
    return OutlineInputBorder(
      borderRadius: borderRadiusValue,
      borderSide: BorderSide(color: borderColor ?? Colors.grey, width: 2),
    );
  }
}

class PhoneNumberTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode requestfocusNode;

  /// 0 = Turkmenistan (+993), 1 = Uzbekistan (+998)
  final int initialCountryIndex;
  const PhoneNumberTextField({
    required this.controller,
    required this.focusNode,
    required this.requestfocusNode,
    this.initialCountryIndex = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<PhoneNumberTextField> createState() => _PhoneNumberTextFieldState();
}

class _PhoneNumberTextFieldState extends State<PhoneNumberTextField> {
  // Available countries: flag emoji, dial code, max digits, hint
  static const List<Map<String, dynamic>> _countries = [
    {'flag': '🇹🇲', 'code': '+993', 'maxLength': 8, 'hint': '65 656565'},
    {'flag': '🇺🇿', 'code': '+998', 'maxLength': 9, 'hint': '90 1234567'},
  ];

  int _selectedIndex = 0;

  Map<String, dynamic> get _selected => _countries[_selectedIndex];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialCountryIndex.clamp(0, _countries.length - 1);
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ..._countries.asMap().entries.map((entry) {
                final i = entry.key;
                final country = entry.value;
                final isSelected = i == _selectedIndex;
                return ListTile(
                  leading: Text(
                    country['flag'] as String,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    '${country['code']}',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? ColorConstants.kPrimaryColor : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  trailing: isSelected ? Icon(Icons.check_circle, color: ColorConstants.kPrimaryColor) : null,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex = i;
                      widget.controller.clear();
                    });
                    // Sync with AuthController
                    try {
                      Get.find<AuthController>().setCountry(
                        code: country['code'] as String,
                        maxLength: country['maxLength'] as int,
                      );
                    } catch (_) {}
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  OutlineInputBorder _buildOutlineInputBorder({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadii.borderRadius20,
      borderSide: BorderSide(color: borderColor ?? Colors.grey, width: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int maxLen = _selected['maxLength'] as int;
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: TextFormField(
        style: TextStyle(
          color: Colors.black,
          fontSize: AppFontSizes.getFontSize(4.5),
          fontWeight: FontWeight.w600,
        ),
        cursorColor: Colors.black,
        controller: widget.controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'errorEmpty'.tr;
          }
          if (value.length != maxLen) {
            return 'errorPhoneCount'.tr;
          }
          return null;
        },
        onEditingComplete: () {
          widget.requestfocusNode.requestFocus();
        },
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLen),
          FilteringTextInputFormatter.digitsOnly,
        ],
        maxLines: 1,
        focusNode: widget.focusNode,
        textInputAction: TextInputAction.next,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          prefixIcon: GestureDetector(
            onTap: _showCountryPicker,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selected['flag'] as String,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selected['code'] as String,
                    style: TextStyle(
                      color: ColorConstants.kPrimaryColor,
                      fontSize: AppFontSizes.getFontSize(4.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
          hintText: _selected['hint'] as String,
          hintStyle: TextStyle(
            color: Colors.grey.shade300,
            fontWeight: FontWeight.w600,
            fontSize: AppFontSizes.getFontSize(4.5),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 110),
          contentPadding: const EdgeInsets.only(left: 10, top: 18, bottom: 15, right: 10),
          isDense: true,
          border: _buildOutlineInputBorder(
            borderColor: ColorConstants.kPrimaryColor.withOpacity(.2),
          ),
          enabledBorder: _buildOutlineInputBorder(
            borderColor: ColorConstants.kPrimaryColor.withOpacity(.2),
          ),
          focusedBorder: _buildOutlineInputBorder(
            borderColor: ColorConstants.kSecondaryColor,
          ),
          focusedErrorBorder: _buildOutlineInputBorder(borderColor: Colors.red),
          errorBorder: _buildOutlineInputBorder(borderColor: Colors.red),
        ),
      ),
    );
  }
}
