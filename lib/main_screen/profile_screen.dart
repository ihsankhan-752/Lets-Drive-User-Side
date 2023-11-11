import 'package:flutter/material.dart';

import '../global/globals.dart';
import '../widgets/info_design_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //name
            Text(
              userModel!.name!,
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
                thickness: 2,
                height: 2,
              ),
            ),

            SizedBox(height: 40),
            //phone information
            InfoDesignUi(
              textInfo: userModel!.phone!,
              iconData: Icons.phone_iphone,
            ),

            //email
            InfoDesignUi(
              textInfo: userModel!.email!,
              iconData: Icons.email,
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white54,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}
