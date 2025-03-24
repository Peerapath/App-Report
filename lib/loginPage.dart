import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'user.dart';
import 'registerPage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  // ฟังก์ชันล็อกอิน
  void login() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เข้าสู่ระบบสำเร็จ!")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (contex) => userPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green[100],
        appBar: AppBar(
          title: null,
          backgroundColor: Colors.green[300],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 500), // จำกัดกว้างสุด 700px
            child: Card(
              // ใช้ Card เพื่อเพิ่มเงา และพื้นหลัง
              color: Colors.white, // พื้นหลังฟอร์ม
              elevation: 5, // เพิ่มเงา
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // SpinKitRotatingCircle(
                        //     color: Colors.white,
                        //     size: 50.0,
                        // ),
                        const SizedBox(height: 30),
                        const Text(
                          "เข้าสู่ระบบ",
                          style: TextStyle(fontSize: 30, color: Colors.black),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "อีเมล",
                            hintText: "กรอกอีเมลของคุณ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)
                            ),
                          ),
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                            EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
                          ]),
                        ),

                        const SizedBox(height: 10),
                        // const Text('รหัสผ่าน'),

                        TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "รหัสผ่าน",
                            hintText: "กรอกรหัสผ่าน",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน'),
                            MinLengthValidator(6,
                                errorText:
                                    'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'),
                          ]),
                        ),

                        const SizedBox(height: 5),

                         Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPageScreen()),
                          );
                        },
                        child: const Text("ยังไม่มีบัญชี? สมัครสมาชิก"),
                      ),
                    ),
                    const SizedBox(height: 20,),

                        Center(
                          child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                          onPressed: login,
                          child: const Text(
                            "ตกลง",
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                         const SizedBox(height: 10),
                   
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
