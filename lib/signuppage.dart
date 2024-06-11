import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp/login.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class signuppage extends StatefulWidget {
  const signuppage({Key? key});

  @override
  State<signuppage> createState() => _SignupPageState();
}

class _SignupPageState extends State<signuppage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var userName = TextEditingController();
  var Email = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;
  TextEditingController confirmPasswordController = TextEditingController();
  bool confirmPasswordVisible = false;

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least 1 special character';
    }

    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  void registeruser() async {
    try {
      if (Email.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          userName.text.isNotEmpty &&
          _formKey.currentState!.validate()) {
        var regbody = {
          "username": userName.text,
          "email": Email.text,
          "password": passwordController.text,
        };
        var response = await http.post(
          Uri.parse(registration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regbody),
        );

        if (response.statusCode == 200) {
          print("Registration successful");
          final token = json.decode(response.body)['token'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => loginscreen(),
            ),
          );
        } else if (response.statusCode == 409) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Username or email already exists"),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          print("Registration failed with status code: ${response.statusCode}");
          print("Response body: ${response.body}");
        }
      } else {
        print("Email and Password are required.");
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
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/signup.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "Sign Up",
                  style: Theme.of(context).textTheme.headline1,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(
                  height: 20,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: userName,
                        decoration: const InputDecoration(
                          hintText: 'User Name',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(right: 18),
                            child: Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Color(0xFFd66d67)),
                          ),
                          contentPadding: EdgeInsets.only(top: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your user name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: Email,
                        decoration: const InputDecoration(
                          hintText: 'Email address',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(right: 18),
                            child: Icon(
                              Icons.email,
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Color(0xFF1c4837)),
                          ),
                          contentPadding: EdgeInsets.only(top: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                              r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                              .hasMatch(value)) {
                            return 'Invalid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !passwordVisible,
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(right: 18),
                            child: Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Color(0xFF1c4837)),
                          ),
                          contentPadding: const EdgeInsets.only(top: 20),
                        ),
                        validator: validatePassword,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: !confirmPasswordVisible,
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(right: 18),
                            child: Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: IconButton(
                              icon: Icon(
                                confirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  confirmPasswordVisible =
                                  !confirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Color(0xFF1c4837)),
                          ),
                          contentPadding: const EdgeInsets.only(top: 20),
                        ),
                        validator: (value) => validateConfirmPassword(
                            value, passwordController.text),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              registeruser();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            shadowColor: Colors.grey,
                            backgroundColor: const Color(0xFFd66d67),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Signup',
                            style: TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: 130,
                              child: Divider(
                                thickness: 0.8,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "Or signup with",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              width: 130,
                              child: Divider(
                                thickness: 0.8,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                // Add your onPressed logic here
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 3,
                                shadowColor: Colors.grey,
                                primary: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Image.asset(
                                'assets/google.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                elevation: 3,
                                shadowColor: Colors.grey,
                                backgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Image.asset(
                                'assets/facebook.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Have an account? ",
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(
                            height: 20,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => loginscreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(color: Colors.deepOrange),
                              ),
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
        ),
      ),
    );
  }
}