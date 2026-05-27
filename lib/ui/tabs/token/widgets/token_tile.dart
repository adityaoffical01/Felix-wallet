import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:felix_wallet_crypto/ui/shared/avatar_widget.dart';
import 'package:felix_wallet_crypto/ui/utils/App_Colors.dart';

class TokenTile extends StatefulWidget {
  final String symbol;
  final Decimal balance;
  final double balanceInFiat;
  final String tokenAddress;
  final int decimal;
  final String? imageUrl;
  const TokenTile({
    Key? key,
    required this.symbol,
    required this.balance,
    required this.balanceInFiat,
    required this.tokenAddress,
    required this.decimal,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<TokenTile> createState() => _TokenTileState();
}

class _TokenTileState extends State<TokenTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.liteGrey.withValues(alpha: 0.5),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        leading: AvatarWidget(
          radius: 40,
          address: widget.tokenAddress,
          iconType: "identicon",
          imageUrl: widget.imageUrl,
        ),
        title: Text(
          widget.symbol,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.balance.toStringAsFixed(6),
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              "\$${widget.balanceInFiat.toStringAsFixed(6)}",
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.primaryBlack,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.liteGrey.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Iconsax.arrow_right_3_copy,
            color: AppColors.primaryBlack,
            size: 16,
          ),
        ),
      ),
    );
  }
}
