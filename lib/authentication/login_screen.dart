import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lets_drive_user_side/authentication/signup_screen.dart';

import '../global/globals.dart';
import '../splash_screen/splash_screen.dart';
import '../widgets/custom_msg.dart';
import '../widgets/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  validateForm() {
    if (emailController.text.length < 3) {
      showCustomMsg(context, "Email is Required");
    } else if (passwordController.text.length < 6) {
      showCustomMsg(context, "Password is Required");
    } else {
      loginUser();
    }
  }

  loginUser() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return ProgressDialog(message: "Processing Please Wait");
        });

    final user = await fAuth
        .signInWithEmailAndPassword(email: emailController.text, password: passwordController.text)
        .catchError((e) {
      Navigator.pop(context);
      showCustomMsg(context, e.toString());
    });
    if (user.user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
      userRef.child(user.user!.uid).once().then((userKey) {
        final snapshot = userKey.snapshot;
        if (snapshot.value != null) {
          currentFirebaseUser = user.user;
          Navigator.push(context, MaterialPageRoute(builder: (_) => MySplashScreen()));
        } else {
          showCustomMsg(context, "No Record Exist");
          fAuth.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (_) => MySplashScreen()));
        }
      });
    } else {
      Navigator.pop(context);
      showCustomMsg(context, "Error Occurred During Login!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2c2c2c),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  "images/logo.png",
                  height: 200,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Login as a User",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: emailController,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10, top: 5),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    hintText: "E-mail",
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: passwordController,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10, top: 5),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    hintText: "Password",
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  validateForm();
                },
                child: Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
                },
                child: Text(
                  "Don't have an Account? Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
