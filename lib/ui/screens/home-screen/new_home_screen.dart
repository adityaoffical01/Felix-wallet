// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:felix_wallet_crypto/constant.dart';
import 'package:felix_wallet_crypto/ui/screens/home-screen/Widget-New/Token_Tab_Content.dart';
import 'package:felix_wallet_crypto/ui/screens/home-screen/widgets/change_network_sheet.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_text.dart';
import 'package:felix_wallet_crypto/ui/utils/App_Colors.dart';
import 'package:felix_wallet_crypto/ui/utils/spaces.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:felix_wallet_crypto/core/providers/contact_provider/contact_provider.dart';
import 'package:felix_wallet_crypto/core/providers/token_provider/token_provider.dart';
import 'package:felix_wallet_crypto/core/providers/wallet_provider/wallet_provider.dart';
import 'package:felix_wallet_crypto/core/model/token_model.dart';
import 'package:felix_wallet_crypto/core/remote/response-model/register_user.dart';
import 'package:felix_wallet_crypto/core/socket/message_engine.dart';
import 'package:felix_wallet_crypto/l10n/transalation.dart';
import 'package:felix_wallet_crypto/ui/screens/home-screen/widgets/account_change_sheet.dart';
import 'package:felix_wallet_crypto/ui/screens/home-screen/widgets/receive_sheet.dart';
import 'package:felix_wallet_crypto/ui/screens/transfer-screen/transfer_screen.dart';
import 'package:felix_wallet_crypto/ui/utils/ui_utils.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();

  static Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: appRadius(SpacingSize.m),
          onTap: onTap,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: appRadius(SpacingSize.m),
              border: Border.all(color: AppColors.liteGrey, width: 0.5),
              color: AppColors.liteGrey.withOpacity(0.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(0.15), color],
                    ),
                    shape: BoxShape.circle,
                    // color: AppColors.primaryColor,
                  ),
                  child: Icon(icon, size: 22, color: AppColors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  InAppWebViewController? webViewController;
  final TextEditingController nameEditingController = TextEditingController();
  final user = Get.find<User>();
  String address = "null";
  bool switchEditName = false;
  String accountName = "";
  String currency = "";
  // final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  // final GlobalKey<ScaffoldState> _fakeScafoldKey = GlobalKey();
  int index = 0;

  @override
  void initState() {
    final messageEngine = MessageEngine.getMessageEngine(context);
    if (user.token != null) {
      messageEngine.socketService.forId = user.id;
      messageEngine.setToken(user.token!);
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      getContactProvider(context).loadContacts();
    });
    getWalletProvider(context).setupWalletConnect();
    getWalletProvider(context).init();
    messageEngine.connect();
    super.initState();
  }

  onAddressTapHandler() {
    getWalletProvider(context).copyPublicAddress().then((value) {
      showPositiveSnackBar(
        context,
        getText(context, key: 'success'),
        getText(context, key: 'addressCopied'),
      );
    });
  }

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

  Future<void> onChnageNetwork() async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return ChangeNetworkSheet(address: address);
      },
    );
    await _onRefresh();
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

  onAccountChangeHandler() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const AccountChangeSheet(),
    );
  }

  Future<void> _onRefresh() async {
    final walletProvider = getWalletProvider(context);
    await walletProvider.updateBalance();
    final tokens = await getTokenProvider(context).loadToken(
      nativeBalance: walletProvider.nativeBalance,
      address: walletProvider.activeWallet.wallet.privateKey.address.hex,
      network: walletProvider.activeNetwork,
    );

    if (mounted && tokens.isNotEmpty) {
      walletProvider.changeFiatBalance(
        tokens[0].balanceInFiat.toStringAsFixed(5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DefaultTabController(
          length: 5,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: InkWell(
                splashFactory: NoSplash.splashFactory,
                onTap: onAccountChangeHandler,
                child: Row(
                  spacing: 5.0,
                  children: [
                    // AvatarWidget(
                    //   radius: 20,
                    //   address: getLiveWalletProvider(
                    //     context,
                    //   ).activeWallet.wallet.privateKey.address.hex,
                    // ),
                    WalletText(
                      localizeKey: getLiveWalletProvider(
                        context,
                      ).getAccountName(),
                      textVarient: TextVarient.body2,
                      bold: true,
                    ),
                    const Icon(Iconsax.arrow_down_1_copy),
                  ],
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: onAddressTapHandler,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.liteGrey),
                    ),
                    child: const Icon(
                      Iconsax.copy_copy,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: onSendHandler,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.liteGrey),
                    ),
                    child: const Icon(
                      CupertinoIcons.qrcode,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () {
                    showWarningSnackBar(
                      context,
                      getText(context, key: 'Notifications'),
                      getText(context, key: 'Is comming soon'),
                    );
                  },
                  // Navigator.of(context, rootNavigator: true).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const HomeScreen(),
                  //   ),
                  // );
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.liteGrey),
                    ),
                    child: const Icon(
                      Iconsax.notification_copy,
                      color: AppColors.primaryBlack,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
              ],
            ),

            body: RefreshIndicator(
              onRefresh: _onRefresh,
              child: NestedScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            /// ================= BALANCE CARD =================
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: appRadius(SpacingSize.m),
                                border: Border.all(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: appRadius(SpacingSize.m),
                                    child: Image.asset(
                                      'assets/icons/wallet_background.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    left: 8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Fund Your Wallet',
                                          style: GoogleFonts.lato(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlack,
                                          ),
                                        ),
                                        Text(
                                          Provider.of<WalletProvider>(
                                            context,
                                          ).getNativeBalanceFormatted(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18.0,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        Text(
                                          Provider.of<WalletProvider>(
                                            context,
                                          ).getPreferedBalanceFormatted(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.0,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 6.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            border: Border.all(
                                              color: AppColors.liteGrey,
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: onAddressTapHandler,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: AppColors
                                                          .primaryColor
                                                          .withOpacity(0.1),
                                                    ),
                                                    shape: BoxShape.circle,
                                                    color: AppColors
                                                        .primaryColor
                                                        .withOpacity(0.05),
                                                  ),
                                                  child: const Icon(
                                                    Iconsax.shield_slash,
                                                    size: 22,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                ),
                                                WalletText(
                                                  textVarient:
                                                      TextVarient.body2,

                                                  localizeKey: showEllipse(
                                                    getLiveWalletProvider(
                                                          context,
                                                        )
                                                        .activeWallet
                                                        .wallet
                                                        .privateKey
                                                        .address
                                                        .hex,
                                                  ),
                                                  color: AppColors.primaryBlack,
                                                ),

                                                const Icon(
                                                  Iconsax.copy_copy,
                                                  size: 22,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Container(
                            //   // width: double.infinity,
                            //   padding: const EdgeInsets.all(12.0),
                            //   decoration: BoxDecoration(
                            //     borderRadius: appRadius(SpacingSize.m),
                            //     color: AppColors.liteGrey.withOpacity(0.5),
                            //     border: Border.all(
                            //       color: AppColors.primaryColor.withOpacity(
                            //         0.1,
                            //       ),
                            //       width: 1.5,
                            //     ),
                            //   ),
                            //   child: Column(
                            //     mainAxisAlignment: MainAxisAlignment.end,
                            //     children: [
                            //       // addHeight(SpacingSize.xs),
                            //       // Center(
                            //       //   child: Image.asset(
                            //       //     'assets/images/wallet_bank.png',
                            //       //     height: 80.0,
                            //       //     width: 80.0,
                            //       //     fit: BoxFit.contain,
                            //       //   ),
                            //       // ),
                            //       Text(
                            //         'Fund Your Wallet',
                            //         style: GoogleFonts.poppins(
                            //           fontSize: 24,
                            //           fontWeight: FontWeight.bold,
                            //           color: AppColors.primaryBlack,
                            //         ),
                            //       ),
                            //       addHeight(SpacingSize.xxs),
                            //       Text(
                            //         Provider.of<WalletProvider>(
                            //           context,
                            //         ).getNativeBalanceFormatted(),
                            //         style: const TextStyle(
                            //           fontWeight: FontWeight.w600,
                            //           fontSize: 18.0,
                            //           color: Colors.black54,
                            //         ),
                            //       ),
                            //       Text(
                            //         Provider.of<WalletProvider>(
                            //           context,
                            //         ).getPreferedBalanceFormatted(),
                            //         style: const TextStyle(
                            //           fontWeight: FontWeight.w600,
                            //           fontSize: 12.0,
                            //           color: Colors.black54,
                            //         ),
                            //       ),
                            //       addHeight(SpacingSize.xs),
                            //       Container(
                            //         padding: const EdgeInsets.symmetric(
                            //           horizontal: 24.0,
                            //           vertical: 10.0,
                            //         ),
                            //         decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(12.0),
                            //           border: Border.all(
                            //             color: AppColors.primaryBlack,
                            //             width: 1.5,
                            //           ),
                            //           // color: AppColors.primaryColor,
                            //           // gradient: const LinearGradient(
                            //           //   begin: Alignment.centerLeft,
                            //           //   end: Alignment.centerRight,
                            //           //   colors: [
                            //           //     Color.fromARGB(255, 125, 194, 255),
                            //           //     Color.fromARGB(255, 38, 119, 225),
                            //           //   ],
                            //           // ),
                            //         ),
                            //         child: InkWell(
                            //           onTap: onAddressTapHandler,
                            //           child: Row(
                            //             spacing: 6.0,
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.spaceEvenly,
                            //             children: [
                            //               WalletText(
                            //                 textVarient: TextVarient.body1,
                            //                 localizeKey: showEllipse(
                            //                   getLiveWalletProvider(context)
                            //                       .activeWallet
                            //                       .wallet
                            //                       .privateKey
                            //                       .address
                            //                       .hex,
                            //                 ),

                            //                 color: AppColors.primaryBlack,
                            //               ),

                            //               const Icon(
                            //                 Iconsax.copy_copy,
                            //                 size: 16,
                            //                 color: AppColors.primaryBlack,
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       ),
                            //       addHeight(SpacingSize.xxs),
                            //     ],
                            //   ),
                            // ),
                            addHeight(SpacingSize.s),

                            /// ================= ACTION BUTTONS =================
                            Row(
                              spacing: 8.0,
                              children: [
                                NewHomeScreen._actionButton(
                                  icon: CupertinoIcons.money_dollar,
                                  title: 'Buy',
                                  onTap: () {
                                    showWarningSnackBar(
                                      context,
                                      getText(context, key: 'Buy'),
                                      getText(context, key: 'Is comming soon'),
                                    );
                                  },
                                  color: AppColors.green,
                                ),
                                NewHomeScreen._actionButton(
                                  icon: Iconsax.arrow_swap_copy,
                                  title: 'Swap',
                                  onTap: () {
                                    showWarningSnackBar(
                                      context,
                                      getText(context, key: 'Swaping'),
                                      getText(context, key: 'Is comming soon'),
                                    );
                                  },
                                  color: AppColors.purple,
                                ),
                                NewHomeScreen._actionButton(
                                  icon: Iconsax.send_1_copy,
                                  title: 'Send',
                                  onTap: onSendHandler,
                                  color: AppColors.blue,
                                ),
                                NewHomeScreen._actionButton(
                                  icon: Iconsax.received_copy,
                                  title: 'Receive',
                                  onTap: onReceiveHandler,
                                  color: AppColors.amber,
                                ),
                              ],
                            ),

                            /// ================= TAB BAR =================
                            const TabBar(
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              padding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              dividerColor: Colors.transparent,
                              indicatorColor: kPrimaryColor,
                              indicatorWeight: 2,
                              indicatorSize: TabBarIndicatorSize.label,
                              labelColor: kPrimaryColor,
                              unselectedLabelColor: Colors.grey,
                              labelStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: kPrimaryColor,
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                              tabs: [
                                Tab(text: 'Tokens'),
                                Tab(text: 'Preps'),
                                Tab(text: 'Predictions'),
                                Tab(text: 'DeFi'),
                                Tab(text: 'NeFTs'),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ];
                },

                /// TAB CONTENT (scrollable automatically)
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TabBarView(
                    children: [
                      TokenTabContent(onTap: onChnageNetwork),
                      const Center(child: Text('Preps Data is comming soon..')),
                      const Center(
                        child: Text('Predictions Data is comming soon..'),
                      ),
                      const Center(child: Text('DeFi Data is comming soon..')),
                      const Center(child: Text('NFTs Data is comming soon..')),
                    ],
                  ),
                ),
              ),
            ),
            // bottomNavigationBar: const CustomNavigationBarWdget(),
          ),
        ),

        getLiveWalletProvider(context).loading
            ? Container(
                height: Get.height,
                width: Get.width,
                color: Colors.black87.withAlpha(200),
                child: const Center(child: CircularProgressIndicator()),
              )
            : const SizedBox(),
      ],
    );
  }
}
