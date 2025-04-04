import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'report.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:confetti/confetti.dart';
import 'package:confetti/confetti.dart' as confetti_lib;

class ReportDetailPage extends StatefulWidget {
  final int reportId;

  const ReportDetailPage(
      {super.key, required this.reportId});

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  Report? report;
  bool isLoading = true;
  double _rating = 0.0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    fetchReportData();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> fetchReportData() async {
    final url = Uri.parse(
        "http://26.21.85.254:8080/Reportig/api/report.php?id=${widget.reportId}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        report = Report.fromJson(data);
        isLoading = false;
      });
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
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Card(
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageSection(),
                              const SizedBox(height: 20),
                              _buildStatusSection(),
                              const SizedBox(height: 20),
                              _buildDetailSection("รายละเอียดการร้องทุกข์",
                                  report!.reportDescription),
                              _buildDetailSection(
                                  "ประเภทปัญหา", report!.problemType),
                              _buildDetailSection("สถานที่", report!.location),
                              _buildDetailSection(
                                  "วันที่แจ้ง", report!.dateTime.toString()),
                              const SizedBox(height: 20),
                              _buildTimeline(),
                              const SizedBox(height: 10),
                              if (report!.reportStatus == 'เสร็จสิ้น')
                                _buildRatingSection(),
                              const SizedBox(height: 10),
                              _buildQRCodeSection(),
                              confetti_lib.ConfettiWidget(
                                confettiController: _confettiController,
                                blastDirectionality: confetti_lib
                                    .BlastDirectionality
                                    .explosive, // กระจายทุกทิศทาง
                                shouldLoop: false,
                                maxBlastForce:
                                    300, // ความแรงสูงสุดของการยิง confetti
                                minBlastForce:
                                    50, // ความแรงต่ำสุดของการยิง confetti
                                numberOfParticles:
                                    200, // จำนวนอนุภาคที่ปล่อยออกมา
                                emissionFrequency:
                                    0.02, // ความถี่ของการปล่อย confetti
                                gravity:
                                    0.5, // ค่าความเร่งแรงโน้มถ่วง (0.1 จะช้ากว่าค่าปกติ)
                                particleDrag:
                                    0.03, // ลดแรงเสียดทานให้ confetti ลอยนานขึ้น
                                colors: [
                                  Colors.red,
                                  Colors.blue,
                                  Colors.green,
                                  Colors.yellow,
                                  Colors.purple
                                ], // สีของอนุภาค
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

  Widget _buildImageSection() {
    List<String> images = [];

    if (report!.reportImageUrl.isNotEmpty &&
        report!.reportImageUrl[0].isNotEmpty) {
      images.add(report!.reportImageUrl[0]);
    } else {
      images.add("http://26.21.85.254:8080/Reportig/api/image_api.php?id=1");
    }

    if (report!.tasks.isNotEmpty &&
        report!.tasks.last.taskImageUrl.isNotEmpty &&
        report!.tasks.last.taskImageUrl[0].isNotEmpty) {
      images.add(report!.tasks.last.taskImageUrl[0]);
    } else {
      images.add("http://26.21.85.254:8080/Reportig/api/image_api.php?id=1");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("รูปภาพก่อนแจ้ง",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("รูปภาพหลังแจ้ง",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 5),
        if (images.isNotEmpty) _buildImageRow(images),
      ],
    );
  }

  Widget _buildImageRow(List<String> imageUrls) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: imageUrls.map((imageUrl) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height *
                    0.3, // Adjust image height based on screen size
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.green[100],
                  child:
                      Icon(Icons.broken_image, size: 50, color: Colors.green),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusSection() {
    Color statusColor;
    switch (report!.reportStatus) {
      case "เสร็จสิ้น":
        statusColor = Colors.green;
        break;
      case "ดำเนินงาน":
        statusColor = Colors.orange;
        break;
      case "รอรับเรื่อง":
        statusColor = Colors.red;
        break;
      case "ส่งต่อ":
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              radius: 10,
              backgroundColor: statusColor,
            ),
          ),
          Text(report!.reportStatus,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String? details) {
    String? formattedDate;
    if (title == "วันที่แจ้ง" && details != null) {
      // Format the date to "d/M/yyyy HH:mm:ss"
      try {
        DateTime dateTime = DateTime.parse(details);
        formattedDate = DateFormat("d/M/yyyy HH:mm:ss").format(dateTime);
      } catch (e) {
        formattedDate = details; // Fallback to the original if parsing fails
      }
    } else {
      formattedDate = details;
    }

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
          child: Text(formattedDate ?? "ไม่มีข้อมูล"),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Divider(color: Colors.purple),
          const SizedBox(height: 10),
          Column(
            children:
                report!.tasks.map((task) => _buildTimelineStep(task)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(Task task) {
    Color statusColor;
    switch (task.taskStatus) {
      case "เสร็จสิ้น":
        statusColor = Colors.green;
        break;
      case "ดำเนินงาน":
        statusColor = Colors.orange;
        break;
      case "รอรับเรื่อง":
        statusColor = Colors.red;
        break;
      case "ส่งต่อ":
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                radius: 10,
                backgroundColor: statusColor,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.taskStatus,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(DateFormat("d/M/yyyy HH:mm:ss")
                      .format(task.taskDateTime)),
                  const SizedBox(height: 5),
                  Text("หน่วยงานที่รับผิดชอบ: ${task.department}"),
                  Text("รายละเอียดปัญหา: ${task.taskDescription}"),
                ],
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget _buildQRCodeSection() {
    String qrData =
        // "http://yourwebsite.com/report_detail?reportId=${widget.reportId}"
        "https://github.com/Peerapath/App-Report";
    return Column(
      children: [
        SizedBox(height: 20),
        SizedBox(height: 10),
        BarcodeWidget(
          barcode: Barcode.qrCode(), // ใช้ QR Code
          data: qrData,
          width: 200,
          height: 200,
          drawText: false, // ไม่แสดงข้อความใต้ QR Code
          errorBuilder: (context, error) => Container(
            width: 200,
            height: 200,
            color: Colors.grey[300],
            child: Icon(Icons.error, size: 50, color: Colors.red),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "github.com/Peerapath/App-Report",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // เพิ่มฟังก์ชันการให้คะแนน
  Widget _buildRatingSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("ให้คะแนน",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(width: 20),
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
            if (mounted) {
              _confettiController.play();
            }
          },
        ),
        SizedBox(width: 20),
        Text("$_rating",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
