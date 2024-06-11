import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class AdminUploadImage extends StatefulWidget {
  @override
  _AdminUploadImageState createState() => _AdminUploadImageState();
}

class _AdminUploadImageState extends State<AdminUploadImage> {
  XFile? selectedImage;
  String? imageName;
  String? fullPath;

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = image;
          imageName = image.name;

          final directoryPath = 'C:\\Users\\Maheen Irfan\\Desktop\\nodejs\\pictures';
          fullPath = '$directoryPath\\$imageName';

          print("Image Name: $imageName");
          print("Full Path: $fullPath");
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _saveFullPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullPath', fullPath ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(
                "Upload Image",
                style: TextStyle(
                  color: Color(0xFF1c4837),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                width: 300,
                child: selectedImage != null
                    ? kIsWeb
                    ? Image.network(selectedImage!.path)
                    : Image.file(File(selectedImage!.path))
                    : Image.asset('assets/uploadimage.jpg'),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Image'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF1c4837),
                  minimumSize: Size(150, 50),
                ),
                onPressed: _pickImage,
              ),
              SizedBox(height: 20),
              if (selectedImage != null)
                ElevatedButton(
                  onPressed: () async {
                    await _saveFullPath();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF1c4837),
                    minimumSize: Size(150, 50),
                  ),
                  child: Text('OK'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
