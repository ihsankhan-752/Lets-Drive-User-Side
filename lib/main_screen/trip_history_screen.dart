import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../info_handler/app_info.dart';
import '../widgets/history_design_ui.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Trips History"),
        leading: InkWell(
            onTap: () {
              SystemNavigator.pop();
            },
            child: Icon(Icons.close)),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey,
            thickness: 2,
            height: 2,
          );
        },
        itemCount: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Card(
            child: HistoryDesignUiWidget(
                tripsHistoryModel: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList[index]),
          );
        },
      ),
    );
  }
}
