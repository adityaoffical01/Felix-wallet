import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:routerino/routerino.dart';
import 'package:felix_wallet_crypto/constant.dart';
import 'package:felix_wallet_crypto/l10n/transalation.dart';
import 'package:felix_wallet_crypto/ui/screens/onboarding-screen/wallet-setup-screen/wallet_setup_screen.dart';
import 'package:felix_wallet_crypto/ui/utils/App_Colors.dart';

class OnboardingScreenWidget extends StatefulWidget {
  const OnboardingScreenWidget({Key? key}) : super(key: key);

  @override
  State<OnboardingScreenWidget> createState() => _OnboardingScreenWidgetState();
}

class _OnboardingScreenWidgetState extends State<OnboardingScreenWidget> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            /// PageView
            PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              children: [_firstPage(), _secondPage(), _thirdPage()],
            ),

            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (index) => _buildIndicator(index),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (currentIndex < 2) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.push(() => const WalletSetupScreen());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        currentIndex == 2 ? "Get Started" : "Next",
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: currentIndex == index ? 20 : 8,
      decoration: BoxDecoration(
        color: currentIndex == index ? kPrimaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  /// First Page (Sirf aapka current content)
  Widget _firstPage() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 120),
        Image.asset('assets/icons/icon.png', height: 140, width: 140),
        const SizedBox(height: 16),
        // const WalletText(
        //   key: Key('app-name-text'),
        //   localizeKey: 'appName',
        //   textVarient: TextVarient.hero,
        // ),
      ],
    );
  }

  /// Second Page
  Widget _secondPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 120),
        Lottie.asset(
          "assets/animations/blockchain.json",
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        Text(
          getText(context, key: 'explorerFeature'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            getText(context, key: 'template2'),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  /// Third Page
  Widget _thirdPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 80),
        Lottie.asset(
          "assets/animations/Lock.json",
          width: 300,
          height: 300,
          fit: BoxFit.cover,
          repeat: false,
        ),
        const Spacer(),
        Text(
          getText(context, key: 'securityYouCan'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            getText(context, key: 'template3'),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}
