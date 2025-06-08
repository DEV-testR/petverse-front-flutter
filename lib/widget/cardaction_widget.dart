// lib/widget/cardaction_widget.dart

import 'package:flutter/material.dart';

class CardActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onPressed;

  const CardActionButton({
    super.key,
    required this.text,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // --- CHANGE START ---
    // Remove the Expanded here
    return Padding( // Now Padding is the root, this is a BoxParentData widget
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
    // --- CHANGE END ---
  }
}