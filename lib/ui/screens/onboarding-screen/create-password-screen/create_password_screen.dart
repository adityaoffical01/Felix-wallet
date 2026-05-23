// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:routerino/routerino.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/core/providers/create_wallet_provider/create_wallet_provider.dart';
import 'package:wallet_cryptomask/core/remote/response-model/settings_response.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/screens/Bottom_Navigation_Bar/Bottom_Navigation_Bar.dart';

//import 'package:wallet_cryptomask/ui/screens/home-screen/home_screen.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text_field.dart';
import 'package:wallet_cryptomask/ui/screens/web-view-screen/web_view_screen.dart';
import 'package:wallet_cryptomask/ui/utils/App_Colors.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

class CreatePasswordScreen extends StatefulWidget {
  static const route = "create_password_screen";
  const CreatePasswordScreen({Key? key}) : super(key: key);

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordCmpState();
}

class _CreatePasswordCmpState extends State<CreatePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final passwordEditingControl = TextEditingController(
    text: kDebugMode ? "11111111" : null,
  );
  final confirmPasswordEditingControl = TextEditingController(
    text: kDebugMode ? "11111111" : null,
  );
  bool isTermsAccepted = false;
  bool isCondition = false;
  bool isLoading = false;
  final settings = Get.find<Settings>();

  bool showPassword = false;

  String? passwordvalidator(string) {
    if (string?.isEmpty == true) {
      return getText(context, key: 'thisFieldNotEmpty');
    }
    if (string!.length < 8) {
      return getText(context, key: 'passwordMustContain');
    }
    return null;
  }

  learnMoreHandler() {
    context.push(
      () => WebViewScreen(
        url: settings.ppUrl,
        title: getText(context, key: 'learnMore'),
      ),
    );
  }

  createPasswordHandler() async {
    setState(() {
      isLoading = true;
    });
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    if (_formKey.currentState?.validate() == true) {
      if (!isTermsAccepted) {
        showErrorSnackBar(
          context,
          getText(context, key: 'invalid'),
          getText(context, key: 'accepTermsWarning'),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
      if (passwordEditingControl.text != confirmPasswordEditingControl.text) {
        showErrorSnackBar(
          context,
          getText(context, key: 'invalid'),
          getText(context, key: 'passwordConfirmPasswordNotMatch'),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
      try {
        final createWalletProvider = getCreateWalletProvider(context);
        final walletProvider = getWalletProvider(context);
        await createWalletProvider.setPassword(passwordEditingControl.text);
        await createWalletProvider.createWallet();
        await walletProvider.openWallet(password: passwordEditingControl.text);
        setState(() {
          isLoading = false;
        });
        showPositiveSnackBar(
          context,
          getText(context, key: 'success'),
          getText(context, key: 'createWalletGreet'),
        );
        await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CustomNavigationBarWdget()),
          (route) => false,
        );
      } catch (e, s) {
        debugPrint('Create wallet failed: $e');
        debugPrintStack(stackTrace: s);
        setState(() {
          isLoading = false;
        });
        showErrorSnackBar(
          context,
          getText(context, key: 'error'),
          e.toString(),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: const WalletText(
          localizeKey: "appName",
          textVarient: TextVarient.hero,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/import_wallet_setup.png',
                  height: 280.0,
                  width: 280.0,
                  fit: BoxFit.contain,
                ),

                const WalletText(
                  key: Key('create-password-text'),
                  localizeKey: "createPassword",
                  textVarient: TextVarient.subHeading,
                ),
                addHeight(SpacingSize.xxs),
                WalletText(
                  center: true,
                  localizeKey: "thisPasswordWill",
                  textVarient: TextVarient.body2,
                  color: AppColors.liteGrey0,
                ),
                addHeight(SpacingSize.xs),
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
                        textFieldType: TextFieldType.password,
                        textEditingController: passwordEditingControl,
                        validator: passwordvalidator,
                        key: const Key('password-text-field'),
                        labelLocalizeKey: "password",
                      ),
                      addHeight(SpacingSize.xs),
                      WalletTextField(
                        textFieldType: TextFieldType.password,
                        textEditingController: confirmPasswordEditingControl,
                        validator: passwordvalidator,
                        key: const Key('confirm-password-text-field'),
                        labelLocalizeKey: "confirmPassword",
                      ),
                      addHeight(SpacingSize.s),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        key: const Key('terms-agreement-section'),
                        children: [
                          Checkbox(
                            activeColor: kPrimaryColor,
                            value: isTermsAccepted,
                            onChanged: (value) {
                              setState(() {
                                isTermsAccepted = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: learnMoreHandler,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: getTextWithPlaceholder(
                                        context,
                                        key: 'iUnserstandTheRecover',
                                        string: getText(
                                          context,
                                          key: 'appName',
                                        ),
                                      ),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.grey,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                    const TextSpan(text: " "),
                                    TextSpan(
                                      text: getText(context, key: 'learnMore'),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                addHeight(SpacingSize.s),
                isLoading
                    ? const CircularProgressIndicator(color: kPrimaryColor)
                    : WalletButton(
                        type: WalletButtonType.gradient,
                        key: const Key('create-wallet-button'),
                        localizeKey: "createPassword",
                        onPressed: createPasswordHandler,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
