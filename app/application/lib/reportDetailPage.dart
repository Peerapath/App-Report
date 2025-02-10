import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ReportDetailPage extends StatefulWidget {
  final int reportId;

  const ReportDetailPage({super.key, required this.reportId});

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  Map<String, dynamic>? report;
  bool isLoading = true;

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
          report = data[0];
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("รายละเอียดปัญหา"),
        backgroundColor: Colors.green[300],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : report == null
              ? Center(child: Text("ไม่พบข้อมูล"))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: 700), // จำกัดกว้างสุด 700px
                    child: Card(
                      color: Colors.white, // พื้นหลังฟอร์ม
                      elevation: 5, // เพิ่มเงา
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _buildImageBox(
                                      "รูปภาพก่อนแจ้ง",
                                      (report!["report_image_path"] != null &&
                                              report!["report_image_path"]
                                                  .isNotEmpty)
                                          ? report!["report_image_path"][0]
                                          : null),
                                  const SizedBox(width: 20),
                                  _buildImageBox(
                                      "รูปภาพหลังแจ้ง",
                                      (report!["tasks"] != null &&
                                              report!["tasks"].isNotEmpty &&
                                              report!["tasks"][0]
                                                      ["task_image_path"] !=
                                                  null &&
                                              report!["tasks"][0]
                                                      ["task_image_path"]
                                                  .isNotEmpty)
                                          ? report!["tasks"][0]
                                              ["task_image_path"][0]
                                          : null),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildStatusSection(),
                              const SizedBox(height: 20),
                              _buildDetailSection("รายละเอียดการร้องทุกข์",
                                  report!["report_description"]),
                              _buildDetailSection(
                                  "ประเภทปัญหา", report!["problem_type"]),
                              _buildDetailSection(
                                  "สถานที่", report!["location"]),
                              _buildDetailSection(
                                  "วันที่แจ้ง", report!["date_time"]),
                              const SizedBox(height: 20),
                              _buildTimeline(),
                              const SizedBox(height: 20),
                              _buildLocationMap(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildImageBox(String title, String? imageUrl) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: imageUrl != null
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : Text("ไม่มีรูปภาพ"),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("สถานะ: ${report!["report_status"]}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String? details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(details ?? "ไม่มีข้อมูล"),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (report!["tasks"] != null)
                ...report!["tasks"].map<Widget>((task) {
                  // แปลงวันที่จาก String เป็น DateTime
                  DateTime dateTime = DateTime.parse(task["task_date_time"]);

                  // แปลงเป็นรูปแบบ ddMMyyyyHHmm
                  String formattedDate =
                      DateFormat("dd-MM-yyyy HH:mm").format(dateTime);

                  return _buildTimelineStep(
                    task["task_status"],
                    formattedDate, // ใช้วันที่ที่ฟอร์แมตแล้ว
                    task['task_status'] == "รอรับเรื่อง"
                        ? Colors.red
                        : (task['task_status'] == "ส่งต่อ"
                            ? Colors.lightBlue
                            : (task['task_status'] == "ดำเนินงาน"
                                ? Colors.orangeAccent
                                : (task['task_status'] == "เสร็จสิ้น"
                                    ? Colors.green
                                    : Colors.grey))),
                  );
                }).toList(),
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

  Widget _buildLocationMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("สถานที่",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green),
          ),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(report!['latitude'] ?? 13.7563,
                  report!['longitude'] ?? 100.5018),
              zoom: 14,
            ),
            markers: {
              Marker(
                markerId: MarkerId("report_location"),
                position: LatLng(report!['latitude'] ?? 13.7563,
                    report!['longitude'] ?? 100.5018),
              ),
            },
          ),
        ),
      ],
    );
  }
}
