import 'dart:async';
import 'dart:convert';
import 'package:application/admin.dart';
import 'package:application/apiLogin.dart';
import 'package:application/main.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'employee.dart';
import 'registerPage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';

void main() {
  runApp(MyAppLogin());
}

class MyAppLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splashloading(),
    );
  }
}

class ApiServiceLogin {
  // late ApiJson _dataFromApi;
  late ApiJson errorstatus;

  Future<http.Response> loginAPI(String? username, String? password) async {
    // print(username);
    // print(password);
    var url = "http://26.21.85.254:8080/Reportig/api/login.php";
    var body = {"user_name": username, "password": password};

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: json.encode(body));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response;
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class Splashloading extends StatefulWidget {
  @override
  _SplashloadingState createState() => _SplashloadingState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiServiceLogin _apiServiceLogin = ApiServiceLogin();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String responseText = '';
  bool isPasswordVisible = false;
  bool isLoading = false;

  // ฟังก์ชันล็อกอินdadweq

  void login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final response = await _apiServiceLogin.loginAPI(
        _usernameController.text,
        _passwordController.text,
      );
      if (response.statusCode == 200) {
        setState(() {
          // responseText = response != null
          //     ? 'Post Created: ${response['user_name']}'
          //     : 'Error creating post';
          isLoading = true;
          ApiJson _apirespond = apiJsonFromJson(response.body);

          print(_apirespond.success);
          print(_apirespond.user.employeeId);

          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("เข้าสู่ระบบสำเร็จ!")),
            );
            if (_apirespond.user.roleId == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (contex) => userPage(
                          employeeID: _apirespond.user.employeeId,
                          f_name: _apirespond.user.firstName,
                          l_name: _apirespond.user.lastName,
                        )),
              );
            } else if (_apirespond.user.roleId == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (contex) => AdminPage()),
              );
            }
          });
        });
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง!")),
        );
      }
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
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: "ชื่อผู้ใช้",
                            hintText: "กรอกชื่อผู้ใช้ของคุณ",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'กรุณากรอกชื่อผู้ใช้'),
                          ]),
                        ),

                        const SizedBox(height: 10),
                        // const Text('รหัสผ่าน'),

                        TextFormField(
                          controller: _passwordController,
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

                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SplashScreen()),
                                  );
                                },
                                child: const Text("กลับหน้าหลัก"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RegisterPageScreen()),
                                  );
                                },
                                child: const Text("ยังไม่มีบัญชี? สมัครสมาชิก"),
                              ),
                            ]),
                        const SizedBox(
                          height: 20,
                        ),

                        Center(
                            child: isLoading
                                ? SpinKitCircle(
                                    color: Colors.green,
                                    size: 50.0,
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 15),
                                    ),
                                    onPressed: () {
                                      login();
                                    },
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

  void buildAlert(BuildContext context) {
    AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.success,
      width: 600,
      showCloseIcon: true,
      title: 'Succes',
      desc: 'ล็อกอินสำเร็จ',
      // btnOkOnPress: () {
      //   debugPrint('OnClcik');
      //   // Navigator.pushReplacement(
      //   //   context,
      //   //   MaterialPageRoute(builder: (context) => userPage()),
      //   // );
      // },
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (type) {
        debugPrint('Dialog Dissmiss from callback $type');
      },
    ).show();
  }
}

class _SplashloadingState extends State<Splashloading> {
  @override
  void initState() {
    super.initState();
    // ตั้งเวลาให้โหลด 3 วินาทีก่อนเปลี่ยนไปหน้าหลัก
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SpinKitFadingCircle(
          color: Colors.green,
          size: 50.0,
        ),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(""),
          content: new Text(msg),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return LoginScreen();
                }));
              },
            ),
          ],
        );
      },
    );
  }
}
