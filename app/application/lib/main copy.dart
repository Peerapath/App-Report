import 'dart:convert';
import 'package:application/admin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'loginPage.dart';
import 'reportDetailPage.dart';
import 'reportFormPage.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// 🏠 หน้าหลัก (StatefulWidget)
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> reportsFromApi = [];
  String selectedStatus = 'ทั้งหมด';

  Future<void> getData() async {
    final url = Uri.parse('http://26.21.85.254:8080/Reportig/api/report.php');
    final response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> newReports = json.decode(response.body);
      setState(() {
        reportsFromApi = newReports.map<Map<String, dynamic>>((report) {
          return {
            "id": report['report_id'],
            "date": report['date_time'],
            "location": report['location'],
            "status": report['report_status'],
            "problemType": report['problem_type'],
            "description": report['report_description'],
            "image": report['report_image_url'].isNotEmpty
                ? report['report_image_url'][0]
                : null,
          };
        }).toList();
      });
    }
  }

  List<Map<String, dynamic>> getFilteredReports() {
    if (selectedStatus == 'ทั้งหมด') {
      return reportsFromApi;
    } else {
      return reportsFromApi
          .where((report) => report['status'] == selectedStatus)
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text("หน้าหลัก"),
        backgroundColor: Colors.green[300],
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {},
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[300]),
              child: Text("เมนู",
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
                title: Text("แจ้งปัญหา"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportFormPage()),
                  );
                }),
            ListTile(
                title: Text("หน้าหลัก"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }),
            ListTile(
                title: Text("สำหรับหน่วยงาน"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }),
            ListTile(
                title: Text("Admin"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminPage()),
                  );
                }),
            ListTile(
              title: Text("Scan QR Code"),
              onTap: () {
                scanQRCode();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
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
                  items: <String>[
                    'ทั้งหมด',
                    'รอรับเรื่อง',
                    'ส่งต่อ',
                    'ดำเนินงาน',
                    'เสร็จสิ้น'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = (constraints.maxWidth ~/ 225).clamp(2, 6);
                return reportsFromApi.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: getFilteredReports().length,
                        itemBuilder: (context, index) {
                          final report = getFilteredReports()[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportDetailPage(
                                    reportId: report["id"],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: report['status'] == "รอรับเรื่อง"
                                        ? Colors.red
                                        : (report['status'] == "ส่งต่อ"
                                            ? Colors.lightBlue
                                            : (report['status'] == "ดำเนินงาน"
                                                ? Colors.yellow
                                                : (report['status'] ==
                                                        "เสร็จสิ้น"
                                                    ? Colors.green
                                                    : Colors.grey))),
                                    width: 1),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    report['image'] != null
                                        ? Image.network(report['image'],
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.cover)
                                        : Container(
                                            width: double.infinity,
                                            height: 50,
                                            color: Colors.grey[300],
                                            child:
                                                Center(child: Text("ไม่มีภาพ")),
                                          ),
                                    Text("ID: ${report['id']}"),
                                    Text("วันที่: ${report['date']}"),
                                    Text("สถานที่: ${report['location']}"),
                                    Text("ประเภท: ${report['problemType']}"),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: report['status'] == "รอรับเรื่อง"
                                            ? Colors.red[200]
                                            : (report['status'] == "ส่งต่อ"
                                                ? Colors.lightBlue[200]
                                                : (report['status'] ==
                                                        "ดำเนินงาน"
                                                    ? Colors.yellow[200]
                                                    : (report['status'] ==
                                                            "เสร็จสิ้น"
                                                        ? Colors.green[200]
                                                        : Colors.grey[200]))),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: report['status'] ==
                                                    "รอรับเรื่อง"
                                                ? Colors.red
                                                : (report['status'] == "ส่งต่อ"
                                                    ? Colors.lightBlue
                                                    : (report['status'] ==
                                                            "ดำเนินงาน"
                                                        ? Colors.yellow
                                                        : (report['status'] ==
                                                                "เสร็จสิ้น"
                                                            ? Colors.green
                                                            : Colors.grey))),
                                            width: 1),
                                      ),
                                      child: Text(
                                        report['status'],
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportFormPage()),
                );
              },
              icon: const Icon(Icons.warning, color: Colors.black),
              label: const Text("แจ้งปัญหา",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> scanQRCode() async {
    String scannedResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // สีปุ่ม Cancel
      "ยกเลิก", // ข้อความปุ่ม Cancel
      true, // เปิด Flash ได้
      ScanMode.QR, // สแกนเฉพาะ QR Code
    );

    if (scannedResult != "-1") {
      // ไปที่หน้ารายละเอียดของ ReportId ที่สแกนมา
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportDetailPage(
              reportId: int.parse(scannedResult.split("=").last)),
        ),
      );
    }
  }
}
