import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../global/globals.dart';
import '../widgets/custom_msg.dart';

class RateDriverScreen extends StatefulWidget {
  final String? assignedDriverId;
  const RateDriverScreen({Key? key, this.assignedDriverId}) : super(key: key);

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.white60,
        child: Container(
          margin: EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 22),
              Text(
                "Rate Trip Experience",
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 22),
              Divider(thickness: 4, height: 4),
              SizedBox(height: 22),
              SmoothStarRating(
                color: Colors.green,
                borderColor: Colors.green,
                size: 35,
                rating: countRatingStar,
                allowHalfRating: false,
                starCount: 5,
                onRatingChanged: (v) {
                  countRatingStar = v;

                  if (countRatingStar == 1) {
                    setState(() {
                      titleStarRating = "Very Bad";
                    });
                  }
                  if (countRatingStar == 2) {
                    setState(() {
                      titleStarRating = "Bad";
                    });
                  }
                  if (countRatingStar == 3) {
                    setState(() {
                      titleStarRating = "Good";
                    });
                  }
                  if (countRatingStar == 4) {
                    setState(() {
                      titleStarRating = "Very Good";
                    });
                  }
                  if (countRatingStar == 5) {
                    setState(() {
                      titleStarRating = "Excellent";
                    });
                  }
                },
              ),
              SizedBox(height: 12),
              Text(
                titleStarRating,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  DatabaseReference rateDriverRef =
                      FirebaseDatabase.instance.ref().child("drivers").child(widget.assignedDriverId!).child("ratings");

                  rateDriverRef.once().then((snap) {
                    if (snap.snapshot.value == null) {
                      rateDriverRef.set(countRatingStar.toString());
                      SystemNavigator.pop();
                    } else {
                      double pastRating = double.parse(snap.snapshot.value.toString());
                      double newAverageRating = (pastRating + countRatingStar) / 2;
                      rateDriverRef.set(newAverageRating.toString());

                      SystemNavigator.pop();
                    }
                    showCustomMsg(context, "Please Restart App Now");
                  });
                },
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
