import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:felix_wallet_crypto/l10n/transalation.dart';
import 'package:felix_wallet_crypto/ui/utils/App_Colors.dart';

// const Color kPrimaryColor = Color(0xff7b15ef);
const Color kPrimaryColor = AppColors.primaryColor;
//  Color(0xff1F66C1);

const String walletConnectSingleTon = "WalletConnectSingleTon";

onBoardScreenContent(BuildContext context) {
  return [
    PageViewModel(
      title: getText(context, key: 'welcomeTo'),
      body: getText(context, key: 'template1'),
      image: Center(
        child: Image.asset("assets/images/wallet_logo.png", height: 250),
      ),
    ),
    PageViewModel(
      title: getText(context, key: 'explorerFeature'),
      body: getText(context, key: 'template2'),
      image: Lottie.asset(
        "assets/animations/blockchain.json",
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      ),
    ),
    PageViewModel(
      title: getText(context, key: 'securityYouCan'),
      body: getText(context, key: 'template3'),
      image: Lottie.asset(
        "assets/animations/Lock.json",
        width: 300,
        height: 300,
        fit: BoxFit.cover,
      ),
    ),
  ];
}
