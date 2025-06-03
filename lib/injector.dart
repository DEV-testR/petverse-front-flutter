// lib/injector.dart

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:petverse_front_flutter/providers/auth_provider.dart';
import 'package:petverse_front_flutter/providers/dashboard_provider.dart';
import 'package:petverse_front_flutter/services/auth_service.dart';
import 'package:petverse_front_flutter/services/user_service.dart';

import 'core/network/dio_client.dart'; // <<< เพิ่ม

final GetIt getIt = GetIt.instance; // <-- นี่คือตัวแปร getIt ที่ main.dart จะเข้าถึงได้

void setupLocator() {
  // Register Dio (HTTP Client library)
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Register DioClient (your custom wrapper for Dio)
  // ให้ DioClient ใช้ Dio instance ที่ถูก register ไว้
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt()));

  // Register AuthService (handles authentication API calls)
  // ให้ AuthService ใช้ DioClient instance ที่ถูก register ไว้
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt()));

  // Register UserService (handles user data API calls)
  // ให้ UserService ใช้ DioClient instance ที่ถูก register ไว้
  getIt.registerLazySingleton<UserService>(() => UserService(getIt()));

  // Register AuthProvider (manages authentication state)
  // AuthProvider ต้องการ AuthService
  getIt.registerLazySingleton<AuthProvider>(() => AuthProvider(getIt()));

  // Register DashboardProvider (manages dashboard data, e.g., list of users)
  // DashboardProvider ต้องการ UserService
  getIt.registerFactory<DashboardProvider>(() => DashboardProvider(getIt()));

  // คุณสามารถเพิ่มการ register สำหรับ service/provider อื่นๆ ได้ที่นี่
}