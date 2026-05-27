import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:felix_wallet_crypto/core/providers/wallet_provider/wallet_provider.dart';
import 'package:felix_wallet_crypto/l10n/transalation.dart';
import 'package:felix_wallet_crypto/ui/screens/home-screen/new_home_screen.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_button.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_text.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_text_field.dart';
import 'package:felix_wallet_crypto/ui/utils/App_Colors.dart';
import 'package:felix_wallet_crypto/ui/utils/spaces.dart';
import 'package:felix_wallet_crypto/ui/utils/ui_utils.dart';

class ImportAccountScreen extends StatefulWidget {
  static const route = "import_account";
  const ImportAccountScreen({Key? key}) : super(key: key);

  @override
  State<ImportAccountScreen> createState() => _ImportAccountScreenState();
}

class _ImportAccountScreenState extends State<ImportAccountScreen> {
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
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        shadowColor: Colors.transparent,
        backgroundColor: AppColors.white,
        title: const Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 70, 10),
          child: Center(
            child: WalletText(
              localizeKey: 'importAccount',
              color: Colors.black,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
      body: getLiveWalletProvider(context).loading
          ? const Center(child: CircularProgressIndicator())
          : getLiveWalletProvider(context).wallets.isNotEmpty
          ? Form(
              key: _privateKeyFormKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/open_wallet.png',
                        // height: 280.0,
                        // width: 280.0,
                        fit: BoxFit.contain,
                      ),
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
                            textFieldType: TextFieldType.input,
                            hint: 'Enter private key',
                            labelLocalizeKey: 'enterPrivateKey',
                            textEditingController: _privateKey,
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
                          // addHeight(SpacingSize.m),
                          Provider.of<WalletProvider>(context).wallets.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: WalletText(localizeKey: 'password'),
                                )
                              : const SizedBox(),
                          Provider.of<WalletProvider>(context).wallets.isEmpty
                              ? addHeight(SpacingSize.s)
                              : const SizedBox(),
                          Provider.of<WalletProvider>(context).wallets.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: WalletTextField(
                                    textFieldType: TextFieldType.input,
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
                                  ),
                                )
                              : const SizedBox(),
                          addHeight(SpacingSize.m),
                          WalletButton(
                            type: WalletButtonType.gradient,
                            localizeKey: 'importAccount',
                            onPressed: onImportAccountHandlerWithPK,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Form(
              key: _privateKeyFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Lottie.asset(
                      "assets/animations/crypto_currency.json",
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: WalletTextField(
                      textFieldType: TextFieldType.input,
                      labelLocalizeKey: 'seedphrase',
                      textEditingController: _seedphrase,
                      validator: (String? string) {
                        if (string!.isEmpty) {
                          return getText(context, key: 'privateKeyNotEmpty');
                        }
                        return null;
                      },
                    ),
                  ),
                  addHeight(SpacingSize.m),
                  Provider.of<WalletProvider>(context).wallets.isEmpty
                      ? addHeight(SpacingSize.s)
                      : const SizedBox(),
                  Provider.of<WalletProvider>(context).wallets.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: WalletTextField(
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
                                return getText(context, key: 'passwordAtleast');
                              }
                              return null;
                            },
                            labelLocalizeKey: 'enterNewPassword',
                          ),
                        )
                      : const SizedBox(),
                  addHeight(SpacingSize.m),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: WalletButton(
                      type: WalletButtonType.filled,
                      localizeKey: 'importAccount',
                      onPressed: onImportAccountHandlerWithSeedphrase,
                    ),
                  ),
                  const SizedBox(height: 170),
                ],
              ),
            ),
    );
  }
}
