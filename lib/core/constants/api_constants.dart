// lib/core/constants/api_constants.dart
class ApiConstants {
  // **สำคัญ**: แก้ไข URL เหล่านี้ให้เป็น URL ของ Backend ของคุณจริง
  static const String authBaseUrl = 'https://api.yourbackend.com'; // ตัวอย่าง: URL สำหรับ API ที่เกี่ยวข้องกับการยืนยันตัวตน
  static const String loginEndpoint = '$authBaseUrl/auth/login'; // ตัวอย่าง: Endpoint สำหรับ Login
  // static const String registerEndpoint = '$authBaseUrl/auth/register';
  // static const String refreshTokenEndpoint = '$authBaseUrl/auth/refresh-token';


  static const String dataBaseUrl = 'https://jsonplaceholder.typicode.com'; // ตัวอย่าง: URL สำหรับ API ทั่วไป (เช่น users)
  static const String usersEndpoint = '$dataBaseUrl/users'; // ตัวอย่าง: Endpoint สำหรับดึงรายชื่อผู้ใช้
// static const String productsEndpoint = '$dataBaseUrl/products';

// เพิ่มค่าคงที่อื่นๆ ตามที่โปรเจกต์ของคุณต้องการ
}