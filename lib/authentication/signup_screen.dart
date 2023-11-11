import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../global/globals.dart';
import '../splash_screen/splash_screen.dart';
import '../widgets/custom_msg.dart';
import '../widgets/progress_dialog.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  validateForm() {
    if (nameController.text.length < 3) {
      showCustomMsg(context, "Name Must Be Greater Than 3 Characters");
    } else if (!emailController.text.contains("@")) {
      showCustomMsg(context, "Email is Not Valid");
    } else if (phoneController.text.isEmpty) {
      showCustomMsg(context, "Provide phone Number");
    } else if (passwordController.text.length < 6) {
      showCustomMsg(context, "Password will be at least 6 characters");
    } else {
      saveUserInformation();
    }
  }

  saveUserInformation() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return ProgressDialog(message: "Processing Please Wait");
        });

    final user = await fAuth
        .createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text)
        .catchError((e) {
      Navigator.pop(context);
      showCustomMsg(context, e.toString());
    });
    if (user.user != null) {
      Map userMap = {
        "id": user.user!.uid,
        "name": nameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
      };
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
      userRef.child(fAuth.currentUser!.uid).set(userMap);
      currentFirebaseUser = user.user;
      showCustomMsg(context, "User Account is Successfully Created");
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => MySplashScreen()));
    } else {
      Navigator.pop(context);
      showCustomMsg(context, "Account is Not Created Yet!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2c2c2c),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset("images/logo.png", height: 180),
              ),
              SizedBox(height: 10),
              Text(
                "Register as a User",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
                  controller: nameController,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10, top: 5),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    hintText: "Name",
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
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
                    hintText: "E-Mail",
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
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
              SizedBox(height: 10),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: phoneController,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10, top: 5),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    hintText: "Phone",
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
                      "Create Account",
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                },
                child: Text(
                  "Already have an Account? Login",
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
