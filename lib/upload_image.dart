import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fyp/config.dart';
import 'dart:convert';
import 'package:fyp/navbar.dart';

import 'userprofile.dart';


class UploadImage extends StatefulWidget {
  final token;

  const UploadImage({@required this.token,Key? key}) : super(key: key);


  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<UploadImage> {
  XFile? selectedImage;
  TextEditingController captionController = TextEditingController();
  late String id;


  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    id = jwtDecodedToken['_id'];
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = XFile(image.path); // Convert to XFile
      });
    }
  }

  Future<void> _confirmImage() async {
    try {
      if (selectedImage != null) {
        final result = await _uploadImage(selectedImage!.path);
        if (result['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NavBar(token: widget.token),
            ),
          );
        } else {
          print("Image is required.");
        }
      }
    } catch (e) {
      print('Error confirming image: $e');
    }
  }

  Future<Map<String, dynamic>> _uploadImage(String imagePath) async {
    try {
      var regbody = {
        "userId": id,
        "check":'post'
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(uploads), // Replace with your actual server URL
      );

      request.fields.addAll(regbody);

      var file = await http.MultipartFile.fromPath('image', imagePath);
      request.files.add(file);

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NavBar(token: widget.token),
              ),
            );
          },
        ),
        title: Text("Upload Image", style: TextStyle(color: Color(0xFF1c4837), fontSize: 28, fontWeight: FontWeight.bold)), // Add the title
      ),

      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10,),
              Container(
                height: 500, // Set the desired height
                width: 500, // Set the desired width
                child: selectedImage != null
                    ? Image.file(
                 File(selectedImage!.path),
                  height: 200,
                )
                    : Image.asset(
                  'assets/uploadimage.jpg',
                  height: 500,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Upload your image',
                style: TextStyle(
                  color: const Color(0xFF1c4837),
                  fontWeight: FontWeight.bold,
                  fontSize: 23
                ),
              ),
              SizedBox(height: 10,),
              Text(
                'Browse and choose the files you want to upload',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1c4837),
                ),
              ),
              const SizedBox(height: 20),
              if (selectedImage == null)
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1c4837),
                    shape: const CircleBorder(),
                    minimumSize: Size(60, 60), // Increase the size here
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 36, // Adjust the icon size if needed
                  ),
                ),
              if (selectedImage != null)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _confirmImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1c4837),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        minimumSize: Size(200, 50), // Increase the size here
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}