import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fyp/messages_inside.dart';
import 'package:fyp/searchbar.dart';
import 'config.dart';
import 'message_reqinside.dart';
import 'navbar.dart';

class MessageDashboard extends StatefulWidget {
  const MessageDashboard.withToken({Key? key, required this.token, required this.onMessagesViewed}) : super(key: key);
  final String? token;
  final Function onMessagesViewed;

  @override
  State<MessageDashboard> createState() => _MessageDashboardState();
}

class _MessageDashboardState extends State<MessageDashboard> with SingleTickerProviderStateMixin {
  late String userId;
  List<Map<String, dynamic>> interactedUsers = [];
  List<Map<String, dynamic>> requestMessages = [];

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    getUserIdFromToken();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void getUserIdFromToken() {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token ?? '');
    setState(() {
      userId = decodedToken['_id'];
    });
    getInteractedUsers();
    getRequestMessages();
  }

  void getInteractedUsers() async {
    final String baseUrl = messages;
    try {
      final response = await http.get(Uri.parse('$baseUrl/interacted/$userId'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          interactedUsers = List<Map<String, dynamic>>.from(jsonResponse['users']);
          // Sort the list based on the timestamp of the last message
          interactedUsers.sort((a, b) {
            final timestampA = a['lastMessage']['timestamp'];
            final timestampB = b['lastMessage']['timestamp'];
            return timestampB.compareTo(timestampA);
          });
        });
      } else {
        print('Failed to load interacted users. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void getRequestMessages() async {
    final String baseUrl = messages;
    try {
      final response = await http.get(Uri.parse('$baseUrl/requests/$userId'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          requestMessages = List<Map<String, dynamic>>.from(jsonResponse['messageRequests']);
        });
      } else {
        print('Failed to load request messages. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void navigateToMessages(Map<String, dynamic> user) async {
    final String baseUrl = messages;

    final messageId = user['lastMessage'] != null
        ? user['lastMessage']['_id']
        : null;

    if (messageId != null) {
      // Call the server endpoint to mark the message as read
      await http.post(Uri.parse('$baseUrl/markAsRead/$messageId'));

      // Update the local state to mark the message as read
      setState(() {
        user['lastMessage']['isUnread'] = false;
      });

      widget.onMessagesViewed(); // Reset unread message count
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Messages(userId: userId, selectedUser: user),
      ),
    );
  }

  Widget buildUserCard(Map<String, dynamic> user) {
    String lastMessage = user['lastMessage'] != null ? user['lastMessage']['message'] ?? 'No messages' : 'No messages';
    bool isUnread = user['lastMessage'] != null ? user['lastMessage']['isUnread'] ?? false : false;

    TextStyle titleTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
      color: isUnread ? Colors.blue : Colors.black,
    );

    TextStyle subtitleTextStyle = TextStyle(
      color: isUnread ? Colors.blue : Colors.grey,
    );

    return ListTile(
      title: Text('${user['username']}', style: titleTextStyle),
      subtitle: Text('Last message: $lastMessage', style: subtitleTextStyle),
      onTap: () {
        navigateToMessages(user);
      },
    );
  }


  Widget buildRequestCard(Map<String, dynamic> request) {
    String message = request['message'];
    String fromUser = request['from']['username'];

    return ListTile(
      title: Text('$fromUser'),
      subtitle: Text(message),
      onTap: () {
        // Navigate to Messages screen for the selected request user
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagesReq(userId: userId, selectedUser: request['from']),
          ),
        );
      },
    );
  }

  void acceptRequest(Map<String, dynamic> request) async {
    final String baseUrl = messages;
    try {
      final response = await http.post(Uri.parse('$baseUrl/accmsg/${request['from']['_id']}/$userId'));

      if (response.statusCode == 200) {
        getInteractedUsers();
        getRequestMessages();
      } else {
        print('Failed to accept request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void rejectRequest(Map<String, dynamic> request) async {
    final String baseUrl = messages;
    try {
      final response = await http.post(Uri.parse('$baseUrl/rejmsg/${request['from']['_id']}/$userId'));

      if (response.statusCode == 200) {
        getRequestMessages();
      } else {
        print('Failed to reject request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(top: 35, left: 8.0, right: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NavBar(token: widget.token),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1c4837),
                        ),
                      ),
                      const Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  // Container(
                  //   height: 40,
                  //   width: 50,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => Search(token: token,),
                  //         ),
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.white,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(15),
                  //         side: BorderSide(color: Colors.black),
                  //       ),
                  //     ),
                  //     child: Icon(
                  //       Icons.search,
                  //       color: Color(0xFFFC6579),
                  //       size: 25,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Container(
                color: Colors.white,
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: const Color(0xFF1c4837),
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'Messages'),
                        Tab(text: 'Requests'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // First tab content: Messages
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: interactedUsers.length,
                                itemBuilder: (context, index) {
                                  final user = interactedUsers[index];
                                  return buildUserCard(user);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Second tab content: Requests
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: requestMessages.length,
                                itemBuilder: (context, index) {
                                  final request = requestMessages[index];
                                  return buildRequestCard(request);
                                },
                              ),
                            ),
                          ],
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
    );
  }
}