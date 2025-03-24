import 'package:application/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterPageScreen(),
    );
  }
}

class RegisterPageScreen extends StatefulWidget {
  @override
  _RegisterPageScreen createState() => _RegisterPageScreen();
}

class _RegisterPageScreen extends State<RegisterPageScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false; // ✅ ตัวแปรควบคุมสถานะโหลด

  // ฟังก์ชันล็อกอิน
  void Register() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // ✅ เริ่มโหลด
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          isLoading = false; // ✅ หยุดโหลด
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
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
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              color: Colors.white,
              elevation: 5,
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
                        const Text(
                          "สมัครสมาชิก",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: "ชื่อนาม-สกุล",
                              hintText: "กรอกชื่อ-นามสกุล",
                              border: OutlineInputBorder()),
                          validator: MultiValidator([
                            RequiredValidator(
                                errorText: 'กรุณากรอกชื่อ-นามสกุล')
                          ]),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "อีเมล",
                            hintText: "กรอกอีเมลของคุณ",
                            border: OutlineInputBorder(),
                          ),
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                            EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "รหัสผ่าน",
                            hintText: "กรอกรหัสผ่าน",
                            border: OutlineInputBorder(),
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
                                    builder: (context) => LoginScreen()),
                              );
                            },
                            child: const Text("คุณมีบัญชีอยู่แล้ว!"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: isLoading
                              ? SpinKitCircle(
                                  color: Colors.green, // ✅ แสดง Spinner
                                  size: 50.0,
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 15),
                                  ),
                                  onPressed: Register,
                                  child: const Text(
                                    "ตกลง",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ),
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
