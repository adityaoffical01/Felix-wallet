import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:felix_wallet_crypto/constant.dart';
import 'package:felix_wallet_crypto/core/model/token_model.dart';
import 'package:felix_wallet_crypto/core/providers/wallet_provider/wallet_provider.dart';
import 'package:felix_wallet_crypto/core/remote/response-model/settings_response.dart';
import 'package:felix_wallet_crypto/l10n/transalation.dart';
import 'package:felix_wallet_crypto/ui/screens/block-web-view-screen/block_web_view.dart';
import 'package:felix_wallet_crypto/ui/screens/contacts-screen/all_contact_screen.dart';
import 'package:felix_wallet_crypto/ui/screens/home-screen/widgets/account_change_sheet.dart';
import 'package:felix_wallet_crypto/ui/screens/home-screen/widgets/receive_sheet.dart';
import 'package:felix_wallet_crypto/ui/screens/login-screen/login_screen.dart';
import 'package:felix_wallet_crypto/ui/screens/onboarding-screen/new-splash/new_onboarding.dart';
import 'package:felix_wallet_crypto/ui/screens/setttings-screen/settings_screen.dart';
import 'package:felix_wallet_crypto/ui/screens/transfer-screen/transfer_screen.dart';
import 'package:felix_wallet_crypto/ui/screens/web-view-screen/web_view_screen.dart';
import 'package:felix_wallet_crypto/ui/shared/avatar_widget.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_button_with_icon.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_text.dart';
import 'package:felix_wallet_crypto/ui/utils/App_Colors.dart';
import 'package:felix_wallet_crypto/ui/utils/ui_utils.dart';
import 'package:felix_wallet_crypto/ui/utils/spaces.dart';

class ProfileAccountWidget extends StatefulWidget {
  const ProfileAccountWidget({Key? key}) : super(key: key);

  @override
  State<ProfileAccountWidget> createState() => _ProfileAccountWidgetState();
}

class _ProfileAccountWidgetState extends State<ProfileAccountWidget> {
  final settings = Get.find<Settings>();
  onReceiveHandler() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return ReceiveSheet(
          address: getWalletProvider(
            context,
          ).activeWallet.wallet.privateKey.address.hex,
        );
      },
    );
  }

  onSendHandler() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => TransferScreen(
          balance: getWalletProvider(context).nativeBalance.toString(),
          token: Token(
            tokenAddress: "",
            symbol: Provider.of<WalletProvider>(
              context,
              listen: false,
            ).activeNetwork.symbol,
            decimal: 18,
            balance: getWalletProvider(context).nativeBalance,
            balanceInFiat: double.parse(
              getWalletProvider(context).balanceInPrefereCurrency,
            ),
          ),
        ),
      ),
    );
  }

  onSharePublicAddressHandler() {
    sharePublicAddress(
      Provider.of<WalletProvider>(
        context,
        listen: false,
      ).activeWallet.wallet.privateKey.address.hex,
    );
  }

  viewOnExplorerHandler() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => BlockWebView(
          title: Provider.of<WalletProvider>(
            context,
            listen: false,
          ).activeNetwork.networkName,
          url: viewAddressOnEtherScan(
            Provider.of<WalletProvider>(context, listen: false).activeNetwork,
            Provider.of<WalletProvider>(
              context,
              listen: false,
            ).activeWallet.wallet.privateKey.address.hex,
          ),
        ),
      ),
    );
  }

  onSettingsHandler() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  onGetHelpHandler() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => WebViewScreen(
          url: settings.helpUrl,
          title: getText(context, key: 'help'),
        ),
      ),
    );
  }

  onLogoutHandler() {
    Provider.of<WalletProvider>(context, listen: false).logout().then((value) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    });
  }

  onDeleteWalletHandler() {
    var alert = StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(kPrimaryColor),
            ),
            child: const WalletText(localizeKey: 'cancel', color: Colors.white),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<WalletProvider>(
                context,
                listen: false,
              ).eraseWallet().then((value) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const OnboardingScreenWidget(),
                  ),
                  (route) => false,
                );
              });
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            child: const WalletText(
              localizeKey: 'eraseAndContinue',
              color: Colors.white,
            ),
          ),
        ],
        title: const WalletText(localizeKey: 'confirmation'),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: getText(context, key: 'eraseWarning'),
                style: GoogleFonts.poppins(),
              ),
              TextSpan(
                text: getText(context, key: 'irreversible'),
                style: GoogleFonts.poppins().copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );

    showDialog(context: context, builder: (context) => alert);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: const WalletText(
          localizeKey: 'appName',
          textVarient: TextVarient.hero,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              addHeight(SpacingSize.s),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: appRadius(SpacingSize.m),
                  color: AppColors.liteGrey.withOpacity(0.5),
                ),

                child: Column(
                  children: [
                    AvatarWidget(
                      radius: 65,
                      address: Provider.of<WalletProvider>(
                        context,
                      ).activeWallet.wallet.privateKey.address.hex,
                    ),
                    addHeight(SpacingSize.xs),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop;
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => const AccountChangeSheet(),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WalletText(
                            localizeKey: Provider.of<WalletProvider>(
                              context,
                            ).getAccountName(),
                            textVarient: TextVarient.body1,
                            bold: true,
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    addHeight(SpacingSize.xxs),
                    WalletText(
                      localizeKey: Provider.of<WalletProvider>(
                        context,
                      ).getNativeBalanceFormatted(),
                    ),
                    addHeight(SpacingSize.xxs),
                    WalletText(
                      localizeKey: showEllipse(
                        Provider.of<WalletProvider>(
                          context,
                        ).activeWallet.wallet.privateKey.address.hex,
                      ),
                    ),
                    addHeight(SpacingSize.xs),
                    Row(
                      children: [
                        Expanded(
                          child: WalletButtonWithIcon(
                            icon: const Icon(Icons.call_made, size: 15),
                            textContent: getText(context, key: 'send'),
                            onPressed: onSendHandler,
                          ),
                        ),

                        Expanded(
                          child: WalletButtonWithIcon(
                            textContent: getText(context, key: 'receive'),
                            onPressed: onReceiveHandler,
                            icon: const Icon(Icons.call_received, size: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              addHeight(SpacingSize.s),
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const AllContactScreen()),
                  );
                },
                trailing: const Icon(
                  Iconsax.arrow_right_3_copy,
                  color: AppColors.primaryBlack,
                ),
                leading: const Icon(
                  Iconsax.call,
                  color: AppColors.primaryBlack,
                  size: 22.0,
                ),
                title: const WalletText(
                  localizeKey: 'Contact Us',
                  textVarient: TextVarient.body1,
                ),
              ),
              // for share
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: onSharePublicAddressHandler,
                trailing: const Icon(
                  Iconsax.arrow_right_3_copy,
                  color: AppColors.primaryBlack,
                ),
                leading: const Icon(
                  Iconsax.share,
                  color: AppColors.primaryBlack,
                  size: 22.0,
                ),
                title: const WalletText(
                  localizeKey: 'shareMyPubliAdd',
                  textVarient: TextVarient.body1,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: viewOnExplorerHandler,
                trailing: const Icon(
                  Iconsax.arrow_right_3_copy,
                  color: AppColors.primaryBlack,
                ),
                leading: const Icon(
                  Iconsax.eye,
                  color: AppColors.primaryBlack,
                  size: 22.0,
                ),
                title: const WalletText(
                  localizeKey: 'viewOnEtherscan',
                  textVarient: TextVarient.body1,
                ),
              ),
              //onSettingsHandler
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: onSettingsHandler,
                trailing: const Icon(
                  Iconsax.arrow_right_3_copy,
                  color: AppColors.primaryBlack,
                ),
                leading: const Icon(
                  Iconsax.setting_2,
                  color: AppColors.primaryBlack,
                  size: 22.0,
                ),
                title: const WalletText(
                  localizeKey: 'settings',
                  textVarient: TextVarient.body1,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: onGetHelpHandler,
                trailing: const Icon(
                  Iconsax.arrow_right_3_copy,
                  color: AppColors.primaryBlack,
                ),
                leading: const Icon(
                  Iconsax.support,
                  color: AppColors.primaryBlack,
                  size: 22.0,
                ),
                title: const WalletText(
                  localizeKey: 'getHelp',
                  textVarient: TextVarient.body1,
                ),
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: onLogoutHandler,
                trailing: const Icon(
                  Iconsax.arrow_right_3_copy,
                  color: AppColors.primaryBlack,
                ),
                leading: const Icon(
                  Iconsax.logout,
                  color: AppColors.primaryBlack,
                  size: 22.0,
                ),
                title: const WalletText(
                  localizeKey: 'logout',
                  textVarient: TextVarient.body1,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: onLogoutHandler,
                trailing: const Icon(
                  Iconsax.arrow_right_3_copy,
                  color: AppColors.primaryBlack,
                ),
                leading: const Icon(
                  Iconsax.trash,
                  color: AppColors.red0,
                  size: 22.0,
                ),
                title: const WalletText(
                  localizeKey: 'deleteWallet',
                  textVarient: TextVarient.body1,
                  color: AppColors.red0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
