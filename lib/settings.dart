import 'package:flutter/material.dart';
import 'package:fyp/aboutus.dart';
import 'package:fyp/loginPage.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isNotificationEnabled = true;
  bool isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 26,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 20,),
                  Text("Settings",style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),)
                ],
              ),
              SizedBox(height: 30),
              Text(
                'General Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                title: Text('Notifications'),
                subtitle: Text('Enable/Disable Notifications'),
                trailing: Switch(
                  value: isNotificationEnabled,
                  onChanged: (bool newValue) {
                    setState(() {
                      isNotificationEnabled = newValue;
                    });

                  },
                  activeColor: Color(0xFFd66d67), // Change this to your desired active color
                  inactiveThumbColor:  Colors.grey[300],
                ),
              ),
              Divider(),
              Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                title: Text('Change Password'),
                onTap: () {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => Page3(),
                  //   ),
                  // );
                },
              ),
              ListTile(
                title: Text('About us'),
                trailing: Icon(
                  Icons.question_mark_outlined, // Use the appropriate icon for logout
                  color:Color(0xFF273236), // You can adjust the color as needed
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => aboutus(),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Logout'),
                trailing: Icon(
                  Icons.logout, // Use the appropriate icon for logout
                  color:Color(0xFF273236), // You can adjust the color as needed
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => loginPage()
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
