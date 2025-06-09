import 'package:flutter/material.dart';

class MoreContentScreen extends StatelessWidget {
  const MoreContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ข้อมูลตัวอย่างของบริการ/ฟังก์ชันต่างๆ
    final List<Map<String, dynamic>> services = [
      {
        'icon': Icons.business, // ไอคอนสำหรับ Core
        'iconColor': Colors.blue.shade700,
        'title': '@Core',
        'subtitle': 'HRIS and self-service system',
      },
      {
        'icon': Icons.smartphone, // ไอคอนสำหรับ App HR
        'iconColor': Colors.teal.shade700,
        'title': 'App HR',
        'subtitle': 'Wise@Work',
      },
      {
        'icon': Icons.link, // ไอคอนสำหรับ Corporate Link (QBIC)
        'iconColor': Colors.purple.shade700,
        'title': 'Corporate Link (QBIC)',
        'subtitle': 'Open Qbic web via @Work app',
      },
      {
        'icon': Icons.people_alt_outlined, // ไอคอนสำหรับ Employee Engagement
        'iconColor': Colors.orange.shade700,
        'title': 'Employee Engagement',
        'subtitle': 'Create with default u1_code',
      },
      {
        'icon': Icons.face, // ไอคอนสำหรับ Face I/O
        'iconColor': Colors.red.shade700,
        'title': 'Face I/O',
        'subtitle': 'Check in/out with face verification',
      },
      {
        'icon': Icons.folder_open, // ไอคอนสำหรับ File
        'iconColor': Colors.brown.shade700,
        'title': 'File',
        'subtitle': 'Cloud storage',
      },
      {
        'icon': Icons.videocam_outlined, // ไอคอนสำหรับ Meet
        'iconColor': Colors.indigo.shade700,
        'title': 'Meet',
        'subtitle': 'Online meeting',
      },
      {
        'icon': Icons.group_add_outlined, // ไอคอนสำหรับ Onboarding
        'iconColor': Colors.green.shade700,
        'title': 'Onboarding',
        'subtitle': 'Team onboarding experience',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // พื้นหลังสีเทาอ่อน
      /*appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'More',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue), // ปุ่ม + ด้านขวาบน
            onPressed: () {
              // TODO: Implement add functionality
            },
          ),
          const SizedBox(width: 8),
        ],
      ),*/
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0), // Padding ด้านบนสำหรับหัวข้อ
              child: Text(
                '@work Services', // หัวข้อกลุ่มบริการ
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true, // ทำให้ ListView ใช้พื้นที่เท่าที่จำเป็น
              physics: const NeverScrollableScrollPhysics(), // ปิดการ scroll ของ ListView เพราะมี SingleChildScrollView แล้ว
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceCard(
                  context,
                  icon: service['icon'],
                  iconColor: service['iconColor'],
                  title: service['title'],
                  subtitle: service['subtitle'],
                );
              },
            ),
            const SizedBox(height: 20), // เว้นช่องว่างด้านล่าง
            // สามารถเพิ่มส่วนอื่นๆ ที่นี่ได้ เช่น "Utilities" หรือ "Settings"
          ],
        ),
      ),
    );
  }

  // Widget สำหรับสร้าง Card ของแต่ละบริการ
  Widget _buildServiceCard(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required String subtitle,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Margin ระหว่าง Card
      decoration: BoxDecoration(
        color: Colors.white, // พื้นหลัง Card สีขาว
        borderRadius: BorderRadius.circular(10.0), // ขอบมน
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26), // เงาจางๆ
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material( // ใช้ Material เพื่อให้มี InkWell effect (ripple effect)
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Implement navigation to specific service screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on $title')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha((255.0 * 0.1).round()), // สีพื้นหลังไอคอนจางๆ
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: Colors.grey.shade400), // ไอคอนจุดสามจุดด้านขวา
              ],
            ),
          ),
        ),
      ),
    );
  }
}