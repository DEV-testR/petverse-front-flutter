import 'package:flutter/material.dart';
import 'package:petverse_front_flutter/main.dart';

class AppCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool showViewAll;
  final List<Widget>? buttons;

  const AppCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    this.showViewAll = false,
    this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[700]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                if (title == 'Meet' || title == 'Webinar')
                  Row(
                    children: [
                      Icon(Icons.arrow_right_alt, color: Colors.grey[700]),
                      SizedBox(width: 4),
                      Text('Join', style: TextStyle(color: Colors.grey[700])),
                      SizedBox(width: 16),
                      Icon(Icons.add, color: Colors.grey[700]),
                      SizedBox(width: 4),
                      Text('New', style: TextStyle(color: Colors.grey[700])),
                    ],
                  )
                else
                  Container(),
              ],
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (buttons != null && buttons!.isNotEmpty) ...[
              SizedBox(height: 16),
              Row(
                children: buttons!,
              ),
            ],
            if (showViewAll) ...[
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Handle View all tap
                    logger.d('View all for $title tapped!');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.blue[700], size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}