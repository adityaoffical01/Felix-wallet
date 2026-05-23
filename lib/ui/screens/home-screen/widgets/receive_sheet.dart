import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/App_Colors.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

class ReceiveSheet extends StatefulWidget {
  final String address;
  const ReceiveSheet({Key? key, required this.address}) : super(key: key);

  @override
  State<ReceiveSheet> createState() => _ReceiveSheetState();
}

class _ReceiveSheetState extends State<ReceiveSheet> {
  onCopyHandler() {
    copyAddressToClipBoard(widget.address, context);
  }

  onShareHandler() {
    shareSendUrl(widget.address);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            addHeight(SpacingSize.xs),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.withAlpha(60),
              ),
              width: 50,
              height: 4,
            ),
            addHeight(SpacingSize.s),
            const WalletText(localizeKey: 'receive'),
            QrImageView(
              data: widget.address,
              version: QrVersions.auto,
              size: 200.0,
            ),
            addHeight(SpacingSize.xs),
            const WalletText(localizeKey: 'scanAddressto'),
            addHeight(SpacingSize.s),
            const Expanded(child: SizedBox()),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                color: kPrimaryColor.withAlpha(30),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // addWidth(SpacingSize.s),
                  WalletText(localizeKey: showEllipse(widget.address)),

                  InkWell(
                    onTap: onCopyHandler,
                    child: const Icon(
                      Iconsax.copy_copy,
                      // size: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),

                  InkWell(
                    onTap: onShareHandler,
                    child: const Icon(Iconsax.share_copy, color: kPrimaryColor),
                  ),
                ],
              ),
            ),
            addHeight(SpacingSize.m),
          ],
        ),
      ),
    );
  }
}
