import 'package:driver_app/configMap.dart';
import 'package:driver_app/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Future initialize() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future<String> getToken() async {
    // use the returned token to send messages to users from your custom server
    String token = await _firebaseMessaging.getToken();

    print('This is token ::');
    print(token);

    driverRef.child(currentFirebaseUser.uid).child('token').set(token);

    _firebaseMessaging.subscribeToTopic("alldrivers");
    _firebaseMessaging.subscribeToTopic("allriders");
  }
}
