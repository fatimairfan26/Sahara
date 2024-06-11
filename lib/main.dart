import 'package:flutter/material.dart';
import 'package:fyp/loginPage.dart';
import 'package:fyp/navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({Key? key, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          headline1: GoogleFonts.lato(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headline2: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          headline3: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          headline4: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headline5: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headline6: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: TextTheme(
          headline1: GoogleFonts.lato(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headline2: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          headline3: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          headline4: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headline5: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headline6: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
      ),
      themeMode: ThemeMode.system, // Set the default theme mode to system
      debugShowCheckedModeBanner: false,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (token != null && token!.isNotEmpty && !JwtDecoder.isExpired(token!)) {
      return NavBar(token: token!);
    } else {
      return loginPage();
    }
  }
}
