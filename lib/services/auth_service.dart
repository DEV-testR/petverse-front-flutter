// lib/data/services/auth_service.dart
import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../dto/auth_response.dart';
import '../dto/login_request.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  /// เมธอดสำหรับเรียก API เพื่อทำการ Login
  /// จะคืนค่าเป็น AuthResponse ที่มี accessToken และ refreshToken เท่านั้น
  Future<AuthResponse> login(LoginRequest request) async { // <<< เปลี่ยน Return Type
    try {
      final response = await _dioClient.post(
        ApiConstants.loginEndpoint,
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

      // แปลง JSON response กลับมาเป็น AuthResponse
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
}