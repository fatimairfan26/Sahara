import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'dart:io';
import 'config.dart';

class EditProfilePage extends StatefulWidget {
  final String token;
  const EditProfilePage({required this.token, Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late String selectedGender = 'Female';
  late String userId;
  late String imageUrl = ''; // Variable to hold the image URL
  bool isLoading = true;
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    fetchImage();
  }

  void fetchImage() async {
    final String baseUrl = latestprofileimage;
    try {
      final response = await http.get(Uri.parse('$baseUrl/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['image']['check'] == 'profile' && !data['image']['isApproved']) {
          String imagePath2 = data['image']['imagePath'].toString() ?? '';
          String encodedImagePath = Uri.encodeFull(imagePath2.split('\\savedimg\\').last);
          String url = 'http://localhost:3000/images/$encodedImagePath';
          print(url);

          setState(() {
            imageUrl = url;
            isLoading = false;
          });
        } else {
          print('No valid images found');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Failed to load profile image');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateUserDetails() async {
    final String baseUrl = update;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'bio': _bioController.text,
        }),
      );
      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: ${data['error']}')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1c4837)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF1c4837),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.menu_open_rounded, color: Color(0xFF1c4837)),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => Hamburger()),
          //     );
          //   },
          // ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : NetworkImage('https://th.bing.com/th/id/OIP.O8vv9O4Ku4HvFQyep-NXMAHaLG?w=131&h=197&c=7&r=0&o=5&pid=1.7'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => changeimage(token: widget.token)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1c4837),
              ),
              child: const Text('Change Profile Picture', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                fillColor: Color(0xFF1c4837),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                fillColor: Color(0xFF1c4837),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: updateUserDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1c4837),
                minimumSize: Size(20, 50),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class changeimage extends StatefulWidget {
  final String token;
  const changeimage({required this.token, Key? key}) : super(key: key);

  @override
  _changeimageState createState() => _changeimageState();
}

class _changeimageState extends State<changeimage> {
  late String userId;
  File? _ProfileImage;
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
        _ProfileImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImage(String userId) async {
    if (_ProfileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an image')));
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse(uploads));
    request.fields['userId'] = userId;
    request.fields['imageType'] = 'profile';
    request.files.add(await http.MultipartFile.fromPath('image', _ProfileImage!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image uploaded successfully')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EditProfilePage(token: widget.token)),
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
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Color(0xFF1c4837),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Select Image to Change Your Profile Picture",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  _ProfileImage == null ? Text('') : Image.file(_ProfileImage!),
                  SizedBox(height: 20),
                  Container(
                    width: 250,
                    height: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFE5B4),
                      ),
                      onPressed: () => pickImage(ImageSource.gallery),
                      child: Text(''),
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
            ],
          ),
        ),
      ),
    );
  }
}