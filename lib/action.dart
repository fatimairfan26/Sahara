import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



// class BlockUserPopup extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       contentPadding: EdgeInsets.zero,
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               color: const Color(0xFFd66d67),
//               child: const Row(
//                 children: [
//                   Icon(Icons.block_outlined, color: Colors.white, size: 35,),
//                   SizedBox(width: 8),
//                   Padding(
//                     padding: EdgeInsets.only(top: 2.0),
//                     child: Text('Block User',
//                       style: TextStyle(color: Colors.white, fontSize: 26),),
//                   ),
//                 ],
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Are you sure you want to block this user?',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Icon(Icons.remove_circle),
//                       SizedBox(width: 8),
//                       Flexible(
//                         child: Text(
//                           'They won\'t be able to message you or find your profile.',
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Icon(Icons.notifications_off),
//                       SizedBox(width: 8),
//                       Flexible(
//                         child: Text(
//                           'They won\'t be notified that you have blocked them.',
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Icon(Icons.settings),
//                       SizedBox(width: 8),
//                       Flexible(
//                         child: Text(
//                           'You can unblock them at any time by going to settings.',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Row(
//               children: [
//                 const SizedBox(width: 3,
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     height: 40,
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.of(context).pop(true),
//                       style: ButtonStyle(
//                         backgroundColor: MaterialStateProperty.all<Color>(
//                             const Color(0xFFd66d67)),
//                       ),
//                       child: const Text(
//                           'Block', style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//
//                 ),
//                 const SizedBox(width: 3,
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     height: 40,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color(0xFFd66d67), // Border color
//                         width: 1, // Border width
//                       ),
//                     ),
//                     child: TextButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: const Text('Cancel', style: TextStyle(color: Color(
//                           0xFFd66d67))),
//                     ),
//                   ),
//
//                 ),
//                 const SizedBox(width: 3,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 15,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ReportUserPopup extends StatefulWidget {
  final String tokenUserId;
  final String profileUserId;

  const ReportUserPopup({
    Key? key,
    required this.tokenUserId,
    required this.profileUserId,
  }) : super(key: key);

  @override
  _ReportUserPopupState createState() => _ReportUserPopupState();
}

class _ReportUserPopupState extends State<ReportUserPopup> {
  int _selectedIndex = -1;
  late TextEditingController _reasonController;

  void _handleOvalTap(int index) {
    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = -1; // Deselect if already selected
      } else {
        _selectedIndex = index;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  Future<void> storeInfo() async {
    try {
      if (_selectedIndex != -1) {
        var reportOption = reportOptions[_selectedIndex];

        var regbody = {
          "userId": widget.tokenUserId,
          "Reporteduserid": widget.profileUserId,
          "reportOption": reportOption,
          "reason": _reasonController.text,
        };

        var response = await http.post(
          Uri.parse("http://192.168.43.197:3000/report"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regbody),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print("Information stored successfully");
          Navigator.of(context).pop(); // Close the current dialog
          Future.delayed(Duration(milliseconds: 100), () {
            _showConfirmationDialog(); // Show confirmation dialog after delay
          });
        } else {
          print("Registration failed with status code: ${response.statusCode}");
          print("Response body: ${response.body}");
        }
      } else {
        print("No option selected");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Submitted', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          content: const Text('Your report has been submitted and respective action will be taken. Thank you.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFd66d67),
              ),
              child: Text(
                'Ok',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFd66d67),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24,),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text('Report User', style: TextStyle(color: Colors.white, fontSize: 26),),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Help us understand what\'s happening',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < reportOptions.length; i++)
                        SelectableOval(
                          text: reportOptions[i],
                          isSelected: _selectedIndex == i,
                          onTap: () => _handleOvalTap(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Reason *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your reason here',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      height: 40,
                      width: 170,
                      child: ElevatedButton(
                        onPressed: () {
                          storeInfo();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFd66d67)),
                        ),
                        child: const Text('Report', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<String> reportOptions = [
  'Hate Speech',
  'Spam',
  'Scam',
  'Violence',
  'Harassment',
  'Fake Page',
  'Something Else',
];

class SelectableOval extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableOval({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? const Color(0xFFd66d67) : Colors.grey[300],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
