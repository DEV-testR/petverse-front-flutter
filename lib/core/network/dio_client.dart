import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_constants.dart';

class DioClient {
  // เปลี่ยนจากการสร้าง Dio instance ภายในคลาส
  // ไปเป็นการรับ Dio instance เข้ามาทาง Constructor
  final Dio _dio;

  // Constructor ที่รับ Dio instance เข้ามา
  DioClient(this._dio) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // แนบ accessToken จาก prefs ทุกครั้ง
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          // สามารถเพิ่ม print เพื่อ debug ได้
          // print('DioClient Interceptor: Adding Authorization header with token: $token');
        } else {
          // print('DioClient Interceptor: No access token found.');
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // ถ้า 401 ให้ลอง refresh token
        if (e.response?.statusCode == 401) {
          // print('DioClient Interceptor: 401 Unauthorized. Attempting to refresh token.');
          final refreshed = await _refreshToken();
          if (refreshed) {
            // print('DioClient Interceptor: Token refreshed. Retrying request.');
            // retry คำขอเดิม
            final requestOptions = e.requestOptions;
            final newToken =
            (await SharedPreferences.getInstance()).getString('accessToken');

            final options = Options(
              method: requestOptions.method,
              headers: {
                // คัดลอก headers เดิม และเพิ่ม Authorization header ใหม่
                ...requestOptions.headers,
                'Authorization': 'Bearer $newToken',
              },
            );

            // ส่งคำขอเดิมซ้ำด้วย Dio instance เดิม
            // ใช้ _dio.fetch เพื่อให้คำขอใหม่ผ่าน Interceptor อีกครั้ง
            final response = await _dio.fetch(requestOptions.copyWith(
              headers: options.headers, // ใช้ headers ที่อัปเดตแล้ว
            ));

            return handler.resolve(response); // ใช้ response ใหม่จากการ retry
          } else {
            // ถ้า refresh token ล้มเหลว ควรจัดการ logout ผู้ใช้
            // print('DioClient Interceptor: Failed to refresh token. Logging out user.');
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('accessToken');
            await prefs.remove('refreshToken');
            // คุณอาจต้องการ throw error หรือส่ง notification ให้ AuthProvider จัดการ logout ที่นี่
          }
        }
        return handler.next(e); // ให้ error เดิมไปต่อ
      },
    ));
    // print('DioClient initialized with Interceptors.'); // สำหรับ debug
  }

  // === Methods ใช้งานหลัก ===
  Future<Response> get(String path, {Options? options}) =>
      _dio.get(path, options: options);

  Future<Response> post(String path, {data, Options? options}) =>
      _dio.post(path, data: data, options: options);

  // === รีเฟรช Access Token ===
  Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      // print('DioClient: No refresh token found for refresh attempt.');
      return false;
    }

    try {
      // **สำคัญ**: สร้าง Dio instance ใหม่สำหรับการ refresh token โดยเฉพาะ
      // เพื่อป้องกันไม่ให้คำขอ refresh token วนกลับมาติด interceptor ตัวเอง
      // ซึ่งอาจทำให้เกิด loop ไม่สิ้นสุดหรือพฤติกรรมที่ไม่คาดคิดได้
      final Dio refreshDio = Dio();
      // _refreshDio.options.baseUrl = 'http://localhost:48080'; // กำหนด base URL ถ้าจำเป็น

      final response = await refreshDio.post(
        '${ApiConstants.baseUrl}/auth/refresh-token',
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['accessToken'] != null) {
        await prefs.setString('accessToken', response.data['accessToken']);
        // หาก backend ส่ง refreshToken ใหม่มาด้วย ควร update ด้วย
        // if (response.data['refreshToken'] != null) {
        //   await prefs.setString('refreshToken', response.data['refreshToken']);
        // }
        // print('DioClient: Refresh token successful!');
        return true;
      }
    } catch (_) {
      // หากเกิดข้อผิดพลาดในการ refresh token (เช่น refresh token ไม่ถูกต้อง/หมดอายุ)
      // ควรลบ token ทั้งหมดเพื่อบังคับให้ผู้ใช้ login ใหม่
      // print('DioClient: Refresh token failed. Clearing tokens.');
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
    }

    return false;
  }
}