import 'package:flutter/material.dart';

class Hamburger extends StatefulWidget {
  const Hamburger({Key? key}) : super(key: key);

  @override
  State<Hamburger> createState() => _HamburgerState();
}

class _HamburgerState extends State<Hamburger> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF1c4837)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Edit Other Details',
            style:TextStyle(
              color: Color(0xFF1c4837),
              fontWeight: FontWeight.bold,
            ) ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),

            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => Dashboard()),
                // );
              },
              child: Text('Interests',
                style: TextStyle(
                  fontSize: 18,
                ) , ),
            ),
            const SizedBox(height: 18.0),

            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => Dashboard()),
                // );              },
              },
              child: Text('Personality of Partner',
                style: TextStyle(
                  fontSize: 18,
                ) ,),
            ),
            const SizedBox(height: 18.0),

            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => Dashboard()),
                // );
              },
              child: Text('About Me',

                style: TextStyle(
                  fontSize: 18,
                ) ,),
            ),
          ],
        ),
      ),
    );
  }
}