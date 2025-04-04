// To parse this JSON data, do
//
//     final apiJson = apiJsonFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ApiJson apiJsonFromJson(String str) => ApiJson.fromJson(json.decode(str));

String apiJsonToJson(ApiJson data) => json.encode(data.toJson());

class ApiJson {
    String success;
    User user;

    ApiJson({
        required this.success,
        required this.user,
    });

    factory ApiJson.fromJson(Map<String, dynamic> json) => ApiJson(
        success: json["success"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "user": user.toJson(),
    };
}

class User {
    int employeeId;
    String userName;
    String firstName;
    String lastName;
    int roleId;
    String roleName;
    int departmentId;
    String departmentName;
    int organizationId;
    String organizationName;

    User({
        required this.employeeId,
        required this.userName,
        required this.firstName,
        required this.lastName,
        required this.roleId,
        required this.roleName,
        required this.departmentId,
        required this.departmentName,
        required this.organizationId,
        required this.organizationName,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        employeeId: json["employee_id"],
        userName: json["user_name"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        roleId: json["role_id"],
        roleName: json["role_name"],
        departmentId: json["department_id"],
        departmentName: json["department_name"],
        organizationId: json["organization_id"],
        organizationName: json["organization_name"],
    );

    Map<String, dynamic> toJson() => {
        "employee_id": employeeId,
        "user_name": userName,
        "first_name": firstName,
        "last_name": lastName,
        "role_id": roleId,
        "role_name": roleName,
        "department_id": departmentId,
        "department_name": departmentName,
        "organization_id": organizationId,
        "organization_name": organizationName,
    };
}
