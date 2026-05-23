// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallet_cryptomask/core/remote/response-model/settings_response.dart';
import 'package:wallet_cryptomask/main_app.dart';
import 'package:wallet_cryptomask/core/model/collectible_model.dart';
import 'package:wallet_cryptomask/core/model/contact_model.dart';
import 'package:wallet_cryptomask/core/model/token_model.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:wallet_cryptomask/ui/screens/login-screen/login_screen.dart';
import 'package:wallet_cryptomask/ui/screens/onboarding-screen/new-splash/new_onboarding.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await dotenv.load(fileName: '.env');

  await loadAppSettings();

  await initHiveAdapter();

  Box box = await Hive.openBox("user_preference");

  runApp(
    MainApp(
      locale: await getAppLocale(box),
      initialWidget: await getInitialWidget(),
      userPreferenceBox: box,
    ),
  );
}

initHiveAdapter() async {
  if (kIsWeb) {
    Hive
      ..init("")
      ..registerAdapter(TokenAdapter())
      ..registerAdapter(CollectibleAdapter())
      ..registerAdapter(ContactAdapter());
  } else {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive
      ..init(appDocumentDirectory.path)
      ..registerAdapter(TokenAdapter())
      ..registerAdapter(CollectibleAdapter())
      ..registerAdapter(ContactAdapter());
  }
}

getAppLocale(Box box) async {
  return (await box.get("LOCALE")) ?? "en";
}

loadAppSettings() async {
  try {
    final settingsResponse = await RemoteServer.settings().timeout(
      const Duration(seconds: 10),
    );
    if (Get.isRegistered<Settings>()) {
      Get.replace<Settings>(settingsResponse.data);
    } else {
      Get.put(settingsResponse.data);
    }
  } catch (e) {
    log(e.toString());
    final fallbackSettings = Settings(
      helpUrl: "",
      tcUrl: "",
      ppUrl: "",
      about: "",
    );
    if (Get.isRegistered<Settings>()) {
      Get.replace<Settings>(fallbackSettings);
    } else {
      Get.put(fallbackSettings);
    }
  }
}

Future<Widget> getInitialWidget() async {
  FlutterSecureStorage fss = const FlutterSecureStorage();
  String? wallet = await fss.read(key: "wallet");
  if (wallet != null) {
    return const LoginScreen();
  } else {
    return const OnboardingScreenWidget();
    // OnboardScreen();
  }
}
