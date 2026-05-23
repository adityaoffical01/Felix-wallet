// ignore_for_file: deprecated_member_use


import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';

enum WalletButtonType { outline, filled, gradient }

enum WalletButtonSize { small, medium, large }

class WalletButton extends StatefulWidget {
  final Function()? onPressed;
  final WalletButtonType type;
  final String? localizeKey;
  final bool fullWidth;
  final double textSize;
  final WalletButtonSize buttonSize;
  final double borderRadius;
  const WalletButton({
    Key? key,
    required this.onPressed,
    this.textSize = 14,
    this.buttonSize = WalletButtonSize.medium,
    this.fullWidth = true,
    this.localizeKey,
    this.borderRadius = 8.0,
    this.type = WalletButtonType.outline,
  }) : super(key: key);

  @override
  State<WalletButton> createState() => _WalletButtonState();
}

class _WalletButtonState extends State<WalletButton> {
  @override
  Widget build(BuildContext context) {
    final bool isGradient = widget.type == WalletButtonType.gradient;

    return SizedBox(
      height: 40,
      width: widget.fullWidth ? double.infinity : null,
      child: isGradient
          ? _buildGradientButton(context)
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.type == WalletButtonType.filled
                    ? widget.onPressed != null
                          ? Colors.white
                          : Colors.grey
                    : kPrimaryColor,
                backgroundColor: widget.type == WalletButtonType.filled
                    ? widget.onPressed != null
                          ? kPrimaryColor
                          : kPrimaryColor.withAlpha(80)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                side: widget.type == WalletButtonType.outline
                    ? const BorderSide(width: 1.0, color: kPrimaryColor)
                    : BorderSide.none,
              ),
              onPressed: widget.onPressed,
              child: Text(
                getText(context, key: widget.localizeKey!),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: widget.textSize,
                ),
              ),
            ),
    );
  }

  Widget _buildGradientButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.onPressed != null
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xff6DBBFF), kPrimaryColor],
              )
            : LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade300],
              ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: widget.onPressed,
          child: Center(
            child: Text(
              getText(context, key: widget.localizeKey!),
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w600,
                fontSize: widget.textSize,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
