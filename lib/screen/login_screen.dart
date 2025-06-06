// lib/presentation/pages/auth/login_screen.dart

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:petverse_front_flutter/screen/pincode_screen.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // เพิ่ม state สำหรับการแสดง loading

  @override
  void dispose() {
    _emailController.dispose();
    // _passwordController.dispose();
    super.dispose();
  }

  /*void _doLogin() async {
    logger.d('[BEGIN] _doLogin');
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // ***** เพิ่ม mounted check ที่นี่ *****
      if (!mounted) return; // ถ้า Widget ไม่อยู่ใน tree แล้ว ไม่ต้องทำอะไรต่อ

      if (success) {
        // Login สำเร็จแล้ว HomePage (Root widget) จะตรวจจับการเปลี่ยนแปลง
        // ของ AuthProvider.isAuthenticated และนำทางไปยัง DashboardPage อัตโนมัติ
      } else {
        // Login ไม่สำเร็จ แสดงข้อความผิดพลาด
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage ?? 'เข้าสู่ระบบไม่สำเร็จ')),
        );
      }
    }
  }*/

  void verifilyEmail() async {
    logger.d('[BEGIN] verifilyEmail');

    if (!_formKey.currentState!.validate()) {
      logger.d('Email validation failed locally.');
      return; // ถ้า validation ล้มเหลว ก็ไม่ต้องทำอะไรต่อ
    }

    // เริ่มแสดง loading
    setState(() {
      _isLoading = true;
    });

    final String enteredEmail = _emailController.text.trim();
    bool emailExists = false;
    String errorMessage = '';

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      emailExists = await authProvider.validateEmail(enteredEmail);
    } catch (e) {
      logger.e('Error validating email: $e');
      errorMessage = e.toString(); // เก็บข้อความ error ไว้
    } finally {
      // *** mounted check ควรจะอยู่ตรงนี้เสมอ หลัง await และก่อน setState ล่าสุด ***
      // หยุดแสดง loading
      setState(() {
        _isLoading = false;
      });
    }

    if (!mounted) {
      logger.d('Widget unmounted after API call, stopping further operations.');
      return; // ถ้า Widget ไม่อยู่ใน tree แล้ว ไม่ต้องทำอะไรต่อ
    }

    // หลังจากที่ API call เสร็จสิ้นและ _isLoading ถูกตั้งค่าแล้ว
    // ค่อยดำเนินการต่อ
    if (emailExists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinCodeScreen(email: enteredEmail),
        ),
      );
      logger.d('Email verification successful. Navigating to PinCodeScreen with email: $enteredEmail');
    }
    else {
      // ถ้าอีเมลไม่มีอยู่ในระบบ หรือการตรวจสอบไม่ผ่าน
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบอีเมลนี้ในระบบ')),
      );
      logger.d('Email not found in system.');
    }

    // ถ้ามี error จาก try-catch block
    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการตรวจสอบอีเมล: $errorMessage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800], // สีน้ำเงินเข้มตามรูป
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets, // หรือไอคอนที่คล้ายกับโลโก้
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(width: 8),
                Text(
                  'Pet_Verse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),

            // Sign In text
            Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),

            // Email or Username input
            /*Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email or Username',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: 'example@gmail.com', // ตัวอย่างจากรูป IMG_3985
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 50),*/
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email or Username',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintText: 'example@gmail.com',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      errorStyle: const TextStyle(color: Colors.redAccent), // ปรับสีข้อความ error
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอีเมลหรือชื่อผู้ใช้';
                      }
                      // ตรวจสอบว่าเป็นอีเมลหรือไม่ ถ้าไม่ได้ต้องการบังคับเป็นอีเมลทั้งหมดก็สามารถลบออกได้
                      if (!EmailValidator.validate(value.trim())) {
                        return 'กรุณากรอกรูปแบบอีเมลที่ถูกต้อง';
                      }
                      return null; // ไม่มี error
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction, // ตรวจสอบเมื่อผู้ใช้พิมพ์
                    enabled: !_isLoading, // ปิดการใช้งาน input ขณะ loading
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // Sign in button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => verifilyEmail(), // ปิดปุ่มขณะ loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Sign in with your account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Sign In with Other Options
            TextButton(
              onPressed: () {
                // Handle other sign-in options
              },
              child: Text(
                'Sign In with Other Options',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}