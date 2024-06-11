import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class MessagesReq extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> selectedUser;

  const MessagesReq({Key? key, required this.userId, required this.selectedUser}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<MessagesReq> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _showTypingOptions = false;
  bool _isAccepting = false; // Added variable to track accepting or rejecting

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  void fetchMessages() async {
    try {
      final String baseUrl = messages; // Replace with your base URL
      final response = await http.get(Uri.parse('$baseUrl/inbox/${widget.userId}/${widget.selectedUser['_id']}'));
      if (response.statusCode == 200) {
        final messages = jsonDecode(response.body)['messages'];
        for (var message in messages) {
          _messages.add(ChatMessage(
            text: message['message'],
            isSentByUser: message['from'] == widget.userId,
            timestamp: DateTime.parse(message['timestamp']),
          ));
        }
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        setState(() {});
      } else {
        print('Failed to load messages. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _handleReject() async {
    final String baseUrl = messages; // URL for rejecting messages
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rejmsg/${widget.selectedUser['_id']}/${widget.userId}/'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        // If the rejection request is successful, navigate back
        Navigator.pop(context);
      } else {
        print('Failed to reject message. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _handleAccept() async {
    final String baseUrl = messages; // URL for accepting messages
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accmsg/${widget.selectedUser['_id']}/${widget.userId}/'),
        body: jsonEncode({
          'fromUser': widget.selectedUser['_id'],
          'toUser': widget.userId,

        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _showTypingOptions = true;
        });
      } else {
        print('Failed to accept message. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _handleSubmitted(String text) async {
    String baseUrl = messages;

    // Determine the base URL based on the action taken by the user
    if (_showTypingOptions) {

      try {
        final response = await http.post(Uri.parse('$baseUrl/send'),
          body: jsonEncode({
            'fromUser': widget.selectedUser['_id'],
            'toUser': widget.userId,
            'message': text,
          }),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
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
      }    }
    else {

      if (_isAccepting) {
        _handleAccept();
      } else {
        _handleReject();
      }
    }

    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                        child: Image.asset(
                            'assets/images/man.png', fit: BoxFit.contain),
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
                        icon: const Icon(Icons.more_vert, color: Color(
                            0xFF273236)),
                        onSelected: (String choice) {
                          if (choice == "View User's profile") {
                            // Handle Option 1
                          } else if (choice == 'Block user') {
                            // Handle Option 2
                          } else if (choice == 'Report user') {
                            // Handle Option 3
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: "View User's profile",
                              child: Text("View User's profile"),
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
                        offset: Offset(0, 45),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => _messages[index],
                    ),
                  ),
                  const Divider(height: 1.0),
                  if (_showTypingOptions)
                    _buildTextComposer()
                  else
                    _buildAcceptRejectButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptRejectButtons() {
    return Container(
      color: Colors.white,
      height: 60,
      child: Row(
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isAccepting = false;
                });
                _handleReject();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(color: Colors.white),
                ),
                minimumSize: Size.fromHeight(60),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, color: Colors.red),
                  SizedBox(width: 5),
                  Text('Reject', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isAccepting = true;
                });
                _handleAccept();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(color: Colors.white),
                ),
                minimumSize: Size.fromHeight(60),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 5),
                  Text('Accept', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),
        ],
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