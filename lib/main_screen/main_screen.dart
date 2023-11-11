import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_drive_user_side/main_screen/rate_driver_screen.dart';
import 'package:lets_drive_user_side/main_screen/search_places_screen.dart';
import 'package:lets_drive_user_side/main_screen/select_nearest_active_driver_screen.dart';
import 'package:provider/provider.dart';

import '../assistants/assistants_methods.dart';
import '../assistants/geofire_assistant.dart';
import '../global/globals.dart';
import '../info_handler/app_info.dart';
import '../models/active_driver_model.dart';
import '../widgets/custom_msg.dart';
import '../widgets/map_black_theme.dart';
import '../widgets/my_drawer.dart';
import '../widgets/pay_fare_amount_dialog_box.dart';
import '../widgets/progress_dialog.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "your Name";
  String userEmail = "your Email";

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<ActiveDriverModel> onlineNearByAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;

  String driverRideStatus = "Driver is Coming";

  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  String userRideRequestStatus = "";

  bool requestPositionInfo = true;

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);

    userName = userModel!.name!;
    userEmail = userModel!.email!;

    initializeGeoFireListener();

    AssistantMethods.readTripKeysForOnlineUser(context);
  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();
  }

  saveRideRequestInformation() {
    //1. save the RideRequest Information
    referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    var originLocation = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation = Provider.of<AppInfo>(context, listen: false).dropOffLocation;

    Map originLocationMap = {
      //"key": value,
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation!.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      //"key": value,
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModel!.name,
      "userPhone": userModel!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
    };

    referenceRideRequest!.set(userInformationMap);

    tripRideRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }
      if ((eventSnap.snapshot.value as Map)['car_details'] != null) {
        setState(() {
          driverCarDetails = (eventSnap.snapshot.value as Map)['car_details'].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['driverPhone'] != null) {
        setState(() {
          driverPhone = (eventSnap.snapshot.value as Map)['driverPhone'].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['driverName'] != null) {
        setState(() {
          driverName = (eventSnap.snapshot.value as Map)['driverName'].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)['status'] != null) {
        setState(() {
          userRideRequestStatus = (eventSnap.snapshot.value as Map)['status'];
        });
      }

      if ((eventSnap.snapshot.value as Map)['driverLocation'] != null) {
        double driverCurrentPositionLat =
            double.parse((eventSnap.snapshot.value as Map)['driverLocation']['latitude'].toString());
        double driverCurrentPositionLng =
            double.parse((eventSnap.snapshot.value as Map)['driverLocation']['longitude'].toString());
        LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

        //status=accepted
        if (userRideRequestStatus == "accepted") {
          updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng);
        }
        //status=arrived
        if (userRideRequestStatus == "arrived") {
          setState(() {
            driverRideStatus = "Driver has Arrived";
          });
        }
        //status=ontrip

        if (userRideRequestStatus == "ontrip") {
          updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
        }

        //status= ended
        if (userRideRequestStatus == "ended") {
          if ((eventSnap.snapshot.value as Map)['fareAmount'] != null) {
            double fareAmount = double.parse((eventSnap.snapshot.value as Map)['fareAmount'].toString());
            var response = await showDialog(
              context: context,
              builder: (_) {
                return PayFareAmountDialog(totalFareAmount: fareAmount);
              },
              barrierDismissible: false,
            );
            if (response == "cashPayed") {
              //user can rate driver now
              if ((eventSnap.snapshot.value as Map)['driverId'] != null) {
                String assignedDriverId = (eventSnap.snapshot.value as Map)['driverId'].toString();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RateDriverScreen(
                      assignedDriverId: assignedDriverId,
                    ),
                  ),
                );
                referenceRideRequest!.onDisconnect();
                tripRideRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }
      }
    });

    onlineNearByAvailableDriversList = GeofireAssistant.activeDriverList;
    searchNearestOnlineDrivers();
  }

  updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;
      LatLng userPickUpPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userPickUpPosition,
      );
      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus = "Driver is Coming ::" + directionDetailsInfo.duration_text.toString();
      });
      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation = Provider.of<AppInfo>(context, listen: false).dropOffLocation;

      LatLng userDropOffDestinationPosition =
          LatLng(dropOffLocation!.locationLatitude!, dropOffLocation.locationLongitude!);

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userDropOffDestinationPosition,
      );
      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus = "Going Towards Destination ::" + directionDetailsInfo.duration_text.toString();
      });
      requestPositionInfo = true;
    }
  }

  searchNearestOnlineDrivers() async {
    //no active driver available
    if (onlineNearByAvailableDriversList.length == 0) {
      //cancel/delete the RideRequest Information
      referenceRideRequest!.remove();

      setState(() {
        polyLineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoOrdinatesList.clear();
      });

      showCustomMsg(context, "No Online Nearest Driver Available. Search Again after some time, Restarting App Now.");

      Future.delayed(const Duration(milliseconds: 4000), () {
        SystemNavigator.pop();
      });

      return;
    }

    //active driver available
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);

    var response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => SelectNearestActiveDriversScreen(referenceRideRequest: referenceRideRequest!)));

    if (response == "driverChoosed") {
      FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId!).once().then((snap) {
        if (snap.snapshot.value != null) {
          //send notification to that specific driver
          sendNotificationToDriverNow(chosenDriverId!);

          //Display Waiting Response UI from a Driver

          showWaitingResponseFromDriverUI();

          FirebaseDatabase.instance
              .ref()
              .child("drivers")
              .child(chosenDriverId!)
              .child("newRideStatus")
              .onValue
              .listen((eventSnapshot) {
            //1.driver can cancel the rideRequest PushNotification
            //(newRideStatus==idle)
            if (eventSnapshot.snapshot.value == "idle") {
              showCustomMsg(context, "Driver has Cancelled your Request please Choose Another One");
              Future.delayed(Duration(seconds: 3), () {
                showCustomMsg(context, "ReStart App Now");
                SystemNavigator.pop();
              });
            }
            //2.driver can Accept the rideRequest PushNotification
            //(newRideStatus==accepted
            if (eventSnapshot.snapshot.value == "accepted") {
              //designing Ui for driver Information
              showUIForAssignedDriverInfo();
            }
          });
        } else {
          showCustomMsg(context, "This driver do not exist. Try again.");
        }
      });
    }
  }

  showUIForAssignedDriverInfo() {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;

      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 240;
    });
  }

  showWaitingResponseFromDriverUI() {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight = 220;
    });
  }

  sendNotificationToDriverNow(String chosenDriverId) {
    //assign/SET rideRequestId to newRideStatus in
    // Drivers Parent node for that specific choosen driver
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(chosenDriverId)
        .child("newRideStatus")
        .set(referenceRideRequest!.key);

    //automate the push notification service
    FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId).child("token").once().then((snap) {
      if (snap.snapshot.value != null) {
        String deviceRegistrationToken = snap.snapshot.value.toString();

        //send Notification Now
        AssistantMethods.sendNotificationToDriverNow(
          deviceRegistrationToken,
          referenceRideRequest!.key.toString(),
          context,
        );

        showCustomMsg(context, "Notification sent Successfully.");
      } else {
        showCustomMsg(context, "Please choose another driver.");
        return;
      }
    });
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    for (int i = 0; i < onlineNearestDriversList.length; i++) {
      await ref.child(onlineNearestDriversList[i].driverId.toString()).once().then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;
        dList.add(driverKeyInfo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearByDriverIconMarker();

    return Scaffold(
      key: sKey,
      drawer: Container(
        width: 265,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black,
          ),
          child: MyDrawer(
            name: userName,
            email: userEmail,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            polylines: polyLineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              //for black theme google map
              newGoogleMapController!.setMapStyle(mapBlackTheme);

              setState(() {
                bottomPaddingOfMap = 240;
              });

              locateUserPosition();
            },
          ),

          //custom hamburger button for drawer
          Positioned(
            top: 60,
            left: 14,
            child: GestureDetector(
              onTap: () {
                if (openNavigationDrawer) {
                  sKey.currentState!.openDrawer();
                } else {
                  //restart-refresh-minimize app progmatically
                  SystemNavigator.pop();
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(
                  openNavigationDrawer ? Icons.menu : Icons.close,
                  color: Colors.black54,
                ),
              ),
            ),
          ),

          //ui for searching location
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      //from
                      Row(
                        children: [
                          const Icon(
                            Icons.add_location_alt_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "From",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Text(
                                Provider.of<AppInfo>(context).userPickUpLocation != null
                                    ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!)
                                            .substring(0, 24) +
                                        "..."
                                    : "not getting address",
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10.0),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0),

                      //to
                      GestureDetector(
                        onTap: () async {
                          //go to search places screen
                          var responseFromSearchScreen =
                              await Navigator.push(context, MaterialPageRoute(builder: (c) => SearchPlacesScreen()));

                          if (responseFromSearchScreen == "obtainedDropoff") {
                            setState(() {
                              openNavigationDrawer = false;
                            });

                            //draw routes - draw polyline
                            await drawPolyLineFromOriginToDestination();
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_location_alt_outlined,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 12.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "To",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                Text(
                                  Provider.of<AppInfo>(context).dropOffLocation != null
                                      ? Provider.of<AppInfo>(context).dropOffLocation!.locationName!
                                      : "Where to go?",
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10.0),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0),

                      ElevatedButton(
                        child: const Text(
                          "Request a Ride",
                        ),
                        onPressed: () {
                          if (Provider.of<AppInfo>(context, listen: false).dropOffLocation != null) {
                            saveRideRequestInformation();
                          } else {
                            showCustomMsg(context, "Please select destination location");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //ui for waiting response from driver

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: waitingResponseFromDriverContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        'Waiting From Driver Response',
                        duration: Duration(seconds: 6),
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      ScaleAnimatedText(
                        'Please Wait.....',
                        duration: Duration(seconds: 10),
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(fontSize: 32.0, fontFamily: 'Canterbury', color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //ui for displaying Assigned Driver Information

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: assignedDriverInfoContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //status of the ride
                    Center(
                      child: Text(
                        driverRideStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    Divider(thickness: 2, height: 2, color: Colors.white54),

                    //vehicles details of the driver
                    SizedBox(height: 20),
                    Text(
                      driverCarDetails,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    //driver name

                    SizedBox(height: 4),

                    Text(
                      driverName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),

                    //call driver button
                    SizedBox(height: 14),
                    Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.white54,
                    ),
                    SizedBox(height: 14),

                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {},
                        icon: Icon(
                          Icons.phone_android,
                          color: Colors.black54,
                        ),
                        label: Text(
                          "Call",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).dropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    pLineCoOrdinatesList.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.purpleAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!.listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          //whenever any driver become active/online
          case Geofire.onKeyEntered:
            ActiveDriverModel activeNearbyAvailableDriver = ActiveDriverModel();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeofireAssistant.activeDriverList.add(activeNearbyAvailableDriver);
            if (activeNearbyDriverKeysLoaded == true) {
              displayActiveDriversOnUsersMap();
            }
            break;

          //whenever any driver become non-active/offline
          case Geofire.onKeyExited:
            GeofireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnUsersMap();
            break;

          //whenever driver moves - update driver location
          case Geofire.onKeyMoved:
            ActiveDriverModel activeNearbyAvailableDriver = ActiveDriverModel();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeofireAssistant.updateActiveDriverLocation(activeNearbyAvailableDriver);
            displayActiveDriversOnUsersMap();
            break;

          //display those online/active drivers on user's map
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }

  displayActiveDriversOnUsersMap() {
    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for (ActiveDriverModel eachDriver in GeofireAssistant.activeDriverList) {
        LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId("driver" + eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }

      setState(() {
        markersSet = driversMarkerSet;
      });
    });
  }

  createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png").then((value) {
        activeNearbyIcon = value;
      });
    }
  }
}
