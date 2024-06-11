import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:fyp/adminuploadimage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'config.dart';
import 'loginPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  bool isMenuOpen = true;
  int selectedIndex = 0;
  String selectedProfileName = '';

  void openDocumentPage(String profileName) {
    setState(() {
      selectedProfileName = profileName;
      selectedIndex = 4; // Index of DocumentPage
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side menu
          if (isMenuOpen)
            Container(
              width: 200,
              color: Colors.grey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 8, left: 20),
                        child: Text('SAHARA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            isMenuOpen = false;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Divider(thickness: 1),
                  buildMenuButtonWithLines('Dashboard', 0),
                  buildMenuButtonWithLines('Profile Approval', 1),
                  buildMenuButtonWithLines('Review Report', 2),
                  buildMenuButtonWithLines('Event Information', 3),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => loginPage()
                          ),
                        );

                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey.shade300,
                        minimumSize: Size(double.infinity, 36),
                      ),
                      child: Text('Logout', style: TextStyle(color: Colors.black),),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: 50,
              color: Colors.grey.shade200,
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      setState(() {
                        isMenuOpen = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Color(0xFFd66d67),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Welcome Back', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IndexedStack(
                      index: selectedIndex,
                      children: [
                        UserCountWidget(),
                        ProfilesPage(),
                        ReportPage(),
                        EventInformationPage(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuButtonWithLines(String text, int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
              child: Text(
                text,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        Divider(thickness: 1),
      ],
    );
  }

  Widget buildPage(String text) {
    return Container(
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}



class ProfilesPage extends StatefulWidget {
  @override
  _ProfilesPageState createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  List profiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfiles();
  }

  fetchProfiles() async {
    final response = await http.get(Uri.parse(pendingapproval));

    if (response.statusCode == 200) {
      setState(() {
        profiles = json.decode(response.body);
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
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
  final profile;

  ProfileBox(this.profile);

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
            profile['username'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 13),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentPage(profile: profile),
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


class DocumentPage extends StatefulWidget {
  final profile;

  DocumentPage({required this.profile});

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  String securitypicspath = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImage(widget.profile['userId']);
  }

  void fetchImage(String userId) async {
    final String baseUrl = userimage;

    final response = await http.get(Uri.parse('$baseUrl/$userId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> suggestion = json.decode(response.body);
      if (suggestion.isNotEmpty && suggestion['check'] == 'security' && suggestion['isApproved'] == false) {
        String imagePath2 = suggestion['imagePath'].toString() ?? '';
        String encodedImagePath = Uri.encodeFull(imagePath2.split('\\pictures\\').last);
        String url = 'http://192.168.43.197:3000/images/$encodedImagePath';
        print(url);

        setState(() {
          securitypicspath = url;
          isLoading = false;
        });
      } else {
        print('No valid images found');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<void> approveImage() async {
    final response = await http.post(
      Uri.parse(acceptimage),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': widget.profile['userId']}),
    );

    if (response.statusCode == 200) {
      print('Image approved');
    } else {
      print('Failed to approve image');
    }
  }

  Future<void> rejectImage() async {
    final response = await http.post(
      Uri.parse(rejectimage),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': widget.profile['userId']}),
    );

    if (response.statusCode == 200) {
      print('Image rejected');
    } else {
      print('Failed to reject image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);

              },
              icon: Icon(
                Icons.arrow_back,
                color: Color(0xFF1c4837),
              ),
            ),
            Text(
              widget.profile['username'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            securitypicspath.isNotEmpty
                ? Row(
              children: [
                Expanded(
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                    ),
                    child: Image.network(
                      securitypicspath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            )
                : Center(child: Text('No image found')),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await approveImage();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));                  },
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
                  onPressed:  () async {
                    await rejectImage();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));                  },
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



class EventInformationPage extends StatefulWidget {
  @override
  _EventInformationPageState createState() => _EventInformationPageState();
}
class _EventInformationPageState extends State<EventInformationPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? selectedCategory;
  String? selectedDay;
  String? selectedInterest;
  String? selectedExclusion;
  int? rating;  // Add rating field
  final List<String> categories = ['Environmental', 'Sports', 'Community', 'Educational', 'Technology', 'Entertainment'];
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> interests = [
    "Acting", "Art Galleries", "Board Games", "Creative writing", "Design", "DIY", "Fashion",
    "Film & Cinema", "Filmmaking", "Knitting", "Learning languages", "Live music", "Photography", "Painting", "Reading",
    "Playing music", "Pottery", "Travel", "Standup Comedy", "TV shows", "Theatre", "Sewing", "Museums",
    "Family time", "Activism", "Politics", "Volunteering", "Spending Time with friends",
    "Baking", "Bubble Tea", "Cake decorating", "Chocolate", "Coffee", "Eating out", "Takeaway",
    "Fish&chips", "Junk food", "Cold drinks", "Vegetarian", "Sushi", "Chinese", "Vegan", "Pizza", "Bbq", "Meat lover", "Eating healthy",
    "Cooking", "Bird watching", "Star gazing", "Gardening", "Hiking", "Fishing", "sunrise viewing", "Scuba diving", "Camping", "sunset viewing",
    "Dancing", "Rowing", "Cycling", "Sailing", "Skiing", "Soccer", "Tennis", "Surfing", "Yoga", "Running",
    "Volleyball", "Rugby", "Pilates", "Golf", "Ice Hockey", "Gym", "Fencing", "Rock Climbing", "Cricket",
    "Baseball", "Badminton", "Boxing", "Animation", "Coding", "Blogging", "Tech", "Content Creation", "Digital art", "Video games"
  ];
  final List<String> exclusions = ['Hearing', 'Speaking', 'Physical', 'Irlen syndrome', 'Dwarfs', 'Others'];
  final picker = ImagePicker();
  XFile? image;
  String? eventName;
  String? location;
  String? eventInfo;
  String? money;
  final TextEditingController _timeController = TextEditingController();
  String? fullPath;

  @override
  void initState() {
    super.initState();
    _loadFullPath();
  }

  Future<void> _loadFullPath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullPath = prefs.getString('fullPath');
      print(fullPath);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _openUploadImagePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AdminUploadImage();
      },
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> storeEventInformation() async {
    try {
      var eventBody = {
        "name": eventName,
        "rating": rating ?? 0,  // Include rating in the event body
        "categoryName": selectedCategory,
        "location": location,
        "about": eventInfo,
        "time": _timeController.text,
        "money": money,
        "date": selectedDate?.toIso8601String(),
        "day": selectedDay,
        "cantplay": selectedExclusion != null ? [selectedExclusion] : [],
        "interest": selectedInterest != null ? [selectedInterest] : [],
        "imagePath": fullPath ?? '',
      };

      print("FullPath: ${fullPath}");

      var response = await http.post(
        Uri.parse("http://192.168.43.197:3000/api/saveUpcomingEvent"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(eventBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Event information stored successfully");
        Future.delayed(Duration(milliseconds: 100), () {
          _showConfirmationDialog(); // Show confirmation dialog after delay
        });
      } else {
        print("Event submission failed with status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      storeEventInformation();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('The event information has been uploaded.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();// Reset the form fields
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Upload Event Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFd66d67)),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd66d67)),
                  ),
                ),
                onSaved: (value) => eventName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd66d67)),
                  ),
                ),
                value: selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                items: categories.map((category) {
                  return DropdownMenuItem(
                    child: Text(category),
                    value: category,
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Location',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd66d67)),
                  ),
                ),
                onSaved: (value) => location = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Information about Event',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd66d67)),
                  ),
                ),
                onSaved: (value) => eventInfo = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter information about event';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Rating',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd66d67)),
                  ),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => rating = int.tryParse(value ?? '0'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rating';
                  }
                  final ratingValue = int.tryParse(value);
                  if (ratingValue == null || ratingValue < 0 || ratingValue > 5) {
                    return 'Please enter a rating between 0 and 5';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: TextFormField(
                        controller: _timeController,
                        decoration: const InputDecoration(
                          labelText: 'Select Time',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFd66d67)),
                          ),
                          suffixIcon: Icon(Icons.access_time, color: Color(0xFFd66d67)),
                        ),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          await _selectTime(context);
                        },
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a time';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFd66d67)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate != null ? DateFormat.yMd().format(selectedDate!) : 'Select Date',
                              style: TextStyle(color: Colors.black),
                            ),
                            Icon(Icons.calendar_today, color: Color(0xFFd66d67)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Money',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd66d67)),
                  ),
                ),
                onSaved: (value) => money = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter money';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Day',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd66d67)),
                  ),
                ),
                value: selectedDay,
                onChanged: (newValue) {
                  setState(() {
                    selectedDay = newValue;
                  });
                },
                items: days.map((day) {
                  return DropdownMenuItem(
                    child: Text(day),
                    value: day,
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a day';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Those who can\'t play that event',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd66d67)),
                  ),
                ),
                value: selectedExclusion,
                onChanged: (newValue) {
                  setState(() {
                    selectedExclusion = newValue;
                  });
                },
                items: exclusions.map((exclusion) {
                  return DropdownMenuItem(
                    child: Text(exclusion),
                    value: exclusion,
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select an exclusion';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Interest',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFd66d67)),
                  ),
                ),
                value: selectedInterest,
                onChanged: (newValue) {
                  setState(() {
                    selectedInterest = newValue;
                  });
                },
                items: interests.map((interest) {
                  return DropdownMenuItem(
                    child: Text(interest),
                    value: interest,
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select an interest';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.image),
                    label: Text('Add Image'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFd66d67),
                      minimumSize: Size(150, 50), // Adjust the width and height as needed
                    ),
                    onPressed: _openUploadImagePopup,
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFd66d67),
                      minimumSize: Size(150, 50), // Adjust the width and height as needed
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}





class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<dynamic> reports = [];
  bool isLoading = true;
  Map<String, String> usernames = {};
  Map<String, String> emails = {};
  String email = '';

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final url = 'http://192.168.43.197:3000/getreports'; // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(jsonResponse['reports']); // Print the reports to the console
        setState(() {
          reports = jsonResponse['reports'];
          isLoading = false;
        });
        await fetchUsernames();
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUsernames() async {
    for (var report in reports) {
      final reportedUserId = report['Reporteduserid'];
      final userWhoReportedId = report['userId'];
      await fetchUsername(reportedUserId);
      await fetchUsername(userWhoReportedId);
    }
    setState(() {});
  }

  Future<void> fetchUsername(String userId) async {
    if (!usernames.containsKey(userId)) {
      final url = 'http://192.168.43.197:3000/getusername/$userId'; // Replace with your API URL
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          print(jsonResponse['username']); // Print the username to the console
          setState(() {
            usernames[userId] = jsonResponse['username'];
          });
        } else {
          throw Exception('Failed to load username');
        }
      } catch (error) {
        print(error);
      }
    }
  }

  Future<void> deleteUser(String userId) async {
    final userUrl = 'http://192.168.43.197:3000/deleteuser/$userId'; // Replace with your API URL
    try {
      final userResponse = await http.delete(Uri.parse(userUrl));
      if (userResponse.statusCode == 200) {
        final userJsonResponse = json.decode(userResponse.body);
        print(userJsonResponse['message']); // Print the message to the console

        // Delete all reports associated with this user
        final List<dynamic> reportsToDelete = reports
            .where((report) => report['Reporteduserid'] == userId || report['userId'] == userId)
            .toList();
        for (var report in reportsToDelete) {
          await deleteReport(report['_id']);
        }

        setState(() {
          reports.removeWhere((report) => report['Reporteduserid'] == userId || report['userId'] == userId);
        });

        // Show success message or perform other actions as needed
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (error) {
      print(error);
      // Handle error as needed
    }
  }

  Future<void> deleteReport(String reportId) async {
    final reportUrl = 'http://192.168.43.197:3000/deletereport/$reportId'; // Replace with your API URL
    try {
      final response = await http.delete(Uri.parse(reportUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(jsonResponse['message']); // Print the message to the console
        setState(() {
          reports.removeWhere((report) => report['_id'] == reportId);
        });
        // Show success message or perform other actions as needed
      } else {
        throw Exception('Failed to delete report');
      }
    } catch (error) {
      print(error);
      // Handle error as needed
    }
  }

  Future<void> getEmail(String userId) async {
    final String url = 'http://192.168.43.197:3000/getemail/$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          email = data['email']; // Adjust the key based on your response structure
        });
        print('Email: $email');
      } else {
        print('Failed to load email. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void sendEmail(String recipientEmail) async {
    final url = 'http://192.168.43.197:3001/send-email';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'recipientEmail': recipientEmail,
        'subject': 'Warning: Incorrect Report Notification',
        'text': 'We have reviewed the report you issued regarding another user’s account and found it to be incorrect. Please ensure that future reports adhere to our community guidelines. Continuous misuse of the reporting system may result in penalties.',
      }),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully');
    } else {
      print('Failed to send email: ${response.body}');
    }
  }
  void sendEmail2(String recipientEmail) async {
    final url = 'http://192.168.43.197:3001/send-email';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'recipientEmail': recipientEmail,
        'subject': 'Account Deletion Notification',
        'text': 'Your account has been deleted due to a report issued by a user, which has been found to violate the policies of this application.',
      }),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully');
    } else {
      print('Failed to send email: ${response.body}');
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: FittedBox(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Users Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFd66d67),
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final reportedUserId = report['Reporteduserid'];
                final userWhoReportedId = report['userId'];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('Report ID: ${report['_id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User Who Reported: ${usernames[userWhoReportedId] ?? 'Loading...'}'),
                        Text('User Reported: ${usernames[reportedUserId] ?? 'Loading...'}'),
                        Text('Description: ${report['reason']}'),
                        Text('Category: ${report['reportOption']}'),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await deleteReport(report['_id']);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                              ),
                              child: Text('Ignore'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                await getEmail(reportedUserId);
                                sendEmail(email);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                              ),
                              child: Text("Warning To The Reported User", style: TextStyle(color: Colors.black),),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                await getEmail(reportedUserId);
                                // await deleteUser(reportedUserId);
                                sendEmail2(email);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFFd66d67), // Background color for Delete button
                              ),
                              child: Text("Delete User's Account"),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}




class UserCountWidget extends StatefulWidget {
  @override
  _UserCountWidgetState createState() => _UserCountWidgetState();
}

class _UserCountWidgetState extends State<UserCountWidget> {
  int totalUsers = 0;
  double averageRating = 0.0;
  List<Map<String, dynamic>> reviews = [];
  Map<String, String> usernames = {};

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchTotalUsers();
    fetchAverageRating();
    _startPeriodicFetch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicFetch() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchTotalUsers();
      fetchAverageRating();
    });
  }

  Future<void> fetchTotalUsers() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.43.197:3000/allusers'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != null && data['success']) {
          setState(() {
            totalUsers = data['totalUsers'] ?? 0;
          });
        } else {
          print('Failed to fetch users');
        }
      } else {
        print('Server error');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchAverageRating() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.43.197:3000/getrating'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] != null && data['status']) {
          setState(() {
            averageRating = (data['averageRating'] ?? 0.0).toDouble();
            reviews = List<Map<String, dynamic>>.from(data['success']);
          });
          for (var review in reviews) {
            await fetchUsername(review['userId']);
          }
        } else {
          print('Failed to fetch rating');
        }
      } else {
        print('Server error');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchUsername(String userId) async {
    final url = 'http://192.168.43.197:3000/getusername/$userId'; // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('username') && jsonResponse['username'] != null) {
          final username = jsonResponse['username'];
          setState(() {
            usernames[userId] = username;
          });
        } else {
          print('Username not found for userId $userId');
        }
      } else {
        throw Exception('Failed to load username');
      }
    } catch (error) {
      print('Error fetching username for userId $userId: $error');
    }
  }

  Color getColorForRating(double rating) {
    if (rating <= 2) {
      return Colors.red;
    } else if (rating <= 4) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalUsersStr = totalUsers.toString();
    final themeColor = Color(0xFFd66d67); // Adjust this color to match your theme

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total User signed in the application',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: totalUsersStr.split('').map((digit) {
                        return Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: Center(
                            child: Text(
                              digit,
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Reviews',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 300, // Adjust height as needed
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.all(16.0),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            final userId = review['userId'];
                            final rating = review['rating'];
                            final reviewText = review['review'];
                            final username = usernames[userId] ?? 'Loading...';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Username: $username',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                StarDisplay(
                                  value: rating.toDouble(),
                                  color: getColorForRating(rating.toDouble()),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Rating: $rating',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Review: $reviewText',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => Divider(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Application rating',
                          style: TextStyle(fontSize:18),
                        ),
                        SizedBox(height: 10),
                        StarDisplay(
                          value: averageRating,
                          color: getColorForRating(averageRating),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${averageRating.toStringAsFixed(1)} Rating',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
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

class StarDisplay extends StatelessWidget {
  final double value;
  final Color color;

  const StarDisplay({Key? key, required this.value, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int fullStars = value.floor();
    bool hasHalfStar = (value - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: color);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: color);
        } else {
          return Icon(Icons.star_border, color: color);
        }
      }),
    );
  }
}
