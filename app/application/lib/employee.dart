import 'dart:async';
import 'dart:convert';
import 'package:application/reportDetailPageEP.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'report.dart';
import 'loginPage.dart';
import 'reportDetailPage.dart';
import 'reportFormPage.dart';
import 'admin.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'main.dart';

class userPage extends StatefulWidget {
  final int employeeID;
  final String f_name;
  final String l_name;

  const userPage(
      {super.key,
      required this.employeeID,
      required this.f_name,
      required this.l_name});

  @override
  _userPageState createState() => _userPageState();
}

class _userPageState extends State<userPage> {
  List<Report> reports = [];
  String selectedStatus = 'ทั้งหมด';
  String selectedStatus_job = "ทั้งหมด";
  bool dropdown_grid = false;
  bool button_grid = false;

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
      // for (var report in reports) {
      //   print(report.employeesId);
      // }
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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButtonAccept_Job(),
              _buildDropdown(),
            ],
          ),
          Expanded(
            child: button_grid ? _buildReportGrid_job() : _buildReportGrid(),
          ),
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
      title: Text("${widget.f_name} ${widget.l_name}"),
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
          ListTile(title: Text("Scan QR Code"), onTap: scanQRCode),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    fetchReports();
    dropdown_grid = true;
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
              "ส่งต่อ",
              "ดำเนินงาน",
              "เสร็จสิ้น",
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
    List<Report> filteredReports = reports
        .where((r) => r.employeesId == widget.employeeID)
        .where((r) =>
            selectedStatus == 'ทั้งหมด' || r.reportStatus == selectedStatus)
        .toList();

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
            builder: (context) => ReportDetailPageEP(
                reportId: report.reportId, employeeID: widget.employeeID),
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

  Widget _buildButtonAccept_Job() {
    fetchReports();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            button_grid = !button_grid;
            dropdown_grid = false;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: button_grid ? Colors.red : Colors.grey,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          button_grid ? "กลับไปหน้าหลัก" : "แสดงงานที่ต้องรับ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildReportGrid_job() {
    List<Report> filteredReports = reports
        .where((r) => r.reportStatus == "รอรับเรื่อง")
        .where((r) =>
            selectedStatus_job == 'ทั้งหมด' ||
            r.reportStatus == selectedStatus_job)
        .toList();
    // List<Report> filteredReports = selectedStatus_job == 'ทั้งหมด'
    //     ? reports
    //     : reports.where((r) => r.reportStatus == selectedStatus_job).toList();

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
              return _buildReportCard_job(filteredReports[index]);
            },
          );
  }

  Widget _buildReportCard_job(Report report) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailPageEP(
              reportId: report.reportId,
              employeeID: widget.employeeID,
            ),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
