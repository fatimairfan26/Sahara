import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:fyp/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'loginPage.dart';

class ForgetPassword extends StatefulWidget {
  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}
class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _recipientEmailController =
  TextEditingController();
  int randomCode = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  void _loadSavedEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedEmail = prefs.getString('savedEmail') ?? '';
    setState(() {
      _recipientEmailController.text = savedEmail;
    });
  }

  void _saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedEmail', email);
    print(email);
  }

  void sendMail({required String recipientEmail}) async {
    String username = 'neeham657@gmail.com';
    String appPassword = 'ihlspydujymmcztx';

    final smtpServer = gmail(username, appPassword);

    setState(() {
      randomCode = Random().nextInt(9000) + 1000;
    });

    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientEmail)
      ..subject = 'Mail '
      ..text = 'Random Code: $randomCode';

    try {
      await send(message, smtpServer);
      _saveEmail(recipientEmail);
      showSnackbar('Email sent successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Page2(randomCode: randomCode),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
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
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/forgetpass.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Text(
                      'Forgot Password',
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(color: Colors.black),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Enter the email address associated with your account.',
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(color: Colors.black),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      style: TextStyle(color: Colors.black),
                      controller: _recipientEmailController,
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1c4837)),
                        ),
                        hintText: 'Email address',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 18),
                          child: Icon(
                            Icons.email,
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1c4837)),
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
                      height: 45,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            sendMail(
                              recipientEmail: _recipientEmailController.text,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          shadowColor: Colors.grey,
                          primary: const Color(0xFF1c4837),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class Page2 extends StatefulWidget {
  final int randomCode;

  Page2({required this.randomCode});

  @override
  State<Page2> createState() => _Page2State();
}
class _Page2State extends State<Page2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var Code1 = TextEditingController();
  var Code2 = TextEditingController();
  var Code3 = TextEditingController();
  var Code4 = TextEditingController();
  late int storedRandomCode;

  @override
  void initState() {
    super.initState();
    storedRandomCode = widget.randomCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Verification code",
                    style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.black),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "We have sent verification code on",
                    style: Theme.of(context).textTheme.headline2!.copyWith(color: Colors.black),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    "${widget.randomCode}@gmail.com", // Replace with actual email
                    style: Theme.of(context).textTheme.headline2!.copyWith(color: Colors.black),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildCodeTextField(Code1),
                        buildCodeTextField(Code2),
                        buildCodeTextField(Code3),
                        buildCodeTextField(Code4),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (compareCodes()) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Page3(),
                              ),
                            );
                          } else {
                            showSnackbar("Incorrect verification code");
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        shadowColor: Colors.grey,
                        primary: const Color(0xFF1c4837),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  Widget buildCodeTextField(TextEditingController controller) {
    return SizedBox(
      height: 68,
      width: 64,
      child: TextFormField(
        style: TextStyle(color: Colors.black),
        controller: controller,
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF1c4837),
              width: 2,
            ),
          ),
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '';
          }
          return null;
        },
      ),
    );
  }

  bool compareCodes() {
    String enteredCode =
        "${Code1.text}${Code2.text}${Code3.text}${Code4.text}";
    return int.parse(enteredCode) == storedRandomCode;
  }
}

class Page3 extends StatefulWidget {
  @override
  State<Page3> createState() => _Page3State();
}
class _Page3State extends State<Page3> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var Password1 = TextEditingController();
  var Password2 = TextEditingController();
  late SharedPreferences prefs; // Add this line
  String email2 = '';

  @override
  void initState() {
    super.initState();
    init(); // Call the init method
  }

  Future<void> init() async {
    await initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    email2= prefs.getString('savedEmail') ?? '';
    print('Email from SharedPreferences: $email2');
  }


  Future<void> updatePassword(String email) async {
    if (Password1.text.isNotEmpty && Password2.text.isNotEmpty) {
      print('Email: $email2'); // Print email before creating request body

      var reqbody = {
        "email": email2,
        "newPassword": Password1.text,
      };

      try {
        var response = await http.post(
          Uri.parse(updatePasswordapi),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqbody),
        );
        if (response.statusCode == 200) {
          print('Password updated successfully');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => loginPage(),
            ),
          );
        } else {
          print('Failed to update password. Status code: ${response.statusCode}');
        }
      } catch (e) {
        // Handle network or other errors
        print('Error updating password: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create new password",
                    style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.black),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Please enter your new password",
                    style: Theme.of(context).textTheme.headline2!.copyWith(color: Colors.black),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.black),
                    controller: Password1,
                    obscureText: true,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFd66d67)),
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
                          icon: const Icon(Icons.remove_red_eye),
                          color: Colors.grey,
                          onPressed: () {},
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
                    height: 20,
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.black),
                    controller: Password2,
                    obscureText: true,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFd66d67)),
                      ),
                      hintText: 'Confirm Password',
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
                          icon: const Icon(Icons.remove_red_eye),
                          color: Colors.grey,
                          onPressed: () {},
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
                      if (value != Password1.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await updatePassword(prefs.getString('email') ?? '');
                          } catch (e) {
                            print('Error calling updatePassword: $e');
                            // Handle the error as needed
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
                        'Send',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
