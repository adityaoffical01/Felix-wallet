// ignore_for_file: invalid_return_type_for_catch_error, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:felix_wallet_crypto/constant.dart';
import 'package:felix_wallet_crypto/core/providers/wallet_provider/wallet_provider.dart';
import 'package:felix_wallet_crypto/core/remote/response-model/register_user.dart';
import 'package:felix_wallet_crypto/l10n/transalation.dart';
import 'package:felix_wallet_crypto/ui/screens/Bottom_Navigation_Bar/Bottom_Navigation_Bar.dart';
import 'package:felix_wallet_crypto/ui/screens/deactivated-screen/deactivated_screen.dart';
import 'package:felix_wallet_crypto/ui/screens/onboarding-screen/onboard_screen.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_button.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_text.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_text_field.dart';
import 'package:felix_wallet_crypto/ui/utils/App_Colors.dart';
import 'package:felix_wallet_crypto/ui/utils/ui_utils.dart';
import 'package:felix_wallet_crypto/ui/utils/spaces.dart';
import 'package:felix_wallet_crypto/utils/update_utils.dart';

class LoginScreen extends StatefulWidget {
  static const route = "login_screen_route";
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? "11111111" : null,
  );
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isLoading = false;

  @override
  void initState() {
    checkForUpdate(context);
    super.initState();
  }

  openWalletHandler() async {
    WalletProvider walletProvider = context.read<WalletProvider>();
    if (_formKey.currentState!.validate()) {
      walletProvider.showLoading();
      walletProvider
          .openWallet(password: passwordController.text)
          .then((value) {
            walletProvider.hideLoading();
            final user = Get.find<User>();
            if (user.isDeactivated) {
              return Navigator.of(
                context,
                rootNavigator: true,
              ).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DeactivatedScreen()),
                (route) => false,
              );
            }
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const CustomNavigationBarWdget(),
              ),
              (route) => false,
            );
          })
          .catchError((e) {
            walletProvider.hideLoading();
            showErrorSnackBar(
              context,
              getText(context, key: 'error'),
              getText(context, key: 'passwordIncorrect'),
            );
            return e;
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  addHeight(SpacingSize.xs),
                  const Expanded(child: SizedBox()),
                  Center(
                    child: Image.asset(
                      'assets/images/open_wallet.png',
                      // height: 280.0,
                      // width: 280.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                  addHeight(SpacingSize.m),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WalletText(
                        localizeKey: 'welcomeBack',
                        textVarient: TextVarient.hero,
                      ),
                    ],
                  ),
                  addHeight(SpacingSize.m),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.liteGrey.withOpacity(0.5),
                      border: Border.all(
                        color: AppColors.liteGrey0.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        WalletTextField(
                          textEditingController: passwordController,
                          validator: (String? string) {
                            if (string!.isEmpty) {
                              return getText(
                                context,
                                key: 'passwordShouldntBeEmpy',
                              );
                            }
                            return null;
                          },
                          textFieldType: TextFieldType.password,
                          labelLocalizeKey: 'password',
                        ),
                        addHeight(SpacingSize.s),
                        Consumer<WalletProvider>(
                          builder: (context, value, child) {
                            if (value.loading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: kPrimaryColor,
                                ),
                              );
                            }
                            return WalletButton(
                              type: WalletButtonType.gradient,
                              localizeKey: 'openWallet',
                              onPressed: openWalletHandler,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  addHeight(SpacingSize.s),
                  WalletText(
                    center: true,
                    localizeKey: 'cantLogin',
                    color: AppColors.grey,
                    textVarient: TextVarient.body3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          var alert = AlertDialog(
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    kPrimaryColor,
                                  ),
                                ),
                                child: const WalletText(
                                  localizeKey: "cancel",
                                  color: Colors.white,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  getWalletProvider(context).eraseWallet().then(
                                    (value) {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (_) => const OnboardScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    },
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    Colors.red,
                                  ),
                                ),
                                child: const WalletText(
                                  localizeKey: 'eraseAndContinue',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                            title: const WalletText(
                              localizeKey: 'confirmation',
                            ),
                            content: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: getText(context, key: 'eraseWarning'),
                                  ),
                                  TextSpan(
                                    text: getText(context, key: 'irreversible'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                          showDialog(
                            context: context,
                            builder: (context) => alert,
                          );
                        },
                        child: const WalletText(
                          localizeKey: 'resetWallet',
                          bold: true,
                          color: Colors.red,
                          underline: true,
                          center: true,
                        ),
                      ),
                    ],
                  ),
                  addHeight(SpacingSize.l),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
