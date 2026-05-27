import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:felix_wallet_crypto/constant.dart';
import 'package:felix_wallet_crypto/ui/screens/home-screen/new_home_screen.dart';
import 'package:felix_wallet_crypto/ui/screens/home-screen/widgets/account_change_sheet.dart';
import 'package:felix_wallet_crypto/ui/screens/home-screen/widgets/new_profile_account.dart';
import 'package:felix_wallet_crypto/ui/screens/transaction-history-screen/transaction_history_screen.dart';
import 'package:felix_wallet_crypto/ui/shared/wallet_button.dart';
import 'package:felix_wallet_crypto/ui/tabs/browser/browser_tab.dart';

class CustomNavigationBarWdget extends StatefulWidget {
  const CustomNavigationBarWdget({Key? key}) : super(key: key);

  @override
  State<CustomNavigationBarWdget> createState() =>
      _CustomNavigationBarWdgetState();
}

class _CustomNavigationBarWdgetState extends State<CustomNavigationBarWdget> {
  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );
  int _lastStableIndex = 0;

  Future<void> _showAccountChangeConfirmation() async {
    final bool isConfirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Are you sure you want to create a new account'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: WalletButton(
                          borderRadius: 44.0,
                          localizeKey: 'Cancel',
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: WalletButton(
                          borderRadius: 44.0,
                          type: WalletButtonType.gradient,
                          onPressed: () => Navigator.of(context).pop(true),
                          localizeKey: 'Confirm',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ) ??
        false;

    if (!mounted || !isConfirmed) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => const AccountChangeSheet(),
    );
  }

  void _onNavItemSelected(int index) {
    // Intercept the center Add tab (mapped to ExploreScreen) for account creation.
    if (index == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.jumpToTab(_lastStableIndex);
        }
      });
      _showAccountChangeConfirmation();
      return;
    }
    _lastStableIndex = index;
  }

  List<Widget> _buildScreens() {
    return [
      // const HomeScreen(),
      const NewHomeScreen(),
      BrowserTab(index: 1),
      const ExploreScreen(),
      const TransactionHistoryScreen(),
      const ProfileAccountWidget(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Iconsax.home),
        inactiveIcon: const Icon(Iconsax.home_copy),
        title: "Home",
        activeColorPrimary: kPrimaryColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Iconsax.discover),
        inactiveIcon: const Icon(Iconsax.discover_1_copy),
        title: "Explore",
        activeColorPrimary: kPrimaryColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Iconsax.add_copy, color: Colors.white),
        title: "Add",
        activeColorPrimary: kPrimaryColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Iconsax.receipt),
        inactiveIcon: const Icon(Iconsax.receipt_copy),
        title: "History",
        activeColorPrimary: kPrimaryColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Iconsax.user),
        inactiveIcon: const Icon(Iconsax.user_copy),
        title: "Account",
        activeColorPrimary: kPrimaryColor,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: PersistentTabView(
        navBarHeight: 65,
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarItems(),
        navBarStyle: NavBarStyle.style15,
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        handleAndroidBackButtonPress: true,
        stateManagement: true,
        onItemSelected: _onNavItemSelected,
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('History')));
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Explore')));
  }
}

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Add')));
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Account')));
  }
}
