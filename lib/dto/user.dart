import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String email;
  final String? fullName; // <--- Change to nullable String

  User({required this.id, required this.email, this.fullName}); // <--- Make fullName optional in constructor

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}