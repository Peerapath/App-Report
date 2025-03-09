import 'package:application/admin.dart';
import 'package:flutter/material.dart';

import 'registerPage.dart';
import 'user.dart';

// 🔓 เข้าสู่ระบบ
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100], // พื้นหลังนอกฟอร์ม
      appBar: AppBar(
        title: const Text("เข้าสู่ระบบ"),
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
                    const Text("อีเมล"),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "กรอกอีเมลของคุณ",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("รหัสผ่าน"),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "กรอกรหัสผ่าน",
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => userPage()),
                          );
                          // เชื่อมต่อระบบล็อกอินที่นี่
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("เข้าสู่ระบบสำเร็จ!")),
                          );
                        },
                        child: const Text("เข้าสู่ระบบ",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                        child: const Text("ยังไม่มีบัญชี? สมัครสมาชิก"),
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
