import 'package:flutter/material.dart';

class MoreContentScreen extends StatelessWidget {
  const MoreContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'หน้าจอเพิ่มเติม',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}