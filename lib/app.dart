// app.dart

import 'package:flutter/material.dart';
import 'package:petverse_front_flutter/screen/dashboard_screen.dart';
import 'package:petverse_front_flutter/screen/login_screen.dart';
import 'package:petverse_front_flutter/widget/loading_widget.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'providers/auth_provider.dart';

class PetVerseApp extends StatefulWidget {
  const PetVerseApp({super.key});

  @override
  State<PetVerseApp> createState() => _PetVerseAppState();
}

class _PetVerseAppState extends State<PetVerseApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.d('[MyApp] calling autoLogin in initState');
      Provider.of<AuthProvider>(context, listen: false).autoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.d('[MyApp] build method called');
    return MaterialApp(
      title: 'PetVerse',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          logger
            ..d('[MyApp] authProvider.isLoading: ${authProvider.isLoading}')
            ..d('[MyApp] authProvider.isAuthenticated: ${authProvider.isAuthenticated}')
            ..d('[MyApp] authProvider.email: ${authProvider.email}');

          if (authProvider.isLoading) {
            return const Scaffold(body: Center(child: LoadingIndicator()));
          }

          return authProvider.isAuthenticated
              ? const DashboardScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
