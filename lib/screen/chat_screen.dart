import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatPartnerName; // เพิ่มตัวแปรสำหรับรับชื่อผู้ติดต่อ

  const ChatScreen({super.key, required this.chatPartnerName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    // ตัวอย่างข้อความ (isMe: true = ข้อความของคุณ, isMe: false = ข้อความของอีกฝ่าย)
    {'text': 'สวัสดีครับ! มีอะไรให้ช่วยไหมครับ?', 'isMe': false},
    {'text': 'สวัสดีครับ พอดีอยากสอบถามเรื่องการดูแลสัตว์เลี้ยงครับ', 'isMe': true},
    {'text': 'ได้เลยครับ! คุณสนใจสัตว์เลี้ยงประเภทไหนเป็นพิเศษ หรือมีคำถามอะไรไหมครับ?', 'isMe': false},
    {'text': 'อยากได้คำแนะนำเรื่องอาหารสำหรับสุนัขพันธุ์เล็กครับ', 'isMe': true},
    {'text': 'แน่นอนครับ สำหรับสุนัขพันธุ์เล็ก แนะนำอาหารที่มีโปรตีนสูงและเม็ดเล็กครับ', 'isMe': false},
    {'text': 'ขอบคุณมากครับ!', 'isMe': true},
    {'text': 'มีอะไรเพิ่มเติมสอบถามได้เลยนะครับ', 'isMe': false},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({'text': _messageController.text, 'isMe': true});
        _messageController.clear();
      });
      // เพิ่ม logic สำหรับ auto-scroll (ถ้าต้องการ)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // พื้นหลังแชทสีเทาอ่อนๆ
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // เงาจางๆ ที่ด้านล่าง AppBar
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.grey.shade600, size: 30),
          onPressed: () {
            Navigator.pop(context); // กลับไปยังหน้าจอ InboxScreen
          },
        ),
        title: Text(
          widget.chatPartnerName, // แสดงชื่อผู้ติดต่อที่รับมา
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // จัด Title ให้อยู่ตรงกลาง
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey.shade600),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.grey.shade600), // ไอคอนจุดสามจุดแนวนอน
            onPressed: () {
              // TODO: Implement more options
            },
          ),
          const SizedBox(width: 8), // เว้นระยะขอบขวา
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false, // ข้อความล่าสุดอยู่ด้านล่าง
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isMe = message['isMe'];

                // สำหรับข้อความของอีกฝ่าย ให้แสดง Avatar
                final bool showAvatar = !isMe && (index == 0 || _messages[index - 1]['isMe'] == true);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Avatar ของอีกฝ่าย
                      if (showAvatar)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person, size: 20, color: Colors.blueAccent),
                          ),
                        ),
                      // เว้นช่องว่าง ถ้าไม่มี Avatar
                      if (!showAvatar && !isMe)
                        const SizedBox(width: 40),

                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                          margin: EdgeInsets.only(
                            left: isMe ? 60.0 : 0.0,
                            right: isMe ? 0.0 : 60.0,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green.shade100 : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16.0),
                              topRight: const Radius.circular(16.0),
                              bottomLeft: isMe ? const Radius.circular(16.0) : const Radius.circular(4.0),
                              bottomRight: isMe ? const Radius.circular(4.0) : const Radius.circular(16.0),
                            ),
                          ),
                          child: Text(
                            message['text'],
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey.shade600),
                    onPressed: () {
                      // TODO: Implement emoji picker
                    },
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Aa',
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (text) {
                          setState(() {}); // เพื่อให้ปุ่มส่งเปลี่ยนสถานะเมื่อมีข้อความ
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600),
                    onPressed: () {
                      // TODO: Implement camera functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.image_outlined, color: Colors.grey.shade600),
                    onPressed: () {
                      // TODO: Implement image/video picker
                    },
                  ),
                  _messageController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.send, color: Colors.blue.shade700),
                    onPressed: _sendMessage,
                  )
                      : IconButton(
                    icon: Icon(Icons.mic_none, color: Colors.grey.shade600),
                    onPressed: () {
                      // TODO: Implement voice message recording
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}