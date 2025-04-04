// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String success;
  UserClass user;

  User({
    required this.success,
    required this.user,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        success: json["success"],
        user: UserClass.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "user": user.toJson(),
      };
}

class UserClass {
  int id;
  String userName;
  String fName;
  String lName;
  String email;

  UserClass({
    required this.id,
    required this.userName,
    required this.fName,
    required this.lName,
    required this.email,
  });

  factory UserClass.fromJson(Map<String, dynamic> json) => UserClass(
        id: json["id"],
        userName: json["user_name"],
        fName: json["f_name"],
        lName: json["l_name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_name": userName,
        "f_name": fName,
        "l_name": lName,
        "email": email,
      };
}
