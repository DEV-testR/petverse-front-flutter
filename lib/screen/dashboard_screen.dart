import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:petverse_front_flutter/screen/login_screen.dart';
import 'package:petverse_front_flutter/screen/userprofile_screen.dart';
import 'package:provider/provider.dart';


import '../dto/user.dart';
import '../main.dart'; // For logger
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import 'dashboard_inbox_content.dart';
import 'dashboard_feed_content.dart';
import 'dashboard_more_content.dart';
import 'dashboard_team_content.dart';
import 'dashboard_today_content.dart';
// ไม่จำเป็นต้อง import 'cardaction_widget.dart' ตรงนี้แล้ว ถ้ามันถูกย้ายไปใน dashboard_content.dart

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // ตัวแปรสำหรับเก็บ index ของแท็บที่ถูกเลือก

  // รายการของ Widget (หน้าจอ) ที่จะแสดงผลเมื่อแต่ละแท็บถูกเลือก
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // กำหนดค่าให้กับ _pages ใน initState
    _pages = [
      DashboardTodayContent(onRefresh: _fetchDashboardData), // หน้า Today
      const InboxContentScreen(), // หน้า Inbox/Chat
      const TeamContentScreen(), // หน้า Team
      const FeedContentScreen(), // หน้า Feed
      const MoreContentScreen(), // หน้า More
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // เรียกข้อมูลสำหรับหน้า Dashboard (Today) เมื่อเริ่มต้น
      _fetchDashboardData();
    });
  }

  Future<void> _fetchDashboardData() async {
    logger.d('[DashboardScreen] Fetching dashboard data...');
    if (!mounted) return;

    try {
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      await dashboardProvider.fetchUsersProfile();
      await dashboardProvider.fetchListUsers();
      logger.d('[DashboardScreen] Dashboard data fetched successfully.');
    } catch (e) {
      logger.e('[DashboardScreen] Error fetching dashboard data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard data: $e')),
        );
      }
    }
  }

  void logout() async {
    logger.d('[BEGIN] logout');
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (!mounted) {
        logger.d('Widget unmounted after API call, stopping further operations.');
        return;
      }

      logger.d('Logout successful. main.dart will handle navigation to LoginScreen.');
      // ใช้ pushReplacement เพื่อไม่ให้ย้อนกลับมาหน้า Dashboard ได้เมื่อกดปุ่มย้อนกลับ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } catch (e) {
      logger.e('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  // ฟังก์ชันนี้จะถูกเรียกเมื่อมีการแตะที่ Bottom Navigation Item
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // อัปเดต index ที่ถูกเลือก
    });
    logger.d('Bottom navigation item tapped: $index');
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final User? userProfile = dashboardProvider.userProfile;
    final userProfilePicUrl = userProfile?.profilePic;

    final String currentDayOfWeek = DateFormat('EEEE', 'en').format(DateTime.now());
    final String currentMonthDay = DateFormat('MMMM d', 'en').format(DateTime.now());

    // กำหนดชื่อ Title ของ AppBar ตามหน้าจอที่เลือก
    String appBarTitle = 'Today';
    switch (_selectedIndex) {
      case 0:
        appBarTitle = 'Today';
        break;
      case 1:
        appBarTitle = 'Inbox';
        break;
      case 2:
        appBarTitle = 'Team';
        break;
      case 3:
        appBarTitle = 'Feed';
        break;
      case 4:
        appBarTitle = 'More';
        break;
    }


    return PopScope(
      canPop: false, // ป้องกันการ Pop ออกจากหน้าจอ (เช่น กดปุ่ม Back)
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        logger.d('Attempted to pop from Dashboard, but blocked by PopScope. Result: $result');
        // หากผู้ใช้อยู่บนแท็บอื่น (ไม่ใช่ Today) ให้กลับไปที่แท็บ Today
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
        // ถ้าอยู่บนแท็บ Today แล้วกด back อีกครั้ง จะไม่มีอะไรเกิดขึ้น (เพราะ canPop: false)
        // คุณสามารถเพิ่ม logic เช่น แสดง dialog "Exit App?" ได้ที่นี่
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50, // พื้นหลังสีเทาอ่อนแบบ iOS
        appBar: AppBar(
          automaticallyImplyLeading: false, // ซ่อนปุ่มย้อนกลับอัตโนมัติ
          backgroundColor: Colors.white, // AppBar สีขาว
          elevation: 0.5, // เงาจางๆ แบบ iOS
          title: Row(
            children: [
              Text(
                appBarTitle, // เปลี่ยน Title ตามหน้าจอที่เลือก
                style: TextStyle(
                  color: Colors.black, // Title หลักสีดำ
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedIndex == 0) ...[ // แสดงวันที่เฉพาะบนหน้า Today เท่านั้น
                const SizedBox(width: 8),
                Text(
                  '$currentDayOfWeek, $currentMonthDay',
                  style: TextStyle(
                    color: Colors.grey.shade600, // วันที่สีเทาอ่อนๆ
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            // ปุ่มเมนูตั้งค่า/ออกจากระบบ
            PopupMenuButton<String>(
              icon: Icon(Icons.settings_outlined, color: Colors.blue.shade700), // ไอคอนตั้งค่าแบบ iOS
              onSelected: (String result) async {
                if (result == 'logout') {
                  logout();
                } else if (result == 'settings') {
                  logger.d('Settings option selected.');
                  // TODO: เพิ่มการนำทางไปหน้า Settings
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('Settings', style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              offset: const Offset(0, 50), // เลื่อนเมนูลงมาเล็กน้อย
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // ขอบมนขึ้น
              elevation: 4,
            ),
            // รูปโปรไฟล์ผู้ใช้
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  logger.d('[DashboardScreen] User avatar clicked, navigating to UserProfileScreen.');
                  if (userProfile != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(user: userProfile),
                      ),
                    );
                  } else {
                    logger.w('[DashboardScreen] User data is null, cannot navigate to profile.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User data not available.')),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade100, // พื้นหลังอวตารสีฟ้าอ่อน
                  child: userProfilePicUrl != null && userProfilePicUrl.isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      userProfilePicUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        logger.e('Error loading avatar image: $error');
                        return Icon(Icons.person, size: 25, color: Colors.blue.shade700);
                      },
                    ),
                  )
                      : Icon(Icons.person, size: 25, color: Colors.blue.shade700),
                ),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex, // แสดงหน้าจอตาม index ที่เลือก
          children: _pages, // รายการของหน้าจอทั้งหมด
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // สำหรับ 5 รายการควรใช้ fixed
          backgroundColor: Colors.white, // พื้นหลังสีขาว
          selectedItemColor: Colors.blue, // สีน้ำเงินสำหรับไอเท็มที่เลือก
          unselectedItemColor: Colors.grey.shade600, // สีเทาเข้มสำหรับไอเท็มที่ไม่ได้เลือก
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600), // ป้ายกำกับตัวหนาขึ้นเมื่อเลือก
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          showUnselectedLabels: true, // แสดงป้ายกำกับเสมอ
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outlined), // ไอคอนโปร่งสำหรับไม่ได้เลือก
              activeIcon: Icon(Icons.star), // ไอคอนทึบสำหรับเลือก
              label: 'Today',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              activeIcon: Icon(Icons.chat),
              label: 'Inbox', // ใช้คำว่า Inbox
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rss_feed_outlined),
              activeIcon: Icon(Icons.rss_feed),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz), // ไอคอน "เพิ่มเติม"
              label: 'More',
            ),
          ],
          currentIndex: _selectedIndex, // ตั้งค่า index ปัจจุบัน
          onTap: _onItemTapped, // Callback เมื่อมีการแตะรายการ
        ),
      ),
    );
  }
}