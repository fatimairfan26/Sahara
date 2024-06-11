import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class Messages extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> selectedUser;

  const Messages({Key? key, required this.userId, required this.selectedUser}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}
class _ChatScreenState extends State<Messages> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  void fetchMessages() async {
    try {
      final String baseUrl = messages;

      // Fetch messages between the selected users
      final response = await http.get(Uri.parse('$baseUrl/inbox/${widget.userId}/${widget.selectedUser['_id']}'));
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final messages = jsonDecode(response.body)['messages'];
        for (var message in messages) {
          _messages.add(ChatMessage(
            text: message['message'],
            isSentByUser: message['from'] == widget.userId,
            timestamp: DateTime.parse(message['timestamp']),
          ));
        }

        // Sort messages by timestamp
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        setState(() {}); // Update the UI after fetching and sorting messages
      } else {
        print('Failed to load messages. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  void _handleSubmitted(String text) async {
    final String baseUrl = messages;

    try {
      // Send a new message
      final response = await http.post(Uri.parse('$baseUrl/send'),
        body: jsonEncode({
          'from': widget.userId,
          'to': widget.selectedUser['_id'],
          'message': text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Successfully sent message
        final sentTimestamp = DateTime.now();
        _messages.add(ChatMessage(
          text: text,
          isSentByUser: true,
          timestamp: sentTimestamp,
        ));

        setState(() {});
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }

    _textController.clear();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top:25.0),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('chat.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                height: 60,
                child: Row(
                  children: <Widget>[
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
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.transparent,
                          child: Image.asset('assets/images/man.png', fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          widget.selectedUser['username'],
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Color(0xFF273236),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Color(0xFF273236)),
                            onSelected: (String choice) {
                              if (choice == "View User's profile") {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => viewprofile(),
                                //   ),
                                // );
                                // Handle Option 1
                              } else if (choice == 'Block user') {
                                // Handle Option 2
                              }else if (choice == 'Report user') {
                                // Handle Option 2
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value:  "View User's profile",
                                  child: Text( "View User's profile"),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Block user',
                                  child: Text('Block user'),
                                ),
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
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => _messages[index],
                ),
              ),
              const Divider(height: 1.0),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F0),
                ),
                child: _buildTextComposer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: const IconThemeData(color: Color(0xFFd3e4fe)),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration(
                  hintText: 'Send a message',
                  contentPadding: EdgeInsets.all(20.0),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_voice_outlined),
              onPressed: () {},
              color: const Color(0xFF273236),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _handleSubmitted(_textController.text),
              color: const Color(0xFF1c4837),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isSentByUser;
  final DateTime timestamp;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isSentByUser,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
        isSentByUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: isSentByUser
                  ? const Color(0xFF1c4837)
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.0,
                color: isSentByUser ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}