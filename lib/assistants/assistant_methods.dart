import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../global/global.dart';
import '../models/direction_details.dart';
import '../models/directions.dart';
import '../models/place_prediction.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../info_handler/app_info.dart';
import 'package:location/location.dart' as loc;

class AssistantMethods {
  /// Reads the currently logged-in user's info from Firebase and stores it globally.
  static void readCurrentOnlineUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = Users.fromSnapshot(snap.snapshot);
      }
    });
  }

  /// Reverse Geocodes a lat/lng to an address and saves it to AppInfo via Provider.
  static Future<String> searchAddressForGeographicCoOrdinates(
      loc.LocationData position, BuildContext context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";
    String humanReadableAddress = "";
    
    var requestResponse = await receiveRequest(apiUrl);

    if (requestResponse != "error") {
      var jsonResponse = json.decode(requestResponse);
      if (jsonResponse['status'] == "OK") {
        humanReadableAddress = jsonResponse["results"][0]["formatted_address"];

        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatLng = LatLng(position.latitude!, position.longitude!);
        userPickUpAddress.locationName = humanReadableAddress;

        if (context.mounted) {
          Provider.of<AppInfo>(context, listen: false)
              .updatePickUpLocationAddress(userPickUpAddress);
        }
      }
    }
    return humanReadableAddress;
  }

  /// Searches for places using the Google Places Autocomplete API.
  static Future<void> findPlaceAutoCompleteSearch(String searchInput) async {
    if (searchInput.length > 1) {
      String apiUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchInput&key=$googleMapKey&components=country:ng";

      var response = await receiveRequest(apiUrl);

      if (response == "error") return;

      var responseData = json.decode(response);

      if (responseData["status"] == "OK") {
        var predictions = responseData["predictions"];
        var placesList = (predictions as List)
            .map((jsonData) => PlacePrediction.fromJson(jsonData))
            .toList();
        placePredictionList = placesList;
      }
    }
  }

  /// Fetches the lat/lng and name for a given place ID from the Places Details API.
  static Future<Directions> getPlaceDirectionDetails(String placeId) async {
    String placeDetailUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleMapKey";

    var response = await receiveRequest(placeDetailUrl);
    Directions directions = Directions();

    if (response == "error") return directions;

    var responseData = json.decode(response);
    if (responseData["status"] == "OK") {
      directions.locationName = responseData["result"]["name"];
      double lat = responseData["result"]["geometry"]["location"]["lat"];
      double lng = responseData["result"]["geometry"]["location"]["lng"];
      directions.locationLatLng = LatLng(lat, lng);
    }

    return directions;
  }

  /// Makes an HTTP GET request to the given url and returns the response body.
  static Future<String> receiveRequest(String url) async {
    try {
      http.Response httpResponse = await http.get(Uri.parse(url));
      if (httpResponse.statusCode == 200) {
        return httpResponse.body;
      } else {
        return "error";
      }
    } catch (e) {
      return "error";
    }
  }

  /// Gets direction details (distance, duration, polyline) between two locations.
  static Future<DirectionDetails?> obtainOriginToDestinationDirectionDetails(
      double originLat, double originLng,
      double destinationLat, double destinationLng) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$destinationLat,$destinationLng&key=$googleMapKey";

    var response = await receiveRequest(directionUrl);

    if (response == "error") return null;

    var responseData = json.decode(response);
    if (responseData["status"] != "OK") return null;

    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.ePoints =
        responseData["routes"][0]["overview_polyline"]["points"];
    directionDetails.distanceText =
        responseData["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        responseData["routes"][0]["legs"][0]["distance"]["value"];
    directionDetails.durationText =
        responseData["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        responseData["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  /// Calculates the estimated fare based on distance and duration.
  static double calculateFareAmountOnBasisOfDirections(
      DirectionDetails directionDetails) {
    double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.1;
    double distanceTraveledFare =
        (directionDetails.distanceValue! / 1000) * 0.1;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;
    return double.parse(totalFareAmount.toStringAsFixed(2));
  }
}
