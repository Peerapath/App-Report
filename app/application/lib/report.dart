// To parse this JSON data, do
//
//     final report = reportFromJson(jsonString);

import 'dart:convert';

Report reportFromJson(String str) => Report.fromJson(json.decode(str));

String reportToJson(Report data) => json.encode(data.toJson());

class Report {
  int reportId;
  int employeesId;
  String reportDescription;
  String location;
  DateTime dateTime;
  String problemType;
  String reportStatus;
  List<String> reportImageUrl;
  List<Task> tasks;

  Report({
    required this.reportId,
    required this.employeesId,
    required this.reportDescription,
    required this.location,
    required this.dateTime,
    required this.problemType,
    required this.reportStatus,
    required this.reportImageUrl,
    required this.tasks,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        reportId: json["report_id"],
        employeesId: json["employees_id"],
        reportDescription: json["report_description"],
        location: json["location"],
        dateTime: DateTime.parse(json["date_time"]),
        problemType: json["problem_type"],
        reportStatus: json["report_status"],
        reportImageUrl:
            List<String>.from(json["report_image_url"].map((x) => x)),
        tasks: List<Task>.from(json["tasks"].map((x) => Task.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "report_id": reportId,
        "employees_id": employeesId,
        "report_description": reportDescription,
        "location": location,
        "date_time": dateTime.toIso8601String(),
        "problem_type": problemType,
        "report_status": reportStatus,
        "report_image_url": List<dynamic>.from(reportImageUrl.map((x) => x)),
        "tasks": List<dynamic>.from(tasks.map((x) => x.toJson())),
      };
}

class Task {
  int taskId;
  DateTime taskDateTime;
  String taskDescription;
  String taskStatus;
  String department;
  int employeesId;
  List<String> taskImageUrl;

  Task({
    required this.taskId,
    required this.taskDateTime,
    required this.taskDescription,
    required this.taskStatus,
    required this.department,
    required this.employeesId,
    required this.taskImageUrl,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        taskId: json["task_id"],
        taskDateTime: DateTime.parse(json["task_date_time"]),
        taskDescription: json["task_description"],
        taskStatus: json["task_status"],
        department: json["department"],
        employeesId: json["employees_id"],
        taskImageUrl: List<String>.from(json["task_image_url"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "task_id": taskId,
        "task_date_time": taskDateTime.toIso8601String(),
        "task_description": taskDescription,
        "task_status": taskStatus,
        "department": department,
        "employees_id": employeesId,
        "task_image_url": List<dynamic>.from(taskImageUrl.map((x) => x)),
      };
}
