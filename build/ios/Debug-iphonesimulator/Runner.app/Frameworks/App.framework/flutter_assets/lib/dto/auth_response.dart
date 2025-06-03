import 'package:json_annotation/json_annotation.dart';
part 'auth_response.g.dart';

@JsonSerializable() // <--- Annotation ที่บอกให้ json_serializable ทำงาน
class AuthResponse {
  final String accessToken;
  final String refreshToken;

  AuthResponse({required this.accessToken, required this.refreshToken});

  // Factory constructor สำหรับสร้าง object จาก JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

  // Method สำหรับแปลง object เป็น JSON
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
