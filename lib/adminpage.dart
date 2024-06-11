import 'package:flutter/material.dart';

class ProfilesPage extends StatefulWidget {
  @override
  _ProfilesPageState createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  List<String> profiles = [
    'Profile 1',
    'Profile 2',
    'Profile 3',
    'Profile 4',
    'Profile 5'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profiles Needing Approval',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3 / 1,
                ),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  return ProfileBox(profiles[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileBox extends StatelessWidget {
  final String profileName;

  ProfileBox(this.profileName);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profileName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 13,),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                print('You clicked me');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentPage(profileName: profileName),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFd66d67), // Set the background color here
              ),
              child: Text('View Documents'),
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentPage extends StatelessWidget {
  final String profileName;
  final String documentImage1 = 'https://via.placeholder.com/150'; // Replace with actual image URL from the database
  final String documentImage2 = 'https://via.placeholder.com/150'; // Replace with actual image URL from the database

  DocumentPage({required this.profileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profileName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                    ),
                    child: Image.network(
                      documentImage1,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                    ),
                    child: Image.network(
                      documentImage2,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print('Approved');
                    // Add your approval logic here
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  child: Row(
                    children: [
                      Text('Approve'),
                      SizedBox(width: 4),
                      Icon(Icons.check),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    print('Rejected');
                    // Add your rejection logic here
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: Row(
                    children: [
                      Text('Reject'),
                      SizedBox(width: 4),
                      Icon(Icons.close),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


