import 'package:flutter/material.dart';

import '../main.dart'; // For logger

// _buildDashboardCard และ CardActionButton ควรถูกย้ายมาที่นี่หรือไฟล์แยกเพื่อการนำมาใช้ใหม่
// ถ้าคุณยังไม่ได้ย้าย ให้ย้ายมาที่นี่หรือสร้างไฟล์ widget แยก
Widget _buildDashboardCard({
  required BuildContext context, // ต้องรับ context เข้ามา
  required IconData icon,
  required String title,
  required String content,
  List<Widget>? buttons,
  bool showViewAll = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withAlpha(26),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue.shade700, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            if (showViewAll)
              GestureDetector(
                onTap: () {
                  logger.d('View All tapped for $title');
                  // TODO: Navigate to relevant list view
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        if (buttons != null && buttons.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: buttons.map((button) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: button,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    ),
  );
}

class CardActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onPressed;

  const CardActionButton({super.key, required this.text, required this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed ?? () { /* Handle action */ },
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withAlpha(26), width: 1),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }
}

class DashboardTodayContent extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const DashboardTodayContent({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.blue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDashboardCard(
              context: context, // Pass context here
              icon: Icons.announcement,
              title: 'Announcements',
              content: 'No recent announcements',
              showViewAll: true,
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context: context, // Pass context here
              icon: Icons.checklist,
              title: 'Tasks',
              content: 'No pending tasks',
              showViewAll: true,
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context: context, // Pass context here
              icon: Icons.group,
              title: 'Meetings',
              content: 'No upcoming meetings',
              buttons: [
                CardActionButton(text: '+ Join', color: Colors.blue.shade700),
                CardActionButton(text: '+ Create New', color: Colors.blue.shade700),
              ],
              showViewAll: true,
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context: context, // Pass context here
              icon: Icons.monitor_outlined,
              title: 'Webinars',
              content: 'No upcoming webinars',
              buttons: [
                CardActionButton(text: '+ Create New', color: Colors.blue.shade700),
              ],
              showViewAll: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  logger.d('Reorder button tapped!');
                  // TODO: Implement reorder logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.blue.shade200, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Reorder Dashboard',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}