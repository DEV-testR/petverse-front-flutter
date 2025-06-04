import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:petverse_front_flutter/providers/auth_provider.dart';
import 'package:petverse_front_flutter/providers/dashboard_provider.dart';
import 'package:petverse_front_flutter/screen/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // สำหรับ SharedPreferences

// ***** สำคัญมาก: ตรวจสอบและแก้ไขเส้นทางนี้ให้ถูกต้อง *****
// สมมติว่า injector.dart อยู่ใน lib/injector.dart
import 'package:petverse_front_flutter/injector.dart'; // <--- ต้องแน่ใจว่า import ถูกต้อง

final logger = Logger(
  printer: PrettyPrinter(),
);

final loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

void main() async {
  // ตรวจสอบให้แน่ใจว่า Flutter Engine ถูกเตรียมพร้อมก่อนใช้งาน Native code (เช่น SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // ตั้งค่า Dependency Injection ด้วย GetIt
  setupLocator();

  // สำคัญ: เริ่มต้น SharedPreferences ก่อน runApp เพื่อให้แน่ใจว่าพร้อมใช้งาน
  // ไม่ต้องเก็บค่าที่นี่ แค่เรียกเพื่อให้แน่ใจว่า initialized
  await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      Logger.level = Level.info;
    }
    else {
      Logger.level = Level.debug;
    }


    // ใช้ MultiProvider เพื่อให้ AuthProvider และ DashboardProvider พร้อมใช้งานทั่วทั้งแอป
    return MultiProvider(
      providers: [
        // กำหนด Provider สำหรับ AuthProvider (ดึงจาก GetIt)
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        // กำหนด Provider สำหรับ DashboardProvider (ดึงจาก GetIt)
        ChangeNotifierProvider(create: (_) => getIt<DashboardProvider>()),
      ],
      child: MaterialApp(
        title: 'PetVerse App', // เปลี่ยนชื่อ title ของแอป
        theme: ThemeData(
          primarySwatch: Colors.blue, // กำหนดสีหลักของแอป
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blueAccent, // สี AppBar
            foregroundColor: Colors.white, // สีตัวอักษรบน AppBar
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // สีพื้นหลังปุ่ม
              foregroundColor: Colors.white, // สีตัวอักษรปุ่ม
            ),
          ),
          // สามารถกำหนด colorScheme หรือ theme อื่นๆ ได้ตามต้องการ
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // ใช้สีฟ้าเป็น seedColor
        ),
        // กำหนด HomePage เป็นหน้าจอเริ่มต้นของแอปพลิเคชัน
        // HomePage จะจัดการการนำทางไปยัง Login หรือ Dashboard โดยอัตโนมัติ
        home: const HomeScreen(),
        // ไม่ต้องใช้ routes หรือ initialRoute หาก HomePage ทำหน้าที่เป็น Router หลัก
      ),
    );
  }
}

// ไม่จำเป็นต้องมี MyHomePage อีกต่อไป เนื่องจาก HomePage จะเป็นจุดเริ่มต้นแทน
// คุณสามารถลบ MyHomePage และ _MyHomePageState ออกจากไฟล์นี้ได้เลย