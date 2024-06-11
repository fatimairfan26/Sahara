import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:io';
import 'config.dart';
import 'loginPage.dart';
import 'navbar.dart';

class UploadPage extends StatefulWidget {
  final String token;
  const UploadPage({required this.token, Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  late String userId;
  File? _disabilityCardImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
  }

  Future pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _disabilityCardImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImage(String userId) async {
    if (_disabilityCardImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an image')));
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse(uploads));
    request.fields['userId'] = userId;
    request.fields['check'] = 'security';
    request.files.add(await http.MultipartFile.fromPath('image', _disabilityCardImage!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image uploaded successfully')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => loginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Please Upload your Details to Continue Further",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              _disabilityCardImage == null
                  ? Text('No Disability Card Image Selected')
                  : Image.file(_disabilityCardImage!),
              SizedBox(height: 20),
              Container(
                width: 250,
                height: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFE5B4), // background color
                  ),
                  onPressed: () => pickImage(ImageSource.gallery),
                  child: Text('Select Disability Card Image'),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200], // background color
                  ),
                  onPressed: userId != null ? () => uploadImage(userId) : null,
                  child: Text('Upload ', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}