import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/settings.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'edit_profile.dart';
import 'upload_image.dart';

class userprofile extends StatefulWidget {
  final String token;
  const userprofile({required this.token, Key? key}) : super(key: key);

  @override
  State<userprofile> createState() => _userprofileState();
}

class _userprofileState extends State<userprofile> {

  Future<void> fetchUserImages(String userId) async {
    try {
      final apiUrl = 'http://192.168.43.197:3000/post/images/$userId';
      print('Request URL: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        List<String> fetchedImagePaths = responseData['userImages'].map<String>((data) {
          return data['imagePath'].toString() ?? '';
        }).toList();

        setState(() {
          List<String> urlsToAdd = fetchedImagePaths.map((imagePath) {
            String encodedImagePath = Uri.encodeFull(imagePath.split('\\pictures\\').last);
            return 'http://192.168.43.197:3000/images/$encodedImagePath';
          }).toList();
          postImagePaths.addAll(urlsToAdd);
        });
      } else {
        print('Error fetching user images: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user images: $error');
    }
  }

  Future<void> fetchUserprofileimage(String userId) async {
    try {
      final apiUrl = 'http://192.168.43.197:3000/profile/images/$userId';
      print('Request URL: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        String imagePath = responseData['userImages'][0]['imagePath'].toString() ?? '';
        String encodedImagePath = Uri.encodeFull(imagePath.split('\\pictures\\').last);
        String url = 'http://192.168.43.197:3000/images/$encodedImagePath';

        setState(() {
          profilepicspath = url;
        });
      } else {
        print('Error fetching user images: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user images: $error');
    }
  }

  String profilepicspath = '';


  List<String> postImagePaths = [

  ];
  final TextEditingController textController = TextEditingController(text: 'Dummy link test');
  bool isPopupVisible = false;
  void showPopup() {
    setState(() {
      isPopupVisible = true;
    });
  }

  void hidePopup() {
    setState(() {
      isPopupVisible = false;
    });
  }

  String username = '';
  late String userId;
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    loadUsername();
    fetchUserImages(userId);
    fetchUserprofileimage(userId);
    _loadUserInfo();
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? ''; // Use default value if username is null
    });
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await getUserInfo(userId);
    if (userInfo != null) {
      final String bio = userInfo['bio'];
      setState(() {
        userbio = bio;
      });
    }
  }
  String userbio = '';
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    final baseurl = 'http://192.168.43.197:3000/get'; // Replace 'your_api_url_here' with your actual API URL
    try {
      final response = await http.get(
        Uri.parse('$baseurl/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(responseData);
        return responseData;
      } else {
        print('Error fetching user information: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception while fetching user information: $e');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            height: double.infinity,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(left: 12, right: 8, top: 30, bottom: 5),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 25),
                        Expanded(
                          flex: 5,
                          child: Text(
                            username,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.settings, size: 20,),
                            color: const Color(0xFF273236),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Settings(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            flex: 1,
                            child: CircleAvatar(
                              radius: 70, // Increase the radius for a bigger CircleAvatar
                              backgroundColor: Color(0xFFd66d67),
                              backgroundImage: profilepicspath.isNotEmpty
                                  ? NetworkImage(profilepicspath)
                                  : null,
                              child: profilepicspath.isEmpty
                                  ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                                  : null,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "🌍 Passionate explorer of the world, with an insatiable curiosity for culture and adventure.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 16),
                      child: Container(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 36,
                                width: MediaQuery.of(context).size.width / 2,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfilePage(token: widget.token,),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 3,
                                    shadowColor: Colors.grey,
                                    primary: const Color(0xFFd66d67),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text("Edit profile", style: TextStyle(color: Colors.white, fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 36,
                                width: MediaQuery.of(context).size.width / 2,
                                child: ElevatedButton(
                                  onPressed: showPopup,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 3,
                                    shadowColor: Colors.grey,
                                    primary: const Color(0xFFd66d67),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: const Text(
                                      'Share profile',
                                      style: TextStyle(color: Colors.white, fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 12, right: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Posts", style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      height: 470,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                        ),
                        itemCount: postImagePaths.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              border: Border.all(
                                color: Colors.grey,
                                width: 2.0,
                              ),
                            ),
                            child: Image.network(
                              postImagePaths[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isPopupVisible)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Popup content
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 280,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Share with your friends ',
                                style: Theme.of(context).textTheme.headline1,
                              ),
                              Text(
                                'Invite your friends and family and earn Reward',
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              const SizedBox(height: 60),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: TextField(
                                  controller: textController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  Clipboard.setData(ClipboardData(text: textController.text));
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Link copied to clipboard'),
                                                    ),
                                                  );
                                                },
                                                icon: Image.asset('assets/link.png'),
                                              ),
                                              Text(
                                                'Copy Link',
                                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color:  Colors.black),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: ElevatedButton(
                                        onPressed: hidePopup,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFd66d67),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isPopupVisible ? null : Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UploadImage(token: widget.token),
              ),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: const Color(0xFFd66d67),
        ),
      ),
    );
  }
}
