import 'package:driver_app/configMap.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/screens/mainscreen.dart';
import 'package:driver_app/screens/registrationscreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CarInfoScreen extends StatelessWidget {
  static const String idScreen = "car_info";

  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController =
      TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 22.0),
            Image.asset(
              "images/logo.png",
              width: 390.0,
              height: 250.0,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 22.0),
              child: Column(
                children: [
                  SizedBox(height: 12.0),
                  Text(
                    "Enter Car Details",
                    style: TextStyle(
                      fontFamily: "Brand-Bold",
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: carModelTextEditingController,
                    decoration: InputDecoration(
                      labelText: "Car Model",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 15.0),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: carNumberTextEditingController,
                    decoration: InputDecoration(
                      labelText: "Car Number",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 15.0),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: carColorTextEditingController,
                    decoration: InputDecoration(
                      labelText: "Car Color",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 15.0),
                  ),
                  SizedBox(height: 42.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (carModelTextEditingController.text.isEmpty) {
                          displayToastMessage(
                              context, "Please write car model!");
                        } else if (carNumberTextEditingController
                            .text.isEmpty) {
                          displayToastMessage(
                              context, "Please write car number!");
                        } else if (carColorTextEditingController.text.isEmpty) {
                          displayToastMessage(
                              context, "Please write car color!");
                        } else {
                          saveDriverCarInfo(context);
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(17.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'NEXT',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
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
        ),
      ),
    ));
  }

  void saveDriverCarInfo(BuildContext context) {
    String userId = currentFirebaseUser.uid;

    Map carInfoMap = {
      "car_color": carColorTextEditingController.text.trim(),
      "car_number": carNumberTextEditingController.text.trim(),
      "car_model": carModelTextEditingController.text.trim()
    };

    driverRef.child(userId).child("car_details").set(carInfoMap);

    Navigator.pushNamedAndRemoveUntil(
      context,
      MainScreen.idScreen,
      (route) => false,
    );
  }
}
