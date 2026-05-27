// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:felix_wallet_crypto/constant.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_text.dart';
import 'package:felix_wallet_crypto/ui/utils/App_Colors.dart';
import 'package:felix_wallet_crypto/ui/utils/spaces.dart';

enum TextFieldType { input, password }

class WalletTextField extends StatefulWidget {
  final TextFieldType textFieldType;
  final String labelLocalizeKey;
  final String? Function(String?)? validator;
  final TextEditingController? textEditingController;
  final int? maxLength;
  final String? hint;
  const WalletTextField({
    super.key,
    required this.textFieldType,
    required this.labelLocalizeKey,
    this.validator,
    this.maxLength,
    this.textEditingController,
    this.hint,
  });

  @override
  State<WalletTextField> createState() => _WalletTextFieldState();
}

class _WalletTextFieldState extends State<WalletTextField> {
  bool showPassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.textFieldType == TextFieldType.password) {
      setState(() {
        showPassword = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WalletText(
              localizeKey: widget.labelLocalizeKey,
              textVarient: TextVarient.body2,
            ),
            widget.textFieldType == TextFieldType.password
                ? InkWell(
                    onTap: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    child: const WalletText(
                      localizeKey: "show",
                      textVarient: TextVarient.body2,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        addHeight(SpacingSize.xxs),
        TextFormField(
          maxLength: widget.maxLength,
          controller: widget.textEditingController,
          validator: widget.validator,
          cursorColor: kPrimaryColor,
          obscureText: !showPassword,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: AppColors.liteGrey0, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.liteGrey0.withOpacity(0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.liteGrey0.withOpacity(0.4),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.liteGrey0.withOpacity(0.4),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.liteGrey0.withOpacity(0.4),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(),
            ),
          ),
        ),
      ],
    );
  }
}
