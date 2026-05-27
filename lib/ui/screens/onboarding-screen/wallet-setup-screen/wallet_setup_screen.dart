// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:routerino/routerino.dart';
import 'package:felix_wallet_crypto/constant.dart';
import 'package:felix_wallet_crypto/core/providers/wallet_provider/wallet_provider.dart';
import 'package:felix_wallet_crypto/l10n/transalation.dart';
import 'package:felix_wallet_crypto/ui/screens/home-screen/new_home_screen.dart';
import 'package:felix_wallet_crypto/ui/screens/onboarding-screen/create-password-screen/create_password_screen.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_button.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_text.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_text_field.dart';
import 'package:felix_wallet_crypto/ui/utils/App_Colors.dart';
import 'package:felix_wallet_crypto/ui/utils/spaces.dart';
import 'package:felix_wallet_crypto/ui/utils/ui_utils.dart';
import 'package:provider/provider.dart';

class WalletSetupScreen extends StatefulWidget {
  static String route = "wallet_setup_screen";

  const WalletSetupScreen({Key? key}) : super(key: key);

  @override
  State<WalletSetupScreen> createState() => _WalletSetupScreenState();
}

class _WalletSetupScreenState extends State<WalletSetupScreen> {
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _privateKeyFormKey = GlobalKey();
  final TextEditingController _privateKey = TextEditingController();
  final TextEditingController _seedphrase = TextEditingController();

  onImportAccountHandlerWithPK() {
    final walletProvider = getWalletProvider(context);
    if (_privateKeyFormKey.currentState!.validate()) {
      walletProvider.showLoading();
      walletProvider
          .importAccountFromPrivateKey(privateKey: _privateKey.text)
          .then((value) {
            walletProvider.hideLoading();
            Navigator.of(context).pop();
          })
          .catchError((e) {
            walletProvider.hideLoading();
            showErrorSnackBar(
              context,
              getText(context, key: 'error'),
              e.toString(),
            );
          });
    }
  }

  onImportAccountHandlerWithSeedphrase() {
    final walletProvider = getWalletProvider(context);
    if (_privateKeyFormKey.currentState!.validate()) {
      walletProvider.showLoading();
      walletProvider
          .importAccountFromSeedphraseOnboarding(
            seedphrase: _seedphrase.text,
            password: _password.text,
          )
          .then((value) async {
            await walletProvider.openWallet(password: _password.text);
            if (mounted) {
              walletProvider.hideLoading();
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const NewHomeScreen()),
                (route) => false,
              );
            }
          })
          .catchError((e) {
            walletProvider.hideLoading();
            showErrorSnackBar(
              context,
              getText(context, key: 'error'),
              e.toString(),
            );
          });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_sharp,
            color: AppColors.primaryBlack,
          ),
        ),
        actions: const [Icon(Icons.arrow_back, color: Colors.transparent)],
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: const WalletText(
          localizeKey: 'importAccount',
          textVarient: TextVarient.hero,
        ),
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Image.asset(
              'assets/images/import_wallet_setup.png',
              height: 280.0,
              width: 280.0,
              fit: BoxFit.contain,
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _privateKeyFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    addHeight(SpacingSize.xl),
                    // const WalletText(
                    //   localizeKey: 'walletSetup',
                    //   textVarient: TextVarient.heading,
                    //   color: AppColors.white,
                    // ),
                    addHeight(SpacingSize.xs),
                    const WalletText(
                      localizeKey: 'importAnExistingWalletOrCreate',
                      textVarient: TextVarient.body2,
                      color: AppColors.white,
                    ),
                    Text(
                      'Securly import an existing wallet Using your secret recovery phrase.',
                      style: TextStyle(
                        color: AppColors.liteGrey0,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    addHeight(SpacingSize.s),
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
                            hint: 'Enter your seedphrase',
                            textFieldType: TextFieldType.input,
                            labelLocalizeKey: 'seedphrase',
                            textEditingController: _seedphrase,
                            validator: (String? string) {
                              if (string!.isEmpty) {
                                return getText(
                                  context,
                                  key: 'privateKeyNotEmpty',
                                );
                              }
                              return null;
                            },
                          ),

                          Provider.of<WalletProvider>(context).wallets.isEmpty
                              ? addHeight(SpacingSize.s)
                              : const SizedBox(),
                          Provider.of<WalletProvider>(context).wallets.isEmpty
                              ? WalletTextField(
                                  hint: 'Enter your new password',
                                  textFieldType: TextFieldType.password,
                                  textEditingController: _password,
                                  validator: (String? string) {
                                    if (string!.isEmpty) {
                                      return getText(
                                        context,
                                        key: 'passwordNotEmpty',
                                      );
                                    }
                                    if (string.length < 8) {
                                      return getText(
                                        context,
                                        key: 'passwordAtleast',
                                      );
                                    }
                                    return null;
                                  },
                                  labelLocalizeKey: 'enterNewPassword',
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    addHeight(SpacingSize.xs),
                    WalletButton(
                      localizeKey: 'import',
                      type: WalletButtonType.gradient,
                      onPressed: () {
                        onImportAccountHandlerWithSeedphrase();
                        // context.push(() => const ImportAccountScreen());
                      },
                    ),
                    addHeight(SpacingSize.xxs),
                    GestureDetector(
                      onTap: () {
                        context.push(() => const CreatePasswordScreen());
                      },
                      child: const WalletText(
                        localizeKey: 'createANewWallet',
                        textVarient: TextVarient.body2,
                        color: kPrimaryColor,
                        bold: true,
                      ),
                    ),
                    addHeight(SpacingSize.l),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
