import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:application/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'reportForm.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  _ReportFormPageState createState() => _ReportFormPageState();
}
class SplashForm extends StatefulWidget {
  @override
  _SplashFormState createState() => _SplashFormState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedCategory = "ถนน";
  String _selectedUrgency = "ภายใน 3 วัน";
  List<Uint8List> _selectedImages = [];
  String responseText = '';
  bool isLoading = false;

  /// 📌 ฟังก์ชันเลือกรูปภาพ รองรับทั้ง Mobile และ Web
  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, withData: true);

    if (result != null) {
      setState(() {
        _selectedImages = result.files.map((file) => file.bytes!).toList();
      });
    }
  }

  /// 📌 ฟังก์ชันส่งข้อมูลไปยังเซิร์ฟเวอร์
  Future<void> sendPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      ReportForm reportForm = ReportForm(
        dateTime: DateTime.now(),
        description: _detailController.text,
        problemTypeId: (() {
          switch (_selectedCategory) {
            case "ถนน":
              return 1;
            case "สะพาน":
              return 2;
            case "อาคาร":
              return 3;
            case "ไฟฟ้า":
              return 4;
            case "น้ำเสีย":
              return 5;
            default:
              return 0;
          }
        })(),
        location: _locationController.text,
        urgencyId: _selectedUrgency == "ภายใน 3 วัน"
            ? 1
            : (_selectedUrgency == "ภายใน 1 สัปดาห์" ? 2 : 3),
        statusId: 1,
        fName: _nameController.text.split(' ')[0],
        lName: _nameController.text.split(' ').length > 1
            ? _nameController.text.split(' ')[1]
            : "",
        email: _emailController.text,
        reportImages: _selectedImages, // 📌 ใช้รูปภาพที่เป็น `Uint8List`
      );

      String response = await reportForm.uploadReport();

      setState(() {
        responseText = response.contains("success")
            ? 'Post Created Successfully'
            : 'Error creating post';
      });

      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ส่งข้อมูลสำเร็จ!")),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      });
    }
  }

  /// 📌 แสดงตัวอย่างรูปภาพที่เลือก
  Widget _buildImagePreview(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.memory(_selectedImages[index], fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text("แจ้งปัญหา", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.green[300],
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            color: Colors.white,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("รายละเอียดการแจ้งปัญหา"),
                      TextFormField(
                        controller: _detailController,
                        decoration: InputDecoration(
                          hintText: "กรุณาพิมพ์รายละเอียดที่ต้องการแจ้ง",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        validator:
                            RequiredValidator(errorText: "กรุณากรอกข้อมูล"),
                      ),
                      const SizedBox(height: 10),
                      const Text("เลือกประเภทปัญหา"),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: ["ถนน", "สะพาน", "อาคาร", "ไฟฟ้า", "น้ำเสีย"]
                            .map((String category) {
                          return DropdownMenuItem(
                              value: category, child: Text(category));
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("ชื่อ-นามสกุล ผู้แจ้ง"),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "กรุณากรอกชื่อ-นามสกุล",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'กรุณากรอกชื่อ-นามสกุล')
                        ]),
                      ),
                      const SizedBox(height: 10),
                      const Text("อีเมลผู้แจ้ง"),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "เช่น abc@gmail.com",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                          EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง')
                        ]),
                      ),
                      const SizedBox(height: 10),
                      const Text("สถานที่เกิดเหตุ"),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: "กรุณากรอกสถานที่เกิดเหตุ",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: RequiredValidator(
                            errorText: "กรุณากรอกสถานที่เกิดเหตุ"),
                      ),
                      const SizedBox(height: 10),
                      const Text("แนบรูปภาพ"),
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _selectedImages.isNotEmpty
                                ? _buildImagePreview(context)
                                : const Center(child: Text("แตะเพื่อเลือกภาพ")),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.green[300]))
                              : ElevatedButton(
                                  onPressed: sendPost,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[200]),
                                  child: const Text("ส่งข้อมูล",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _SplashFormState extends State<SplashForm> {
  @override
  void initState() {
    super.initState();
    // ตั้งเวลาให้โหลด 3 วินาทีก่อนเปลี่ยนไปหน้าหลัก
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ReportFormPage()),
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
}