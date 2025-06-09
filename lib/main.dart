// main.dart

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:petverse_front_flutter/screen/pincode_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'injector.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';


final logger = Logger(printer: PrettyPrinter());
final loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');

  // Register SharedPreferences once
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  setupLocator(onAuthError: callBackOnAuthError);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(getIt<AuthService>())),
        ChangeNotifierProvider(create: (_) => DashboardProvider(getIt<UserService>())),
      ],
      child: const PetVerseApp(),
    ),
  );
}

void callBackOnAuthError() async {
  logger.e('[Auth Error] Triggering AuthProvider to clear response.');
  final email = getIt<SharedPreferences>().getString('email') ?? '';

  final navState = navigatorKey.currentState;
  if (navState != null) {
    navState.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => PinCodeScreen(email: email),
      ),
          (_) => false,
    );
  } else {
    logger.e('Navigator state context is null. Cannot navigate.');
  }
}
