import 'package:json_annotation/json_annotation.dart';
part 'login_request.g.dart';

@JsonSerializable() // <--- Annotation ที่บอกให้ json_serializable ทำงาน
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  // Factory constructor สำหรับสร้าง object จาก JSON
  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

  // Method สำหรับแปลง object เป็น JSON
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
