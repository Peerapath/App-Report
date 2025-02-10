import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportFormPage extends StatefulWidget {
  @override
  _ReportFormPageState createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  int _problemTypeId = 1;
  int _urgencyId = 1;

  Future<void> _submitReport() async {
    final url = Uri.parse("http://26.21.85.254:8080/Reportig/api/report.php");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "date_time": DateTime.now().toIso8601String(),
        "description": _descriptionController.text,
        "problem_type_id": _problemTypeId,
        "location": _locationController.text,
        "urgency_id": _urgencyId,
        "status_id": 1,
        "f_name": _fNameController.text,
        "l_name": _lNameController.text,
        "email": _emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ส่งรายงานสำเร็จ")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาดในการส่งรายงาน")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("แจ้งปัญหา"), backgroundColor: Colors.green[300]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "รายละเอียดปัญหา")),
            TextField(controller: _locationController, decoration: InputDecoration(labelText: "สถานที่")),
            TextField(controller: _fNameController, decoration: InputDecoration(labelText: "ชื่อ")),
            TextField(controller: _lNameController, decoration: InputDecoration(labelText: "นามสกุล")),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "อีเมล")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReport,
              child: Text("ส่งรายงาน"),
            ),
          ],
        ),
      ),
    );
  }
}
