// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:felix_wallet_crypto/core/providers/wallet_provider/wallet_provider.dart';
import 'package:felix_wallet_crypto/ui/shared/avatar_widget.dart';
import 'package:felix_wallet_crypto/ui/screens/import-account-screen/import_account_screen.dart';
import 'package:felix_wallet_crypto/ui/utils/App_Colors.dart';
import 'package:felix_wallet_crypto/ui/utils/spaces.dart';

class AccountChangeSheet extends StatefulWidget {
  final Function(String address, int? index)? onChange;
  const AccountChangeSheet({Key? key, this.onChange}) : super(key: key);

  @override
  State<AccountChangeSheet> createState() => _AccountChangeSheetState();
}

class _AccountChangeSheetState extends State<AccountChangeSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            addHeight(SpacingSize.xs),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.withAlpha(60),
              ),
              width: 50,
              height: 4,
            ),
            // addHeight(SpacingSize.s),
            addHeight(SpacingSize.s),
            // Container(
            //   width: double.infinity,
            //   height: 1,
            //   color: Colors.grey.withAlpha(60),
            // ),
            Text(
              'Accounts',
              style: GoogleFonts.poppins(
                color: AppColors.primaryBlack,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: Provider.of<WalletProvider>(context).wallets.length,
                itemBuilder: (context, index) => ListTile(
                  onTap: () {
                    getWalletProvider(context).startNetworkSwitch();
                    Provider.of<WalletProvider>(
                      context,
                      listen: false,
                    ).changeAccount(index);
                    Navigator.of(context).pop();
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 16,
                  ),
                  title: Text(
                    Provider.of<WalletProvider>(context).getAccountNameFor(
                      Provider.of<WalletProvider>(context)
                          .wallets[index]
                          .wallet
                          .privateKey
                          .address
                          .hex
                          .toLowerCase(),
                    ),
                  ),
                  leading: AvatarWidget(
                    radius: 30,
                    address: Provider.of<WalletProvider>(
                      context,
                    ).wallets[index].wallet.privateKey.address.hex,
                  ),
                ),
              ),
            ),
            // Container(
            //   width: double.infinity,
            //   height: 1,
            //   color: Colors.grey.withAlpha(60),
            // ),
            addHeight(SpacingSize.xxs),
            InkWell(
              onTap: () {
                final walletProvider = getWalletProvider(context);
                walletProvider.showLoading();
                walletProvider.createNewAccount().then((value) {
                  walletProvider.hideLoading();
                });
              },
              child: Container(
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),

                decoration: BoxDecoration(
                  borderRadius: appRadius(SpacingSize.m),
                  color: AppColors.liteGrey.withOpacity(0.5),
                ),
                child: Provider.of<WalletProvider>(context).loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlack,
                        ),
                      )
                    : Center(
                        child: Text(
                          'Create New Acount',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),
              ),
            ),

            addHeight(SpacingSize.xxs),
            InkWell(
              onTap: () async {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => const ImportAccountScreen(),
                  ),
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: appRadius(SpacingSize.m),
                  color: AppColors.liteGrey.withOpacity(0.5),
                ),
                child: Center(
                  child: Text(
                    'Import Account',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
              ),
            ),

            // Container(
            //   width: double.infinity,
            //   height: 1,
            //   color: Colors.grey.withAlpha(60),
            // ),
            // addHeight(SpacingSize.s),
            // InkWell(
            //   onTap: () async {
            //     context.push(() => const ImportAccountScreen());
            //   },
            //   child: const WalletText(
            //     localizeKey: 'importAccount',
            //     color: kPrimaryColor,
            //   ),
            // ),
            addHeight(SpacingSize.s),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey.withAlpha(60),
            ),
            addHeight(SpacingSize.s),
          ],
        ),
      ),
    );
  }
}
