import 'package:flutter/material.dart';
import '../models/directions.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation;
  Directions? userDropOffLocation;

  void updatePickUpLocationAddress(Directions pickUpAddress) {
    userPickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
