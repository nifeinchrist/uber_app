import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  String googleMapKey = "AIzaSyCZ3hh7Ap0wWPDyctG6eogtcfVQnFK2e-s";
  
  // Test Geocoding APIs
  print("Testing Geocoding...");
  String latlng = "37.4219983,-122.084";
  String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latlng&key=$googleMapKey";
  var res = await http.get(Uri.parse(url));
  print("Geocoding status code: ${res.statusCode}");
  if (res.statusCode == 200) {
    var j = json.decode(res.body);
    print("Geocoding API status: ${j['status']}");
    if (j['error_message'] != null) {
      print("Error: ${j['error_message']}");
    }
  }

  // Test Directions API
  print("\nTesting Directions API...");
  String dirUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=37.4219,-122.084&destination=37.4220,-122.085&key=$googleMapKey";
  var dirRes = await http.get(Uri.parse(dirUrl));
  print("Directions status code: ${dirRes.statusCode}");
  if (dirRes.statusCode == 200) {
    var j = json.decode(dirRes.body);
    print("Directions API status: ${j['status']}");
    if (j['error_message'] != null) {
      print("Error: ${j['error_message']}");
    }
  }
}
