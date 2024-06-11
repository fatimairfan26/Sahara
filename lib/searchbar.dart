import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp/viewprofile.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'config.dart';

class Search extends StatefulWidget {
  final String token;

  const Search({required this.token, Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _foundUsers = [];

  @override
  void initState() {
    super.initState();
    print('Search initialized with token: ${widget.token}');
  }

  Future<void> _runFilter(String enteredKeyword) async {
    final baseurl = 'http://192.168.43.197:3000/search';
    final response = await http.get(
      Uri.parse('$baseurl/$enteredKeyword'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        _foundUsers = responseData.map((user) {
          final id = user['_id'];
          final username = user['username'];
          print('Found User ID: $id, Username: $username');
          return {
            'id': id,
            'username': username,
          };
        }).toList();
      });
    } else {
      print('Error fetching search results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 50, left: 8.0, right: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.83,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _runFilter(value),
                      decoration: InputDecoration(
                        hintText: 'Enter username ',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                ],
              )),
          Expanded(
            child: _foundUsers.isEmpty
                ? Center(
              child: Text('No results found'),
            )
                : ListView.builder(
              itemCount: _foundUsers.length,
              itemBuilder: (context, index) {
                final user = _foundUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user['username'][0]),
                  ),
                  title: Text(user['username']),
                  onTap: () {
                    final id = user['id'];
                    final username = user['username'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewProfile(
                          userid: id,
                          username: username,
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// class viewprofile extends StatefulWidget {
//   final String token;
//   final String userid;
//   final String username;
//
//   const viewprofile({required this.userid, required this.username, required this.token});
//
//   @override
//   State<viewprofile> createState() => _viewprofileState();
// }
//
// class _viewprofileState extends State<viewprofile> {
//   String selectedValue = 'Liked';
//   String userbio = '';
//   String name = '';
//   late String userId;
//   bool isPopupVisible = false;
//   final TextEditingController textController = TextEditingController(text: 'Dummy link test');
//
//   @override
//   void initState() {
//     super.initState();
//     print("ViewProfile initialized with token: ${widget.token}, UserID: ${widget.userid}, Username: ${widget.username}");
//     try {
//       Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
//       userId = jwtDecodedToken['_id'];
//       print("Decoded user ID from token in ViewProfile: $userId");
//     } catch (e) {
//       print("Error decoding token in ViewProfile: $e");
//     }
//     _loadUserInfo();
//     fetchUserImages(widget.userid);
//     fetchUserprofileimage(widget.userid);
//   }
//
//   void navigateToMessages() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Messages(
//           userId: userId,
//           selectedUser: {'_id': widget.userid, 'username': widget.username}, // Pass the user details correctly
//         ),
//       ),
//     );
//   }
//
//   Future<void> _loadUserInfo() async {
//     final userInfo = await getUserInfo(widget.userid);
//     if (userInfo != null) {
//       final String bio = userInfo['bio'];
//       setState(() {
//         userbio = bio;
//         name = widget.username;
//       });
//     }
//   }
//
//   Future<Map<String, dynamic>?> getUserInfo(String id) async {
//     final baseurl = 'http://192.168.43.197:3000/get'; // Replace 'your_api_url_here' with your actual API URL
//     try {
//       final response = await http.get(
//         Uri.parse('$baseurl/$id'),
//       );
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//         print(responseData);
//         return responseData;
//       } else {
//         print('Error fetching user information: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       print('Exception while fetching user information: $e');
//       return null;
//     }
//   }
//
//   Future<void> fetchUserImages(String userId) async {
//     try {
//       final apiUrl = 'http://192.168.43.197:3000/post/images/$userId';
//       print('Request URL: $apiUrl');
//
//       final response = await http.get(Uri.parse(apiUrl));
//
//       print('Response Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//
//         List<String> fetchedImagePaths = responseData['userImages'].map<String>((data) {
//           return data['imagePath'].toString() ?? '';
//         }).toList();
//
//         setState(() {
//           List<String> urlsToAdd = fetchedImagePaths.map((imagePath) {
//             String encodedImagePath = Uri.encodeFull(imagePath.split('\\pictures\\').last);
//             return 'http://192.168.43.197:3000/images/$encodedImagePath';
//           }).toList();
//           postImagePaths.addAll(urlsToAdd);
//         });
//       } else {
//         print('Error fetching user images: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error fetching user images: $error');
//     }
//   }
//
//   Future<void> fetchUserprofileimage(String userId) async {
//     try {
//       final apiUrl = 'http://192.168.43.197:3000/profile/images/$userId';
//       print('Request URL: $apiUrl');
//
//       final response = await http.get(Uri.parse(apiUrl));
//
//       print('Response Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//
//         String imagePath = responseData['userImages'][0]['imagePath'].toString() ?? '';
//         String encodedImagePath = Uri.encodeFull(imagePath.split('\\pictures\\').last);
//         String url = 'http://192.168.43.197:3000/images/$encodedImagePath';
//
//         setState(() {
//           profilepicspath = url;
//         });
//       } else {
//         print('Error fetching user images: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error fetching user images: $error');
//     }
//   }
//
//   String profilepicspath = '';
//   List<String> postImagePaths = [];
//
//   void showPopup() {
//     setState(() {
//       isPopupVisible = true;
//     });
//   }
//
//   void hidePopup() {
//     setState(() {
//       isPopupVisible = false;
//     });
//   }
//
//   String truncateBio(String bio, int wordLimit) {
//     List<String> words = bio.split(' ');
//     if (words.length > wordLimit) {
//       words = words.sublist(0, wordLimit);
//       return words.join(' ') + '...';
//     }
//     return bio;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             color: Colors.white,
//             height: double.infinity,
//             width: double.infinity,
//             child: Padding(
//               padding: EdgeInsets.only(left: 12, right: 12, top: 28),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           flex: 1,
//                           child: IconButton(
//                             icon: const Icon(Icons.arrow_back),
//                             color: const Color(0xFF273236),
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ),
//                         SizedBox(width: 15),
//                         Expanded(
//                           flex: 5,
//                           child: Text(
//                             name,
//                             style: TextStyle(
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 1,
//                           child: Align(
//                             alignment: Alignment.center,
//                             child: PopupMenuButton<String>(
//                                 icon: const Icon(Icons.more_vert, color: Color(0xFF273236)),
//                                 onSelected: (String choice) {
//                                   if (choice == 'Report user') {
//                                     showDialog(
//                                       context: context,
//                                       builder: (BuildContext context) {
//                                         return ReportUserPopup();
//                                       },
//                                     );
//                                   }
//                                 },
//                                 itemBuilder: (BuildContext context) {
//                                   return <PopupMenuEntry<String>>[
//                                     const PopupMenuItem<String>(
//                                       value: 'Report user',
//                                       child: Text('Report user'),
//                                     ),
//                                   ];
//                                 },
//                                 offset: Offset(0, 45)
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         SizedBox(width: 8),
//                         CircleAvatar(
//                           radius: 50, // Increase the radius for a bigger CircleAvatar
//                           backgroundColor: Color(0xFFd66d67),
//                           backgroundImage: profilepicspath.isNotEmpty
//                               ? NetworkImage(profilepicspath)
//                               : null,
//                           child: profilepicspath.isEmpty
//                               ? Icon(
//                             Icons.person,
//                             size: 60,
//                             color: Colors.white,
//                           )
//                               : null,
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(left: 14.0),
//                               child: Text(
//                                 name,
//                                 style: TextStyle(fontSize: 21),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 16.0),
//                               child: Text(
//                                 "25 yrs",
//                                 style: TextStyle(color: Colors.grey, fontSize: 15),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 16.0),
//                               child: Text(
//                                 "Physical",
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 7.0),
//                               child: Text(
//                                 truncateBio(userbio, 5),
//                                 style: TextStyle(fontSize: 15),
//                               ),
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(left: 12, right: 12, top: 12),
//                       child: SizedBox(
//                         height: 36,
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             int compatibilityScore = calculateCompatibilityScore();
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) => _buildPopupDialog(context, compatibilityScore),
//                             );
//                           },
//                           style: ElevatedButton.styleFrom(
//                             elevation: 3,
//                             shadowColor: Colors.grey,
//                             primary: const Color(0xFFd66d67),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text('Compatibility Score', style: TextStyle(
//                               color: Colors.white, fontSize: 18)),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 16),
//                       child: Container(
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 1,
//                               child: SizedBox(
//                                 height: 36,
//                                 width: MediaQuery.of(context).size.width / 2,
//                                 child: ElevatedButton(
//                                   onPressed: showPopup,
//                                   style: ElevatedButton.styleFrom(
//                                     elevation: 3,
//                                     shadowColor: Colors.grey,
//                                     primary: const Color(0xFFd66d67),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(bottom: 3),
//                                     child: const Text(
//                                       'Share profile',
//                                       style: TextStyle(
//                                           color: Colors.white, fontSize: 18),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 6),
//                             Expanded(
//                               flex: 1,
//                               child: SizedBox(
//                                 height: 36,
//                                 width: MediaQuery.of(context).size.width / 2,
//                                 child: ElevatedButton(
//                                   onPressed: navigateToMessages,
//                                   style: ElevatedButton.styleFrom(
//                                     elevation: 3,
//                                     shadowColor: Colors.grey,
//                                     primary: const Color(0xFFd66d67),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(bottom: 3),
//                                     child: const Text(
//                                       'Message',
//                                       style: TextStyle(
//                                           color: Colors.white, fontSize: 18),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(left: 12, right: 12),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Text("Posts", style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),),
//                         ],
//                       ),
//                     ),
//                     Divider(thickness: 1,),
//                     Container(
//                       margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                       height: 470,
//                       child: postImagePaths.isEmpty
//                           ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.camera_alt,
//                               size: 60,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(height: 20),
//                             Text(
//                               'No posts yet',
//                               style: TextStyle(fontSize: 20),
//                             ),
//                           ],
//                         ),
//                       )
//                           : GridView.builder(
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 1,
//                           crossAxisSpacing: 5.0,
//                           mainAxisSpacing: 5.0,
//                         ),
//                         itemCount: postImagePaths.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           return Container(
//                             decoration: BoxDecoration(
//                               color: Colors.grey,
//                               border: Border.all(
//                                 color: Colors.grey,
//                                 width: 2.0,
//                               ),
//                             ),
//                             child: Image.network(
//                               postImagePaths[index],
//                               fit: BoxFit.cover,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (isPopupVisible)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Popup content
//                     Container(
//                       width: MediaQuery.of(context).size.width,
//                       height: 280,
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(25),
//                           topRight: Radius.circular(25),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: SingleChildScrollView(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Share with your friends ',
//                                 style: Theme.of(context).textTheme.headline1,
//                               ),
//                               Text(
//                                 'Invite your friends and family and earn Reward',
//                                 style: Theme.of(context).textTheme.headline2,
//                               ),
//                               const SizedBox(height: 60),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[200],
//                                   borderRadius: BorderRadius.circular(20.0),
//                                 ),
//                                 child: TextField(
//                                   controller: textController,
//                                   decoration: const InputDecoration(
//                                     contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
//                                     border: InputBorder.none,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 40),
//                               Align(
//                                 alignment: Alignment.bottomCenter,
//                                 child: Row(
//                                   children: [
//                                     Align(
//                                       alignment: Alignment.bottomLeft,
//                                       child: Row(
//                                         children: [
//                                           Column(
//                                             children: [
//                                               IconButton(
//                                                 onPressed: () {
//                                                   Clipboard.setData(ClipboardData(text: textController.text));
//                                                   ScaffoldMessenger.of(context).showSnackBar(
//                                                     const SnackBar(
//                                                       content: Text('Link copied to clipboard'),
//                                                     ),
//                                                   );
//                                                 },
//                                                 icon: Image.asset('assets/link.png'),
//                                               ),
//                                               Text(
//                                                 'Copy Link',
//                                                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const Spacer(),
//                                     Align(
//                                       alignment: Alignment.bottomRight,
//                                       child: ElevatedButton(
//                                         onPressed: hidePopup,
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: const Color(0xFFd66d67),
//                                         ),
//                                         child: Text(
//                                           'Cancel',
//                                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPopupDialog(BuildContext context, int compatibilityScore) {
//     return AlertDialog(
//       title: const Text('Compatibility Score', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           SizedBox(
//             height: 200,
//             child: PieChart(
//               PieChartData(
//                 sections: [
//                   PieChartSectionData(
//                     color: Color(0xFFd66d67),
//                     value: compatibilityScore.toDouble(),
//                     title: compatibilityScore.toString(),
//                     showTitle: false, // Hide the title text
//                   ),
//                   PieChartSectionData(
//                     color: Colors.grey[300],
//                     value: (100 - compatibilityScore).toDouble(),
//                     showTitle: false, // Hide the title text
//                   ),
//                 ],
//                 centerSpaceRadius: 60,
//                 sectionsSpace: 0,
//               ),
//             ),
//           ),
//           SizedBox(height: 20,),
//           Text('Your compatibility score is $compatibilityScore'),
//         ],
//       ),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           style: TextButton.styleFrom(
//             primary: Theme.of(context).primaryColor,
//           ),
//           child: const Text('Close'),
//         ),
//       ],
//     );
//   }
//
//   int calculateCompatibilityScore() {
//     int userScore = 75;
//     int partnerScore = 80;
//     int compatibilityScore = (userScore + partnerScore) ~/ 2;
//     return compatibilityScore;
//   }
// }
