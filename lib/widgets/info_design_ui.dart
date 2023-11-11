import 'package:flutter/material.dart';

class InfoDesignUi extends StatefulWidget {
  final String? textInfo;
  final IconData? iconData;
  const InfoDesignUi({Key? key, this.textInfo, this.iconData}) : super(key: key);

  @override
  State<InfoDesignUi> createState() => _InfoDesignUiState();
}

class _InfoDesignUiState extends State<InfoDesignUi> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white54,
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: ListTile(
        leading: Icon(widget.iconData, color: Colors.black),
        title: Text(
          widget.textInfo!,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
