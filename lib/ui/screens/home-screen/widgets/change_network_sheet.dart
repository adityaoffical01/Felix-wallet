import 'package:flutter/material.dart';
import 'package:felix_wallet_crypto/core/providers/network_provider/network_provider.dart';
import 'package:felix_wallet_crypto/core/providers/token_provider/token_provider.dart';
import 'package:felix_wallet_crypto/core/providers/wallet_provider/wallet_provider.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_text.dart';

class ChangeNetworkSheet extends StatelessWidget {
  final String address;
  const ChangeNetworkSheet({Key? key, required this.address}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          /// Top Handle
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          /// Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(child: WalletText(localizeKey: "networks")),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1),
          ),

          /// Network List
          Expanded(
            child: ListView.builder(
              itemCount: getNetworkProvider(context).networks.length,
              itemBuilder: (context, index) {
                final network = getNetworkProvider(context).networks[index];

                return ListTile(
                  onTap: () async {
                    final walletProvider = getWalletProvider(context);

                    walletProvider.startNetworkSwitch();

                    await walletProvider.changeNetwork(index);

                    getTokenProvider(context).loadToken(
                      nativeBalance: walletProvider.nativeBalance,
                      address: address,
                      network: network,
                    );

                    Navigator.pop(context);
                  },
                  leading: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: network.dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: WalletText(localizeKey: network.networkName),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
