import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class PinCodeScreen extends StatefulWidget {
  final String email;

  const PinCodeScreen({super.key, required this.email});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  String _pinCode = '';
  final int _pinLength = 6;

  void _onNumberTap(String number) async { // <<< เพิ่ม async ที่นี่
    setState(() {
      if (_pinCode.length < _pinLength) {
        _pinCode += number;
      }
    });

    if (_pinCode.length == _pinLength) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // ***** mounted check ควรจะอยู่หลัง await *****
      // แต่ก่อนที่จะเรียก await เราสามารถดึง authProvider มาไว้ก่อนได้
      // เนื่องจาก Provider.of(context, listen: false) ไม่ได้ใช้ context หลัง async gap โดยตรง
      // แต่การเรียกเมธอดบน authProvider อาจจะมีการใช้ context ภายหลัง

      // เรียก login function ของ AuthProvider แบบ asynchronous
      // และรอผลลัพธ์
      final bool loginSuccess = await authProvider.loginWithPin(widget.email, _pinCode); // <<< เพิ่ม await และใช้ widget.email

      // ***** เพิ่ม mounted check ที่นี่ เพื่อตรวจสอบว่า widget ยังคงอยู่ใน tree ก่อนใช้ context อีกครั้ง *****
      if (!mounted) {
        return; // ถ้า Widget ไม่อยู่ใน tree แล้ว ไม่ต้องทำอะไรต่อ
      }

      if (loginSuccess) {
        // Login สำเร็จแล้ว
        // HomePage (Root widget) จะตรวจจับการเปลี่ยนแปลง
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // Login ไม่สำเร็จ แสดงข้อความผิดพลาด
        // (อาจจะต้องล้าง PIN code ในกรณีที่ login ไม่สำเร็จ เพื่อให้ผู้ใช้กรอกใหม่)
        setState(() {
          _pinCode = ''; // ล้าง PIN
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage ?? 'เข้าสู่ระบบไม่สำเร็จ')),
        );
      }
    }
  }

  void _onClearTap() {
    setState(() {
      if (_pinCode.isNotEmpty) {
        _pinCode = _pinCode.substring(0, _pinCode.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.email,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter your PIN code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'for ${widget.email}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _pinCode.length ? Colors.white : Colors.white54,
                        border: Border.all(color: Colors.white54),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // Number Pad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                if (index == 9) {
                  return Container();
                } else if (index == 11) {
                  return _buildNumberPadButton(
                    child: const Icon(Icons.backspace, color: Colors.white),
                    onTap: _onClearTap,
                  );
                } else if (index == 10) {
                  return _buildNumberPadButton(
                    child: const Text('0', style: TextStyle(fontSize: 30, color: Colors.white)),
                    onTap: () => _onNumberTap('0'),
                  );
                } else {
                  final number = (index + 1).toString();
                  return _buildNumberPadButton(
                    child: Text(number, style: const TextStyle(fontSize: 30, color: Colors.white)),
                    onTap: () => _onNumberTap(number),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPadButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[700],
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}