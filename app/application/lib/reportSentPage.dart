import 'package:flutter/material.dart';
import 'dart:io';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ReportSentPage extends StatefulWidget {
  @override
  _ReportSentPageState createState() => _ReportSentPageState();
}

class _ReportSentPageState extends State<ReportSentPage> {
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController();
  String _selectedCategory = "หน่วยงาน A";
  // String _selectedUrgency = "ภายใน 3 วัน"; // ค่าตั้งต้นของความเร่งด่วน
  List<File> _selectedImages = []; // สำหรับมือถือ
  List<Uint8List> _selectedImagesWeb = []; // สำหรับเว็บ

  // 📷 เลือกรูปจากอุปกรณ์
  Future<void> _pickImages() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true, // อนุญาตให้เลือกหลายไฟล์
      );

      if (result != null) {
        setState(() {
          _selectedImagesWeb = result.files.map((file) => file.bytes!).toList();
        });
      }
    } else {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? pickedFiles = await picker.pickMultiImage();

      if (pickedFiles != null) {
        setState(() {
          _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
        });
      }
    }
  }

  // Google Maps
  // late GoogleMapController mapController;
  // final LatLng _center = const LatLng(13.7563, 100.5018); // Bangkok

  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

// ช่องแนบรูปภาพที่ปรับขนาดอัตโนมัติ
  Widget _buildImagePreview(BuildContext context) {
    double itemSize = (MediaQuery.of(context).size.width - 64) /
        2; // คำนวณขนาดของรูปภาพให้พอดีกับ 2 รูปในแถว

    return GridView.builder(
      shrinkWrap: true, // ทำให้ GridView ย่อขนาดตามขนาดของเนื้อหาภายใน
      physics: NeverScrollableScrollPhysics(), // ปิดการเลื่อน
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // จำนวนคอลัมน์ (แถวละ 2 รูป)
        crossAxisSpacing: 8.0, // ระยะห่างระหว่างรูป
        mainAxisSpacing: 8.0, // ระยะห่างในแนวตั้ง
      ),
      itemCount: kIsWeb ? _selectedImagesWeb.length : _selectedImages.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: itemSize,
            height: itemSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: kIsWeb
                ? Image.memory(_selectedImagesWeb[index], fit: BoxFit.cover)
                : Image.file(_selectedImages[index], fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100], // พื้นหลังนอกฟอร์ม
      appBar: AppBar(
        title: const Text("แจ้งปัญหา", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.green[300],
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        // จัดให้อยู่ตรงกลาง
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 700), // จำกัดกว้างสุด 700px
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
                    // Dropdown ประเภทปัญหา
                    const Text("เลือกหน่วยงาน"),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: [
                        "หน่วยงาน A",
                        "หน่วยงาน B",
                        "หน่วยงาน C",
                        "หน่วยงาน D"
                      ].map((String category) {
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

                    // ชื่อ-นามสกุล
                      const Text("ชื่อ-นามสกุล"),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "กรุณากรอกชื่อ-นามสกุล",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text("รายละเอียดปัญหา"),
                    TextField(
                      controller: _detailController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "กรุณาพิมพ์รายละเอียดที่ต้องการ",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // อีเมล
                    // const Text("อีเมลผู้แจ้ง"),
                    // TextField(
                    //   controller: _emailController,
                    //   keyboardType: TextInputType.emailAddress,
                    //   decoration: InputDecoration(
                    //     hintText: "เช่น abc@gmail.com",
                    //     border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(8)),
                    //   ),
                    // ),
                    // const SizedBox(height: 10),

                    // แนบรูปภาพ
                    // แนบรูปภาพ
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
                          child: _selectedImages.isNotEmpty ||
                                  _selectedImagesWeb.isNotEmpty
                              ? _buildImagePreview(context)
                              : const Center(child: Text("แตะเพื่อเลือกภาพ")),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // แผนที่ Google Map
                    // const Text("สถานที่เกิดปัญหา (คลิกแผนที่เพื่อเลือก)"),
                    // SizedBox(
                    //   height: 300,
                    //   child: GoogleMap(
                    //     onMapCreated: _onMapCreated,
                    //     initialCameraPosition:
                    //         CameraPosition(target: _center, zoom: 15),
                    //     markers: {
                    //       Marker(
                    //           markerId: const MarkerId("selectedLocation"),
                    //           position: _center),
                    //     },
                    //   ),
                    // ),
                    // const SizedBox(height: 10),

                    // 🔥 เลือกความเร่งด่วน
                    // const Text("ระดับความเร่งด่วน"),
                    // DropdownButtonFormField<String>(
                    //   value: _selectedUrgency,
                    //   items: [
                    //     "ภายใน 3 วัน",
                    //     "ภายใน 7 วัน",
                    //     "ภายใน 14 วัน",
                    //     "ไม่เร่งด่วน"
                    //   ].map((String urgency) {
                    //     return DropdownMenuItem(
                    //         value: urgency, child: Text(urgency));
                    //   }).toList(),
                    //   onChanged: (newValue) {
                    //     setState(() {
                    //       _selectedUrgency = newValue!;
                    //     });
                    //   },
                    //   decoration: InputDecoration(
                    //     border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(8)),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),

                    // ปุ่มส่งข้อมูล
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        onPressed: () {
                          _submitForm();
                        },
                        child: const Text("ส่งข้อมูล",
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

  void _submitForm() {
    String details = _detailController.text;
    String name = _nameController.text;
    // String email = _emailController.text;

    if (details.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ส่งข้อมูลสำเร็จ!")),
    );

    // กลับไปหน้าหลัก
    Navigator.pop(context);
  }
}
