import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widget/appcard_widget.dart';
import '../widget/cardaction_widget.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchUsers();
    });
  }

  void logout() async {
    logger.d('[BEGIN] logout');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (!mounted) {
        logger.d('Widget unmounted after API call, stopping further operations.');
        return; // ถ้า Widget ไม่อยู่ใน tree แล้ว ไม่ต้องทำอะไรต่อ
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } catch (e) {
      logger.e('Error validating email: $e');
    } finally {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800], // สีน้ำเงินเข้มตามรูป
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.business_center, // หรือไอคอนที่คล้ายกับโลโก้
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Today',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(width: 8),
            Text(
              'Friday, June 6', // วันที่ปัจจุบัน
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
        actions: [
          // แทน IconButton ด้วย PopupMenuButton
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white), // ไอคอนตั้งค่า
            onSelected: (String result) async {
              if (result == 'logout') {
                logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red), // ไอคอน logout
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)), // ข้อความ logout
                  ],
                ),
              ),
            ],
            offset: const Offset(0, 50), // ปรับตำแหน่ง Dropdown ให้ไม่ทับ AppBar
            color: Colors.white, // สีพื้นหลังของ dropdown
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 4,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppCard(
              icon: Icons.announcement,
              title: 'Announcement',
              content: 'No recent announcements',
              showViewAll: true,
            ),
            AppCard(
              icon: Icons.checklist,
              title: 'Qbic',
              content: 'No recent To Do',
              showViewAll: true,
            ),
            AppCard(
              icon: Icons.group,
              title: 'Meet',
              content: 'No upcoming meetings',
              buttons: [
                CardActionButton(text: '+ Join', color: Colors.red[400]!),
                CardActionButton(text: '+ Create New', color: Colors.red[400]!),
              ],
              showViewAll: true,
            ),
            AppCard(
              icon: Icons.calendar_today,
              title: 'Webinar',
              content: 'No upcoming webinars',
              buttons: [
                CardActionButton(text: '+ Create New', color: Colors.blue[400]!),
              ],
              showViewAll: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text(
                'Reorder',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.star), // หรือไอคอนที่คล้ายกับในรูป
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.email),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
        currentIndex: 0, // ตั้งค่าให้ Today เป็นอันที่เลือก
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}
