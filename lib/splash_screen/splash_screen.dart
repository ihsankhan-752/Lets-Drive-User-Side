import 'dart:async';

import 'package:flutter/material.dart';

import '../assistants/assistants_methods.dart';
import '../authentication/login_screen.dart';
import '../global/globals.dart';
import '../main_screen/main_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    fAuth.currentUser != null ? AssistantMethods.readCurrentOnlineUserInfo() : null;

    Timer(Duration(seconds: 3), () async {
      if (await fAuth.currentUser != null) {
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(context, MaterialPageRoute(builder: (_) => MainScreen()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2c2c2c),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset("images/logo.png"),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
