import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:driver_app/models/allUser.dart';
import 'package:geolocator/geolocator.dart';

String mapKey = "AIzaSyDKFRPM_2zrr1J14al_9_4Vi80jWV_S6G8";

User firebaseUser;

AllUser userCurrentInfo;

User currentFirebaseUser;

StreamSubscription<Position> homeTabPageStreamSubscription;