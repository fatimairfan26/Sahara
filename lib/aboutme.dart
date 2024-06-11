// import 'dart:html';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fyp/config.dart';
import 'dart:convert';
import 'package:fyp/interests.dart';
import 'loginPage.dart';
import 'transition.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class UserProfile {
  String selectedDisability = '';
  String selectedEducationBackground = '';
  String selectedMaritalStatus = '';
  String selectedNationality = '';
  String selectedReligion = '';
  String selectedOccupation = '';
  String selectedCity = '';
  String selectedGender = '';
  String selectedHeight = '';
  String selectedDob = '';
  String bio= '';

}


class GenderPage extends StatefulWidget {
  final String token;
  const GenderPage({required this.token, Key? key}) : super(key: key);

  @override
  _GenderPageState createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  int currentStep = 1;
  late String userid;
  bool isTapped1 = false;
  bool isTapped2 = false;
  final totalSteps = 14;
  late UserProfile userProfile;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
    userid = jwtDecodedToken['_id'];
    userProfile = UserProfile();
  }

  void selectContainer(int containerNumber) {
    setState(() {
      if (containerNumber == 1) {
        isTapped1 = true;
        isTapped2 = false;
      } else if (containerNumber == 2) {
        isTapped1 = false;
        isTapped2 = true;
      }
    });
  }

  void userinfo(BuildContext context, String selectedGender) {
    try {
      if (selectedGender.isNotEmpty) {
        setState(() {
          userProfile.selectedGender = selectedGender;
        });
        print("Selected Gender: $selectedGender");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HeightPage(token: widget.token, userProfile: userProfile),
          ),
        );
      } else {
        setState(() {
          errorMessage = "Please enter the field; it's mandatory";
        });
        print(errorMessage);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 37),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text('Step $currentStep of $totalSteps'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 90),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Which one are you?",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: InkWell(
                        onTap: () {
                          selectContainer(1);
                        },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8E2F2),
                            border: Border.all(
                              color: isTapped1 ? Colors.black : Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/man.png', fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: 5,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: InkWell(
                        onTap: () {
                          selectContainer(2);
                        },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8E2F2),
                            border: Border.all(
                              color: isTapped2 ? Colors.black : Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/woman.png', fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: Text(
                  "To give you a fully customized experience we need to know your gender",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:15.0),
                child: Container(
                  width: double.infinity,
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      userinfo(context, isTapped1 ? 'Male' : isTapped2 ? 'Female' : '');
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
    );
  }
}


class HeightPage extends StatefulWidget {
  final String token;
  final UserProfile userProfile;

  const HeightPage({required this.token, required this.userProfile, Key? key}) : super(key: key);

  @override
  _HeightPageState createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  int currentStep = 2;
  late String userid;
  final totalSteps = 14;
  final int initialIndex = 100;
  String selectedHeight = '';
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
    userid = jwtDecodedToken['_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                        PageTransition.navigateToPageLeft(
                          context,
                          GenderPage(token: widget.token),
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
              const SizedBox(height: 90),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select your height",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 400,
                    child: ListWheelScrollView.useDelegate(
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      itemExtent: 50,
                      controller: FixedExtentScrollController(initialItem: initialIndex),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 250,
                        builder: (BuildContext context, int index) {
                          return Ft(
                            feets: index,
                          );
                        },
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedHeight = index.toString();
                          errorMessage = '';
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Container(
                    width: 70,
                    height: 200, // Set a height to limit vertical space
                    child: ListWheelScrollView.useDelegate(
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      itemExtent: 50,
                      controller: FixedExtentScrollController(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 2,
                        builder: (BuildContext context, int index) {
                          if (index == 0) {
                            return measurement(
                              isItcm: true,
                            );
                          } else {
                            return measurement(
                              isItcm: false,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedHeight.isNotEmpty) {
                        widget.userProfile.selectedHeight = selectedHeight;
                        print("Selected Height: ${widget.userProfile.selectedHeight}");

                        PageTransition.navigateToPageRight(
                          context,
                          DobPage(token: widget.token, userProfile: widget.userProfile),
                        );
                      } else {
                        setState(() {
                          errorMessage = "Please select your height; it's mandatory";
                        });
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
    );
  }
}

class Ft extends StatelessWidget {
  final int feets;

  Ft({required this.feets});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          feets.toString(),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class measurement extends StatelessWidget {
  final bool isItcm;

  measurement({required this.isItcm});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          isItcm ? 'Cm' : 'Inch',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}



class DobPage extends StatefulWidget {
  final String token;
  final UserProfile userProfile;
  const DobPage({required this.token, required this.userProfile, Key? key}) : super(key: key);

  @override
  _DobPageState createState() => _DobPageState();
}
class _DobPageState extends State<DobPage> {
  DateTime today = DateTime.now();
  DateTime selectedDay = DateTime.now();
  late String userid;
  DateTime selectedDate = DateTime.now(); // Variable to store the selected date

  void onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      selectedDay = day;
    });
    print('Selected day: $day');

    // Store the selected date in the variable
    selectedDate = day;
  }

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    userid = jwtDecodedToken['_id'];
  }

  late UserProfile userProfile;
  int currentStep = 3;
  final totalSteps = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                        PageTransition.navigateToPageLeft(context, HeightPage(token: widget.token, userProfile: widget.userProfile));
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
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select your Date of Birth",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child:TableCalendar(
                  availableGestures: AvailableGestures.all,
                  rowHeight: 60,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextFormatter: (date, _) {
                      return '${DateFormat.yMMM().format(date)}'; // Displaying month and year
                    },
                    titleTextStyle: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideTextStyle: TextStyle(color: Colors.grey),
                  ),
                  onHeaderTapped: (DateTime focusedDay) async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: focusedDay,
                      firstDate: DateTime(DateTime.now().year - 100),
                      lastDate: DateTime(DateTime.now().year + 100),
                      initialDatePickerMode: DatePickerMode.year,
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDay = pickedDate;
                      });
                    }
                  },
                  selectedDayPredicate: (day) {
                    // Only highlight the selected date
                    return isSameDay(day, selectedDay);
                  },
                  focusedDay: selectedDay,
                  firstDay: DateTime.utc(1900, 10, 16),
                  lastDay: DateTime.now(),
                  onDaySelected: onDaySelected,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Use the selectedDate variable here
                      widget.userProfile.selectedDob = selectedDate.toString();
                      print("Selected Date of Birth: ${widget.userProfile.selectedDob}");
                      PageTransition.navigateToPageRight(
                        context,
                        DisabilityPage(token: widget.token, userProfile: widget.userProfile),
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
    );
  }


}




class DisabilityPage extends StatefulWidget {
  final String token;
  final UserProfile userProfile; // Make sure this line is present
  const DisabilityPage({required this.token, required this.userProfile, Key? key}) : super(key: key);

  @override
  _DisabilityPageState createState() => _DisabilityPageState();
}
class _DisabilityPageState extends State<DisabilityPage> {
  String? selectedDisability;
  int currentStep = 4;
  final totalSteps = 14;
  late String userid;

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    userid = jwtDecodedToken['_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        PageTransition.navigateToPageLeft(
                          context,
                          DobPage(token: widget.token, userProfile: widget.userProfile),
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
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "What's your unique feature?",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                height: 220,
                width: 300,
                child: Image.asset(
                  'assets/leadership.png',
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomDropdown(
                    label: 'Disability',
                    value: selectedDisability,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDisability = newValue;
                      });
                    },
                    items: const <String>[
                      'Hearing',
                      'Speaking',
                      'Physical',
                      'Irlen syndrome',
                      'Dwarfs',
                      'Others',
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: Text(
                  "To provide you with a tailored experience, Please share your disability",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Store selected disability in userProfile
                      widget.userProfile.selectedDisability = selectedDisability ?? '';
                      print("Selected Disability: ${widget.userProfile.selectedDisability}");

                      // Continue with the navigation or other actions
                      PageTransition.navigateToPageRight(context, MaritalPage(token: widget.token, userProfile: widget.userProfile));
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
    );
  }
}


class MaritalPage extends StatefulWidget {
  final String token;
  final UserProfile userProfile; // Make sure this line is present
  const MaritalPage({required this.token, required this.userProfile, Key? key}) : super(key: key);

  @override
  _MaritalPageState createState() => _MaritalPageState();
}
class _MaritalPageState extends State<MaritalPage> {
  String? selectedMaritalStatus;
  int currentStep = 5;
  final totalSteps = 14;
  late String userid;

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    userid = jwtDecodedToken['_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        PageTransition.navigateToPageLeft(
                          context,
                          DisabilityPage(token: widget.token, userProfile: widget.userProfile),
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
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "What's your marital status?",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                height: 220,
                width: 300,
                child: Image.asset(
                  'assets/familybg.jpg',
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomDropdown(
                    label: 'Marital status',
                    value: selectedMaritalStatus,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMaritalStatus = newValue;
                      });
                    },
                    items: const <String>[
                      'Single',
                      'Married',
                      'Divorced',
                      'Widow',
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: Text(
                  "To provide you with a tailored experience, Please share your marital status",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Store selected marital status in userProfile
                      widget.userProfile.selectedMaritalStatus = selectedMaritalStatus ?? '';
                      print("Selected Marital Status: ${widget.userProfile.selectedMaritalStatus}");

                      // Continue with the navigation or other actions
                      PageTransition.navigateToPageRight(context, NationalityPage (token: widget.token, userProfile: widget.userProfile));
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
    );
  }
}



class NationalityPage extends StatefulWidget {
  final String token;
  final UserProfile userProfile; // Make sure this line is present
  const NationalityPage({required this.token, required this.userProfile, Key? key}) : super(key: key);

  @override
  _NationalityPageState createState() => _NationalityPageState();
}
class _NationalityPageState extends State<NationalityPage> {
  String? selectedNationality;
  int currentStep = 6;
  final totalSteps = 14;
  late String userid;

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    userid = jwtDecodedToken['_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        PageTransition.navigateToPageLeft(
                          context,
                          MaritalPage(token: widget.token, userProfile: widget.userProfile),
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
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "What's your Nationality?",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                height: 220,
                width: 300,
                child: Image.asset(
                  'assets/nationality.png',
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomDropdown(
                    label: 'Nationality',
                    value: selectedNationality,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedNationality = newValue;
                      });
                    },
                    items: const <String>[
                      'Pakistani',
                      'American',
                      'British',
                      'Canadian',
                      'Indian',
                      'Other',
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: Text(
                  "Please provide details about your nationality",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Store selected nationality in userProfile
                      widget.userProfile.selectedNationality = selectedNationality ?? '';
                      print("Selected Nationality: ${widget.userProfile.selectedNationality}");

                      // Continue with the navigation or other actions
                      PageTransition.navigateToPageRight(context, ReligionPage(token: widget.token, userProfile: widget.userProfile));
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
    );
  }
}


class ReligionPage extends StatefulWidget {
  final String token;
  final UserProfile userProfile; // Make sure this line is present
  const ReligionPage({required this.token, required this.userProfile, Key? key}) : super(key: key);

  @override
  _ReligionPageState createState() => _ReligionPageState();
}
class _ReligionPageState extends State<ReligionPage> {
  String? selectedReligion;
  int currentStep = 7;
  final totalSteps = 14;
  late String userid;

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    userid = jwtDecodedToken['_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        PageTransition.navigateToPageLeft(
                          context,
                          NationalityPage(token: widget.token, userProfile: widget.userProfile),
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
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "What's your Religion?",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                height: 220,
                width: 300,
                child: Image.asset(
                  'assets/religion.png',
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomDropdown(
                    label: 'Religion',
                    value: selectedReligion,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedReligion = newValue;
                      });
                    },
                    items: const <String>[
                      'Islam',
                      'Christianity',
                      'Hinduism',
                      'Buddhism',
                      'Sikhism',
                      'Other',
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: Text(
                  "Please provide details about your Religion",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Store selected religion in userProfile
                      widget.userProfile.selectedReligion = selectedReligion ?? '';
                      print("Selected Religion: ${widget.userProfile.selectedReligion}");

                      // Continue with the navigation or other actions
                      PageTransition.navigateToPageRight(context, OccupationPage(token: widget.token, userProfile: widget.userProfile));
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
    );
  }
}




class OccupationPage extends StatefulWidget {
  final String token;
  final UserProfile userProfile; // Make sure this line is present
  const OccupationPage({required this.token, required this.userProfile, Key? key}) : super(key: key);

  @override
  _OccupationPageState createState() => _OccupationPageState();
}
class _OccupationPageState extends State<OccupationPage> {
  String? selectedOccupation;
  int currentStep = 8;
  final totalSteps = 14;
  late String userid;

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token!);
    userid = jwtDecodedToken['_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        PageTransition.navigateToPageLeft(
                          context,
                          ReligionPage(token: widget.token, userProfile: widget.userProfile),
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
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "What's your Occupation?",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                height: 220,
                width: 300,
                child: Image.asset(
                  'assets/occupation.png',
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomDropdown(
                    label: 'Occupation',
                    value: selectedOccupation,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedOccupation = newValue;
                      });
                    },
                    items: const <String>[
                      'Student',
                      'Housewife',
                      'Unemployed',
                      'Employed',
                      'Other',
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 80),
                child: Text(
                  " Tell us what field of work are you in",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Store selected occupation in userProfile
                      widget.userProfile.selectedOccupation = selectedOccupation ?? '';
                      print("Selected Occupation: ${widget.userProfile.selectedOccupation}");

                      // Continue with the navigation or other actions
                      PageTransition.navigateToPageRight(context, CityPage(token: widget.token, userProfile: widget.userProfile));
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
    );
  }
}


class CityPage extends StatefulWidget {
  final String token;
  final UserProfile userProfile; // Make sure this line is present
  const CityPage({required this.token, required this.userProfile, Key? key}) : super(key: key);

  @override
  _CityPageState createState() => _CityPageState();
}
class _CityPageState extends State<CityPage> {
  String? selectedCity;
  int currentStep = 9;
  final totalSteps = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        PageTransition.navigateToPageLeft(
                          context,
                          OccupationPage(token: widget.token, userProfile: widget.userProfile),
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
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Where are you from?",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                height: 220,
                width: 300,
                child: Image.asset(
                  'assets/city.jpg',
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomDropdown(
                    label: 'City',
                    value: selectedCity,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCity = newValue;
                      });
                    },
                    items: const <String>[
                      'Karachi',
                      'Lahore',
                      'Islamabad',
                      'Rawalpindi',
                      'Faisalabad',
                      'Multan',
                      'Peshawar',
                      'Quetta',
                      'Sialkot',
                      'Gujranwala',
                      'Other',
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 85),
                child: Text(
                  "Tell us in which city you are living",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Store selected city in userProfile
                      widget.userProfile.selectedCity = selectedCity ?? '';
                      print("Selected City: ${widget.userProfile.selectedCity}");

                      // Continue with the navigation or other actions
                      PageTransition.navigateToPageRight(context, UserProfileSetupPage(token: widget.token, userProfile: widget.userProfile));
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
    );
  }
}


class UserProfileSetupPage extends StatefulWidget {
  final String token;
  final UserProfile userProfile;

  const UserProfileSetupPage({required this.token, required this.userProfile, Key? key}) : super(key: key);

  @override
  _UserProfileSetupPageState createState() => _UserProfileSetupPageState();
}
class _UserProfileSetupPageState extends State<UserProfileSetupPage> {
  String? bio;
  // String? imagePath;
  int currentStep = 10;
  final totalSteps = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
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
              SizedBox(height: 20,),
              Container(
                height: 220,
                width: 300,
                child: Image.asset(
                  'assets/profile.png',
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(height: 60),
              Text(
                'Write Bio for your profile so that your friends can see',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              TextField(
                onChanged: (value) {
                  setState(() {
                    bio = value;
                  });
                },
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write a short bio about yourself',
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Store selected city in userProfile
                      widget.userProfile.bio = bio ?? '';
                      print("bio: ${widget.userProfile.bio}");

                      // Continue with the navigation or other actions
                      PageTransition.navigateToPageRight(context, educational(token: widget.token, userProfile: widget.userProfile));
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
    );
  }
}





class educational extends StatefulWidget {
  final String token;
  final UserProfile userProfile;

  const educational({required this.token, required this.userProfile, Key? key}) : super(key: key);

  @override
  _educationalPageState createState() => _educationalPageState();
}
class _educationalPageState extends State<educational> {
  String? selectedEducationBackground;
  int currentStep = 12;
  final totalSteps = 14;
  late String userid;

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
    userid = jwtDecodedToken['_id'];
  }

  void storeInfo() async {
    try {
      var regbody = {
        "userId": userid,
        "gender": widget.userProfile.selectedGender,
        "height": widget.userProfile.selectedHeight,
        "dateofbirth": widget.userProfile.selectedDob,
        "disability": widget.userProfile.selectedDisability,
        "marital": widget.userProfile.selectedMaritalStatus,
        "nationality": widget.userProfile.selectedNationality,
        "religion": widget.userProfile.selectedReligion,
        "occupation": widget.userProfile.selectedOccupation,
        "city": widget.userProfile.selectedCity,
        "bio": widget.userProfile.bio,
        "education": widget.userProfile.selectedEducationBackground,
      };

      var response = await http.post(
        Uri.parse(storeuserinfo),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regbody),
      );

      if (response.statusCode == 200) {
        print("Information stored successfully");
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                if (widget.token.isNotEmpty) {
                  return interests(token: widget.token);
                } else {
                  print("Error: widget.token is empty");
                  return Scaffold(
                    body: Center(
                      child: Text("Error: Unable to proceed without a valid token"),
                    ),
                  );
                }
              },
            ),
          );
        });
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context); // Adjust navigation as needed
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
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Your educational background?",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                height: 220,
                width: 300,
                child: Image.asset(
                  'assets/edu.jpg',
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomDropdown(
                    label: 'Educational Background',
                    value: selectedEducationBackground,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedEducationBackground = newValue;
                      });
                    },
                    items: const <String>[
                      'Matric',
                      'Intermediate',
                      'Undergraduate',
                      'Graduate',
                      'Ph.D.',
                      'Other',
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 30),
                child: Text(
                  "Tell us what's your educational background",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      handleContinueButtonPress();
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
    );
  }

  void handleContinueButtonPress() {
    widget.userProfile.selectedEducationBackground = selectedEducationBackground ?? '';
    print("Selected Education Background: ${widget.userProfile.selectedEducationBackground}");
    storeInfo();
  }
}