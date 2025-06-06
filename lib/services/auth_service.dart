// lib/data/services/auth_service.dart
import 'package:dio/dio.dart';

import '../core/network/api_constants.dart';
import '../core/network/dio_client.dart';
import '../dto/auth_response.dart';
import '../dto/login_request.dart';
import '../main.dart';

class AuthService {
  final DioClient _dioClient;
  AuthService(this._dioClient);

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      logger.d('[BEGIN] AuthService.login');
      final response = await _dioClient.post(
        '${ApiConstants.baseUrl}/auth/login',
        data: request.toJson(),
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid or empty response data from login API.',
        );
      }

      return AuthResponse.fromJson(response.data); // <<< ใช้ AuthResponse
    } on DioException catch (e) {
      String errorMessage = 'Failed to connect to the server.';
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (statusCode == 401) {
          errorMessage = 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
        } else if (statusCode == 400 && responseData != null && responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else {
          errorMessage = 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์: $statusCode';
        }
      } else {
        errorMessage = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณ';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดที่ไม่รู้จัก: ${e.toString()}');
    }
  }

  Future<AuthResponse> loginWithPin(String email, String pin) async {
    try {
      logger.d('[BEGIN] AuthService.loginWithPin');
      final response = await _dioClient.get(
        '${ApiConstants.baseUrl}/auth/login/pin',
        queryParameters: {
          'email': email,
          'pin': pin,
        },
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid or empty response data from login API.',
        );
      }

      return AuthResponse.fromJson(response.data); // <<< ใช้ AuthResponse
    } on DioException catch (e) {
      String errorMessage = 'Failed to connect to the server.';
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        if (statusCode == 401) {
          errorMessage = 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
        } else if (statusCode == 400 && responseData != null && responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else {
          errorMessage = 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์: $statusCode';
        }
      } else {
        errorMessage = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณ';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดที่ไม่รู้จัก: ${e.toString()}');
    }
  }

  Future<bool> validateEmail(String email) async {
    try {
      logger.d('[BEGIN] AuthService.validateEmail with email: $email');

      // *** แก้ไข: ใช้ queryParameters สำหรับ GET request แทน data ***
      final response = await _dioClient.get(
        '${ApiConstants.baseUrl}/auth/email/validate',
        queryParameters: {
          'email': email, // ส่งอีเมลเป็น query parameter
        },
      );

      logger.d('Response status code: ${response.statusCode}');
      logger.d('Response data: ${response.data}');

      // ตรวจสอบสถานะ response
      if (response.statusCode != 200) { // แก้ไข !== เป็น !=
        // การโยน DioException ด้วย response ที่มีอยู่แล้ว
        // จะช่วยให้การจัดการ error ใน catch block ทำงานได้ดีขึ้น
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse, // อาจเปลี่ยนเป็น DioExceptionType.badResponse ขึ้นอยู่กับเวอร์ชั่น Dio
          error: 'Invalid or unexpected response from API for email verification.',
        );
      }

      // ถ้าต้องการคืนค่า AuthResponse:
      // final authResponse = AuthResponse.fromJson(response.data);
      // return authResponse;

      // ถ้าต้องการแค่ตรวจสอบว่า email ถูก verify สำเร็จหรือไม่
      // และ API คืน 200 OK หมายถึงสำเร็จ
      return true;

    } on DioException catch (e) {
      String errorMessage = 'Failed to connect to the server.';
      logger.e('DioException occurred in verifilyEmail: ${e.message}');
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data; // อาจเป็น Map, String หรืออื่นๆ

        logger.e('Response Status Code: $statusCode');
        logger.e('Response Data: $responseData');

        if (statusCode == 401) {
          errorMessage = 'ไม่ได้รับอนุญาต: ข้อมูลยืนยันตัวตนไม่ถูกต้อง';
        } else if (statusCode == 400) {
          if (responseData != null && responseData is Map<String, dynamic> && responseData.containsKey('message')) {
            errorMessage = responseData['message'].toString(); // ดึง message จาก response body
          } else {
            errorMessage = 'ข้อมูลไม่ถูกต้อง: $statusCode'; // Fallback message
          }
        } else if (statusCode == 404) {
          errorMessage = 'ไม่พบปลายทาง API: $statusCode';
        } else if (statusCode == 500) {
          errorMessage = 'เกิดข้อผิดพลาดภายในเซิร์ฟเวอร์: $statusCode';
        } else {
          errorMessage = 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์: $statusCode';
        }
      } else {
        // กรณีที่ไม่มี response (เช่น connection timeout, ไม่มีอินเทอร์เน็ต)
        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
          errorMessage = 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
        } else if (e.type == DioExceptionType.unknown) {
          errorMessage = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณ';
        } else {
          errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${e.message}';
        }
      }
      // โยน Exception ที่มี errorMessage ที่ชัดเจน
      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Unknown error occurred in verifilyEmail: $e');
      throw Exception('เกิดข้อผิดพลาดที่ไม่รู้จัก: ${e.toString()}');
    }
  }
}