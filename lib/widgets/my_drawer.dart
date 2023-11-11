import 'package:flutter/material.dart';

import '../global/globals.dart';
import '../main_screen/about_us_screen.dart';
import '../main_screen/profile_screen.dart';
import '../main_screen/trip_history_screen.dart';
import '../splash_screen/splash_screen.dart';

class MyDrawer extends StatefulWidget {
  final String? name, email;
  const MyDrawer({Key? key, this.name, this.email}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 40, color: Colors.grey),
                  SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name!,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        widget.email!,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripHistoryScreen()));
            },
            child: ListTile(
              leading: Icon(Icons.history, color: Colors.white54),
              title: Text(
                "History",
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileScreen()));
            },
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.white54),
              title: Text(
                "Visit Profile",
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AboutScreen()));
            },
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.white54),
              title: Text(
                "About",
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              fAuth.signOut();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => MySplashScreen()));
            },
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.white54),
              title: Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
