import 'package:flutter/material.dart';

import 'loginPage.dart';
import 'reportDetailPage.dart';
import 'reportFormPage.dart';
import 'main.dart';

// 🔓 admin
class AdminPage extends StatelessWidget {
  final List<Map<String, dynamic>> reports = [
    {"status": "เสร็จสิ้น", "color": Colors.green},
    {"status": "รอดำเนินการ", "color": Colors.blue},
    {"status": "รอรับเรื่อง", "color": Colors.orange},
    {"status": "รอรับเรื่อง", "color": Colors.orange},
    {"status": "รอดำเนินการ", "color": Colors.blue},
    {"status": "เสร็จสิ้น", "color": Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100], // เพิ่มสีพื้นหลังที่นี่
      appBar: AppBar(
        title: Text("Aidmin"),
        backgroundColor: Colors.green[300],
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
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
                title: Text("อื่นๆ"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color.fromARGB(255, 0, 255, 242),
            child: const Column(
              children: [
                Text(
                  "รูปภาพ",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Icon(Icons.circle, size: 10, color: Colors.black),
              ],
            ),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = (constraints.maxWidth ~/ 225).clamp(1, 5);
                return GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportDetailPage(
                                reportId: 1,
                                // {
                                //   "status": reports[index]['status'],
                                //   "date":
                                //       "25 มกราคม 2025", // ตัวอย่างวันที่แจ้ง
                                //   "location":
                                //       "กรุงเทพมหานคร", // ตัวอย่างสถานที่
                                // },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  color: Colors.green[100],
                                  child: Center(child: Text("รูปภาพ")),
                                ),
                                Text("ID"),
                                Text("วันที่แจ้ง สถานที่"),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: reports[index]['color'],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    reports[index]['status'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
          // ปุ่มแจ้งปัญหา
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
              label: const Text(
                "แจ้งปัญหา",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
