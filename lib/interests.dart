import 'package:flutter/material.dart';
import 'package:fyp/aboutme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'package:fyp/personality.dart';
import 'package:fyp/transition.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class interests extends StatefulWidget {
  final String? token;

  const interests({required this.token, Key? key}) : super(key: key);

  @override
  _InterestsState createState() => _InterestsState();
}

class _InterestsState extends State<interests> {
  int currentStep = 13;
  final totalSteps = 14;
  Map<String, List<String>> categorySelections = {
    'Interests': [],
    'Community': [],
    'Food & Drinks': [],
    'Outdoor Activities': [],
    'Sports': [],
    'Technology': [],
  };

  Map<String, List<String>> categoryItems = {
    'Interests': [
      "Acting", "Art Galleries", "Board Games", "Creative writing", "Design", "DIY", "Fashion",
      "Film & Cinema", "Filmmaking", "Knitting", "Learning languages", "Live music", "Photography", "Painting", "Reading",
      "Playing music", "Pottery", "Travel", "Standup Comedy", "TV shows", "Theatre", "Sewing", "Museums",
    ],
    'Community': ["Family time", "Activism", "Politics", "Volunteering", "Spending Time with friends"],
    'Food & Drinks': [
      "Baking", "Bubble Tea", "Cake decorating", "Chocolate", "Coffee", "Eating out", "Takeaway",
      "Fish&chips", "Junk food", "Cold drinks", "Vegetarian", "Sushi", "Chinese", "Vegan", "Pizza", "Bbq", "Meat lover", "Eating healthy",
      "Cooking",
    ],
    'Outdoor Activities': ["Bird watching", "Star gazing", "Gardening", "Hiking", "Fishing", "sunrise viewing", "Scuba diving", "Camping", "sunset viewing"],
    'Sports': [
      "Dancing", "Rowing", "Cycling", "Sailing", "Skiing", "Soccer", "Tennis", "Surfing", "Yoga", "Running",
      "Volleyball", "Rugby", "Running", "Pilates", "Golf", "Ice Hockey", "Gym", "Fencing", "Rock Climbing", "Cricket",
      "Baseball", "Badminton", "Boxing",
    ],
    'Technology': ["Animation", "Coding", "Blogging", "Tech", "Content Creation", "Digital art", "Video games"],
  };

  late String userId;

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    userId = jwtDecodedToken['_id']; // Initialize the userProfile
  }

  void storeInterest() async {
    try {
      if (widget.token == null) {
        return;
      }

      List<String> allInterests = [];
      categorySelections.forEach((category, selections) {
        allInterests.addAll(selections ?? []);
      });

      var regBody = {
        "userId": userId,
        "interests": allInterests,
      };


      print("Request Body: $regBody");

      var response = await http.post(
        Uri.parse(storeinterests),
        headers: {
          "Content-Type": "application/json",
          // Add any other required headers here
        },
        body: jsonEncode(regBody),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("Information stored successfully");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Personality(token: widget.token,),
          ),
        );
      } else {
        print("Registration failed with status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          PageTransition.navigateToPageRight(
                            context,
                            educational(
                              token: widget.token ?? '',
                              userProfile: UserProfile(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back_ios_sharp),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3, right: 40),
                            child: Text('Step $currentStep of $totalSteps'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 7, top: 5),
                    child: const Text(
                      'Interests & Hobbies',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF273236),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 640,
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: <Widget>[
                      const Text(
                        "Select 15 interest for better profile matching experience",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      for (var category in categoryItems.keys) buildCategoryChips(category),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        storeInterest();
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
                        'Continue',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
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

  Widget buildCategoryChips(String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20),
        Text(
          category,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 8.0,
          children: categoryItems[category]?.map((item) {
            final isSelected = categorySelections[category]?.contains(item) == true;
            return ChoiceChip(
              label: Text(
                item,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.black,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => _handleCategorySelection(category, item),
              elevation: isSelected ? 0 : 2,
              backgroundColor: isSelected ? Colors.black : Colors.transparent,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Colors.black, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          })?.toList() ?? [],
        ),
      ],
    );
  }

  void _handleCategorySelection(String category, String item) {
    setState(() {
      if (categorySelections[category]?.contains(item) == true) {
        categorySelections[category]?.remove(item);
      } else {
        if (totalSelectedItems() < 15) {
          categorySelections[category]?.add(item);
        } else {
          // Handle the case where the user tries to select more than 15 items
        }
      }
    });
  }

  int totalSelectedItems() {
    int total = 0;
    categorySelections.forEach((category, selections) {
      total += selections?.length ?? 0;
    });
    return total;
  }
}
