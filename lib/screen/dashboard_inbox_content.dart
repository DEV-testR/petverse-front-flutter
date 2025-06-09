import 'package:flutter/material.dart';

import 'chat_screen.dart';

class InboxContentScreen extends StatelessWidget {
  const InboxContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ตัวอย่างข้อมูลรายชื่อแชท
    final List<Map<String, String>> chatList = [
      {'name': 'เพื่อน (ผู้เชี่ยวชาญสัตว์เลี้ยง)', 'lastMessage': 'มีอะไรเพิ่มเติมสอบถามได้เลยนะครับ'},
      {'name': 'กลุ่มคนรักแมว', 'lastMessage': 'มีใครแนะนำคลินิกสัตว์ดีๆ แถวนี้บ้างคะ?'},
      {'name': 'น้องหมาอ้วน', 'lastMessage': 'Woof woof!'},
      {'name': 'พี่เลี้ยงสัตว์เลี้ยง', 'lastMessage': 'พรุ่งนี้กี่โมงดีคะ?'},
      {'name': 'คลินิกสัตว์ใจดี', 'lastMessage': 'คุณหมอแจ้งผลตรวจแล้วค่ะ'},
    ];

    return Scaffold(
      backgroundColor: Colors.white, // พื้นหลังสีขาว
      /*appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // เงาจางๆ
        title: const Text(
          'แชท', // หรือ 'Inbox'
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // จัด Title ให้อยู่ตรงกลาง
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.blue.shade700), // เพิ่มปุ่มสร้างแชทใหม่
            onPressed: () {
              // TODO: Implement create new chat
            },
          ),
          const SizedBox(width: 8), // เว้นระยะขอบขวา
        ],
      ),*/
      body: ListView.separated(
        padding: const EdgeInsets.all(0), // ไม่มี padding โดยรวม
        itemCount: chatList.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200), // เส้นแบ่งบางๆ
        itemBuilder: (context, index) {
          final chat = chatList[index];
          return InkWell( // ทำให้ item กดได้
            onTap: () {
              // เมื่อกดที่ item, นำทางไปยังหน้าจอแชทจริง
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatPartnerName: chat['name']!, // ส่งชื่อผู้ติดต่อ/กลุ่มไปให้หน้าจอแชท
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28, // ขนาด Avatar
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, size: 30, color: Colors.blueAccent), // ไอคอนโปรไฟล์
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat['name']!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat['lastMessage']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '10:30 AM', // เวลาล่าสุด (สามารถดึงมาจากข้อมูลจริงได้)
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}