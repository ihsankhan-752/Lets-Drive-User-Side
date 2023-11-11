import 'package:flutter/material.dart';

showCustomMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.white,
      content: Text(
        msg,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  );
}
