import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(), // หรือจะใช้ SpinKit หรือ Custom Loading อื่นๆ ก็ได้
    );
  }
}