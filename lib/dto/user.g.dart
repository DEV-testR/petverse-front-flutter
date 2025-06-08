// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  email: json['email'] as String,
  fullName: json['fullName'] as String?,
  profilePic: json['profilePic'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  address: json['address'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'email': instance.email,
  'fullName': instance.fullName,
  'profilePic': instance.profilePic,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
};
