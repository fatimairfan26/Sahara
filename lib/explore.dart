import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';

class exploreprofiles extends StatefulWidget {
  final token;

  const exploreprofiles({required this.token, Key? key}) : super(key: key);

  @override
  State<exploreprofiles> createState() => _exploreprofilesState();
}

class _exploreprofilesState extends State<exploreprofiles> {
  late String userId;
  final List<Widget> tabs = [
    const Tab(text: 'Liked profiles'),
    const Tab(text: 'Rejected profiles'),
  ];

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: tabs.length,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 106,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text("Explore profile 's",
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.left),
                  ),
                  const SizedBox(height: 15),
                  TabBar(
                    tabs: tabs,
                    isScrollable: true,
                    indicatorColor: Colors.black,
                    // Customize the indicator color
                    labelColor: Colors
                        .black, // Set the text color of the selected tab to black
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  LikedProfiles(userId: userId),
                  rejectedprofiles(userId: userId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LikedProfiles extends StatefulWidget {
  final String userId;

  LikedProfiles({required this.userId});

  @override
  _LikedProfilesState createState() => _LikedProfilesState();
}
class _LikedProfilesState extends State<LikedProfiles> {
  List<String> acceptedUserIds = [];
  String profilepicspath = '';
  Map<String, String> imageUrls = {};
  @override
  void initState() {
    super.initState();
    getAcceptedUsers();
  }
  Future<void> getAcceptedUsers() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.43.197:3000/acceptedUsers/${widget.userId}'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> users = jsonResponse['acceptedUsers'];
        final List<String> profileIds = users.map((user) => user['profileId'].toString()).toList();
        setState(() {
          acceptedUserIds = profileIds;
        });

        for (String profileId in acceptedUserIds) {
          await fetchUserName(profileId);
          await fetchUserProfileImage(profileId);
        }
      } else {
        throw Exception('Failed to load accepted users');
      }
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> fetchUserName(String userId) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.43.197:3000/user/$userId/username'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        String name = jsonResponse['username'];
        // Do something with the name, like storing it in a map
        setState(() {
          // Store the username in a map with the profileId as the key
          usernameMap[userId] = name;
        });
      } else {
        print('Error fetching username for user ID $userId');
      }
    } catch (error) {
      print('Error fetching username for user ID $userId: $error');
    }
  }

  Map<String, String> usernameMap = {};
  Future<void> fetchUserProfileImage(String acceptedUserIds) async {
    try {
      final apiUrl = 'http://192.168.43.197:3000/profile/images/$acceptedUserIds';
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
          // Store the image URL in a map with the profileId as the key
          imageUrls[acceptedUserIds] = url;
        });
      } else {
        print('Error fetching user images: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user images: $error');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 15, left: 9, right: 8),
        child: ListView(
          children: [
            const Text(
              "Liked Profiles",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            imageUrls.isNotEmpty
                ? GridView.builder(
              shrinkWrap: true,
              // Important for using a GridView inside a ListView
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 25,
                crossAxisSpacing: 8.0,
              ),
              itemCount: acceptedUserIds.length,
              itemBuilder: (context, index) {
                String profileId = acceptedUserIds[index];
                String imageUrl = imageUrls[profileId] ?? ''; // Get the image URL for the current profileId
                String username = usernameMap[profileId] ?? ''; // Get the username for the current profileId

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 17),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Positioned(
                        top: 90,
                        left: 33,
                        child: Text(
                          username,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
                : const Center(
              child: Column(
                children: [
                  SizedBox(height: 250),
                  Text("People you've liked will appear here",
                      style: TextStyle(fontSize: 17)),
                  SizedBox(height: 25),
                  Text("No liked profiles"),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}


class rejectedprofiles extends StatefulWidget {
  final String userId;

  rejectedprofiles({required this.userId});
  @override
  _rejectedprofilesState createState() => _rejectedprofilesState();
}

class _rejectedprofilesState extends State<rejectedprofiles> {
  List<String> rejectedUsersIds = [];
  String profilepicspath1 = '';
  Map<String, String> imageUrls1 = {};
  @override
  void initState() {
    super.initState();
    getrejectedUsers();
  }
  Future<void> getrejectedUsers() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.43.197:3000/rejectedUsers/${widget.userId}'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic>? users = jsonResponse['rejectedUsers']; // Add "?" for null safety
        if (users != null) {
          final List<String> profileIds = users.map((user) => user['profileId'].toString()).toList();
          setState(() {
            rejectedUsersIds = profileIds;
          });

          for (String profileId in rejectedUsersIds) {
            await fetchUserName(profileId);
            await fetchUserProfileImage(profileId);
          }
        }
      } else {
        throw Exception('Failed to load rejected users');
      }
    } catch (error) {
      print(error.toString());
    }
  }
  Future<void> fetchUserName(String userId) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.43.197:3000/user/$userId/username'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        String name = jsonResponse['username'];
        // Do something with the name, like storing it in a map
        setState(() {
          // Store the username in a map with the profileId as the key
          usernameMap[userId] = name;
        });
      } else {
        print('Error fetching username for user ID $userId');
      }
    } catch (error) {
      print('Error fetching username for user ID $userId: $error');
    }
  }

  Map<String, String> usernameMap = {};
  Future<void> fetchUserProfileImage(String rejectedUsersIds) async {
    try {
      final apiUrl = 'http://192.168.43.197:3000/profile/images/$rejectedUsersIds';

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
          // Store the image URL in a map with the profileId as the key
          imageUrls1[rejectedUsersIds] = url;
        });
      } else {
        print('Error fetching user images: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user images: $error');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.only(top: 15, left: 9, right: 8),
          child: ListView(
            children: [
              const Text(
                "Rejected Profiles",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              imageUrls1.isNotEmpty
                  ? GridView.builder(
                shrinkWrap: true,
                // Important for using a GridView inside a ListView
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 8.0,
                ),
                itemCount: rejectedUsersIds.length,
                itemBuilder: (context, index) {
                  String profileId = rejectedUsersIds[index];
                  String imageUrl = imageUrls1[profileId] ?? ''; // Get the image URL for the current profileId
                  String username = usernameMap[profileId] ?? ''; // Get the username for the current profileId

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 17),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Positioned(
                          top: 90,
                          left: 33,
                          child: Text(
                            username,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
                  : const Center(
                child: Column(
                  children: [
                    SizedBox(height: 250),
                    Text("People you've liked will appear here",
                        style: TextStyle(fontSize: 17)),
                    SizedBox(height: 25),
                    Text("No liked profiles"),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}


// class blockedusers extends StatefulWidget {
//   final String userId;
//
//   blockedusers({required this.userId});
//   @override
//   _blockedusersState createState() => _blockedusersState();
// }
//
// class _blockedusersState extends State<blockedusers> {
//   List<String> blockedUsersIds = [];
//   String profilepicspath1 = '';
//   Map<String, String> imageUrls1 = {};
//   @override
//   void initState() {
//     super.initState();
//     getBlockedUsers();
//   }
//   Future<void> getBlockedUsers() async {
//     try {
//       final response = await http.get(Uri.parse('http://192.168.43.197:3000/blocked/${widget.userId}'));
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         final List<dynamic>? users = jsonResponse['blockedUsers']; // Add "?" for null safety
//         if (users != null) {
//           final List<String> profileIds = users.map((user) => user['profileId'].toString()).toList();
//           setState(() {
//             blockedUsersIds = profileIds;
//           });
//
//           for (String profileId in blockedUsersIds) {
//             await fetchUserName(profileId);
//             await fetchUserProfileImage(profileId);
//           }
//         }
//       } else {
//         throw Exception('Failed to load blocked users');
//       }
//     } catch (error) {
//       print(error.toString());
//     }
//   }
//   Future<void> fetchUserName(String userId) async {
//     try {
//       final response = await http.get(Uri.parse('http://192.168.43.197:3000/user/$userId/username'));
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         String name = jsonResponse['username'];
//         // Do something with the name, like storing it in a map
//         setState(() {
//           // Store the username in a map with the profileId as the key
//           usernameMap[userId] = name;
//         });
//       } else {
//         print('Error fetching username for user ID $userId');
//       }
//     } catch (error) {
//       print('Error fetching username for user ID $userId: $error');
//     }
//   }
//
//   Map<String, String> usernameMap = {};
//   Future<void> fetchUserProfileImage(String blockedUsersIds) async {
//     try {
//       final apiUrl = 'http://192.168.43.197:3000/profile/images/$blockedUsersIds';
//
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
//           // Store the image URL in a map with the profileId as the key
//           imageUrls1[blockedUsersIds] = url;
//         });
//       } else {
//         print('Error fetching user images: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error fetching user images: $error');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//           padding: const EdgeInsets.only(top: 15, left: 9, right: 8),
//           child: ListView(
//             children: [
//               const Text(
//                 "Blocked Profiles",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 15),
//               imageUrls1.isNotEmpty
//                   ? GridView.builder(
//                 shrinkWrap: true,
//                 // Important for using a GridView inside a ListView
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   childAspectRatio: 1.0,
//                   mainAxisSpacing: 25,
//                   crossAxisSpacing: 8.0,
//                 ),
//                 itemCount: blockedUsersIds.length,
//                 itemBuilder: (context, index) {
//                   String profileId = blockedUsersIds[index];
//                   String imageUrl = imageUrls1[profileId] ?? ''; // Get the image URL for the current profileId
//                   String username = usernameMap[profileId] ?? ''; // Get the username for the current profileId
//
//                   return Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(40),
//                     ),
//                     child: Stack(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(left: 17),
//                           child: CircleAvatar(
//                             radius: 40,
//                             backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Positioned(
//                           top: 90,
//                           left: 33,
//                           child: Text(
//                             username,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               )
//                   : const Center(
//                 child: Column(
//                   children: [
//                     SizedBox(height: 250),
//                     Text("People you've liked will appear here",
//                         style: TextStyle(fontSize: 17)),
//                     SizedBox(height: 25),
//                     Text("No liked profiles"),
//                   ],
//                 ),
//               ),
//             ],
//           )
//       ),
//     );
//   }
// }
