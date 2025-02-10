import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 🔎 หน้าหน้าแสดงรายละเอียด
class ReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green[100], // พื้นหลังนอกฟอร์ม
        appBar: AppBar(
          title: Text("รายละเอียดปัญหา", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.green[300],
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 700), // จำกัดกว้างสุด 700px
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
                          _buildImageBox("ก่อนแจ้ง", report['beforeImage']),
                          const SizedBox(width: 20),
                          _buildImageBox("หลังแจ้ง", report['afterImage']),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildStatusSection(),
                      const SizedBox(height: 20),
                      _buildDetailSection(
                          "รายละเอียดการร้องทุกข์", report['complaintDetails']),
                      _buildDetailSection(
                          "รายละเอียดการแก้ไข", report['solutionDetails']),
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
        ));
  }

  Widget _buildImageBox(String title, String? imageUrl) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          width: 150,
          height: 150,
          color: Colors.green[100],
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
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("สถานะ: ${report['status']}",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          Text("ปัญหา: "),
          Text("วันที่แจ้ง: ${report['date'] ?? 'ไม่ระบุ'}"),
          Text("สถานที่: ${report['location'] ?? 'ไม่ระบุ'}"),
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

  Widget _buildLocationMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("สถานที่",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(5.0),
          margin: EdgeInsets.symmetric(vertical: 5.0),
          height: 300,
          width: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.green),
          ),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(report['latitude'] ?? 13.7563,
                  report['longitude'] ?? 100.5018),
              zoom: 14,
            ),
            markers: {
              Marker(
                markerId: MarkerId("report_location"),
                position: LatLng(report['latitude'] ?? 13.7563,
                    report['longitude'] ?? 100.5018),
              ),
            },
          ),
        ),
      ],
    );
  }
}
