import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/config.dart';
import 'package:fyp/forgetpassword.dart';
import 'package:fyp/signuppage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'aboutme.dart';
import 'personality.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({Key? key});

  @override
  State<loginscreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<loginscreen> {
  TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var Email = TextEditingController();
  late SharedPreferences prefs;
  String errorMessage = '';

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginuser() async {
    await initSharedPreferences();

    if (Email.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var reqbody = {
        "email": Email.text,
        "password": passwordController.text,
      };
      var response = await http.post(
        Uri.parse(login2),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqbody),
      );
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        var mytoken = jsonResponse['token'];
        prefs.setString('token', mytoken);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GenderPage(token: mytoken),
          ),
        );

      } else {
        errorMessage = "User not found";
        print(errorMessage);
      }
    }

    setState(() {});
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/login.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "Login your account",
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
                            borderSide: BorderSide(color: Color(0xFFd66d67)),
                          ),
                          contentPadding: EdgeInsets.only(top: 15),
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
                      const SizedBox(
                        height: 20,
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
                            borderSide: BorderSide(color: Color(0xFFd66d67)),
                          ),
                          contentPadding: const EdgeInsets.only(top: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgetPassword(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              loginuser();
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
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 18),
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
                              "Or login with",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
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
                                primary: Colors.grey[300],
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(
                              height: 20,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => signuppage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(color: Colors.deepOrange),
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}