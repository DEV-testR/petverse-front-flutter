// lib/presentation/pages/auth/login_screen.dart

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:petverse_front_flutter/screen/pincode_screen.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _emailFormatErrorText; // <<< เพิ่มตัวแปร state สำหรับ error รูปแบบอีเมล
  bool _isLoading = false; // เพิ่ม state สำหรับการแสดง loading
  bool _showPasswordInput = false; // <<< เพิ่ม State สำหรับการแสดง Password Input

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

    final String enteredEmail = _emailController.text.trim();
    if (!_isEmailValid(enteredEmail)) return;

    _setLoading(true);

    bool emailExists = false;
    String errorMessage = '';

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      emailExists = await authProvider.validateEmail(enteredEmail);
    } catch (e) {
      logger.e('Error validating email: $e');
      errorMessage = e.toString();
    }

    _setLoading(false);

    if (!mounted) {
      logger.d('Widget unmounted after API call, stopping further operations.');
      return;
    }

    if (emailExists) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PinCodeScreen(email: enteredEmail)),
      );
      logger.d('Email verified. Navigated to PinCodeScreen with: $enteredEmail');
    } else {
      // _showSnackBar('ไม่พบอีเมลนี้ในระบบ');
      setState(() {
        _emailFormatErrorText = 'ไม่พบอีเมลนี้ในระบบ';
      });
      logger.d('Email not found in system.');
    }

    if (errorMessage.isNotEmpty) {
      _showSnackBar('เกิดข้อผิดพลาดในการตรวจสอบอีเมล: $errorMessage');
    }
  }

  void _doLoginWithPassword() async {
    logger.d('[BEGIN] _doLoginWithPassword');

    final String enteredEmail = _emailController.text.trim();
    final String enteredPassword = _passwordController.text;

    if (!_isEmailValid(enteredEmail, forLogin: true)) return;

    if (!_formKey.currentState!.validate() || _emailFormatErrorText!.isNotEmpty) {
      logger.d('Form validation failed for password login.');
      return;
    }

    _setLoading(true);

    String errorMessage = '';
    bool loginSuccess = false;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      loginSuccess = await authProvider.login(enteredEmail, enteredPassword);
    } catch (e) {
      logger.e('Error during password login: $e');
      errorMessage = e.toString();
    }

    _setLoading(false);

    if (!mounted) {
      logger.d('Widget unmounted after password login API call.');
      return;
    }

    if (loginSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      _showSnackBar(errorMessage.isNotEmpty ? errorMessage : 'เข้าสู่ระบบไม่สำเร็จ');
    }
  }

  bool _isEmailValid(String email, {bool forLogin = false}) {
    if (email.isEmpty) {
      setState(() {
        _emailFormatErrorText = 'กรุณากรอกอีเมลหรือชื่อผู้ใช้';
      });
      return false;
    }

    if (!EmailValidator.validate(email)) {
      logger.d('Email format invalid${forLogin ? ' for password login' : ''}.');
      setState(() {
        _emailFormatErrorText = 'กรุณากรอกรูปแบบอีเมลที่ถูกต้อง';
      });
      return false;
    }

    setState(() {
      _emailFormatErrorText = '';
    });

    return true;
  }

  void _setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // สีน้ำเงินเข้มตามรูป
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
                      // focusedBorder (เมื่อ focus)
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0), // ตัวอย่าง border สีฟ้าเมื่อ focus
                      ),
                      // ***** เพิ่ม errorBorder และ focusedErrorBorder ที่นี่ *****
                      errorBorder: OutlineInputBorder( // เมื่อมี error และไม่ได้ focus
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.redAccent, width: 2.0), // Border สีแดงเมื่อมี error
                      ),
                      focusedErrorBorder: OutlineInputBorder( // เมื่อมี error และ focus
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red, width: 2.5), // Border สีแดงเข้มขึ้นเมื่อมี error และ focus
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintText: 'example@gmail.com',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 20.0), // ปรับสีข้อความ error
                      errorText: _emailFormatErrorText, // <<< แสดง error message จาก state
                    ),
                    // ***** เพิ่ม onChanged callback ตรงนี้ *****
                    onChanged: (value) {
                      // ถ้ามี error รูปแบบอีเมลแสดงอยู่ และผู้ใช้เริ่มพิมพ์
                      // ให้ล้าง error นั้นทันที
                      if (_emailFormatErrorText != null) {
                        setState(() {
                          _emailFormatErrorText = null;
                        });
                      }
                    },
                    /*validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอีเมลหรือชื่อผู้ใช้';
                      }

                      return null; // ไม่มี error
                    },*/
                    autovalidateMode: AutovalidateMode.onUserInteraction, // ตรวจสอบเมื่อผู้ใช้พิมพ์
                    enabled: !_isLoading, // ปิดการใช้งาน input ขณะ loading
                  ),
                  // <<< เพิ่ม Password Input ที่นี่ >>>
                  if (_showPasswordInput) ...[ // แสดงเมื่อ _showPasswordInput เป็น true
                    const SizedBox(height: 20), // ระยะห่างจาก Email Input
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true, // ซ่อนข้อความรหัสผ่าน
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 20.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกรหัสผ่าน';
                        }
                        if (value.length < 6) { // กำหนดความยาวขั้นต่ำของรหัสผ่าน (ตัวอย่าง)
                          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction, // <<< อยู่ตรงนี้
                      enabled: !_isLoading,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 50),

            // Sign in button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (_showPasswordInput) {
                    _doLoginWithPassword(); // เรียกใช้ Login ด้วย Password
                  } else {
                    verifilyEmail(); // เรียกใช้ Verify Email (ไปหน้า PIN)
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 2,
                  ),
                )
                    : Text((_showPasswordInput ? 'Sign in' : 'Sign in with your account'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Sign In with Other Options (ปุ่มสลับโหมด)
            TextButton(
              onPressed: _isLoading ? null : () {
                setState(() {
                  _showPasswordInput = !_showPasswordInput; // สลับค่า true/false
                  _emailController.clear();
                  _passwordController.clear();
                  _emailFormatErrorText = null;
                  _formKey.currentState?.reset(); // ล้าง error messages ของ form
                });
                logger.d('Toggle login mode. Now show password: $_showPasswordInput');
              },
              child: Text(
                _showPasswordInput ? 'Sign In with PIN' : 'Sign In with Other Option', // ข้อความเปลี่ยนตามโหมด
                style: TextStyle(
                  color: _isLoading ? Colors.white38 : Colors.white70,
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