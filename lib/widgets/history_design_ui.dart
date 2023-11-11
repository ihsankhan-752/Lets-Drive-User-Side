import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/history_model.dart';

class HistoryDesignUiWidget extends StatefulWidget {
  final TripsHistoryModel? tripsHistoryModel;
  const HistoryDesignUiWidget({Key? key, this.tripsHistoryModel}) : super(key: key);

  @override
  State<HistoryDesignUiWidget> createState() => _HistoryDesignUiWidgetState();
}

class _HistoryDesignUiWidgetState extends State<HistoryDesignUiWidget> {
  String formatDateAndTime(String dateTimeFromDB) {
    DateTime dateTime = DateTime.parse(dateTimeFromDB);

    String formatDateTime =
        "${DateFormat.MMMd().format(dateTime)} , ${DateFormat.y().format(dateTime)}, ${DateFormat.jm().format(dateTime)}";

    return formatDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //driver name and Fare amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Driver :" + widget.tripsHistoryModel!.driverName!,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          SizedBox(height: 2),

          //car details

          Row(
            children: [
              Icon(Icons.car_repair, color: Colors.black, size: 28),
              SizedBox(width: 12),
              Text(
                widget.tripsHistoryModel!.car_details!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          SizedBox(height: 16),

          //pickup address along with icon

          Row(
            children: [
              Image.asset("images/origin.png", height: 24, width: 24),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  child: Text(
                    widget.tripsHistoryModel!.originAddress!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              )
            ],
          ),

          //icon+ dropOff Location
          SizedBox(height: 14),

          Row(
            children: [
              Image.asset("images/destination.png", height: 26, width: 26),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  child: Text(
                    widget.tripsHistoryModel!.destinationAddress!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              )
            ],
          ),

          //making date format
          SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              formatDateAndTime(widget.tripsHistoryModel!.time!),
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
