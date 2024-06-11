import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/action.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'config.dart';
import 'messages_inside.dart';

class ViewProfile extends StatefulWidget {
  final String userid;
  final String username;
  final String token;

  const ViewProfile({required this.userid, required this.username, required this.token});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  String userbio = '';
  String name = '';
  late String tokenUserId; // To store the userId from the token
  late String profileUserId; // To store the userId from the widget
  bool isPopupVisible = false;
  final TextEditingController textController = TextEditingController(
      text: 'Dummy link test');
  late double compatibilityScore;
  late int matches;
  late int totalCriteria;


  @override
  void initState() {
    super.initState();
    print('ViewProfile initialized with token: ${widget.token}');
    print('ViewProfile initialized with userId: ${widget.userid}');
    print('ViewProfile initialized with username: ${widget.username}');
    tokenUserId = widget.token;
    profileUserId = widget.userid;
    print(profileUserId);
    _loadUserInfo();
    fetchUserImages(profileUserId);
    fetchUserprofileimage(profileUserId);
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await getUserInfo(profileUserId);
    if (userInfo != null) {
      final String bio = userInfo['bio'];
      setState(() {
        userbio = bio;
        name = widget.username;
      });
    }
  }

  Future<Map<String, dynamic>?> getUserInfo(String profileUserId) async {
    final baseurl = 'http://192.168.43.197:3000/get'; // Replace 'your_api_url_here' with your actual API URL
    try {
      final response = await http.get(
        Uri.parse('$baseurl/$profileUserId'),
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

  Future<void> fetchUserImages(String profileUserId) async {
    try {
      final apiUrl = 'http://192.168.43.197:3000/post/images/$profileUserId';
      print('Request URL: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        List<String> fetchedImagePaths = responseData['userImages'].map<
            String>((data) {
          return data['imagePath'].toString() ?? '';
        }).toList();

        setState(() {
          List<String> urlsToAdd = fetchedImagePaths.map((imagePath) {
            String encodedImagePath = Uri.encodeFull(imagePath
                .split('\\pictures\\')
                .last);
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

  Future<void> fetchCompatibilityScore(String tokenUserId,
      String profileUserId) async {
    try {
      final apiUrl = 'http://192.168.43.197:3000/compatibility/$tokenUserId/$profileUserId';
      print('Request URL: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        double compatibilityScoreDouble = responseData['compatibilityScore'];
        int compatibilityScore = compatibilityScoreDouble.round();

        // Display the dialog with the compatibility score
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              _buildPopupDialog(context, compatibilityScore),
        );
      } else {
        print('Error fetching compatibility score: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching compatibility score: $error');
    }
  }

  Future<void> fetchUserprofileimage(String profileUserId) async {
    try {
      final apiUrl = 'http://192.168.43.197:3000/profile/images/$profileUserId';
      print('Request URL: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        String imagePath = responseData['userImages'][0]['imagePath']
            .toString() ?? '';
        String encodedImagePath = Uri.encodeFull(imagePath
            .split('\\pictures\\')
            .last);
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
  List<String> postImagePaths = [];

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

  String truncateBio(String bio, int wordLimit) {
    List<String> words = bio.split(' ');
    if (words.length > wordLimit) {
      words = words.sublist(0, wordLimit);
      return words.join(' ') + '...';
    }
    return bio;
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
              padding: EdgeInsets.only(left: 12, right: 12, top: 28),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            color: const Color(0xFF273236),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          flex: 5,
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.center,
                            child: PopupMenuButton<String>(
                                icon: const Icon(
                                    Icons.more_vert, color: Color(0xFF273236)),
                                onSelected: (String choice) {
                                  if (choice == 'Report user') {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ReportUserPopup(
                                          tokenUserId: tokenUserId,
                                          profileUserId: profileUserId,
                                        );
                                      },
                                    );

                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'Report user',
                                      child: Text('Report user'),
                                    ),
                                  ];
                                },
                                offset: Offset(0, 45)
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 50,
                          // Increase the radius for a bigger CircleAvatar
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 14.0),
                              child: Text(
                                name,
                                style: TextStyle(fontSize: 21),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                "25 yrs",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 15),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                "Physical",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 7.0),
                              child: Text(
                                truncateBio(userbio, 5),
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 12, right: 12, top: 12),
                      child: SizedBox(
                        height: 36,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            String userId1 = tokenUserId;
                            String userId2 = profileUserId;
                            await fetchCompatibilityScore(userId1, userId2);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            shadowColor: Colors.grey,
                            primary: const Color(0xFFd66d67),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Compatibility Score',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12, right: 12, top: 5, bottom: 16),
                      child: Container(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 36,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 2,
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
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 36,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 2,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Messages(
                                              userId: widget.token,
                                              // Use tokenUserId
                                              selectedUser: {
                                                '_id': profileUserId,
                                                'username': widget.username
                                              },
                                            ),
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 3.0),
                                    child: const Text(
                                      'Message',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
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
                          ),),
                        ],
                      ),
                    ),
                    Divider(thickness: 1,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      height: 470,
                      child: postImagePaths.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No posts yet',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      )
                          : GridView.builder(
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
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
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
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headline1,
                              ),
                              Text(
                                'Invite your friends and family and earn Reward',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headline2,
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
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 20.0),
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
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: textController
                                                              .text));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Link copied to clipboard'),
                                                    ),
                                                  );
                                                },
                                                icon: Image.asset(
                                                    'assets/link.png'),
                                              ),
                                              Text(
                                                'Copy Link',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                    color: Colors.black),
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
                                          backgroundColor: const Color(
                                              0xFFd66d67),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: Colors.white),
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
    );
  }

  Widget _buildPopupDialog(BuildContext context, int compatibilityScore) {
    return AlertDialog(
      title: const Text(
        'Compatibility Score',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Color(0xFFd66d67).withOpacity(0.8),
                    value: compatibilityScore.toDouble(),
                    title: '${compatibilityScore}%',
                    titleStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    radius: 60,
                    borderSide: BorderSide(
                      color: Color(0xFFd66d67),
                      width: 2,
                    ),
                    showTitle: true,
                  ),
                  PieChartSectionData(
                    color: Colors.grey[300]!,
                    value: (100 - compatibilityScore).toDouble(),
                    showTitle: false,
                    radius: 60,
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 5,
                borderData: FlBorderData(
                  show: false,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Your compatibility score is $compatibilityScore%',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            primary: Theme
                .of(context)
                .primaryColor,
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

