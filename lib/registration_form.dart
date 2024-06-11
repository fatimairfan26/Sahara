import 'package:flutter/material.dart';
import 'package:fyp/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Registration Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegForm(),
    );
  }
}

class RegForm extends StatefulWidget {
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
  bool transportationService = false;
  String? gender;

  void eventinfo() async {
    try {
      if (_formKey.currentState!.validate()) {
        var regBody = {
          "userId": "65903ca9649c0b9322b9294c",
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "email": emailController.text,
          "contactNo": contactNoController.text,
          "gender": gender,
          "city": cityController.text,
          "address": addressController.text,
          "postalCode": postalCodeController.text,
        };

        var response = await http.post(
          Uri.parse(registereventinfo),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        if (response.statusCode == 200) {
          print("Registration successful");
          // Handle successful registration
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 4.0),
            child: ListView(
              children: [
                SizedBox(height: 30),
                Text(
                  "REGISTRATION FORM",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 14),
                Text(
                  "Fill the form to register yourself in the event",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Colors.black45),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 60,
                        child: TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            hintText: 'First Name',
                              labelStyle: TextStyle(color: Color(0xFF1c4837)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF1c4837)),
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
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 60,
                        child: TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            hintText: 'Last Name',
                            labelStyle: TextStyle(color: Color(0xFF1c4837)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF1c4837)),
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
                SizedBox(height: 10),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      labelStyle: TextStyle(color: Color(0xFF1c4837)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1c4837)),
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
                SizedBox(height: 10),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: contactNoController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Contact No',
                      labelStyle: TextStyle(color: Color(0xFF1c4837)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1c4837)),
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
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: buildGenderRadio(),
                ),
                SizedBox(height: 10),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                      hintText: 'City',
                      labelStyle: TextStyle(color: Color(0xFF1c4837)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1c4837)),
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
                SizedBox(height: 10),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Address',
                      labelStyle: TextStyle(color: Color(0xFF1c4837)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1c4837)),
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
                SizedBox(height: 10),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: postalCodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Postal Code',
                      labelStyle: TextStyle(color: Color(0xFF1c4837)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1c4837)),
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
                SizedBox(height: 50),
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
                      shadowColor: Colors.grey,
                      primary: const Color(0xFFd66d67),
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
        Text('Gender:', style: TextStyle(fontSize: 16)),
        SizedBox(width: 10),
        Radio<String>(
          value: 'male',
          groupValue: gender,
          onChanged: (value) {
            setState(() {
              gender = value;
            });
          },
        ),
        Text('Male'),
        SizedBox(width: 20),
        Radio<String>(
          value: 'female',
          groupValue: gender,
          onChanged: (value) {
            setState(() {
              gender = value;
            });
          },
        ),
        Text('Female'),
      ],
    );
  }
}


