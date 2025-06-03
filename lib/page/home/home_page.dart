import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/loading_component.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_page.dart';
import '../login/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // เรียก autoLogin เมื่อหน้าจอถูกสร้างขึ้น
    // WidgetsBinding.instance.addPostFrameCallback รับประกันว่า build context พร้อมใช้งาน
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).autoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consumer จะ rebuild UI เมื่อ AuthProvider มีการเปลี่ยนแปลง
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          // แสดง Loading Indicator ขณะกำลังตรวจสอบสถานะ Login
          return const Scaffold(
            body: Center(child: LoadingIndicator()),
          );
        } else {
          // ถ้า Login แล้ว (isAuthenticated เป็น true) ไปที่ Dashboard
          if (authProvider.isAuthenticated) {
            return const DashboardPage();
          } else {
            // ถ้ายังไม่ Login ไปที่หน้า Login
            return const LoginPage();
          }
        }
      },
    );
  }
}