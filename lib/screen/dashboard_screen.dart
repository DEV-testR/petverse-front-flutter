import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:petverse_front_flutter/screen/login_screen.dart';
import 'package:petverse_front_flutter/screen/userprofile_screen.dart';
import 'package:provider/provider.dart';

import '../dto/user.dart';
import '../main.dart'; // For logger
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widget/cardaction_widget.dart'; // Assuming CardActionButton is styled iOS-friendly

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _fetchDashboardData() async {
    logger.d('[DashboardScreen] Fetching dashboard data...');
    if (!mounted) return;

    try {
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      await dashboardProvider.fetchUsersProfile();
      await dashboardProvider.fetchListUsers();
      logger.d('[DashboardScreen] Dashboard data fetched successfully.');
    } catch (e) {
      logger.e('[DashboardScreen] Error fetching dashboard data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard data: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDashboardData();
    });
  }

  void logout() async {
    logger.d('[BEGIN] logout');
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (!mounted) {
        logger.d('Widget unmounted after API call, stopping further operations.');
        return;
      }

      logger.d('Logout successful. main.dart will handle navigation to LoginScreen.');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } catch (e) {
      logger.e('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final User? userProfile = dashboardProvider.userProfile;
    final userProfilePicUrl = userProfile?.profilePic;

    final String currentDayOfWeek = DateFormat('EEEE', 'en').format(DateTime.now());
    final String currentMonthDay = DateFormat('MMMM d', 'en').format(DateTime.now());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        logger.d('Attempted to pop from Dashboard, but blocked by PopScope. Result: $result');
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50, // Very light grey background like iOS
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white, // White AppBar
          elevation: 0.5, // Subtle shadow for iOS feel
          title: Row(
            children: [
              // Icon(Icons.business_center, color: Colors.blue.shade700, size: 28), // Retained, use a modern icon
              // SizedBox(width: 8),
              Text(
                'Today',
                style: TextStyle(
                  color: Colors.black, // Main title in black
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$currentDayOfWeek, $currentMonthDay',
                style: TextStyle(
                  color: Colors.grey.shade600, // Date in subtle grey
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            // Settings/Logout Menu Button
            PopupMenuButton<String>(
              icon: Icon(Icons.settings_outlined, color: Colors.blue.shade700), // iOS-like settings icon
              onSelected: (String result) async {
                if (result == 'logout') {
                  logout();
                } else if (result == 'settings') {
                  logger.d('Settings option selected.');
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('Settings', style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              offset: const Offset(0, 50),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // More rounded
              elevation: 4,
            ),
            // User Profile Avatar
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  logger.d('[DashboardScreen] User avatar clicked, navigating to UserProfileScreen.');
                  if (userProfile != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(user: userProfile),
                      ),
                    );
                  } else {
                    logger.w('[DashboardScreen] User data is null, cannot navigate to profile.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User data not available.')),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade100, // Lighter blue for avatar background
                  child: userProfilePicUrl != null && userProfilePicUrl.isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      userProfilePicUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        logger.e('Error loading avatar image: $error');
                        return Icon(Icons.person, size: 25, color: Colors.blue.shade700);
                      },
                    ),
                  )
                      : Icon(Icons.person, size: 25, color: Colors.blue.shade700),
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _fetchDashboardData,
          color: Colors.blue, // iOS-like blue for refresh indicator
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Announcement Card
                _buildDashboardCard(
                  icon: Icons.announcement,
                  title: 'Announcements', // Plural for common usage
                  content: 'No recent announcements',
                  showViewAll: true,
                ),
                const SizedBox(height: 16), // Consistent spacing

                // Qbic Card (assuming this is a task/todo)
                _buildDashboardCard(
                  icon: Icons.checklist,
                  title: 'Tasks', // More general term
                  content: 'No pending tasks', // More active description
                  showViewAll: true,
                ),
                const SizedBox(height: 16),

                // Meet Card
                _buildDashboardCard(
                  icon: Icons.group,
                  title: 'Meetings',
                  content: 'No upcoming meetings',
                  buttons: [
                    CardActionButton(text: '+ Join', color: Colors.blue.shade700), // iOS blue for action
                    CardActionButton(text: '+ Create New', color: Colors.blue.shade700),
                  ],
                  showViewAll: true,
                ),
                const SizedBox(height: 16),

                // Webinar Card
                _buildDashboardCard(
                  icon: Icons.monitor_outlined, // A bit more modern icon
                  title: 'Webinars',
                  content: 'No upcoming webinars',
                  buttons: [
                    CardActionButton(text: '+ Create New', color: Colors.blue.shade700),
                  ],
                  showViewAll: true,
                ),
                const SizedBox(height: 30), // More spacing before the last button

                // Reorder Button
                SizedBox(
                  width: double.infinity, // Full width button
                  child: ElevatedButton(
                    onPressed: () {
                      logger.d('Reorder button tapped!');
                      // TODO: Implement reorder logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // White background for secondary button
                      foregroundColor: Colors.blue.shade700, // Blue text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                        side: BorderSide(color: Colors.blue.shade200, width: 1), // Subtle border
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14), // Taller button
                      elevation: 0, // Flat design
                    ),
                    child: const Text(
                      'Reorder Dashboard', // More descriptive text
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Fixed type for all items
          backgroundColor: Colors.white, // White background
          selectedItemColor: Colors.blue, // iOS blue for selected item
          unselectedItemColor: Colors.grey.shade600, // Darker grey for unselected
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600), // Bolder label
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          showUnselectedLabels: true, // Always show labels
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outlined), // Outlined icon for non-selected
              activeIcon: Icon(Icons.star), // Filled icon for selected
              label: 'Today',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              activeIcon: Icon(Icons.chat),
              label: 'Inbox', // More common iOS term
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rss_feed_outlined),
              activeIcon: Icon(Icons.rss_feed),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz), // Standard more icon
              label: 'More',
            ),
          ],
          currentIndex: 0,
          onTap: (index) {
            // Handle navigation
            logger.d('Bottom navigation item tapped: $index');
          },
        ),
      ),
    );
  }

  // Helper method to build a dashboard card with iOS-like styling
  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String content,
    List<Widget>? buttons,
    bool showViewAll = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Card background white
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26), // Subtle shadow
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
              Icon(icon, color: Colors.blue.shade700, size: 28), // Icon in blue
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
                      color: Colors.blue.shade700, // iOS blue for "View All"
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
              color: Colors.grey.shade600, // Content in grey
            ),
          ),
          if (buttons != null && buttons.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
              children: buttons.map((button) {
                return Expanded( // <-- Add Expanded here if you want the buttons to fill available space
                  child: Padding( // Padding is now inside Expanded
                    padding: const EdgeInsets.only(left: 8.0), // Spacing between buttons
                    child: button, // This `button` is now the ElevatedButton from CardActionButton
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// Ensure your AppCard and CardActionButton widgets are also styled for iOS
// For AppCard, you might want to remove its internal box decoration if this _buildDashboardCard wraps it.
// Or, _buildDashboardCard can directly replace the AppCard usage.
// Assuming AppCard is now handled by _buildDashboardCard properties for iOS styling.

// Example of how CardActionButton could be styled for iOS:
// class CardActionButton extends StatelessWidget {
//   final String text;
//   final Color color; // This color will be ignored, iOS buttons are mostly blue or system red/green
//
//   const CardActionButton({super.key, required this.text, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       onPressed: () { /* Handle action */ },
//       style: TextButton.styleFrom(
//         foregroundColor: Colors.blue.shade700, // Standard iOS blue for action buttons
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8), // Subtle rounding
//           side: BorderSide(color: Colors.blue.shade200, width: 1), // Light blue border
//         ),
//         minimumSize: Size.zero, // Compact button
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),
//       child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
//     );
//   }
// }