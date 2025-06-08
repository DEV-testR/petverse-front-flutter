import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // ไม่จำเป็นต้อง import ที่นี่แล้ว เพราะ DioClient จัดการเอง

import '../core/network/api_constants.dart';
import '../core/network/dio_client.dart';
import '../dto/user.dart';


class UserService {
  final DioClient _dioClient;

  UserService(this._dioClient);

  /// เมธอดสำหรับดึงรายชื่อผู้ใช้ทั้งหมดจาก API
  /// **เมธอดนี้ควรคืนค่าเป็น List ของผู้ใช้**
  Future<List<User>> fetchListUsers() async {
    try {
      // เรียก API ที่คืนค่าเป็น List ของผู้ใช้ทั้งหมด
      final response = await _dioClient.get('${ApiConstants.baseUrl}/v1/users/getUsers');
      if (response.data == null || response.data is! List) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid or empty response data for users list. Expected a List.',
        );
      }

      return (response.data as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch users list.';
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        if (statusCode == 404) {
          errorMessage = 'ไม่พบข้อมูลผู้ใช้'; // อาจจะหมายถึงไม่มีผู้ใช้ในระบบ
        } else if (responseData != null && responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else {
          errorMessage = 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์: $statusCode';
        }
      } else {
        errorMessage = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณ';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดที่ไม่รู้จักในการดึงผู้ใช้: ${e.toString()}');
    }
  }

  /// **เมธอดสำหรับดึงข้อมูลโปรไฟล์ผู้ใช้ที่ Login อยู่**
  /// เมธอดนี้จะเรียก API ที่ใช้ accessToken เพื่อดึงข้อมูล user profile ของตัวเอง
  Future<User> fetchUser() async {
    try {
      // เรียก API endpoint สำหรับข้อมูลโปรไฟล์ของผู้ใช้ที่ล็อกอินอยู่
      // ซึ่ง API นี้ควรคืนข้อมูล User object เดียว (Map<String, dynamic>)
      final response = await _dioClient.get('${ApiConstants.baseUrl}/v1/users/me');
      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid or empty response data for user profile. Expected a Map.',
        );
      }

      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch user profile.';
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        if (statusCode == 401) {
          errorMessage = 'Access Token ไม่ถูกต้องหรือหมดอายุ โปรดเข้าสู่ระบบใหม่';
        } else if (statusCode == 404) {
          errorMessage = 'ไม่พบข้อมูลโปรไฟล์ผู้ใช้ (404)';
        } else if (responseData != null && responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else {
          errorMessage = 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์: $statusCode';
        }
      } else {
        errorMessage = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณ';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unknown error occurred while fetching user profile: ${e.toString()}');
    }
  }
}