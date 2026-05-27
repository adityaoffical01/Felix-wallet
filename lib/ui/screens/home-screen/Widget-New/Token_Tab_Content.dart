// ignore_for_file: deprecated_member_use
// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/utils/App_Colors.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:decimal/decimal.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/core/providers/token_provider/token_provider.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/ui/screens/token-dashboard-screen/token_dashboard_screen.dart';
import 'package:wallet_cryptomask/ui/tabs/token/widgets/token_tile.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

class TokenTabContent extends StatefulWidget {
  final VoidCallback onTap;
  const TokenTabContent({Key? key, required this.onTap}) : super(key: key);

  @override
  State<TokenTabContent> createState() => _TokenTabContentState();
}

class _TokenTabContentState extends State<TokenTabContent> {
  // Timer? _tokenBalanceTimer;

  @override
  void initState() {
    super.initState();
    setupAndLoadToken();
  }

  setupAndLoadToken() async {
    final tokens = await getTokenProvider(context).loadToken(
      nativeBalance: getWalletProvider(context).nativeBalance,
      address: getWalletProvider(
        context,
      ).activeWallet.wallet.privateKey.address.hex,
      network: getWalletProvider(context).activeNetwork,
    );
    if (mounted) {
      getWalletProvider(
        context,
      ).changeFiatBalance(tokens[0].balanceInFiat.toStringAsFixed(5));
    }
  }

  onTokenPressHandler(Token token) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => TokenDashboardScreen(tokenAddress: token.tokenAddress),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 5.0,
          children: [
            InkWell(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.liteGrey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: getLiveWalletProvider(
                          context,
                        ).activeNetwork.dotColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    addWidth(SpacingSize.xs),
                    WalletText(
                      localizeKey: getLiveWalletProvider(
                        context,
                      ).activeNetwork.networkName,
                      textVarient: TextVarient.body3,
                    ),
                    addWidth(SpacingSize.xs),
                    const Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),

                // const Row(
                //   spacing: 5.0,
                //   children: [
                //     Text(
                //       'Popular Tokens',
                //       style: TextStyle(
                //         color: Colors.black,
                //         fontSize: 12,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //     Icon(Iconsax.arrow_down_1_copy, size: 18),
                //   ],
                // ),
              ),
            ),

            const Spacer(),
            GestureDetector(
              onTap: () {
                showWarningSnackBar(
                  context,
                  getText(context, key: 'Filter'),
                  getText(context, key: 'Is comming soon'),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.liteGrey),
                ),
                child: const Icon(Iconsax.setting_5_copy, size: 18),
              ),
            ),
            GestureDetector(
              onTap: () {
                showWarningSnackBar(
                  context,
                  getText(context, key: 'Add'),
                  getText(context, key: 'Is comming soon'),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.liteGrey),
                ),
                child: const Icon(Iconsax.add_copy, size: 18),
              ),
            ),
          ],
        ),
        // for the content
        const SizedBox(height: 12),
        Provider.of<TokenProvider>(context).tokens.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: Provider.of<TokenProvider>(context).tokens.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () => onTokenPressHandler(
                      Provider.of<TokenProvider>(
                        context,
                        listen: false,
                      ).tokens[index],
                    ),
                    child: TokenTile(
                      imageUrl: Provider.of<TokenProvider>(
                        context,
                        listen: false,
                      ).tokens[index].imageUrl,
                      decimal: Provider.of<TokenProvider>(
                        context,
                        listen: false,
                      ).tokens[index].decimal,
                      tokenAddress: Provider.of<TokenProvider>(
                        context,
                        listen: false,
                      ).tokens[index].tokenAddress,
                      balance: Decimal.parse(
                        Provider.of<TokenProvider>(
                          context,
                          listen: false,
                        ).tokens[index].balance.toString(),
                      ),
                      symbol: Provider.of<TokenProvider>(
                        context,
                        listen: false,
                      ).tokens[index].symbol,
                      balanceInFiat: Provider.of<TokenProvider>(
                        context,
                        listen: false,
                      ).tokens[index].balanceInFiat,
                    ),
                  ),
                ),
              )
            : const Center(child: WalletText(localizeKey: 'youDontHaveToken')),

        // ListView.builder(
        //   shrinkWrap: true,
        //   itemCount: 5,
        //   physics: const NeverScrollableScrollPhysics(),
        //   itemBuilder: (context, index) {
        //     return ListTile(
        //       contentPadding: EdgeInsets.zero,
        //       leading: Container(
        //         padding: const EdgeInsets.all(5.0),
        //         decoration: BoxDecoration(
        //           color: kPrimaryColor.withOpacity(0.1),
        //           shape: BoxShape.circle,
        //         ),
        //         child: ClipOval(
        //           child: Image.asset(
        //             'assets/images/eth.png',
        //             width: 35,
        //             height: 35,
        //           ),
        //         ),
        //       ),
        //       title: const Text(
        //         'Ethorium',
        //         style: TextStyle(
        //           color: Colors.black,
        //           fontSize: 14,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //       subtitle: const Row(
        //         spacing: 5,
        //         children: [
        //           Text(
        //             '0 ETH',
        //             style: TextStyle(
        //               color: Colors.grey,
        //               fontSize: 12,
        //               fontWeight: FontWeight.w600,
        //             ),
        //           ),
        //           Icon(Icons.circle, size: 8),
        //           Text(
        //             'Earn 2.4%',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontSize: 12,
        //               fontWeight: FontWeight.w600,
        //             ),
        //           ),
        //         ],
        //       ),

        //       trailing: const Column(
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Text(
        //             '\$ 00.00',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontSize: 14,
        //               fontWeight: FontWeight.w600,
        //             ),
        //           ),
        //           Text(
        //             '- 10.23%',
        //             style: TextStyle(
        //               color: AppColors.red0,
        //               fontSize: 12,
        //               fontWeight: FontWeight.w600,
        //             ),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }
}
