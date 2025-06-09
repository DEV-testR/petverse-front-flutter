import 'package:flutter/material.dart';

class TeamContentScreen extends StatelessWidget {
  const TeamContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ข้อมูลตัวอย่างของสมาชิกทีม แยกตามกลุ่ม/แผนก
    final Map<String, List<Map<String, String>>> teamData = {
      'Management Team': [
        {'name': 'สมศรี สุขใจ', 'position': 'CEO', 'profilePic': 'https://via.placeholder.com/100/FF5733/FFFFFF?text=SS'},
        {'name': 'สมชาย ใจดี', 'position': 'CTO', 'profilePic': 'https://via.placeholder.com/100/3366FF/FFFFFF?text=SC'},
      ],
      'Marketing Department': [
        {'name': 'อรอนงค์ รักสัตว์', 'position': 'Marketing Manager', 'profilePic': 'https://via.placeholder.com/100/33FF57/FFFFFF?text=AO'},
        {'name': 'มานะ มามาก', 'position': 'Marketing Specialist', 'profilePic': 'https://via.placeholder.com/100/FFC300/FFFFFF?text=MM'},
      ],
      'Development Team': [
        {'name': 'ภูมิพัฒน์ พัฒนา', 'position': 'Lead Developer', 'profilePic': 'https://via.placeholder.com/100/6C3483/FFFFFF?text=PP'},
        {'name': 'พิมพ์ชนก ช่างโค้ด', 'position': 'Frontend Developer', 'profilePic': 'https://via.placeholder.com/100/2980B9/FFFFFF?text=PC'},
        {'name': 'เดชชาติ จัดเต็ม', 'position': 'Backend Developer', 'profilePic': 'https://via.placeholder.com/100/27AE60/FFFFFF?text=DC'},
      ],
      'Customer Support': [
        {'name': 'นภา ใจเย็น', 'position': 'Support Lead', 'profilePic': 'https://via.placeholder.com/100/D35400/FFFFFF?text=NJ'},
        {'name': 'เมตตา บริการ', 'position': 'Support Specialist', 'profilePic': 'https://via.placeholder.com/100/8E44AD/FFFFFF?text=MB'},
      ],
    };

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // พื้นหลังสีเทาอ่อน
      /*appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'ทีม', // หรือ 'Team Directory'
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.blue), // ไอคอนเพิ่มสมาชิก
            onPressed: () {
              // TODO: Implement add member functionality
            },
          ),
          const SizedBox(width: 8),
        ],
      ),*/
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วน Search Bar (สามารถเพิ่มได้ถ้าต้องการ)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
            ),

            // รายการทีมงาน
            ...teamData.keys.map((groupName) {
              final members = teamData[groupName]!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // เพิ่ม horizontal padding ให้เท่ากับ margin ของ Card
                child: Card( // ใช้ Card เพื่อให้ดูเป็นกล่องๆ มีเงาเล็กน้อย
                  color: Colors.grey.shade100, // <--- สามารถกำหนดสีให้เหมือนพื้นหลัง Scaffold หรือไม่กำหนดเลยก็ได้ (Default คือสีขาว)
                  elevation: 1.0, // <--- เพิ่มความหนาของเงาขึ้นเล็กน้อย
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // <--- เพิ่มขอบมนขึ้นอีกนิด
                    // side: BorderSide(color: Colors.red, width: 1), // กำหนด border ที่มีสีจางๆ และความหนาคงที่
                  ),
                  margin: EdgeInsets.zero, // ไม่ต้องมี margin ของ Card เพราะ padding ด้านนอกจัดการแล้ว
                  child: ExpansionTile(
                    // นี่คือส่วนสำคัญ: กำหนด shape ของ ExpansionTile
                    shape: RoundedRectangleBorder( // เมื่อขยาย
                      borderRadius: BorderRadius.circular(12.0), // ให้ขอบมนเหมือน Card
                      side: BorderSide.none, // <--- สำคัญ: ไม่มีเส้นขอบ
                    ),
                    collapsedShape: RoundedRectangleBorder( // เมื่อยุบ
                      borderRadius: BorderRadius.circular(12.0), // ให้ขอบมนเหมือน Card
                      side: BorderSide.none, // <--- สำคัญ: ไม่มีเส้นขอบ
                    ),
                    // tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    // childrenPadding: EdgeInsets.zero, // ให้แน่ใจว่าไม่มี padding ที่ทำให้เกิดช่องว่าง
                    // backgroundColor: Colors.red, // <--- สามารถกำหนดเพื่อให้หัว ExpansionTile เป็นสีขาวได้
                    // collapsedBackgroundColor: Colors.white, // <--- สีเมื่อยุบ
                    title: Text(
                      groupName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    children: members.map((member) {
                      return Column(
                        children: [
                          // ตรวจสอบว่าไม่ใช่สมาชิกคนสุดท้ายในกลุ่ม เพื่อไม่ให้มี Divider หลังคนสุดท้าย
                          if (member != members.last) Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200, indent: 70), // เส้นแบ่งสมาชิก
                          _buildTeamMemberTile(member), // Tile ของสมาชิกแต่ละคน
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20), // เว้นช่องว่างด้านล่าง
          ],
        ),
      ),
    );
  }

  // Widget สำหรับสร้าง ListTile ของสมาชิกทีม
  Widget _buildTeamMemberTile(Map<String, String> member) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(member['profilePic']!),
        backgroundColor: Colors.grey.shade200,
        onBackgroundImageError: (exception, stackTrace) {
          // Fallback icon if image fails to load
          debugPrint('Error loading image for ${member['name']}: $exception');
        },
        child: member['profilePic'] == null || member['profilePic']!.isEmpty // แสดงไอคอนถ้าไม่มีรูป
            ? const Icon(Icons.person, size: 30, color: Colors.blueGrey)
            : null,
      ),
      title: Text(
        member['name']!,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        member['position']!,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.phone_outlined, color: Colors.blue.shade700, size: 22), // ไอคอนโทรศัพท์
            onPressed: () {
              // TODO: Implement call action
            },
          ),
          IconButton(
            icon: Icon(Icons.message_outlined, color: Colors.blue.shade700, size: 22), // ไอคอนข้อความ
            onPressed: () {
              // TODO: Implement message action
            },
          ),
        ],
      ),
      onTap: () {
        // TODO: Implement navigate to member's profile or details
        // 예를เช่น: Navigator.push(context, MaterialPageRoute(builder: (context) => MemberDetailScreen(member: member)));
      },
    );
  }
}