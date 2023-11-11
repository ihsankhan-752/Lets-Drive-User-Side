import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          //image
          Container(
            height: 230,
            child: Center(
              child: Image.asset(
                "images/car_logo.png",
                width: 260,
              ),
            ),
          ),

          Column(
            children: [
              //company name
              const Text(
                "Uber & inDriver Clone",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),


              //about you & your company - write some info


              const SizedBox(
                height: 10,
              ),

              const Text(
                "This app has been developed by Ihsan Khan, "
                "We Developed This App For All Types of Car in our Country Pakistan ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              //close
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white54,
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
