import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // อย่าลืมเพิ่มใน pubspec.yaml

import '../dto/auth_response.dart';
import '../dto/login_request.dart';
import '../main.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthResponse? _authResponse;
  bool _isLoading = false;
  String? _errorMessage;
  String _email = '';

  AuthResponse? get loggedInUser => _authResponse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get email => _email;
  bool get isAuthenticated => _authResponse != null; // ตรวจสอบว่า Login แล้วหรือยัง

  AuthProvider(this._authService); // รับ auth_service.dart ผ่าน Constructor (จาก GetIt)

  Future<void> autoLogin() async {
    logger.d('[BEGIN] AuthProvider.autoLogin');
    _isLoading = true;
    notifyListeners(); // แจ้งเตือน UI ว่ากำลังโหลด

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');

      if (accessToken != null && accessToken.isNotEmpty) {
        // ในแอปจริง: ควรจะส่ง token นี้ไปตรวจสอบกับ Backend
        // และดึงข้อมูลผู้ใช้กลับมา (เช่น user profile)
        // เพื่อความง่ายในตัวอย่างนี้ เราจะสร้าง LoginResponseDto สมมติขึ้นมา
        _authResponse = AuthResponse(
          accessToken: accessToken,
          refreshToken: prefs.getString('refreshToken') ?? '', // ดึง refreshToken
        );
        logger.d('Auto-login successful with token: $accessToken');
      } else {
        _authResponse = null; // ไม่มี token แสดงว่ายังไม่ Login
        logger.d('Auto-login Failed Token Not Found.');
      }
    } catch (e) {
      debugPrint('Auto-login failed: $e');
      _authResponse = null;
      _errorMessage = 'Auto-login failed. Please log in again.';
    } finally {
      _isLoading = false;
      notifyListeners(); // แจ้งเตือน UI ว่าโหลดเสร็จสิ้น
    }
  }

  Future<bool> login(String email, String password) async {
    logger.d('[BEGIN] AuthProvider.login');
    _isLoading = true;
    _errorMessage = null; // เคลียร์ข้อผิดพลาดก่อนเริ่ม Login ใหม่
    notifyListeners(); // แจ้งเตือน UI ว่ากำลังโหลด

    try {
      final request = LoginRequest(email: email, password: password);
      _authResponse = await _authService.login(request); // เรียกใช้ Service

      // เก็บ Token และข้อมูลผู้ใช้ลงใน SharedPreferences เมื่อ Login สำเร็จ
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('accessToken', _authResponse!.accessToken);
      await prefs.setString('refreshToken', _authResponse!.refreshToken);
      return true; // Login สำเร็จ
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}'; // เก็บข้อความผิดพลาด
      debugPrint('Login Error: $e');
      _authResponse = null; // เคลียร์สถานะผู้ใช้
      return false; // Login ไม่สำเร็จ
    } finally {
      _isLoading = false;
      notifyListeners(); // แจ้งเตือน UI ว่าโหลดเสร็จสิ้น
    }
  }

  Future<bool> loginWithPin(String email, String pin) async {
    logger.d('[BEGIN] AuthProvider.loginWithPin');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // แจ้งเตือน UI ว่ากำลังโหลด

    try {
      _authResponse = await _authService.loginWithPin(email, pin);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('accessToken', _authResponse!.accessToken);
      await prefs.setString('refreshToken', _authResponse!.refreshToken);

      // *** สำคัญมาก: อัปเดตสถานะ _isAuthenticated ***
      notifyListeners(); // แจ้งเตือนอีกครั้งหลังจากการรับรองความถูกต้อง
      // เพื่อให้ Consumer ใน main.dart อัปเดต UI

      logger.d('[AuthProvider] loginWithPin success, isAuthenticated: $isAuthenticated');
      return true; // Login สำเร็จ
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      debugPrint('Login Error: $e');
      _authResponse = null;

      // *** สำคัญมาก: อัปเดตสถานะ _isAuthenticated ในกรณีที่ Login ไม่สำเร็จ ***
      notifyListeners(); // แจ้งเตือนเมื่อเกิดข้อผิดพลาด เพื่อให้อัปเดต UI หากจำเป็น

      logger.e('[AuthProvider] loginWithPin failed, isAuthenticated: $isAuthenticated');
      return false; // Login ไม่สำเร็จ
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> validateEmail(String email) async {
    logger.d('[BEGIN] AuthProvider.login');
    // _isLoading = true;
    // _errorMessage = null; // เคลียร์ข้อผิดพลาดก่อนเริ่ม Login ใหม่
    // notifyListeners(); // แจ้งเตือน UI ว่ากำลังโหลด

    try {
      return await _authService.validateEmail(email); // เรียกใช้ Service
    } catch (e) {
      // _errorMessage = 'VerifilyEmail failed: ${e.toString()}'; // เก็บข้อความผิดพลาด
      logger.d('VerifilyEmail Error: $e');
      return false;
    } finally {
      // _isLoading = false;
      // notifyListeners(); // แจ้งเตือน UI ว่าโหลดเสร็จสิ้น
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      _authResponse = null; // เคลียร์ข้อมูลผู้ใช้
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken'); // ลบ Token ออกจาก SharedPreferences
      await prefs.remove('refreshToken');
      logger.d('User logged out.');
    } catch (e) {
      logger.d('Logout Error: $e');
      _errorMessage = 'Failed to log out.';
    } finally {
      _isLoading = false;
      notifyListeners(); // แจ้งเตือน UI ว่าโหลดเสร็จสิ้น
    }
  }

}