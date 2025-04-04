import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ReportForm {
  DateTime dateTime;
  String description;
  int problemTypeId;
  String location;
  int urgencyId;
  int statusId;
  String fName;
  String lName;
  String email;
  List<Uint8List> reportImages;

  ReportForm({
    required this.dateTime,
    required this.description,
    required this.problemTypeId,
    required this.location,
    required this.urgencyId,
    required this.statusId,
    required this.fName,
    required this.lName,
    required this.email,
    required this.reportImages,
  });

  Map<String, String> toJson() => {
        "date_time": dateTime.toIso8601String(),
        "description": description,
        "problem_type_id": problemTypeId.toString(),
        "location": location,
        "urgency_id": urgencyId.toString(),
        "status_id": statusId.toString(),
        "f_name": fName,
        "l_name": lName,
        "email": email,
      };

  Future<String> uploadReport() async {
    var uri = Uri.parse('http://26.21.85.254:8080/Reportig/api/report.php');
    var request = http.MultipartRequest('POST', uri);

    request.fields.addAll(toJson());

    for (int i = 0; i < reportImages.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(
        'image[]',
        reportImages[i],
        filename: 'image_$i.jpg',
      ));
    }

    // print("url: ${request.url}");
    // print("method: ${request.method}");
    // print("headers: ${request.headers}");
    // print("fields: ${request.fields}");
    // print("files: ${request.files}");

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    print(responseData);
    return responseData;
  }
}
