import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp/security.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:fyp/navbar.dart';
import 'config.dart';
import 'transition.dart';

class Personality extends StatefulWidget {
  final  token;
  const Personality({required this.token, Key? key}) : super(key: key);

  @override
  PersonalityState createState() => PersonalityState();
}

class PersonalityState extends State<Personality> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String userId;
  String? selectedReligion;
  String? selectedNationality;
  String? selectedMaritalStatus;
  String? selectedEducation;
  String? selectedHobby;
  String? selectedSmoker;
  var religionController = TextEditingController();
  var nationalityController = TextEditingController();
  var educationController = TextEditingController();
  var hobbiesController = TextEditingController();
  var smokerController = TextEditingController();
  var maritalController = TextEditingController();
  var heightController = TextEditingController();
  var casteController = TextEditingController();
  var cityController = TextEditingController();
  var occupationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
  }

  void addTodo() async {
    try {
      if (religionController.text.isNotEmpty &&
          nationalityController.text.isNotEmpty &&
          educationController.text.isNotEmpty &&
          hobbiesController.text.isNotEmpty &&
          smokerController.text.isNotEmpty &&
          maritalController.text.isNotEmpty &&
          heightController.text.isNotEmpty &&
          casteController.text.isNotEmpty &&
          cityController.text.isNotEmpty &&
          occupationController.text.isNotEmpty) {
        var regbody = {
          "userId": userId,
          "religion": religionController.text,
          "nationality": nationalityController.text,
          "education": educationController.text,
          "hobbies": hobbiesController.text,
          "smoker": smokerController.text,
          "marital_status": maritalController.text,
          "height": heightController.text,
          "caste": casteController.text,
          "city": cityController.text,
          "occupation": occupationController.text,
        };
        var response = await http.post(
          Uri.parse(pop),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regbody),
        );

        if (response.statusCode == 200) {
          print("Registration successful");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UploadPage(token: widget.token),
            ),
          );
        } else {
          print("Registration failed with status code: ${response.statusCode}");
          print("Response body: ${response.body}");
        }
      } else {
        print("Fields are required.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      Text(
                        userId,
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        "Personality of Partner",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Help us find the best match for "YOU"',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ],
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomDropdown(
                                    label: 'Religion',
                                    value: selectedReligion,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedReligion = newValue;
                                        religionController.text = newValue ?? '';
                                      });
                                    },
                                    items: [
                                      'Islam',
                                      'Christianity',
                                      'Hinduism',
                                      'Buddhism',
                                      'Sikhism',
                                      'Jews',
                                      'Others',
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0),
                                      color: Colors.grey[200],
                                    ),
                                    child: TextField(
                                      controller: casteController,
                                      decoration: const InputDecoration(
                                        labelText: 'Caste',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(12.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomDropdown(
                                    label: 'Nationality',
                                    value: selectedNationality,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedNationality = newValue;
                                        nationalityController.text = newValue ?? '';
                                      });
                                    },
                                    items: [
                                      'Pakistan',
                                      'USA',
                                      'UK',
                                      'Canada',
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0),
                                      color: Colors.grey[200],
                                    ),
                                    child: TextField(
                                      controller: cityController,
                                      decoration: const InputDecoration(
                                        labelText: 'City',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(12.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.grey[200],
                          ),
                          child: TextField(
                            controller: heightController,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              hintText: 'Height in feet',
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.all(12.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  CustomDropdown(
                                    label: 'Marital Status',
                                    value: selectedMaritalStatus,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedMaritalStatus = newValue;
                                        maritalController.text = newValue ?? '';
                                      });
                                    },
                                    items: [
                                      'Single',
                                      'Divorcee',
                                      'Married',
                                      'Widow',
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                children: [
                                  CustomDropdown(
                                    label: 'Education',
                                    value: selectedEducation,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedEducation = newValue;
                                        educationController.text = newValue ?? '';
                                      });
                                    },
                                    items: [
                                      'Matric',
                                      'Intermediate',
                                      'Undergraduate',
                                      'Graduate',
                                      'Ph.D',
                                      'Other',
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.grey[200],
                          ),
                          child: TextField(
                            controller: occupationController,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              hintText: 'Occupation',
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.all(12.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomDropdown(
                                    label: 'Hobbies',
                                    value: selectedHobby,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedHobby = newValue;
                                        hobbiesController.text = newValue ?? '';
                                      });
                                    },
                                    items: [
                                      'Gardening',
                                      'Listening Music',
                                      'Stamp Collections',
                                      'Travelling',
                                      'Painting',
                                      'Volunteer Work',
                                      'Cooking',
                                      'Baking',
                                      'Meeting New People',
                                      'Puzzles',
                                      'Reading',
                                      'Others',
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                children: [
                                  CustomDropdown(
                                    label: 'Smoker or Non-Smoker',
                                    value: selectedSmoker,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedSmoker = newValue;
                                        smokerController.text = newValue ?? '';
                                      });
                                    },
                                    items: [
                                      'Smoker',
                                      'Non-Smoker',
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 25),
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 65,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  addTodo();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFd66d67),
                                padding: const EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Submit',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
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
      backgroundColor: Colors.white,
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey[200],
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            underline: SizedBox(),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
