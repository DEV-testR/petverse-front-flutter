// lib/injector.dart

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart'; // Import for VoidCallback
import 'package:petverse_front_flutter/providers/auth_provider.dart';
import 'package:petverse_front_flutter/providers/dashboard_provider.dart';
import 'package:petverse_front_flutter/services/auth_service.dart';
import 'package:petverse_front_flutter/services/user_service.dart';

import 'core/network/dio_client.dart';
import 'core/network/api_constants.dart'; // Ensure this path is correct for baseUrl

final GetIt getIt = GetIt.instance;

// Adjust setupLocator to receive onAuthErrorRedirectToPin callback
void setupLocator({required VoidCallback onAuthError}) {
  // Register Dio (HTTP Client library)
  // Ensure BaseOptions with baseUrl are set here for all Dio requests
  getIt.registerLazySingleton<Dio>(() => Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)));

  // Register DioClient (your custom wrapper for Dio)
  // Pass the Dio instance and the onAuthErrorRedirectToPin callback
  getIt.registerLazySingleton<DioClient>(
          () => DioClient(getIt<Dio>(), onAuthError: onAuthError));

  // Register AuthService (handles authentication API calls)
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt<DioClient>()));

  // Register UserService (handles user data API calls)
  getIt.registerLazySingleton<UserService>(() => UserService(getIt<DioClient>()));

  // Register AuthProvider (manages authentication state)
  // This is registered as LazySingleton because it's a global state manager
  getIt.registerLazySingleton<AuthProvider>(() => AuthProvider(getIt<AuthService>()));

  // Register DashboardProvider (manages dashboard data, e.g., list of users)
  // This is registered as Factory because each screen might need its own instance
  getIt.registerFactory<DashboardProvider>(() => DashboardProvider(getIt<UserService>()));
}