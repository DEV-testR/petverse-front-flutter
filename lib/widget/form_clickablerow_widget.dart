// lib/widget/profile_clickable_row.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormClickableRow extends StatelessWidget {
  final String label;
  final Color textColor; // Added a new parameter for text color
  final FontWeight fontWeight;
  final VoidCallback onTap;
  final bool showForwardIcon;

  const FormClickableRow({
    super.key,
    required this.label,
    required this.onTap,
    this.textColor = CupertinoColors.activeBlue, // Default color set to Colors.blue
    this.fontWeight = FontWeight.normal,
    this.showForwardIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Ensures the entire row is tappable
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 16,
              color: textColor,
              fontWeight: fontWeight,
              decoration: TextDecoration.none, // <--- เพิ่มบรรทัดนี้เพื่อเอาเส้นใต้ออก
            )),
            // Use SizedBox.shrink() instead of null
            (showForwardIcon) ? const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16) : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}