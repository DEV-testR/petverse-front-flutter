import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // อย่าลืมเพิ่มใน pubspec.yaml

import '../dto/auth_response.dart';
import '../dto/login_request.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthResponse? _loggedInUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthResponse? get loggedInUser => _loggedInUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _loggedInUser != null; // ตรวจสอบว่า Login แล้วหรือยัง

  AuthProvider(this._authService); // รับ auth_service.dart ผ่าน Constructor (จาก GetIt)

  // เมธอดสำหรับพยายาม Login อัตโนมัติ (เช่น เมื่อเปิดแอป)
  Future<void> autoLogin() async {
    _isLoading = true;
    notifyListeners(); // แจ้งเตือน UI ว่ากำลังโหลด

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');

      if (accessToken != null && accessToken.isNotEmpty) {
        // ในแอปจริง: ควรจะส่ง token นี้ไปตรวจสอบกับ Backend
        // และดึงข้อมูลผู้ใช้กลับมา (เช่น user profile)
        // เพื่อความง่ายในตัวอย่างนี้ เราจะสร้าง LoginResponseDto สมมติขึ้นมา
        _loggedInUser = AuthResponse(
          accessToken: accessToken,
          refreshToken: prefs.getString('refreshToken') ?? '', // ดึง refreshToken
        );
        debugPrint('Auto-login successful with token: $accessToken');
      } else {
        _loggedInUser = null; // ไม่มี token แสดงว่ายังไม่ Login
      }
    } catch (e) {
      debugPrint('Auto-login failed: $e');
      _loggedInUser = null;
      _errorMessage = 'Auto-login failed. Please log in again.';
    } finally {
      _isLoading = false;
      notifyListeners(); // แจ้งเตือน UI ว่าโหลดเสร็จสิ้น
    }
  }

  // เมธอดสำหรับ Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null; // เคลียร์ข้อผิดพลาดก่อนเริ่ม Login ใหม่
    notifyListeners(); // แจ้งเตือน UI ว่ากำลังโหลด

    try {
      final request = LoginRequest(email: email, password: password);
      _loggedInUser = await _authService.login(request); // เรียกใช้ Service

      // เก็บ Token และข้อมูลผู้ใช้ลงใน SharedPreferences เมื่อ Login สำเร็จ
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _loggedInUser!.accessToken);
      await prefs.setString('refreshToken', _loggedInUser!.refreshToken);
      return true; // Login สำเร็จ
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}'; // เก็บข้อความผิดพลาด
      debugPrint('Login Error: $e');
      _loggedInUser = null; // เคลียร์สถานะผู้ใช้
      return false; // Login ไม่สำเร็จ
    } finally {
      _isLoading = false;
      notifyListeners(); // แจ้งเตือน UI ว่าโหลดเสร็จสิ้น
    }
  }

  // เมธอดสำหรับ Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      _loggedInUser = null; // เคลียร์ข้อมูลผู้ใช้
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken'); // ลบ Token ออกจาก SharedPreferences
      await prefs.remove('refreshToken');
      debugPrint('User logged out.');
    } catch (e) {
      debugPrint('Logout Error: $e');
      _errorMessage = 'Failed to log out.';
    } finally {
      _isLoading = false;
      notifyListeners(); // แจ้งเตือน UI ว่าโหลดเสร็จสิ้น
    }
  }
}