// ignore_for_file: use_build_context_synchronously

import 'dart:collection';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:felix_wallet_crypto/constant.dart';
import 'package:felix_wallet_crypto/core/providers/browser_provider/browser_provider.dart';
import 'package:felix_wallet_crypto/core/model/wc_ethereum_transaction.dart';
import 'package:felix_wallet_crypto/core/providers/wallet_provider/wallet_provider.dart';
import 'package:felix_wallet_crypto/l10n/transalation.dart';
import 'package:felix_wallet_crypto/ui/screens/wallet-connect-screen/widgets/connect_sheet.dart';
import 'package:felix_wallet_crypto/ui/screens/wallet-connect-screen/widgets/transaction_sheet.dart';
import 'package:felix_wallet_crypto/ui/utils/ui_utils.dart';

class BrowserView extends StatefulWidget {
  final BrowserProvider webViewModel;
  final Function(String, BrowserProvider) onUrlSubmit;

  const BrowserView({
    super.key,
    required this.webViewModel,
    required this.onUrlSubmit,
  });

  @override
  State<BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  InAppWebViewController? webViewController;
  double progress = 0;
  double progressFactor = 0;
  bool? certified;
  PullToRefreshController? pullToRefreshController;
  bool showHomeButton = false;
  bool showBrowser = true;
  WebUri? url;
  bool dissableProgressAnimation = false;
  bool isAttached = false;
  PullToRefreshController refreshController = PullToRefreshController();
  bool _isConnectDialogOpen = false;
  bool _hasShownConnectedMessage = false;
  Map<String, dynamic> _failure(
    String method,
    String message, {
    bool showUiWarning = true,
  }) {
    debugPrint("[BrowserView][Ethereum][$method] $message");
    if (showUiWarning && mounted) {
      showWarningSnackBar(
        context,
        getText(context, key: 'walletConnect'),
        "$method: $message",
      );
    }
    return {'success': false, 'error': message};
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InAppWebView(
            initialUserScripts: UnmodifiableListView<UserScript>([
              UserScript(
                source: _ethereumProviderScript,
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
              ),
            ]),
            initialSettings: InAppWebViewSettings(
              domStorageEnabled: true,
              allowFileAccess: true,
              useShouldOverrideUrlLoading: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
            ),
            onWebViewCreated: (controller) async {
              webViewController = controller;
              widget.webViewModel.webViewController = controller;
              _registerEthereumHandler(controller);
              loadHomepage();
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              log("HTTP ERROR OCCURED ===> ${errorResponse.statusCode}");
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final requestedUrl = navigationAction.request.url;
              if (requestedUrl != null &&
                  requestedUrl.toString().trim().startsWith("wc:")) {
                await handleRequestToWalletConnect(
                  context,
                  requestedUrl.uriValue,
                );
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onReceivedError: (controller, request, error) {},
            onLoadStart: (controller, url) async {
              // checkRequestIsWalletConnect(url);
              var favIcons = await webViewController?.getFavicons();
              if (favIcons != null && favIcons.isNotEmpty) {
                widget.webViewModel.favicon = favIcons[0];
              }
              isAttached = false;
              widget.webViewModel.url = await controller.getUrl();
              setState(() {
                progress = 0.0;
                dissableProgressAnimation = false;
              });
              progressFactor = MediaQuery.of(context).size.width / 100;
              if (url != null && url.scheme == "https") {
                widget.webViewModel.isSecure = true;
              } else {
                widget.webViewModel.isSecure = false;
              }
              widget.webViewModel.webViewController = controller;
              setState(() {});
            },
            onProgressChanged: (controller, progress) async {
              widget.webViewModel.progress =
                  double.parse(progress.toString()) * progressFactor;
              this.progress =
                  double.parse(progress.toString()) * progressFactor;
              if (progress == 100) {
                widget.webViewModel.title =
                    await widget.webViewModel.webViewController?.getTitle() ??
                    "New page";
              }
              setState(() {});
            },
            onLoadStop: (controller, url) async {
              log(url.toString());
              await _injectEthereumProvider(controller);
            },
          ),
        ),
        Container(width: progress, height: 2, color: kPrimaryColor),
      ],
    );
  }

  void loadHomepage() async {
    widget.webViewModel.webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(dotenv.env['BROWSER_HOMEPAGE'] ?? "")),
    );
  }

  void _registerEthereumHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'cryptomaskEthereumRequest',
      callback: (args) async {
        if (args.isEmpty || args.first is! Map) {
          return _failure("unknown", "Invalid request payload");
        }
        final payload = Map<String, dynamic>.from(args.first as Map);
        final method = payload['method']?.toString() ?? '';
        final params = payload['params'];
        debugPrint(
          "[BrowserView][Ethereum] request method=$method params=$params",
        );

        return _handleEthereumMethod(method, params);
      },
    );
  }

  Future<Map<String, dynamic>> _handleEthereumMethod(
    String method,
    dynamic params,
  ) async {
    final walletProvider = getWalletProvider(context);
    final account = walletProvider.activeWallet.wallet.privateKey.address.hex;
    final chainIdHex =
        "0x${walletProvider.activeNetwork.chainId.toRadixString(16)}";

    if (method == 'eth_requestAccounts') {
      final approved = await _showConnectDialog();
      if (!approved) {
        return _failure(method, "User rejected the request");
      }
      await _syncEthereumState(account, chainIdHex);
      _showConnectedMessage();
      debugPrint("[BrowserView][Ethereum] approved account=$account");
      return {
        'success': true,
        'data': [account],
      };
    }

    if (method == 'eth_accounts') {
      return {
        'success': true,
        'data': [account],
      };
    }

    if (method == 'eth_coinbase') {
      return {'success': true, 'data': account};
    }

    if (method == 'eth_chainId') {
      await _syncEthereumState(account, chainIdHex, emitAccounts: false);
      debugPrint("[BrowserView][Ethereum] chainId=$chainIdHex");
      return {'success': true, 'data': chainIdHex};
    }

    if (method == 'wallet_requestPermissions') {
      final approved = await _showConnectDialog();
      if (!approved) {
        return _failure(method, "User rejected the request");
      }
      await _syncEthereumState(account, chainIdHex);
      _showConnectedMessage();
      return {
        'success': true,
        'data': [
          {'parentCapability': 'eth_accounts', 'caveats': []},
        ],
      };
    }

    if (method == 'wallet_getPermissions') {
      return {
        'success': true,
        'data': [
          {'parentCapability': 'eth_accounts', 'caveats': []},
        ],
      };
    }

    if (method == 'net_version') {
      return {
        'success': true,
        'data': walletProvider.activeNetwork.chainId.toString(),
      };
    }

    if (method == 'eth_call') {
      try {
        if (params is! List || params.isEmpty) {
          return _failure(method, "Invalid eth_call params");
        }
        final result = await walletProvider.web3client.makeRPCCall<dynamic>(
          'eth_call',
          params,
        );
        debugPrint("[BrowserView][Ethereum] eth_call result=$result");
        return {'success': true, 'data': result};
      } catch (e) {
        return _failure(method, e.toString());
      }
    }

    if (method == 'eth_gasPrice') {
      try {
        final gasPrice = await walletProvider.web3client.getGasPrice();
        final gasPriceHex = "0x${gasPrice.getInWei.toRadixString(16)}";
        debugPrint("[BrowserView][Ethereum] eth_gasPrice result=$gasPriceHex");
        return {'success': true, 'data': gasPriceHex};
      } catch (e) {
        return _failure(method, e.toString());
      }
    }

    if (method == 'eth_sendTransaction') {
      try {
        if (params is! List || params.isEmpty || params.first is! Map) {
          return _failure(method, "Invalid eth_sendTransaction params");
        }
        final txPayload = Map<String, dynamic>.from(params.first as Map);
        final from = txPayload['from']?.toString().toLowerCase() ?? '';
        if (from.isEmpty || from != account.toLowerCase()) {
          return _failure(method, "From address mismatch");
        }

        final txHash = await _showSendTransactionDialog(
          WCEthereumTransaction.fromJson(txPayload),
        );
        if (txHash == null || txHash.isEmpty) {
          return _failure(method, "User rejected the request");
        }

        debugPrint(
          "[BrowserView][Ethereum] eth_sendTransaction txHash=$txHash",
        );
        return {'success': true, 'data': txHash};
      } catch (e) {
        return _failure(method, e.toString());
      }
    }

    if (method == 'eth_getTransactionReceipt') {
      try {
        if (params is! List || params.isEmpty) {
          return _failure(method, "Invalid eth_getTransactionReceipt params");
        }
        final result = await walletProvider.web3client.makeRPCCall<dynamic>(
          'eth_getTransactionReceipt',
          params,
        );
        return {'success': true, 'data': result};
      } catch (e) {
        return _failure(method, e.toString());
      }
    }

    if (method == 'wallet_switchEthereumChain') {
      try {
        if (params is List && params.isNotEmpty && params.first is Map) {
          final chainHex = params.first['chainId']?.toString() ?? '';
          final chainId = int.tryParse(
            chainHex.replaceFirst('0x', ''),
            radix: 16,
          );
          if (chainId != null) {
            final index = walletProvider.networks.indexWhere(
              (network) => network.chainId == chainId,
            );
            if (index != -1) {
              await walletProvider.changeNetwork(index);
              final switchedChainIdHex =
                  "0x${walletProvider.activeNetwork.chainId.toRadixString(16)}";
              await _syncEthereumState(
                account,
                switchedChainIdHex,
                emitAccounts: false,
              );
              debugPrint(
                "[BrowserView][Ethereum] switched chainId=$chainId index=$index",
              );
              return {'success': true, 'data': null};
            }
          }
        }
        return _failure(method, "Unsupported chain switch request");
      } catch (e) {
        return _failure(method, e.toString());
      }
    }

    if (method == 'eth_subscribe') {
      return _failure(
        method,
        "Method $method not supported yet",
        showUiWarning: false,
      );
    }

    return _failure(method, "Method $method not supported yet");
  }

  Future<String?> _showSendTransactionDialog(
    WCEthereumTransaction transaction,
  ) async {
    final completer = Completer<String?>();
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      enableDrag: false,
      backgroundColor: Colors.white,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: context.read<WalletProvider>(),
        child: TransactionSheet(
          fromWalletConnect: true,
          iconUrl: widget.webViewModel.favicon?.url.toString() ?? "",
          connectingOrgin:
              widget.webViewModel.url?.toString() ?? "Current DApp",
          transaction: transaction.toJson(),
          onApprove: (txHash) {
            if (!completer.isCompleted) completer.complete(txHash);
          },
          onReject: () {
            if (!completer.isCompleted) completer.complete(null);
          },
        ),
      ),
    );

    if (!completer.isCompleted) {
      completer.complete(null);
    }
    return completer.future;
  }

  Future<bool> _showConnectDialog() async {
    if (_isConnectDialogOpen) return false;
    _isConnectDialogOpen = true;

    final currentUrl = widget.webViewModel.url?.toString() ?? "Current DApp";
    final favIcon = widget.webViewModel.favicon?.url.toString() ?? "";

    final approved =
        await showModalBottomSheet<bool>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) => ChangeNotifierProvider.value(
            value: context.read<WalletProvider>(),
            child: ConnectSheet(
              connectingOrgin: currentUrl,
              imageUrl: favIcon,
              onApprove: (_) => Navigator.of(sheetContext).pop(true),
              onReject: () => Navigator.of(sheetContext).pop(false),
            ),
          ),
        ) ??
        false;

    _isConnectDialogOpen = false;
    return approved;
  }

  void _showConnectedMessage() {
    if (_hasShownConnectedMessage || !mounted) return;
    _hasShownConnectedMessage = true;
    showPositiveSnackBar(
      context,
      getText(context, key: 'walletConnect'),
      "Wallet connected successfully",
    );
  }

  Future<void> _syncEthereumState(
    String account,
    String chainIdHex, {
    bool emitAccounts = true,
  }) async {
    await webViewController?.evaluateJavascript(
      source:
          "window.__cryptomaskSetState && window.__cryptomaskSetState('$account', '$chainIdHex', $emitAccounts);",
    );
  }

  Future<void> _injectEthereumProvider(
    InAppWebViewController controller,
  ) async {
    await controller.evaluateJavascript(source: _ethereumProviderScript);
  }

  String get _ethereumProviderScript => '''
    (function () {
      if (window.ethereum && window.ethereum.isCryptoMask) return;
      const ethereum = {
        isMetaMask: true,
        isCryptoMask: true,
        selectedAddress: null,
        chainId: null,
        _listeners: {},
        isConnected: function() {
          return true;
        },
        request: function(args) {
          return window.flutter_inappwebview
            .callHandler('cryptomaskEthereumRequest', args || {})
            .then(function(resp) {
              if (!resp || !resp.success) {
                throw new Error((resp && resp.error) || 'Request failed');
              }
              return resp.data;
            });
        },
        enable: function() {
          return this.request({ method: 'eth_requestAccounts', params: [] });
        },
        on: function(eventName, handler) {
          if (!this._listeners[eventName]) this._listeners[eventName] = [];
          this._listeners[eventName].push(handler);
          return this;
        },
        removeListener: function(eventName, handler) {
          const listeners = this._listeners[eventName] || [];
          this._listeners[eventName] = listeners.filter(function(item) {
            return item !== handler;
          });
          return this;
        },
        _emit: function(eventName, payload) {
          const listeners = this._listeners[eventName] || [];
          listeners.forEach(function(handler) {
            try { handler(payload); } catch (_) {}
          });
        }
      };
      window.ethereum = ethereum;
      window.__cryptomaskSetState = function(account, chainId, emitAccounts) {
        ethereum.selectedAddress = account;
        ethereum.chainId = chainId;
        ethereum._emit('connect', { chainId: chainId });
        ethereum._emit('chainChanged', chainId);
        if (emitAccounts) ethereum._emit('accountsChanged', [account]);
      };
      if (!window.web3) {
        window.web3 = { currentProvider: ethereum };
      }
    })();
  ''';
}

Future<void> handleRequestToWalletConnect(BuildContext context, Uri url) async {
  final walletProvider = getWalletProvider(context);
  final web3Wallet = walletProvider.web3Wallet;
  final isValidWcUri =
      url.scheme == "wc" && url.queryParameters["symKey"] != null;

  if (!isValidWcUri) {
    showWarningSnackBar(
      context,
      getText(context, key: 'walletConnect'),
      "Invalid WalletConnect request",
    );
    return;
  }

  if (web3Wallet == null) {
    showErrorSnackBar(
      context,
      getText(context, key: 'error'),
      "WalletConnect is not initialized yet",
    );
    return;
  }

  try {
    await web3Wallet.pair(uri: url);
    if (context.mounted) {
      showPositiveSnackBar(
        context,
        getText(context, key: 'walletConnect'),
        "Connection request received. Please approve it.",
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    final errorMessage = e.toString();
    if (errorMessage.toLowerCase().contains("pairing already exists")) {
      showWarningSnackBar(
        context,
        getText(context, key: 'walletConnect'),
        "This DApp is already connected",
      );
      return;
    }

    showErrorSnackBar(context, getText(context, key: 'error'), errorMessage);
  }
}
