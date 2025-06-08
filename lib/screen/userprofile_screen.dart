import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:petverse_front_flutter/main.dart';

import '../dto/user.dart';
import '../widget/form_clickablerow_widget.dart';
import '../widget/formsection_container_widget.dart';
import 'editprofile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _navigateToEditProfile() async {
    final updatedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _user),
      ),
    );

    if (updatedUser != null) {
      setState(() {
        _user = updatedUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d('[UserProfileScreen] Building with User: ${_user.email}');

    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(),
            const SizedBox(height: 20),
            _buildNameAndEmail(),
            const SizedBox(height: 30),
            _buildInfoSection(context),
            const SizedBox(height: 30),
            _buildActionSection(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      foregroundColor: Colors.blue,
      elevation: 0.5,
      centerTitle: true,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildAvatar() {
    final hasProfilePic = _user.profilePic != null && _user.profilePic!.isNotEmpty;

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.blue.shade100,
      child: hasProfilePic
          ? ClipOval(
        child: Image.network(
          _user.profilePic!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, error, _) {
            logger.e('Failed to load profile picture: $error');
            return Icon(Icons.person, size: 80, color: Colors.blue.shade700);
          },
        ),
      )
          : Icon(Icons.person, size: 80, color: Colors.blue.shade700),
    );
  }

  Widget _buildNameAndEmail() {
    return Column(
      children: [
        Text(
          _user.fullName ?? 'Guest User',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          _user.email,
          style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return FormSectionContainer(
      children: [
        _buildInfoRow(context, label: 'Date of Birth', value: _user.getDateOfBirth()),
        _buildInfoRow(context, label: 'Phone Number', value: _user.phoneNumber ?? 'N/A'),
        _buildInfoRow(context, label: 'Location', value: _user.address ?? 'N/A'),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return FormSectionContainer(
      children: [
        FormClickableRow(
          label: 'Edit Profile',
          onTap: _navigateToEditProfile,
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, {required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

