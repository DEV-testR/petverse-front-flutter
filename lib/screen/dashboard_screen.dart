import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widget/loading_component.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // เรียก fetchUsers เมื่อหน้า Dashboard ถูกสร้างขึ้น
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลผู้ใช้ที่ Login เข้ามา
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final String? accessToken = authProvider.loggedInUser?.accessToken;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          // ปุ่ม Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              // หลังจาก Logout แล้ว HomePage (Root widget) จะตรวจจับการเปลี่ยนแปลง
              // ของ AuthProvider.isAuthenticated และนำทางกลับไปยัง LoginPage อัตโนมัติ
            },
            tooltip: 'ออกจากระบบ',
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ยินดีต้อนรับ, N/A!',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'N/A',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'รายชื่อผู้ใช้จาก API:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded( // ใช้ Expanded เพื่อให้ ListView กินพื้นที่ที่เหลือ
                child: Builder( // ใช้ Builder เพื่อให้ context พร้อมใช้งานภายใน
                  builder: (context) {
                    if (dashboardProvider.isLoading) {
                      return const Center(child: LoadingIndicator()); // แสดง Loading Indicator
                    } else if (dashboardProvider.errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dashboardProvider.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => dashboardProvider.fetchUsers(),
                                child: const Text('ลองใหม่'),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (dashboardProvider.users.isEmpty) {
                      return const Center(child: Text('ไม่พบข้อมูลผู้ใช้')); // ถ้าไม่มีข้อมูล
                    } else {
                      // แสดงรายการผู้ใช้ใน ListView
                      return ListView.builder(
                        itemCount: dashboardProvider.users.length,
                        itemBuilder: (context, index) {
                          final user = dashboardProvider.users[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                    (user.fullName != null && user.fullName!.isNotEmpty) ? user.fullName! : 'Empty Name',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text((user.fullName != null && user.fullName!.isNotEmpty) ? user.fullName! : 'Empty Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(user.email),
                              trailing: Text('ID: ${user.id}'),
                              onTap: () {
                                // TODO: Implement navigation to user detail page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('คลิกที่ผู้ใช้: ${user.fullName}')),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}