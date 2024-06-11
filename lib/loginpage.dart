import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/config.dart';
import 'package:fyp/extra.dart';
import 'package:fyp/forgetpassword.dart';
import 'package:fyp/signuppage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'navbar.dart';
class loginPage extends StatefulWidget {
  const loginPage({Key? key});

  @override
  State<loginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<loginPage> {
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
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqbody),
      );

      try {
        var jsonResponse = jsonDecode(response.body);
        print(jsonResponse); // Print the response for debugging

        if (response.statusCode == 200) {
          var mytoken = jsonResponse['token'];
          prefs.setString('token', mytoken);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NavBar(token: mytoken),
            ),
          );
        } else {
          if (jsonResponse.containsKey('message')) {
            var message = jsonResponse['message'];
            if (message != null) {
              if (message.contains('under review')) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Profile Under Review'),
                      content: Text('Your profile is under review. Please wait for approval.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                errorMessage = message;
                print(errorMessage);
              }
            } else {
              errorMessage = "Unknown error occurred";
              print(errorMessage);
            }
          } else {
            errorMessage = "User not found";
            print(errorMessage);
          }
        }
      } catch (e) {
        // Handle parsing errors
        print("Error parsing JSON response: $e");
        errorMessage = "Your profile is under review. Please wait for approval. ";
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                  ],
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
                        style: TextStyle(color: Colors.black), // Set the text color to black
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintText: 'Email address',
                          hintStyle: TextStyle(color: Colors.black), // Set the hint text color to black
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(right: 18),
                            child: Icon(
                              Icons.email,
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color:  Colors.black),
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
                        style: TextStyle(color: Colors.black),
                        controller: passwordController,
                        obscureText: !passwordVisible,
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color:  Colors.black),
                          ),
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.black),
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
                            borderSide: BorderSide(color:  Colors.black),
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
                            style: Theme.of(context).textTheme.headline2!.copyWith(color: Colors.black),
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
                              if (Email.text == 'adminmaheen@gmail.com' &&
                                  passwordController.text == 'admin') {
                                print("admin welcome");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => MyHomePage())
                                );
                              } else {
                                loginuser();
                              }
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