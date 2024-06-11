import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class Review extends StatefulWidget {
  final String? token;
  const Review({@required this.token,Key? key}) : super(key: key);


  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  late String id;
  List<Map<String, dynamic>> reviews = [];
  bool isThumbsUpPressed = false;
  int _selectedRating = 0;
  String _userComment = "";

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    if (token != null) {
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
      id = jwtDecodedToken['_id'];
      print('$id');

      if (id != null) {
        getAllReviews();
      } else {
        print('Error: Decoded _id is null');
      }
    } else {
      print('Error: Token is null');
    }
  }


  void write() async {
    try {
      if (_userComment.isNotEmpty && _selectedRating > 0) {
        var regbody = {
          "userId": id,
          "review": _userComment,
          "rating": _selectedRating.toString(),
        };
        var response = await http.post(
          Uri.parse(wreview),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regbody),
        );

        if (response.statusCode == 200) {
          print("Registration successful");
          final token = json.decode(response.body)['token'];

        } else {
          print("Registration failed with status code: ${response.statusCode}");
          print("Response body: ${response.body}");
        }
      } else {
        print("Review and Rating are required.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: Color(0xFFd66d67),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const Text(
                      'Rate the event',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (int i = 1; i <= 5; i++)
                          Container(
                            width: 46,
                            child: Column(
                              children: [
                                Text(
                                  _Emoji(i),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.star,
                                    color: i <= _selectedRating ? Colors.yellow : Colors.grey,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedRating = i;
                                      print('Rating = $_selectedRating');
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        _navigateToNextPage(context);
                      },
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _Emoji(int rating) {
    switch (rating) {
      case 1:
        return '😢';
      case 2:
        return '😟';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😃';
      default:
        return '';
    }
  }

  void _navigateToNextPage(BuildContext context) {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Comment',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (String? value) {
                  setState(() {
                    _userComment = value!;
                  });
                },
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  hintText: 'Enter your comment...',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  write();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFd66d67),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void getAllReviews() async {
    try {
      if (id != null) {
        final response = await http.get(Uri.parse(getreviewlist));

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          setState(() {
            reviews = List<Map<String, dynamic>>.from(jsonResponse['success']);
          });
        } else {
          print('Failed to load reviews');
        }
      } else {
        print('Error: Token is null');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Widget buildReviewCard(Map<String, dynamic> review) {
    return Column(
      children: [
        SizedBox(height: 10,),
        Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.98,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(2, 2),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${review['username']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(5, (index) {
                    // Fill stars up to the rating value
                    return Icon(
                      index < review['rating'] ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 14,
                    );
                  }),
                ),
                SizedBox(height: 5),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${review['review']}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isThumbsUpPressed = !isThumbsUpPressed;
                    });
                  },
                  icon: Icon(
                    Icons.thumb_up,
                    color: isThumbsUpPressed ? Colors.blue : Colors.grey,
                    size: 12,
                  ),
                  label: Text(
                    'Helpful?',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    elevation: MaterialStateProperty.all(0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    // Calculate average rating
    double averageRating = calculateAverageRating(reviews);
    int totalReviews = reviews.length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.clear_sharp,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ratings & Reviews',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Let's look what our customers has to say about us?",
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  IconButton(
                    icon: const Icon(
                      Icons.create,
                      color: Colors.black,
                    ),
                    onPressed:
                    showPopup,
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.98,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(2, 2),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // Display the calculated average rating
                            averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              // Display stars based on the calculated average rating
                              displayStars(averageRating),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            // Display the total number of reviews
                            'All ratings ($totalReviews)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Reviews",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Column(
                children: reviews.map((review) {
                  return buildReviewCard(review);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }


  double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) {
      return 0.0;
    }

    double totalRating = 0.0;
    for (var review in reviews) {
      totalRating += review['rating'];
    }

    return totalRating / reviews.length;
  }

  Row displayStars(double rating) {
    int filledStars = rating.floor();
    bool hasHalfStar = (rating - filledStars) >= 0.5;

    return Row(
      children: List.generate(5, (index) {
        if (index < filledStars) {
          // Filled star
          return Icon(Icons.star, color: Colors.yellow);
        } else if (index == filledStars && hasHalfStar) {
          // Half-filled star
          return Icon(Icons.star_half, color: Colors.yellow);
        } else {
          // Empty star
          return Icon(Icons.star_border, color: Colors.yellow);
        }
      }),
    );
  }
}