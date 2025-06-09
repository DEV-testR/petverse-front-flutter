import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // สำหรับไอคอน Facebook/Meta

class FeedContentScreen extends StatelessWidget {
  const FeedContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ข้อมูลตัวอย่างของโพสต์ใน Feed
    final List<Map<String, dynamic>> posts = [
      {
        'profilePic': 'https://via.placeholder.com/150/FF5733/FFFFFF?text=A', // URL รูปโปรไฟล์สมมติ
        'username': 'น้องแมวน่ารัก',
        'timeAgo': '2 นาทีที่แล้ว',
        'text': 'เช้านี้อากาศดีจังเลย 😻 ขอให้เป็นวันที่สดใสของทุกคนนะคะ',
        'imageUrl': 'https://via.placeholder.com/600/200?text=Cat+Photo+1', // URL รูปภาพโพสต์สมมติ
        'likes': 150,
        'comments': 12,
        'shares': 3,
      },
      {
        'profilePic': 'https://via.placeholder.com/150/3366FF/FFFFFF?text=B',
        'username': 'สมาคมคนรักหมา',
        'timeAgo': '1 ชั่วโมงที่แล้ว',
        'text': 'วันนี้มีกิจกรรมวิ่งเล่นที่สวนสาธารณะนะคร้าบ 🐶 ใครสนใจพาเจ้าตัวแสบมาร่วมสนุกกันได้เลย!',
        'imageUrl': 'https://via.placeholder.com/600/300?text=Dog+Photo+2',
        'likes': 320,
        'comments': 45,
        'shares': 10,
      },
      {
        'profilePic': 'https://via.placeholder.com/150/33FF57/FFFFFF?text=C',
        'username': 'หมอเดียร์ สัตว์แพทย์',
        'timeAgo': '5 ชั่วโมงที่แล้ว',
        'text': 'เกร็ดความรู้เล็กๆ น้อยๆ เกี่ยวกับการดูแลฟันสัตว์เลี้ยง 🦷✨ การแปรงฟันเป็นประจำช่วยลดปัญหาสุขภาพช่องปากได้นะค้าบ',
        'imageUrl': null, // โพสต์ที่ไม่มีรูปภาพ
        'likes': 88,
        'comments': 5,
        'shares': 2,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // พื้นหลังสีเทาอ่อนๆ เหมือน Facebook
      /*appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Feed',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey.shade600),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: Icon(Icons.add_box_outlined, color: Colors.blue.shade700), // ไอคอนสำหรับสร้างโพสต์ใหม่
            onPressed: () {
              // TODO: Implement create new post
            },
          ),
          const SizedBox(width: 8),
        ],
      ),*/
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostCard(post); // สร้างแต่ละโพสต์ด้วย Widget _buildPostCard
        },
      ),
    );
  }

  // Widget สำหรับสร้าง Post Card แต่ละอัน
  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0), // ระยะห่างระหว่างโพสต์
      color: Colors.white, // พื้นหลังโพสต์สีขาว
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(post['profilePic']),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        post['timeAgo'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: Colors.grey.shade600), // ปุ่ม More สำหรับโพสต์
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              post['text'],
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          if (post['imageUrl'] != null) // แสดงรูปภาพถ้ามี
            Image.network(
              post['imageUrl'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200, // กำหนดความสูงของรูปภาพ
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Text('Error loading image: $error', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.thumbsUp, size: 16, color: Colors.blue.shade700), // ไอคอน Like สีฟ้า
                const SizedBox(width: 4),
                Text(
                  '${post['likes']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const Spacer(), // เว้นช่องว่างตรงกลาง
                Text(
                  '${post['comments']} คอมเมนต์ • ${post['shares']} แชร์',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Colors.grey), // เส้นแบ่งก่อนปุ่ม
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // จัดปุ่มให้กระจายเท่าๆ กัน
            children: [
              _buildReactionButton(Icons.thumb_up_alt_outlined, 'ถูกใจ'), // ปุ่มถูกใจ
              _buildReactionButton(Icons.mode_comment_outlined, 'แสดงความคิดเห็น'), // ปุ่มคอมเมนต์
              _buildReactionButton(Icons.share_outlined, 'แชร์'), // ปุ่มแชร์
            ],
          ),
        ],
      ),
    );
  }

  // Widget สำหรับสร้างปุ่ม Reaction (Like, Comment, Share)
  Widget _buildReactionButton(IconData icon, String text) {
    return Expanded(
      child: Material(
        color: Colors.transparent, // ทำให้ Material ไม่มีพื้นหลัง
        child: InkWell(
          onTap: () {
            // TODO: Implement button action
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}