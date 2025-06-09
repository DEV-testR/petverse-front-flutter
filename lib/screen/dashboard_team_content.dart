import 'package:flutter/cupertino.dart';

class TeamContentScreen extends StatelessWidget {
  const TeamContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'หน้าจอทีม',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}