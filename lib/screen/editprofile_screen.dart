import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Ensure Material is imported if needed for other widgets
import 'package:intl/intl.dart'; // Keep if you use for date formatting
import 'package:provider/provider.dart'; // Keep if you use Provider

// สมมติว่ามี DTO และ Provider ที่เกี่ยวข้อง
import '../dto/user.dart';
import '../main.dart';
import '../providers/dashboard_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    _usernameController.text = user.email;
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
                  errorBuilder: (_, error, _) { // Adjusted errorBuilder signature
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
        _buildCustomTextFieldRow(
          context: context,
          labelText: 'Name',
          controller: _nameController,
          placeholder: 'Enter your name',
        ),
        _buildCustomTextFieldRow(
          context: context,
          labelText: 'Username',
          controller: _usernameController,
          placeholder: 'petverse@example.com',
          readOnly: true,
        ),
        // ใช้ _buildCustomDateFieldRow ที่ปรับปรุงแล้ว
        _buildCustomDateFieldRow(context),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return CupertinoFormSection.insetGrouped(
      header: const Text('CONTACT INFORMATION'),
      children: [
        _buildCustomTextFieldRow(
          context: context,
          labelText: 'Phone',
          controller: _phoneNumberController,
          placeholder: 'Enter your phone number',
          keyboardType: TextInputType.phone,
        ),
        _buildCustomTextFieldRow(
          context: context,
          labelText: 'Address',
          controller: _addressController,
          placeholder: 'Enter your address',
          maxLines: null,
          keyboardType: TextInputType.multiline,
          alignLabelWithTop: true,
        ),
      ],
    );
  }

  // --- ฟังก์ชัน _buildCustomTextFieldRow ที่ปรับใช้ CupertinoFormRow ---
  Widget _buildCustomTextFieldRow({
    required BuildContext context,
    required String labelText,
    required TextEditingController controller,
    String? placeholder,
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool alignLabelWithTop = true,
    double labelWidthRatio = 0.33, // อัตราส่วนสำหรับความกว้างของ label
  }) {
    final int resolvedMaxLines = maxLines ?? 1;

    return CupertinoFormRow(
      // prefix จะเป็นตัว label
      prefix: SizedBox(
        width: MediaQuery.of(context).size.width * labelWidthRatio,
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0), // ปรับให้ label กลางแนวตั้งกับ input
          child: DefaultTextStyle( // บังคับให้ label ไม่เป็นตัวหนา
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
            child: Text(
              labelText,
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ),
      // child คือส่วน input
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        maxLines: maxLines,
        keyboardType: keyboardType,
        cursorColor: CupertinoColors.activeBlue,
        style: const TextStyle(color: CupertinoColors.black),
        decoration: const BoxDecoration( // ไม่มี border
          color: CupertinoColors.white,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        readOnly: readOnly,
        textAlignVertical: alignLabelWithTop && resolvedMaxLines > 1 ? TextAlignVertical.top : TextAlignVertical.center,
      ),
    );
  }
  // --- สิ้นสุดฟังก์ชัน _buildCustomTextFieldRow ที่ปรับใช้ CupertinoFormRow ---

  // --- ฟังก์ชัน _buildCustomDateFieldRow ที่ปรับใช้ CupertinoFormRow ---
  Widget _buildCustomDateFieldRow(BuildContext context) {
    final TextEditingController dateController = TextEditingController(
      text: _selectedDateOfBirth != null
          ? DateFormat('dd MMMM', 'th').format(_selectedDateOfBirth!) // ใช้ 'th' locale
          : '',
    );

    return CupertinoFormRow(
      prefix: SizedBox(
        width: MediaQuery.of(context).size.width * 0.33, // ใช้อัตราส่วนเดียวกับ TextField อื่นๆ
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
            child: const Text(
              'Date of Birth',
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () => _showDatePicker(context),
        child: AbsorbPointer(
          child: CupertinoTextField(
            controller: dateController,
            placeholder: 'Select date of birth',
            readOnly: true,
            cursorColor: CupertinoColors.activeBlue,
            style: const TextStyle(color: CupertinoColors.black),
            decoration: const BoxDecoration( // ไม่มี border
              color: CupertinoColors.white,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            textAlignVertical: TextAlignVertical.center,
          ),
        ),
      ),
    );
  }
  // --- สิ้นสุดฟังก์ชัน _buildCustomDateFieldRow ที่ปรับใช้ CupertinoFormRow ---

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
              Navigator.of(context).pop();
              Navigator.of(context).pop(userUpdate);
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
}