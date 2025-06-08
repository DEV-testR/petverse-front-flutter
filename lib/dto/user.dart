import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:petverse_front_flutter/main.dart'; // <--- ถ้าคุณอ้างอิง logger จาก main.dart

part 'user.g.dart';

@JsonSerializable()
class User {
  final String email;
  final String? fullName;
  final String? profilePic;
  final DateTime? dateOfBirth; // Assuming this field exists and is DateTime
  final String? phoneNumber;
  final String? address;

  User({
    required this.email,
    this.fullName,
    this.profilePic,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
  });

  // เมธอดสำหรับจัดรูปแบบ dateOfBirth
  String getDateOfBirth({String locale = 'th'}) { // เพิ่ม parameter locale
    if (dateOfBirth != null) {
      try {
        // ไม่ต้อง parse แล้ว เพราะ dateOfBirth เป็น DateTime อยู่แล้ว
        // กำหนดรูปแบบวันที่ที่คุณต้องการ เช่น "dd MMMM yyyy"
        return DateFormat('dd MMMM yyyy', locale).format(dateOfBirth!);
      } catch (err) {
        // ใช้ logger ที่ถูกต้อง
        logger.e('Error formatting date of birth: $dateOfBirth - $err');
        return 'N/A';
      }
    }
    return 'N/A'; // คืนค่า 'Not set' ถ้า dateOfBirth เป็น null
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}