import 'dart:async';

import 'package:driver_app/assistants/assistant_method.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/models/direction_detail.dart';
import 'package:driver_app/notifications/push_notification.dart';
import 'package:driver_app/screens/registrationscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

import '../configMap.dart';

class HomeTab extends StatefulWidget {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Completer<GoogleMapController> _controller = Completer();

  GoogleMapController _googleMapController;

  DirectionDetail tripDirectionDetail;

  List<LatLng> pLineCoordinates = [];

  Set<Polyline> polyLineSet = {};

  Set<Marker> markerSet = {};

  Set<Circle> circleSet = {};

  Position currentPosition;

  var geolocator = Geolocator();

  double bottomPaddingOfMap = 16.0;

  String _driverStatusText = "Offline Now - Go online";

  Color _driverStatusColor = Colors.black;

  bool _isDriverAvailable = false;

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(
      target: latLngPosition,
      zoom: 14,
    );
    _googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // String address =
    //     await AssistantMethod.searchCoordinateAddress(position, context);
    // print("This is your address :: " + address);
  }

  void getCurrentDriverInfo() async {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize();
    pushNotificationService.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          // polylines: polyLineSet,
          // markers: markerSet,
          // circles: circleSet,
          initialCameraPosition: HomeTab._kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            _googleMapController = controller;

            locatePosition();

            // setState(() {
            //   bottomPaddingOfMap = 265.0;
            // });
          },
        ),

        //online - offline driver Container
        Container(
          height: 40.0,
          width: double.infinity,
          color: Colors.black54,
        ),

        Positioned(
          top: 60.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!_isDriverAvailable) {
                      makeDriverOnlineNow();
                      getLocationLiveUpdate();
                      setState(() {
                        _driverStatusColor = Colors.green;
                        _driverStatusText = "Online Now";
                        _isDriverAvailable = true;
                      });
                      displayToastMessage(context, "You are Online now");
                    } else {
                      setState(() {
                        _driverStatusColor = Colors.black;
                        _driverStatusText = "Offline Now - Go online";
                        _isDriverAvailable = false;
                      });
                      makeDriverOfflineNow();
                      displayToastMessage(context, "You are Offline now");
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _driverStatusText,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: _driverStatusColor,
                          ),
                        ),
                        Icon(
                          Icons.phone_android,
                          color: Colors.white,
                          size: 26.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude,
        currentPosition.longitude);

    tripRequestRef.onValue.listen((event) {});
  }

  void getLocationLiveUpdate() {
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (_isDriverAvailable) {
        Geofire.setLocation(
          currentFirebaseUser.uid,
          position.latitude,
          position.longitude,
        );
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      _googleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOfflineNow() {
    setState(() {
      Geofire.removeLocation(currentFirebaseUser.uid);
      tripRequestRef.onDisconnect();
      tripRequestRef.remove();
      tripRequestRef = null;
    });
  }
}
