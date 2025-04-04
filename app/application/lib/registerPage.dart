import 'package:application/loginPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

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

class ApiServiceRegister {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> createPost(
      String email, String password, String fullName, String UserName) async {
    try {
      List<String> parts = fullName.split(" ");
      String firstName = parts.isNotEmpty ? parts[0] : ""; // ชื่อ
      String lastName =
          parts.length > 1 ? parts.sublist(1).join(" ") : ""; // นามสกุล
      // print("ชื่อ: $firstName");
      // print("นามสกุล: $lastName");
      // print("$UserName");
      // print("$email");
      final response = await _dio
          .post('http://26.21.85.254:8080/Reportig/api/register.php', data: {
        "user_name": UserName,
        "password": password,
        "f_name": firstName,
        "l_name": lastName,
        "email": email,
        "role_id": "2",
        "department_id": "1"
      });
      print(response.data);
      return response.data;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}

class RegisterPageScreen extends StatefulWidget {
  @override
  _RegisterPageScreen createState() => _RegisterPageScreen();
}

class _RegisterPageScreen extends State<RegisterPageScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiServiceRegister _apiServiceRegister = ApiServiceRegister();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController UserNameController = TextEditingController();
  // final TextEditingController
  String responseText = '';
  bool isPasswordVisible = false;
  bool isLoading = false; // ✅ ตัวแปรควบคุมสถานะโหลด

  // ฟังก์ชันล็อกอินzzzz
  void Register() async {
    if (_formKey.currentState!.validate()) {
      final response = await _apiServiceRegister.createPost(
        emailController.text,
        passwordController.text,
        fullNameController.text,
        UserNameController.text,
      );
      setState(() {
        responseText = response != null
            ? 'Post Created: ${response['email']}'
            : 'Error creating post';
      });
      setState(() {
        isLoading = true; // ✅ เริ่มโหลด
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          isLoading = false; // ✅ หยุดโหลด
        });
        // buildAlert(context);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")),
        // );
      });
      buildAlert(context);
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
                          controller: fullNameController,
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
                          controller: UserNameController,
                          decoration: InputDecoration(
                            labelText: 'ชื่อผู้ใช้',
                            hintText: "กรอกชื่อผู้ใช้",
                            border: OutlineInputBorder(),
                          ),
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'กรุณากรอกชื่อผู้ใช้')
                          ]),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
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
                                  onPressed: () {
                                    Register();
                                  },
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

  void buildAlert(BuildContext context) {
    AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.success,
      width: 600,
      showCloseIcon: true,
      title: 'Succes',
      desc: 'สมัครใช้งานเสร็จสิ้น',
      btnOkOnPress: () {
        debugPrint('OnClcik');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (type) {
        debugPrint('Dialog Dissmiss from callback $type');
      },
    ).show();
  }
}
