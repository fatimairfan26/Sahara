import 'dart:convert';
import 'package:fyp/explore.dart';
import 'package:fyp/userprofile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fyp/message_dashboard.dart';
import 'package:fyp/dashboard.dart';
import 'config.dart';

class NavBar extends StatefulWidget {
  final String? token;
  const NavBar({this.token, Key? key}) : super(key: key);

  @override
  NavBarState createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  int _selectedPage = 0;
  late String id;
  int unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    id = jwtDecodedToken['_id'];
    getUnreadMessageCount();
  }

  void getUnreadMessageCount() async {
    final String baseUrl = messages;

    try {
      final response = await http.get(Uri.parse('$baseUrl/unreadMessageCount/$id'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          unreadMessageCount = jsonResponse['unreadMessageCount'];
        });
      } else {
        print('Failed to load unread message count. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = widget.token;
    print('Building NavBar with Unread Count: $unreadMessageCount'); // Add this line

    final List<Widget> _pageOptions = [
      if (token != null) Dashboard(token: token),
      if (token != null)
        MessageDashboard.withToken(
          token: token,
          onMessagesViewed: () {
            setState(() {
              unreadMessageCount = 0;
            });
          },
        ),
      exploreprofiles(token: token,),
      if (token != null) userprofile(token: token),

      // userprofile(),
    ];
    return Scaffold(
      body: _pageOptions[_selectedPage],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.grey.withOpacity(0.4),
        index: _selectedPage,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.home_outlined, size: 30, color: Colors.black),
          Stack(
            children: [
              Icon(Icons.message_outlined, size: 30, color: Colors.black),
              if (unreadMessageCount > 0)
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadMessageCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Icon(Icons.explore_outlined, size: 30, color: Colors.black),
          Icon(Icons.person, size: 30, color: Colors.black),
        ],
        color: Colors.grey.withOpacity(0.2),
        buttonBackgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 200),
        animationCurve: Curves.bounceInOut,
        onTap: (int index) {
          setState(() {
            _selectedPage = index;
          });
        },
      ),
    );
  }
}