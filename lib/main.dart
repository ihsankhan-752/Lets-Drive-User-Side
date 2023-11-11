import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lets_drive_user_side/splash_screen/splash_screen.dart';
import 'package:provider/provider.dart';

import 'info_handler/app_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MyApp(
      child: ChangeNotifierProvider(
        create: (_) => AppInfo(),
        child: MaterialApp(
          title: 'Drivers App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MySplashScreen(),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget child;
  const MyApp({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(child: widget.child, key: key);
  }
}
