// lib/presentation/providers/dashboard_provider.dart

import 'package:flutter/material.dart';

import '../dto/user.dart';
import '../services/user_service.dart';

class DashboardProvider extends ChangeNotifier {
  final UserService _userService; // รับ UserService ผ่าน Constructor

  // สถานะข้อมูลผู้ใช้
  List<User> _listUser = [];
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters สำหรับเข้าถึงสถานะจากภายนอก
  User? get userProfile => _user;
  List<User> get users => _listUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DashboardProvider(this._userService); // Constructor สำหรับรับ UserService

  /// เมธอดสำหรับดึงข้อมูลผู้ใช้จาก API
  Future<void> fetchListUsers() async {
    _isLoading = true;
    _errorMessage = null; // เคลียร์ข้อผิดพลาดเก่า
    notifyListeners(); // แจ้ง UI ว่าสถานะกำลังโหลด

    try {
      // เรียกใช้ UserService เพื่อดึงข้อมูลผู้ใช้
      _listUser = await _userService.fetchListUsers();
    } catch (e) {
      // จัดการข้อผิดพลาดที่เกิดขึ้นขณะดึงข้อมูล
      _errorMessage = 'ไม่สามารถโหลดข้อมูลผู้ใช้ได้: ${e.toString()}';
      debugPrint('Error fetching users in DashboardProvider: $e'); // สำหรับ debugging
    } finally {
      _isLoading = false;
      notifyListeners(); // แจ้ง UI ว่าสถานะการโหลดเสร็จสิ้น (ไม่ว่าจะสำเร็จหรือมีข้อผิดพลาด)
    }
  }

  Future<void> fetchUsersProfile() async {
    _isLoading = true;
    _errorMessage = null; // เคลียร์ข้อผิดพลาดเก่า
    notifyListeners(); // แจ้ง UI ว่าสถานะกำลังโหลด

    try {
      // เรียกใช้ UserService เพื่อดึงข้อมูลผู้ใช้
      _user = await _userService.fetchUser();
    } catch (e) {
      // จัดการข้อผิดพลาดที่เกิดขึ้นขณะดึงข้อมูล
      _errorMessage = 'ไม่สามารถโหลดข้อมูลผู้ใช้ได้: ${e.toString()}';
      debugPrint('Error fetching users in DashboardProvider: $e'); // สำหรับ debugging
    } finally {
      _isLoading = false;
      notifyListeners(); // แจ้ง UI ว่าสถานะการโหลดเสร็จสิ้น (ไม่ว่าจะสำเร็จหรือมีข้อผิดพลาด)
    }
  }

// คุณสามารถเพิ่มเมธอดอื่นๆ ที่เกี่ยวข้องกับ Dashboard ได้ที่นี่
// เช่น: refreshUsers(), deleteUser(userId), filterUsers() เป็นต้น
}