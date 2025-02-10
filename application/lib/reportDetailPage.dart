import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final url = Uri.parse("http://26.21.85.254:8080/Reportig/api/report.php?id=${widget.reportId}");
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageBox("รูปภาพก่อนแจ้ง", report!["report_image_path"]?.isNotEmpty == true ? report!["report_image_path"][0] : null),
                      const SizedBox(height: 20),
                      _buildStatusSection(),
                      const SizedBox(height: 20),
                      _buildDetailSection("รายละเอียดการร้องทุกข์", report!["report_description"]),
                      _buildDetailSection("ประเภทปัญหา", report!["problem_type"]),
                      _buildDetailSection("สถานที่", report!["location"]),
                      _buildDetailSection("วันที่แจ้ง", report!["date_time"]),
                      const SizedBox(height: 20),
                      _buildTimeline(),
                      const SizedBox(height: 20),
                      _buildLocationMap(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildImageBox(String title, String? imageUrl) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          width: double.infinity,
          height: 200,
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
          Text("สถานะ: ${report!["report_status"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String? details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ไทม์ไลน์การดำเนินการ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        if (report!["tasks"] != null)
          ...report!["tasks"].map<Widget>((task) => _buildTimelineStep(task["task_status"], task["task_date_time"], Colors.blue)).toList(),
      ],
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
        Text("สถานที่", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green),
          ),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(13.7563, 100.5018),
              zoom: 14,
            ),
          ),
        ),
      ],
    );
  }
}
