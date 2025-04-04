import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:form_field_validator/form_field_validator.dart';

class ReportDetailEditPage extends StatefulWidget {
  final reportId;

  const ReportDetailEditPage({super.key, required this.reportId});

  @override
  _ReportDetailEditPageState createState() => _ReportDetailEditPageState();
}

class _ReportDetailEditPageState extends State<ReportDetailEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _solutionController = TextEditingController();
  String _selectedStatus = "รอรับเรื่อง";
  String _selectedDepartment = "หน่วยงาน A";
  File? _beforeImage;
  File? _afterImage;
  bool isLoading = true;

  final List<String> statuses = ["รอรับเรื่อง", "กำลังดำเนินการ", "เสร็จสิ้น"];
  final List<String> departments = ["หน่วยงาน A", "หน่วยงาน B", "หน่วยงาน C"];

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    final url = Uri.parse(
        "http://26.21.85.254:8080/Reportig/api/report.php?id=${widget.reportId}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void validatorsent() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ส่งข้อมูลสำเร็จ!")),
      );
    }
  }

  Future<void> _pickImage(bool isBefore) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isBefore) {
          _beforeImage = File(pickedFile.path);
        } else {
          _afterImage = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text("รายละเอียดปัญหา", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.green[300],
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            color: Colors.white,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildImageBox("ก่อนแจ้ง", _beforeImage, true),
                        const SizedBox(width: 20),
                        _buildImageBox("หลังแจ้ง", _afterImage, false),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDropdown("สถานะปัญหา", statuses, _selectedStatus,
                        (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildEditableField(
                        "รายละเอียดการร้องทุกข์", _complaintController),
                    _buildEditableField(
                        "รายละเอียดการแก้ไข", _solutionController),
                    _buildDropdown(
                        "เลือกหน่วยงาน", departments, _selectedDepartment,
                        (value) {
                      setState(() {
                        _selectedDepartment = value!;
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildTimeline(),
                    const SizedBox(height: 20),
                    _buildLocationMap(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text("ลบข้อมูลทั้งหมด",
                              style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("บันทึกการแก้ไข"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageBox(String title, File? imageFile, bool isBefore) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () => _pickImage(isBefore),
          child: Container(
            width: 150,
            height: 150,
            color: Colors.green[100],
            alignment: Alignment.center,
            child: imageFile != null
                ? Image.file(imageFile, fit: BoxFit.cover)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.green),
                      Text("แนบรูปภาพ"),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options,
      String selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: selectedValue,
          onChanged: onChanged,
          items: options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "ป้อน $label",
          ),
          validator: MultiValidator(
              [RequiredValidator(errorText: "กรุณากรอก${label}")]),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildLocationMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("สถานที่", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 300,
          decoration: BoxDecoration(border: Border.all(color: Colors.green)),
          // child: GoogleMap(
          //   initialCameraPosition: CameraPosition(
          //     target: LatLng(widget.report['latitude'] ?? 13.7563,
          //         widget.report['longitude'] ?? 100.5018),
          //     zoom: 14,
          //   ),
          //   markers: {
          //     Marker(
          //       markerId: MarkerId("report_location"),
          //       position: LatLng(widget.report['latitude'] ?? 13.7563,
          //           widget.report['longitude'] ?? 100.5018),
          //     ),
          //   },
          // ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ไทม์ไลน์การดำเนินการ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineStep(
                  "รอรับเรื่อง", "15 ธ.ค. 67\n12:00 น.", Colors.red),
              _buildTimelineStep(
                  "กำลังดำเนินการ", "15 ธ.ค. 67\n14:00 น.", Colors.orange),
              _buildTimelineStep(
                  "เสร็จสิ้น", "15 ธ.ค. 67\n15:00 น.", Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String time, Color color) {
    return Column(
      children: [
        Icon(Icons.circle, color: color, size: 20),
        const SizedBox(height: 5),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(time, textAlign: TextAlign.center),
      ],
    );
  }
}
