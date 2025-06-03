// lib/data/services/user_service.dart

import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../dto/user.dart';
class UserService {
  final DioClient _dioClient;

  UserService(this._dioClient);

  /// เมธอดสำหรับดึงรายชื่อผู้ใช้จาก API (ตัวอย่าง)
  Future<List<User>> getUsers() async {
    try {
      final response = await _dioClient.get(ApiConstants.usersEndpoint);

      if (response.data == null || response.data is! List) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Invalid or empty response data for users list.',
        );
      }

      return (response.data as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      String errorMessage = 'Failed to connect to the server.';
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        if (statusCode == 404) {
          errorMessage = 'ไม่พบข้อมูลผู้ใช้';
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

  /// **เมธอดใหม่: สำหรับดึงข้อมูลโปรไฟล์ผู้ใช้ที่ Login อยู่**
  /// มักจะเรียก API ที่ใช้ accessToken เพื่อดึงข้อมูล user profile
  Future<User> getUserProfile() async {
    try {
      // **สำคัญ**: เปลี่ยน ApiConstants.userProfileEndpoint ให้ชี้ไปที่ API endpoint ของข้อมูลโปรไฟล์ผู้ใช้
      // (ตัวอย่าง: 'https://api.yourbackend.com/user/profile')
      // ถ้าไม่มี ให้ใช้ ApiConstants.usersEndpoint และเลือกข้อมูลของผู้ใช้คนแรกเพื่อเป็นตัวอย่าง
      final response = await _dioClient.get(ApiConstants.usersEndpoint); // สมมติว่าดึงจาก users endpoint ก่อน

      if (response.data == null || response.data is! List || (response.data as List).isEmpty) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'No user profile data found.',
        );
      }

      // ในความเป็นจริง API นี้ควรคืนข้อมูล UserDto มาโดยตรง ไม่ใช่ List
      // แต่สำหรับตัวอย่างนี้ ผมจะเลือกผู้ใช้คนแรกจาก List เพื่อแสดง
      final userJson = (response.data as List).first as Map<String, dynamic>;
      return User.fromJson(userJson);
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch user profile.';
      if (e.response != null && e.response!.statusCode == 401) {
        errorMessage = 'Access Token ไม่ถูกต้องหรือหมดอายุ โปรดเข้าสู่ระบบใหม่';
      } else {
        errorMessage = 'Error fetching user profile: ${e.toString()}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unknown error occurred while fetching user profile: ${e.toString()}');
    }
  }
}