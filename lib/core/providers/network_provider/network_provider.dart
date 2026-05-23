import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/core/model/network_model.dart';

NetworkProvider getNetworkProvider(BuildContext context) =>
    Provider.of<NetworkProvider>(context, listen: false);

NetworkProvider getLiveNetworkProvider(BuildContext context) =>
    Provider.of<NetworkProvider>(context);

class NetworkProvider extends ChangeNotifier {
  List<Network> networks = [];

  NetworkProvider() {
    networks = loadNetworks();
    notifyListeners();
  }

  List<Network> loadNetworks() {
    final ethereumRpcFromEnv = (dotenv.env['ETHEREUM_RPC_URL'] ?? "").trim();
    final isInvalidInfuraUrl =
        ethereumRpcFromEnv.contains("infura.io/v3") &&
        (ethereumRpcFromEnv.endsWith('/v3') ||
            ethereumRpcFromEnv.endsWith('/v3/'));
    final ethereumRpc = (ethereumRpcFromEnv.isEmpty || isInvalidInfuraUrl)
        ? "https://cloudflare-eth.com"
        : ethereumRpcFromEnv;

    return [
      /// ================== FELIX SMART CHAIN ==================
      Network(
        nameSpace: "eip155",
        networkName: "Felix Smart Chain",
        url: dotenv.env['FELIX_RPC_URL'] ?? "https://rpc.felixexplorer.com",
        symbol: "FLXG",
        currency: "FLXG",
        chainId: 778400,
        logo: "assets/images/felix.png",
        apiKey: "",
        isMainnet: true,
        addressViewUrl: "https://rpc.felixexplorer.com/address/",
        transactionViewUrl: "https://rpc.felixexplorer.com/tx/",
        dotColor: const Color(0xff1fb6ff),
        priceId: "felix",
        etherscanApiBaseUrl: "https://felixexplorer.com/api/",
      ),

      /// ================== ETHEREUM ==================
      Network(
        nameSpace: "eip155",
        networkName: "Ethereum Mainnet",
        url: ethereumRpc,
        symbol: "ETH",
        currency: "ETH",
        chainId: 1,
        logo: "assets/images/eth.png",
        apiKey: dotenv.env['ETHEREUM_ETHERSCAN_API_KEY'] ?? "",
        isMainnet: true,
        addressViewUrl: "https://etherscan.io/address/",
        transactionViewUrl: "https://etherscan.io/tx/",
        dotColor: Colors.yellow,
        priceId: "ethereum",
        etherscanApiBaseUrl: "https://api.etherscan.io/",
      ),

      /// ================== POLYGON MAINNET ==================
      Network(
        nameSpace: "eip155",
        networkName: "Polygon Mainnet",
        url: dotenv.env['POLYGON_RPC_URL'] ?? "",
        symbol: "MATIC",
        currency: "MATIC",
        chainId: 137,
        logo: "assets/images/polygon.png",
        apiKey: dotenv.env['POLYGON_POLYSCAN_API_KEY'] ?? "",
        isMainnet: true,
        addressViewUrl: "https://polygonscan.com/address/",
        transactionViewUrl: "https://polygonscan.com/tx/",
        dotColor: const Color(0xff8247e5),
        priceId: "matic-network",
        etherscanApiBaseUrl: "https://api.polygonscan.com/",
      ),

      /// ================== POLYGON AMOY TESTNET ==================
      Network(
        nameSpace: "eip155",
        networkName: "Polygon Amoy Testnet",
        url: dotenv.env['POLYGON_TESTNET_AMOY_RPC_URL'] ?? "",
        symbol: "MATIC",
        currency: "MATIC",
        chainId: 80002,
        logo: "assets/images/polygon.png",
        apiKey: dotenv.env['POLYGON_POLYSCAN_API_KEY'] ?? "",
        isMainnet: false,
        addressViewUrl: "https://amoy.polygonscan.com/address/",
        transactionViewUrl: "https://amoy.polygonscan.com/tx/",
        dotColor: const Color(0xff8247e5),
        priceId: "matic-network",
        etherscanApiBaseUrl: "https://api-amoy.polygonscan.com/",
      ),

      /// ================== BINANCE SMART CHAIN ==================
      Network(
        nameSpace: "eip155",
        networkName: "Binance Smart Chain",
        url: dotenv.env['BSC_RPC_URL'] ?? "https://bsc-dataseed.binance.org/",
        symbol: "BNB",
        currency: "BNB",
        chainId: 56,
        logo: "assets/images/bnb.png",
        apiKey: dotenv.env['BSC_BSCSCAN_API_KEY'] ?? "",
        isMainnet: true,
        addressViewUrl: "https://bscscan.com/address/",
        transactionViewUrl: "https://bscscan.com/tx/",
        dotColor: const Color(0xfff3ba2f),
        priceId: "binancecoin",
        etherscanApiBaseUrl: "https://api.bscscan.com/",
      ),

      /// ================== BSC TESTNET ==================
      Network(
        nameSpace: "eip155",
        networkName: "BSC Testnet",
        url:
            dotenv.env['BSC_TESTNET_RPC_URL'] ??
            "https://data-seed-prebsc-1-s1.binance.org:8545/",
        symbol: "tBNB",
        currency: "tBNB",
        chainId: 97,
        logo: "assets/images/bnb.png",
        apiKey: dotenv.env['BSC_BSCSCAN_API_KEY'] ?? "",
        isMainnet: false,
        addressViewUrl: "https://testnet.bscscan.com/address/",
        transactionViewUrl: "https://testnet.bscscan.com/tx/",
        dotColor: const Color(0xfff3ba2f),
        priceId: "binancecoin",
        etherscanApiBaseUrl: "https://api-testnet.bscscan.com/",
      ),

      /// ================== LYNXE SMART CHAIN ==================
      // Network(
      //   nameSpace: "eip155",
      //   networkName: "LYNXE Smart Chain",
      //   url: dotenv.env['LYNXE_RPC_URL'] ?? "https://rpc.lynxexplorer.com",
      //   symbol: "LYNXE",
      //   currency: "LYNXE",
      //   chainId: 9860,
      //   logo: "assets/images/lynxe.png",
      //   apiKey: "",
      //   isMainnet: true,
      //   addressViewUrl: "https://rpc.lynxexplorer.com/address/",
      //   transactionViewUrl: "https://rpc.lynxexplorer.com/tx/",
      //   dotColor: const Color(0xff1fb6ff),
      //   priceId: "lynxe",
      //   etherscanApiBaseUrl: "",
      // ),
    ];
  }
}
