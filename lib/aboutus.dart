import 'package:flutter/material.dart';

class aboutus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold( // Background color based on your theme
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: const Color(0xFFe4e8e7),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'About Us',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF273236), // Text color based on your theme
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xFF273236), // Text color based on your theme
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'We are a dedicated team of professionals committed to delivering high-quality Platform where you can interact and register in events.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF273236), // Text color based on your theme
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Contact Us:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF273236), // Text color based on your theme
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Email: sahara@gmail.com',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF273236), // Text color based on your theme
                    ),
                  ),
                  Text(
                    'Phone: +92 3353151657',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF273236), // Text color based on your theme
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
