import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'report.dart';
import 'loginPage.dart';
import 'reportDetailPage.dart';
import 'reportFormPage.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'main.dart';
import 'reportDetailEditPage.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminPage(),
    );
  }
}

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

// 🏠 หน้าหลัก
class _AdminPageState extends State<AdminPage> {
  List<Report> reports = [];
  String selectedStatus = 'ทั้งหมด';

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final url = Uri.parse('http://26.21.85.254:8080/Reportig/api/report.php');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        reports = data.map((json) => Report.fromJson(json)).toList();
      });
    }
  }

  Future<void> scanQRCode() async {
    String scannedResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "ยกเลิก", true, ScanMode.QR);
    if (scannedResult != "-1") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportDetailPage(
            reportId: int.parse(scannedResult.split("=").last),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildDropdown(),
            ],
          ),
          Expanded(child: _buildReportGrid()),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => ReportFormPage()),
      //     );
      //   },
      //   icon: Icon(Icons.warning, color: Colors.black),
      //   label: Text("แจ้งปัญหา",
      //       style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      //   backgroundColor: Colors.yellow[700],
      // ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Admin"),
      backgroundColor: Colors.green[300],
      actions: [IconButton(icon: Icon(Icons.info_outline), onPressed: () {})],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[300]),
            child: Text("เมนู",
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          // _buildDrawerItem(context, "แจ้งปัญหา", ReportFormPage()),
          _buildDrawerItem(context, "ออกจากระบบ", SplashScreen()),
          // _buildDrawerItem(context, "สำหรับหน่วยงาน", LoginScreen()),
          // _buildDrawerItem(context, "Admin", AdminPage()),
          // ListTile(title: Text("Scan QR Code"), onTap: scanQRCode),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DropdownButton<String>(
            value: selectedStatus,
            onChanged: (String? newValue) {
              setState(() {
                selectedStatus = newValue!;
              });
            },
            items: [
              "ทั้งหมด",
              "รอรับเรื่อง",
              "ส่งต่อ",
              "ดำเนินงาน",
              "เสร็จสิ้น"
            ]
                .map((status) =>
                    DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportGrid() {
    List<Report> filteredReports = selectedStatus == 'ทั้งหมด'
        ? reports
        : reports.where((r) => r.reportStatus == selectedStatus).toList();

    return reports.isEmpty
        ? Center(child: CircularProgressIndicator())
        : GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  (MediaQuery.of(context).size.width ~/ 300).clamp(1, 5),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: filteredReports.length,
            itemBuilder: (context, index) {
              return _buildReportCard(filteredReports[index]);
            },
          );
  }

  Widget _buildReportCard(Report report) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailEditPage(reportId: report.reportId),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side:
              BorderSide(color: _getStatusColor(report.reportStatus), width: 2),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                      backgroundColor: _getStatusColor(report.reportStatus),
                      radius: 8),
                  SizedBox(width: 8),
                  Text(report.reportStatus,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("  |  " +
                      DateFormat("d/M/yyyy HH:mm").format(report.dateTime)),
                  Text("  |  ${report.reportId}"),
                ],
              ),
              Text("รายละเอียด: ${report.reportDescription}"),
              Text("สถานที่: ${report.location}"),
              Text("ประเภท: ${report.problemType}"),
              SizedBox(height: 5),
              Expanded(
                child: Image.network(
                  report.reportImageUrl.isNotEmpty
                      ? report.reportImageUrl[0]
                      : "http://26.21.85.254:8080/Reportig/api/image_api.php?id=1",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Row(
              //         children: List.generate(
              //             5,
              //             (index) =>
              //                 Icon(Icons.star, color: Colors.amber, size: 16))),
              //     Row(children: [
              //       Icon(Icons.remove_red_eye, size: 16),
              //       Text("12")
              //     ]),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "รอรับเรื่อง":
        return Colors.red;
      case "ส่งต่อ":
        return Colors.blue;
      case "ดำเนินงาน":
        return Colors.orange;
      case "เสร็จสิ้น":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDrawerItem(BuildContext context, String title, Widget page) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }

   Widget buildSpeedial() {
    return Align(
      alignment: Alignment.bottomRight, // ตำแหน่งมุมขวาล่าง
      child: Padding(
        padding: const EdgeInsets.all(8.0), // เพิ่มระยะห่างจากขอบ
        child: SpeedDial(
          child: Icon(
            Icons.more_horiz,
            color: Colors.black,
          ),
          activeIcon: Icons.close,
          iconTheme: IconThemeData(color: Colors.white),
          buttonSize: Size(56, 56),
          backgroundColor: Colors.white,
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              elevation: 0,
              child: Icon(Icons.warning, color: Colors.black),
              backgroundColor: Colors.yellow,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportFormPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
      Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Center(
              child: Lottie.asset(
            "assets/animations/Uth.json",
            repeat: true,
            width: 250,
            height: 250,
          )),
        ]));
  }
}
