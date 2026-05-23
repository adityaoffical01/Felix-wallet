import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

class ScannerScreen extends StatefulWidget {
  final Function(String address) onQrDecode;
  const ScannerScreen({Key? key, required this.onQrDecode}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _mobileScannerController = MobileScannerController();
  bool _isHandlingResult = false;

  @override
  void dispose() {
    _mobileScannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const WalletText(
              localizeKey: 'scanQrCode',
              color: Colors.white,
              size: 16,
            ),
            addHeight(SpacingSize.m),
            Container(
              color: Colors.black,
              width: 300,
              height: 300,
              child: MobileScanner(
                controller: _mobileScannerController,
                errorBuilder: (context, error) {
                  return const Center(
                    child: WalletText(
                      localizeKey: 'somethingWentWrongInitial',
                      color: Colors.white,
                      align: TextAlign.center,
                    ),
                  );
                },
                onDetect: (capture) {
                  if (_isHandlingResult) return;
                  if (capture.barcodes.isEmpty) {
                    debugPrint('No barcode detected');
                    return;
                  }

                  final rawValue = capture.barcodes.first.rawValue;
                  if (rawValue == null || rawValue.trim().isEmpty) {
                    debugPrint('Failed to scan barcode');
                    return;
                  }

                  _isHandlingResult = true;
                  widget.onQrDecode(rawValue.trim());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
