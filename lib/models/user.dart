import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? gender;
  final int? level;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.gender,
    this.level,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
      level: json['level'],
    );
  }

  @override
  List<Object?> get props => [id, name, email, gender, level];
}
