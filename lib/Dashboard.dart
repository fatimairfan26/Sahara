import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fyp/eventreviews.dart';
import 'package:fyp/messages_inside.dart';
import 'package:fyp/reviews.dart';
import 'package:fyp/searchbar.dart';
import 'package:fyp/viewprofile.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class Dashboard extends StatefulWidget {
  final token;
  const Dashboard({required this.token, Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  bool isPopupVisible = false;
  late String userId;
  String? username;
  final TextEditingController textController = TextEditingController(text: 'Dummy link test');


  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    _fetchUsername();
    fetchUserprofileimage(userId);
  }

  Future<void> fetchUserprofileimage(String userId) async {
    try {
      final apiUrl = 'http://192.168.43.197:3000/profile/images/$userId';
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
          profilepicspath = url;
        });
      } else {
        print('Error fetching user images: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user images: $error');
    }
  }

  String profilepicspath = '';


  Future<void> _fetchUsername() async {
    final baseurl= getname;
    final apiUrl = '$baseurl/$userId/username';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      final username = responseData['username'];
      await prefs.setString('username', username);
      setState(() {
        this.username = username;
      });
    } else {
      print('Error fetching username');
    }
  }

  void showPopup() {
    setState(() {
      isPopupVisible = true;
    });
  }

  void hidePopup() {
    setState(() {
      isPopupVisible = false;
    });
  }


  Event emptyEvent = Event(
    name: '',
    categoryName: '',
    about: '', location: '', time: '', money: '', date: '', rating: null,
    imagelink: '',
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(top:35,left:8.0, right:0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20, // Increase the radius for a bigger CircleAvatar
                              backgroundColor: const Color(0xFFd66d67),
                              backgroundImage: profilepicspath.isNotEmpty
                                  ? NetworkImage(profilepicspath)
                                  : null,
                              child: profilepicspath.isEmpty
                                  ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: username != null
                                  ? Text( 'Hi $username',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:  Colors.black,
                                ),
                              ): const CircularProgressIndicator(),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.star,
                                size: 20,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Review(token: widget.token)),
                                );
                              },
                            ),

                            IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.share,
                                size: 20,
                                color: Colors.black,
                              ),
                              onPressed: showPopup,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Search(token: userId,),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Search",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height:20,),



                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 140,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: tabs(event: emptyEvent, token: widget.token),
              ),
            ),
          ),
          if (isPopupVisible)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Popup content
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 280,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Share with your friends ',
                                style: Theme.of(context).textTheme.headline1,
                              ),
                              Text(
                                'Invite your friends and family and earn Reward',
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              const SizedBox(height: 60),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: TextField(
                                  controller: textController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  Clipboard.setData(ClipboardData(text: textController.text));
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Link copied to clipboard'),
                                                    ),
                                                  );
                                                },
                                                icon: Image.asset('assets/link.png'),
                                              ),
                                              Text(
                                                'Copy Link',
                                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color:  Colors.black),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: ElevatedButton(
                                        onPressed: hidePopup,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFd66d67),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
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
                    ),
                  ],
                ),
              ),
            ),

        ],
      ),
    );
  }
}






class tabs extends StatefulWidget {
  final String? token;
  final Event event;

  // Use a named constructor
  tabs({Key? key, required this.event, required this.token}) : super(key: key);

  @override
  tabsState createState() => tabsState();
}


class tabsState extends State<tabs> {
  int currentIndex = 0;
  late String userId;
  List<Event> eventsdata = [];
  List<Event> upcomingeventsdata = [];
  bool isExpanded = false;
  String usernamed = "";
  String bio = "";
  String city = "";
  String marital = "";
  String imagePath = "";
  String profile_id = "";
  List<dynamic> suggestions = [];
  String profilepicspath2 = "";


  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    userId = jwtDecodedToken['_id'];
    fetchPreviousEventsByUserId(userId:userId);// Initialize the userProfile
    fetchupcomingEventsByUserId(userId:userId);// Initialize the userProfile
    fetchSuggestion(userId);
  }

  void fetchSuggestion(String userId) async {
    final String baseUrl = suggest;
    final response = await http.get(Uri.parse('$baseUrl/$userId'));
    if (response.statusCode == 200) {
      final suggestions = json.decode(response.body);
      if (suggestions.isNotEmpty) {
        final Map<String, dynamic> suggestion = suggestions[0];


        String imagePath2 = suggestion['imagePath'].toString() ?? '';
        String encodedImagePath2 = Uri.encodeFull(imagePath2.split('\\pictures\\').last);
        String url = 'http://192.168.43.197:3000/images/$encodedImagePath2';
        print(url);

        setState(() {
          profile_id = suggestion['puserId'] ?? ""; // Ensure it's treated as a string
          usernamed = suggestion['username'] ?? "";
          bio = suggestion['pbio'] ?? "";
          city = suggestion['pcity'] ?? "";
          marital = suggestion['pmarital'] ?? "";
          profilepicspath2=url;

          print(profilepicspath2);
        });
      } else {
        print('No suggestions found');
      }
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
  void switchImage() {
    fetchSuggestion(userId);
  }



  void acceptUser() async {
    final String baseUrl = accept; // Replace 'your_base_url' with your actual base URL
    final response = await http.post(Uri.parse('$baseUrl/$userId/$profile_id'));
    if (response.statusCode == 200) {
      switchImage();
    } else {
      throw Exception('Failed to accept user');
    }
  }

  void rejectUser() async {
    final String baseUrl = reject; // Replace 'your_base_url' with your actual base URL

    final response = await http.post(Uri.parse('$baseUrl/$userId/$profile_id'));
    if (response.statusCode == 200) {
      switchImage();
    } else {
      throw Exception('Failed to reject user');
    }
  }



  Future<void> fetchPreviousEventsByUserId({required String userId}) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.43.197:3000/previouseventsByDisability/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          eventsdata = responseData.map((data) {
            return Event(
              name: data['eventName'] ?? '',
              categoryName: data['categoryName'] ?? '',
              about: data['about'] ?? '',
              location: data['location'] ?? '',
              time: data['time'] ?? '',
              money: data['money'] ?? '',
              date: data['date'] ?? '',
              rating: (data['rating'] ?? 0).toDouble(),
              imagelink: data['imagePath'] ?? '',

            );
          }).toList();
        });
      } else {
        print('Error fetching previous events by user ID: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching previous events by user ID: $error');
    }
  }

  Future<void> fetchupcomingEventsByUserId({required String userId}) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.43.197:3000/eventsByDisability/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          upcomingeventsdata = responseData.map((data) {
            return Event(
              name: data['name'] ?? '',
              categoryName: data['categoryName'] ?? '',
              about: data['about'] ?? '',
              location: data['location'] ?? '',
              time: data['time'] ?? '',
              money: data['money'] ?? '',
              date: data['date'] ?? '',
              rating: data['rating'] ?? '',
              imagelink: data['imagePath'] ?? '',

            );
          }).toList();
        });
      } else {
        print('Error fetching previous events by user ID: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching previous events by user ID: $error');
    }
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
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
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor:  Color(0xFFd66d67),
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      const Tab(text: 'Events'),
                      const Tab(text: 'Matrimonial'),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  color: Colors.white,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: TabBarView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top:10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Text("Previous events",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headline4),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              seeallPage(),
                                        ),
                                      );
                                      print("hello");
                                    },
                                    child: const Text(
                                      "See all",
                                      style:
                                      TextStyle(color: Colors.black,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            CarouselSlider(
                              items: eventsdata.map((event) {
                                String imagePath2 = event.imagelink.split('\\pictures\\').last;
                                String encodedImagePath2 = Uri.encodeFull(imagePath2);
                                String imageUrl = 'http://192.168.43.197:3000/images/$encodedImagePath2';
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 180,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15.0),
                                        color: Colors.white, // Set the background color of the Container to white
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14.0),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('Error loading image: $error');
                                                return const Center(
                                                  child: Text('Error loading image'),
                                                );
                                              },
                                            ),
                                            Positioned(
                                              top: 10,
                                              left: 8,
                                              right: 10,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    event.name,
                                                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              right: 10,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => detailpage(event: event, token: widget.token,),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  height: 30,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(15),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.2),
                                                        spreadRadius: 5,
                                                        blurRadius: 5,
                                                        offset: const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "View details",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                              options: CarouselOptions(
                                onPageChanged: (int index, CarouselPageChangedReason reason) {
                                  setState(() {
                                    currentIndex = index;
                                  });
                                },
                                enlargeCenterPage: true,
                                autoPlay: true,
                                autoPlayCurve: Curves.easeIn,
                                enableInfiniteScroll: true,
                                viewportFraction: 1,
                                autoPlayInterval: const Duration(seconds: 6),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < eventsdata.length; i++)
                                  buildIndicator(currentIndex == i)
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Text("Categories",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headline4)
                              ],
                            ),
                            const SizedBox(height: 20),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              // Set the scrolling direction to horizontal
                              child: Row(
                                children: [
                                  Column(
                                    // Wrap the image and text in a Column
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 55,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EventListPage(
                                                        initialCategory: "Environmental",
                                                        token:widget.token
                                                    ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 3,
                                            shadowColor: Colors.grey,
                                            primary: const Color(
                                                0xFFe4e8e7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          child: Image.asset(
                                            'assets/environment.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text("Environmental",
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline2),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    // Wrap the image and text in a Column
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 55,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EventListPage(
                                                    initialCategory: "Sports",// Pass
                                                    token:widget.token// your fetch function here
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 3,
                                            shadowColor: Colors.grey,
                                            primary: const Color(
                                                0xFFe4e8e7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          child: Image.asset(
                                            'assets/ballssports.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text("Sports ",
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline2),
                                      // Text under the image
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 23,
                                  ),
                                  Column(
                                    // Wrap the image and text in a Column
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 55,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EventListPage(
                                                    initialCategory: "Community",
                                                    token:widget.token
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 3,
                                            shadowColor: Colors.grey,
                                            primary: const Color(
                                                0xFFe4e8e7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          child: Image.asset(
                                            'assets/community.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text("Community",
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline2),
                                      // Text under the image
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 18,
                                  ),
                                  Column(
                                    // Wrap the image and text in a Column
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 55,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EventListPage(
                                                    initialCategory: "Educational",
                                                    token:widget.token// Pass your fetch function here
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 3,
                                            shadowColor: Colors.grey,
                                            primary: const Color(
                                                0xFFe4e8e7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          child: Image.asset(
                                            'assets/education.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text("Educational",
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline2),
                                      // Text under the image
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    // Wrap the image and text in a Column
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 55,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EventListPage(
                                                    initialCategory: "Technology",
                                                    token:widget.token// Pass your fetch function here
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 3,
                                            shadowColor: Colors.grey,
                                            primary: const Color(
                                                0xFFe4e8e7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          child: Image.asset(
                                            'assets/techno.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text("Technology",
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline2),
                                      // Text under the image
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    // Wrap the image and text in a Column
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 55,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EventListPage(
                                                    initialCategory: "Entertainment",
                                                    token:widget.token// Pass your fetch function here
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 3,
                                            shadowColor: Colors.grey,
                                            primary: const Color(
                                                0xFFe4e8e7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(15),
                                            ),
                                          ),
                                          child: Image.asset(
                                            'assets/environment.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text("Entertainment",
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline2),
                                      // Text under the image
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 35),
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Text("#Onlyforyou",
                                    style: Theme.of(context).textTheme.headline4!.copyWith(color: Color(0xFFd66d67))),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                seeallPageupcoming(token: widget.token,)),
                                      );
                                    },
                                    child: const Text(
                                      "See all",
                                      style:
                                      TextStyle(color: Colors.black,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: upcomingeventsdata.map((event) {
                                  String imagePath = event.imagelink.split('\\pictures\\').last;
                                  String imageUrl = 'http://192.168.43.197:3000/images/$imagePath';
                                  print(imageUrl);
                                  String encodedImagePath = Uri.encodeFull(imagePath);
                                  String imageUrl2 = 'http://192.168.43.197:3000/images/$encodedImagePath';

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => preveventpage(event: event, token: widget.token),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 180,
                                        width: 250,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15.0),
                                          image: DecorationImage(
                                            image: NetworkImage(imageUrl2), // Load image from the network
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 15,
                                                  right: 15,
                                                  left: 15,
                                                  top: 10,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      height: 30,
                                                      width: 55,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[100],
                                                        borderRadius: BorderRadius.circular(15),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(width: 4),
                                                          const Icon(
                                                            Icons.star,
                                                            size: 23,
                                                            color: Colors.yellow,
                                                          ),
                                                          Text(
                                                            event.rating.toString(),
                                                            style: const TextStyle(color: Colors.black),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0, left: 15),
                                              child: Text(
                                                event.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 15),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.65,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(25.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child:Image.network(
                                          profilepicspath2,
                                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                            print('Error loading image: $error');
                                            return const Text('Failed to load image');
                                          },
                                          fit: BoxFit.cover,
                                        ),

                                      ),
                                      Positioned(
                                        top: 10,
                                        left:-5,
                                        child: Row(
                                          children: [


                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: -5,
                                        child: Row(
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white.withOpacity(0.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  side: const BorderSide(color: Colors.white),
                                                ),
                                              ),
                                              onPressed: () {
                                                print(userId);
                                                print(profile_id);
                                                print(usernamed);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => Messages(
                                                      userId: userId, // Use tokenUserId
                                                      selectedUser: {
                                                        '_id': profile_id,
                                                        'username': usernamed
                                                      },
                                                    ),
                                                  ),
                                                );

                                              },
                                              child: const Text(
                                                "Messages",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.more_vert, color: Colors.white),
                                              onPressed: () {
                                                showMenu<String>(
                                                  context: context,
                                                  position: RelativeRect.fromLTRB(900, 250, 20, 0),

                                                  items: [
                                                    PopupMenuItem<String>(
                                                      child:  ListTile(

                                                        title: Text(
                                                          'View Profile',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => ViewProfile(
                                                                userid: profile_id,
                                                                username: usernamed,
                                                                token: userId,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),

                                                    ),
                                                  ],
                                                );
                                              },
                                            ),


                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 100,
                                        left: 10,
                                        right: 10,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(top:8.0),
                                                  child: Text(
                                                    "  $usernamed, $marital ",
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            GestureDetector(
                                              onTap: () {
                                                // setState(() {
                                                //   isExpanded = !isExpanded;
                                                // });
                                              },
                                              child: Text(
                                                "$bio | $city",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,

                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.73,
                                        width: MediaQuery.of(context).size.width,
                                        child: Stack(
                                          children: [
                                            // Background container for the dislike icon
                                            Positioned(
                                              bottom: 20,
                                              left: 10,
                                              child: Container(
                                                width: MediaQuery.of(context).size.width * 0.17,
                                                height: MediaQuery.of(context).size.height * 0.06,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(25),
                                                  color: Color(0xFFd66d67), // Background color behind the icon
                                                ),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.thumb_down,
                                                    color: Colors.white, // Icon color
                                                  ),
                                                  onPressed: rejectUser,
                                                ),
                                              ),
                                            ),
                                            // Background container for the heart icon
                                            Positioned(
                                              bottom: 20,
                                              right: 10,
                                              child: Container(
                                                width: MediaQuery.of(context).size.width * 0.17,
                                                height: MediaQuery.of(context).size.height * 0.06,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(25),
                                                  color: Color(0xFFd66d67), // Background color behind the icon
                                                ),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.favorite,
                                                    color: Colors.white, // Icon color
                                                  ),
                                                  onPressed: acceptUser,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    ],
                                  )

                              ),
                            ),


                          ],

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator(bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        height: isSelected ? 12 : 8,
        width: isSelected ? 12 : 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFFd66d67) : Colors.grey,
        ),
      ),
    );
  }
}



class Event {
  final String name;
  final String categoryName;
  final String about;
  final String location;
  final String time;
  final String money;
  final String date;
  final double? rating;
  final String imagelink;

  Event({
    required this.name,
    required this.categoryName,
    required this.about,
    required this.location,
    required this.time,
    required this.money,
    required this.date,
    required this.rating,
    required this.imagelink,

  });
}

class EventListPage extends StatefulWidget {
  final String? token;
  final String initialCategory;

  EventListPage({required this.initialCategory, required this.token});

  @override
  _EventListPageState createState() => _EventListPageState();
}                                      //categories page
class _EventListPageState extends State<EventListPage> {
  late String selectedCategory;
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
    fetchEventsByCategory(selectedCategory);
  }

  Future<void> fetchEventsByCategory(String category) async {
    try {
      final apiUrl = 'http://192.168.43.197:3000/events?category=$category';
      print('Request URL: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      print('Request URL: ${response.request?.url}');
      print('Request Headers: ${response.request?.headers}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          events = responseData.map((data) {
            return Event(
              name: data['name'] ?? '',
              categoryName: data['categoryName'] ?? '',
              about: data['about'] ?? '',
              location: data['location'] ?? '',
              time: data['time'] ?? '',
              money: data['money'] ?? '',
              date: data['date'] ?? '',
              rating: (data['rating'] ?? 0).toDouble(),
              imagelink: data['imagePath'] ?? '',

            );
          }).toList();
        });
      } else {
        print('Error fetching events: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching events: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top:30.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 10,),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 40),
                Text(
                  selectedCategory,
                  style: const TextStyle(
                    fontSize: 32, // Adjust the font size as needed
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return EventCard(
                    event: events[index],
                    onSelectCategory: _onSelectCategory,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSelectCategory(Event event) async {
    // Store the selected event's name in shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedEventName', event.name);

    setState(() {
      selectedCategory = event.categoryName;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => preveventpage(event: event, token: widget.token,),
      ),
    );
  }
}
class EventCard extends StatelessWidget {
  final Event event;
  final Function(Event) onSelectCategory;

  EventCard({required this.event, required this.onSelectCategory});

  @override
  Widget build(BuildContext context) {
    String imagePath3 = event.imagelink.split('\\pictures\\').last;
    String encodedImagePath3 = Uri.encodeFull(imagePath3);
    String imageUrl3 = 'http://192.168.43.197:3000/images/$encodedImagePath3';

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey, width: 1.0),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  imageUrl3,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return const Center(
                      child: Text('Error loading image'),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                left: 8,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {  onSelectCategory(event);
                  },
                  child: Container(
                    height: 30,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey, width: 1.0),
                    ),
                    child: const Center(
                      child: Text(
                        "View details",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class preveventpage extends StatelessWidget {
  final String? token;
  final Event event;

  preveventpage({required this.event, required this.token});

  @override
  Widget build(BuildContext context) {
    String imagePath3 = event.imagelink.split('\\pictures\\').last;
    String encodedImagePath3 = Uri.encodeFull(imagePath3);
    String imageUrl3 = 'http://192.168.43.197:3000/images/$encodedImagePath3';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl3),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 35),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                event.name,
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                event.location,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "About",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 25),
              child: Text(
                event.about,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color:  Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(Icons.location_on_outlined),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(event.location,  ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(Icons.access_time_sharp),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(event.time,),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(Icons.money_sharp),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(event.money, ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color:  Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(Icons.calendar_month_outlined),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              event.date,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 80,
          width: double.infinity,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 250,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegForm(
                          token: token,
                          event: event,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shadowColor: Colors.grey,
                    primary: const Color(0xFFd66d67),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Register now',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}


class seeallPage extends StatefulWidget {
  final String? token;
  const seeallPage({@required this.token, Key? key}) : super(key: key);
  @override
  _seeallPagePageState createState() => _seeallPagePageState();
}                                        //see all previous events
class _seeallPagePageState extends State<seeallPage> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    fetchAllPreviousEvents();
  }

  Future<void> fetchAllPreviousEvents() async {
    try {
      final response = await http.get(Uri.parse(allprevevents));

      if (response.statusCode == 200) {
        // Handle the response data
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          // Clear the existing events and add the new ones
          events.clear();
          events.addAll(responseData.map((data) {
            return Event(
              name: data['eventName'] ?? '',
              categoryName: data['categoryName'] ?? '',
              about: data['about'] ?? '',
              location: data['location'] ?? '',
              time: data['time'] ?? '',
              money: data['money'] ?? '',
              date: data['date'] ?? '',
              rating: (data['rating'] ?? 0).toDouble(),
              imagelink: data['imagePath'] ?? '',

            );
          }));
        });
      } else {
        print('Error fetching all previous events: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching all previous events: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 10,),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 40),
                const Text(
                  "All Events",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return preveventCard(
                    event: events[index], token: widget.token,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class preveventCard extends StatelessWidget {
  final String? token;
  final Event event;

  preveventCard({required this.event, required this.token,});

  @override
  Widget build(BuildContext context) {
    String imagePath3 = event.imagelink.split('\\pictures\\').last;
    String encodedImagePath3 = Uri.encodeFull(imagePath3);
    String imageUrl3 = 'http://192.168.43.197:3000/images/$encodedImagePath3';

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey, width: 1.0),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  imageUrl3,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return const Center(
                      child: Text('Error loading image'),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                left: 8,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => detailpage(event: event, token: token),
                      ),
                    );
                  },
                  child: Container(
                    height: 30,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey, width: 1.0),
                    ),
                    child: const Center(
                      child: Text(
                        "View details",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class detailpage extends StatelessWidget {
  final String? token;
  final Event event;

  detailpage({required this.event, required this.token,});

  @override
  Widget build(BuildContext context) {
    String imagePath = event.imagelink.split('\\pictures\\').last;
    String encodedImagePath = Uri.encodeFull(imagePath);
    String imageUrl = 'http://192.168.43.197:3000/images/$encodedImagePath';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 35),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                event.name,
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                event.location,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "About",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 25),
              child: Text(
                event.about,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color:  Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(Icons.location_on_outlined),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(event.location),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color:  Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(Icons.access_time_sharp),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(event.time),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.calendar_month_outlined),
                      Padding(
                        padding: const EdgeInsets.only(right: 55),
                        child: Text(event.date),
                      )
                    ],
                  )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 80,
          width: double.infinity,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 250,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventReview(token: token, eventName:  event.name),
                      ),
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shadowColor: Colors.grey,
                    primary: const Color(0xFFd66d67),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Reviews',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10)
            ],
          ),
        ),
      ),
    );
  }
}


class seeallPageupcoming extends StatefulWidget {
  final String? token;
  seeallPageupcoming({required this.token});
  @override
  _seeallPageupcomingState createState() => _seeallPageupcomingState();
}                             //see all upcoming event page
class _seeallPageupcomingState extends State<seeallPageupcoming> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    fetchAllupcomingEvents();
  }

  Future<void> fetchAllupcomingEvents() async {
    try {
      final response = await http.get(Uri.parse(allupcomingevents));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          events.clear();
          events.addAll(responseData.map((data) {
            return Event(
              name: data['name'] ?? '',
              categoryName: data['categoryName'] ?? '',
              about: data['about'] ?? '',
              location: data['location'] ?? '',
              time: data['time'] ?? '',
              money: data['money'] ?? '',
              date: data['date'] ?? '',
              rating: (data['rating'] ?? 0).toDouble(),
              imagelink: data['imagePath'] ?? '',
            );
          }));
        });
      } else {
        print('Error fetching all upcoming events: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching all upcoming events: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top:30.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 40),
                const Text(
                  "All Events",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return upcomingeventCard(
                    event: events[index],
                    token: widget.token,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class upcomingeventCard extends StatelessWidget {
  final String? token;
  final Event event;

  upcomingeventCard({required this.event, required this.token});

  @override
  Widget build(BuildContext context) {
    String imagePath = event.imagelink.split('\\pictures\\').last;
    String encodedImagePath = Uri.encodeFull(imagePath);
    String imageUrl = 'http://192.168.43.197:3000/images/$encodedImagePath';

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.white,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                return const Center(
                  child: Text('Error loading image'),
                );
              },
            ),
            Positioned(
              top: 10,
              left: 8,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => preveventpage(event: event, token: token),
                    ),
                  );
                },
                child: Container(
                  height: 30,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "View details",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class RegForm extends StatefulWidget {
  final String? token;
  final Event event;

  const RegForm({required this.token, required this.event, Key? key}) : super(key: key);

  @override
  _RegFormState createState() => _RegFormState();
}
class _RegFormState extends State<RegForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactNoController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  String? gender;
  late String userId;

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    userId = jwtDecodedToken['_id'];// Initialize the userProfile
  }

  Future<void> saveEmailToPreferences(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }

  void eventinfo() async {
    try {
      if (_formKey.currentState!.validate()) {
        final prefs = await SharedPreferences.getInstance();
        String? selectedEventName = prefs.getString('selectedEventName');

        var regBody = {
          "userId": userId,
          "eventname": widget.event.name,
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "email": emailController.text,
          "contactNo": contactNoController.text,
          "gender": gender,
          "city": cityController.text,
          "address": addressController.text,
          "postalCode": postalCodeController.text,
          "transport": transportValue,
        };

        print('UserId: ${regBody["userId"]}');
        print('Event Name: ${regBody["eventname"]}');
        print('First Name: ${regBody["firstName"]}');
        print('Last Name: ${regBody["lastName"]}');
        print('Email: ${regBody["email"]}');
        print('Contact No: ${regBody["contactNo"]}');
        print('Gender: ${regBody["gender"]}');
        print('City: ${regBody["city"]}');
        print('Address: ${regBody["address"]}');
        print('Postal Code: ${regBody["postalCode"]}');
        print('transport service: ${regBody["transport"]}');

        var response = await http.post(
          Uri.parse(registereventinfo),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        if (response.statusCode == 200) {
          await saveEmailToPreferences(emailController.text);
          Navigator.pop(context);
          print("Registration successful");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(event: widget.event, transportValue: transportValue),
            ),
          );

        } else {
          print("Registration failed with status code: ${response.statusCode}");
          print("Response body: ${response.body}");
          // Handle registration failure
        }
      }
    } catch (e) {
      print("Error: $e");
      // Handle registration error
    }
  }
  bool transportValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only( right: 4.0),
            child: ListView(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,),
                      color: const Color(0xFF273236),
                      iconSize: 25,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      "REGISTRATION FORM",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Fill the form to register yourself in the event",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20),
                Row(
                  children:[
                    Expanded(
                      child: Container(
                        height: 60,
                        child: TextFormField(
                          controller: firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            labelStyle: TextStyle(color: Colors.black),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            contentPadding: EdgeInsets.all(15),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your First Name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 60,
                        child: TextFormField(
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: TextStyle(color: Colors.black),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            contentPadding: EdgeInsets.all(15),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your Last Name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      contentPadding: EdgeInsets.all(15),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email ';
                      }
                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                          .hasMatch(value)) {
                        return 'Invalid email address';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: contactNoController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact No',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      contentPadding: EdgeInsets.all(15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty || value.length != 11) {
                        return 'Please enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: buildGenderRadio(),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      contentPadding: EdgeInsets.all(15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your City';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      contentPadding: EdgeInsets.all(15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your Address';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: postalCodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      contentPadding: EdgeInsets.all(15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your Postal Code';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left:3.0),
                  child: Container(
                    height: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left:4.0),
                          child: Text(
                            'Do You Want Our Transportation Service? (charges will be applied)',
                            style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w300),
                          ),
                        ),
                        Container(
                          height:5
                        ),
                        Row(
                          children: [
                            Radio(
                              value: true,
                              groupValue: transportValue,
                              onChanged: (value) {
                                setState(() {
                                  transportValue = value as bool;
                                  print('Transport value set to: $transportValue');
                                });
                              },
                            ),
                            Text('Yes'),
                            Radio(
                              value: false,
                              groupValue: transportValue,
                              onChanged: (value) {
                                setState(() {
                                  transportValue = value as bool;
                                  print('Transport value set to: $transportValue');
                                });
                              },
                            ),
                            Text('No'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        eventinfo();
                        print("submitted");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shadowColor: Color(0xFFd66d67),
                      primary:  Color(0xFFd66d67),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGenderRadio() {
    return Row(
      children: [
        const Text('Gender:', style: TextStyle(fontSize: 16, color: Colors.black)),
        const SizedBox(width: 10),
        Radio<String>(
          value: 'male',
          groupValue: gender,
          onChanged: (value) {
            setState(() {
              gender = value;
            });
          },
        ),
        const Text('Male'),
        const SizedBox(width: 20),
        Radio<String>(
          value: 'female',
          groupValue: gender,
          onChanged: (value) {
            setState(() {
              gender = value;
            });
          },
        ),
        const Text('Female'),
      ],
    );
  }
}






class AddCardDetailsPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 40),
                const Text(
                  "Add Card Details",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 25.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Name on Card",
                    style: TextStyle(fontSize: 20), // Increase the text size
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "Enter Name",
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    "Credit Card Number",
                    style: TextStyle(fontSize: 20), // Increase the text size
                  ),
                  TextField(
                    controller: cardNumberController,
                    decoration: const InputDecoration(
                      hintText: "Enter Card Number",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      _CreditCardNumberFormatter(),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Expiry",
                              style: TextStyle(fontSize: 20), // Increase the text size
                            ),
                            TextField(
                              controller: expiryController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _ExpiryDateFormatter(),
                              ],
                              decoration: const InputDecoration(
                                hintText: "MM/YYYY",
                              ),
                            ),

                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "CVV",
                              style: TextStyle(fontSize: 20), // Increase the text size
                            ),
                            TextField(
                              controller: cvvController,
                              decoration: const InputDecoration(
                                hintText: "Enter CVV",
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, left: 10,right: 10),
        child: Container(
          height: 60,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: ElevatedButton(
            onPressed: () {
              String cardNumber = cardNumberController.text;
              if (cardNumber.isNotEmpty && cardNumber.length >= 16) {
                Navigator.pop(context, cardNumber);
              } else {
                // Show an error message or handle invalid card number
              }
            },
            style: ElevatedButton.styleFrom(
              primary:  Colors.black, // Set the button background color
              onPrimary: Colors.white, // Set the text color
              elevation: 1, // Set the elevation
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0), // Set the button border radius
                side: const BorderSide(color: Colors.black, width: 1.0), // Set the border color and width
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0), // Set the horizontal padding
            ),
            child: const Text(
              "Add",
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}


class PaymentPage extends StatefulWidget {
  final bool transportValue;
  final Event event;

  PaymentPage({required this.event, required this.transportValue});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<String> cards = [];
  int selectedCardIndex = -1; // Initialize to -1 to indicate no card is selected
  late double amount;
  late double totalAmount;

  @override
  void initState() {
    super.initState();
    setAmountBasedOnTransport();
  }

  void setAmountBasedOnTransport() {
    if (widget.transportValue) {
      amount = 150.0;
    } else {
      amount = 0.0;
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

  void sendMail(String recipientEmail) async {
    String username = 'neeham657@gmail.com';
    String appPassword = 'ihlspydujymmcztx';

    final smtpServer = gmail(username, appPassword);

    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientEmail)
      ..subject = 'Payment Confirmation'
      ..text = 'Your payment has been processed successfully. ';

    try {
      await send(message, smtpServer);
      showSnackbar('Email sent successfully');
    } catch (e) {
      showSnackbar('Failed to send email');
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<String?> getEmailFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  @override
  Widget build(BuildContext context) {
    late double money = double.parse(widget.event.money);
    double totalAmount = money + amount;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 18, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 50),
                const Text(
                  "Payment",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Amount you are about to pay includes:",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Event registration fees + Transportation fees = Total amount",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                "Rs ${widget.event.money} + $amount = $totalAmount",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Choose your desired card to proceed with the payment",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCardIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedCardIndex == index ? Colors.grey : Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      leading: Image.asset(
                        'card.png',
                        width: 40,
                        height: 40,
                      ),
                      title: Text(_obfuscateCardNumber(cards[index]), style: const TextStyle(color: Colors.black)),
                      selected: selectedCardIndex == index,
                      onTap: () {
                        setState(() {
                          selectedCardIndex = index;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: SizedBox(
                height: 200.0,
                child: Container(color: Colors.transparent),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    final newCardNumber = await showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return AddCardDetailsPage();
                      },
                    );
                    if (newCardNumber != null) {
                      setState(() {
                        cards.add(newCardNumber);
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.7),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    height: 60,
                    child: const ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                      leading: Icon(Icons.add, size: 32),
                      title: Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Add Card",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      dense: true,
                      minVerticalPadding: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 60,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedCardIndex == -1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a card before proceeding.'),
                          ),
                        );
                      } else {
                        String? email = await getEmailFromPreferences();
                        if (email != null) {
                          sendMail(email);
                        } else {
                          showSnackbar('Email not found.');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: const BorderSide(color: Colors.black, width: 1.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    child: const Text(
                      "Proceed",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _obfuscateCardNumber(String cardNumber) {
    if (cardNumber.length >= 16) {
      return "**** **** **** ${cardNumber.substring(12)}";
    }
    return cardNumber;
  }
}



class _CreditCardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();

    if (newTextLength >= 4) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 4) + '-');
      if (newValue.selection.end >= 4) selectionIndex++;
    }
    if (newTextLength >= 8) {
      newText.write(newValue.text.substring(4, usedSubstringIndex = 8) + '-');
      if (newValue.selection.end >= 8) selectionIndex++;
    }
    if (newTextLength >= 12) {
      newText.write(newValue.text.substring(8, usedSubstringIndex = 12) + '-');
      if (newValue.selection.end >= 12) selectionIndex++;
    }
    if (newTextLength >= 16) {
      newText.write(newValue.text.substring(12, usedSubstringIndex = 16));
      if (newValue.selection.end >= 16) selectionIndex++;
    }

    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = StringBuffer();

    // Ensure only digits are kept in the text
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Format the text as MM/YYYY
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 && digits.length > 2) {
        newText.write('/');
      }
      if (i < 2) {
        newText.write(digits[i]);
      }
    }

    // If the year part is present, limit it to 2 digits
    if (digits.length > 2) {
      newText.write(digits.substring(2, 4));
    }

    // Limit the text to 5 characters (MM/YYYY)
    if (newText.length > 5) {
      return oldValue;
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

