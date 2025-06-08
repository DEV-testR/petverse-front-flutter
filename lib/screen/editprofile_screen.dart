import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Ensure Material is imported for certain widgets if needed, though Cupertino is primary
import 'package:intl/intl.dart';
import 'package:petverse_front_flutter/main.dart';
import 'package:provider/provider.dart';

import '../dto/user.dart';
import '../providers/dashboard_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Uncomment if you decide to use a traditional Form widget
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController.text = user.fullName ?? '';
    _usernameController.text = user.email; // Username is often email or a unique identifier
    _phoneNumberController.text = user.phoneNumber ?? '';
    _addressController.text = user.address ?? '';
    _selectedDateOfBirth = user.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: _buildNavigationBar(),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _buildProfilePictureSection(),
            const SizedBox(height: 20),
            _buildProfileInfoSection(),
            const SizedBox(height: 20),
            _buildContactInfoSection(),
            const SizedBox(height: 20),
            /*_buildAccountActionSection(),
            const SizedBox(height: 30),*/
          ],
        ),
      ),
    );
  }

  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      middle: const Text('Edit Profile', style: TextStyle(color: CupertinoColors.black)),
      leading: CupertinoNavigationBarBackButton(
        onPressed: () => Navigator.of(context).pop(),
        color: CupertinoColors.activeBlue,
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _saveProfile,
        child: const Text('Save', style: TextStyle(color: CupertinoColors.activeBlue)),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    final profilePic = widget.user.profilePic;
    return Center(
      child: GestureDetector(
        onTap: () => logger.d('Change profile picture tapped'),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: CupertinoColors.systemGrey4,
              child: profilePic != null && profilePic.isNotEmpty
                  ? ClipOval(
                child: Image.network(
                  profilePic,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, _) {
                    logger.e('Error loading edit profile pic: $error');
                    return const Icon(CupertinoIcons.person_alt_circle_fill, size: 60);
                  },
                ),
              )
                  : const Icon(CupertinoIcons.person_alt_circle_fill, size: 60, color: CupertinoColors.white),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(CupertinoIcons.camera_fill, size: 20, color: CupertinoColors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoSection() {
    return CupertinoFormSection.insetGrouped(
      header: const Text('PROFILE INFORMATION'),
      children: [
        _buildCupertinoTextFieldRow(
          labelText: 'Name',
          controller: _nameController,
          placeholder: 'Enter your name',
        ),
        _buildCupertinoTextFieldRow(
          labelText: 'Username',
          controller: _usernameController,
          placeholder: 'petverse@example.com',
          readOnly: true,
        ),
        // ✅ Wrap Date of Birth with GestureDetector
        CupertinoFormRow(
          prefix: const Text('Date of Birth', style: TextStyle(color: CupertinoColors.black)),
          child: GestureDetector(
            onTap: () => _showDatePicker(context),
            child: AbsorbPointer(
              child: CupertinoTextField(
                controller: TextEditingController(
                  text: _selectedDateOfBirth != null
                      ? DateFormat('dd MMMM yyyy', 'th').format(_selectedDateOfBirth!)
                      : '',
                ),
                placeholder: 'Select date of birth',
                readOnly: true,
                cursorColor: CupertinoColors.activeBlue,
                style: const TextStyle(color: CupertinoColors.black),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return CupertinoFormSection.insetGrouped(
      header: const Text('CONTACT INFORMATION'),
      children: [
        _buildCupertinoTextFieldRow(
          labelText: 'Phone',
          controller: _phoneNumberController,
          placeholder: 'Enter your phone number',
          keyboardType: TextInputType.phone,
        ),
        _buildCupertinoTextFieldRow(
          labelText: 'Address',
          controller: _addressController,
          placeholder: 'Enter your address',
          maxLines: null, // ให้ขยายอัตโนมัติ
          keyboardType: TextInputType.multiline,
          alignLabelWithHint: true,
        ),
      ],
    );
  }

  /*Widget _buildAccountActionSection() {
    return CupertinoFormSection.insetGrouped(
      // header: const Text('ACCOUNT ACTIONS'), // Optional header
      children: [
        CupertinoFormRow(
          padding: EdgeInsets.zero,
          child: FormClickableRow(
            label: 'Change Password',
            onTap: () {
              logger.d('Change Password tapped');
              // TODO: Navigate to ChangePasswordScreen
            },
            textColor: CupertinoColors.activeBlue,
            showForwardIcon: true, // Changed to true for standard navigation
            fontWeight: FontWeight.normal, // Typically normal for actions
          ),
        ),
        CupertinoFormRow(
          padding: EdgeInsets.zero,
          child: FormClickableRow(
            label: 'Delete Account',
            onTap: () {
              _showDeleteAccountConfirmation(context);
            },
            textColor: CupertinoColors.systemRed,
            showForwardIcon: false, // No forward arrow for destructive action
            fontWeight: FontWeight.normal, // Typically normal for actions
          ),
        ),
      ],
    );
  }*/

  Widget _buildCupertinoTextFieldRow({
    required String labelText,
    required TextEditingController controller,
    String? placeholder,
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool alignLabelWithHint = true, // Added parameter for label alignment
  }) {
    return CupertinoFormRow(
      prefix: Text(labelText, style: const TextStyle(color: CupertinoColors.black)),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        maxLines: maxLines,
        keyboardType: keyboardType,
        cursorColor: CupertinoColors.activeBlue,
        style: const TextStyle(color: CupertinoColors.black),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
        ), // Remove default decoration if any
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        readOnly: readOnly,
        // Apply vertical alignment for multiline text fields if alignLabelWithHint is true
        // This makes the prefix align with the first line of the multiline text field.
        textAlignVertical: alignLabelWithHint ? TextAlignVertical.top : TextAlignVertical.center,
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    DateTime tempPickedDate = _selectedDateOfBirth ?? DateTime.now();

    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: tempPickedDate,
                onDateTimeChanged: (newDate) {
                  tempPickedDate = newDate;
                },
              ),
            ),
            CupertinoButton(
              child: const Text('Done'),
              onPressed: () {
                setState(() => _selectedDateOfBirth = tempPickedDate);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    // You might want to add more robust validation here, e.g., for phone format, address length.
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Name cannot be empty.');
      return;
    }

    User userUpdate = User(email: _usernameController.text.trim()
        , fullName: _nameController.text.trim()
        , dateOfBirth: _selectedDateOfBirth
        , phoneNumber: _phoneNumberController.text.trim()
        , address: _addressController.text.trim()
    );

    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    dashboardProvider.setUserProfile(userUpdate);
    logger.d('Saving profile with new values: $userUpdate');
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Profile Updated'),
        content: const Text('Your profile has been updated successfully.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Pop the alert dialog
              Navigator.of(context).pop(userUpdate); // Pop EditProfileScreen to go back to UserProfileScreen
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Validation Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /*void _showDeleteAccountConfirmation(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Delete Account'),
        message: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              logger.d('Delete account confirmed');
              // TODO: Implement actual account deletion logic
              Navigator.of(context).pop(); // Dismiss the action sheet
            },
            child: const Text('Delete Account'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(), // Dismiss the action sheet
          child: const Text('Cancel'),
        ),
      ),
    );
  }*/
}