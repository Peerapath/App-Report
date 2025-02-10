import 'package:flutter/material.dart';

// 🔓 สมัครสมาชิก
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100], // พื้นหลังนอกฟอร์ม
      appBar: AppBar(
        title: const Text("สมัครสมาชิก"),
        backgroundColor: Colors.green[300],
      ),
      body: Center(
        // จัดให้อยู่ตรงกลาง
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 500), // จำกัดกว้างสุด 700px
          child: Card(
            // ใช้ Card เพื่อเพิ่มเงา และพื้นหลัง
            color: Colors.white, // พื้นหลังฟอร์ม
            elevation: 5, // เพิ่มเงา
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ชื่อ-นามสกุล"),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "กรอกชื่อ-นามสกุล",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("อีเมล"),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "กรอกอีเมล",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("รหัสผ่าน"),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "ตั้งรหัสผ่าน",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        onPressed: () {
                          // เชื่อมต่อระบบสมัครสมาชิกที่นี่
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")),
                          );
                          Navigator.pop(context); // กลับไปหน้า Login
                        },
                        child: const Text("สมัครสมาชิก",
                            style: TextStyle(color: Colors.white)),
                      ),
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
}
