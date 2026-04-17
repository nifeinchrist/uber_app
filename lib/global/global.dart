import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/place_prediction.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
Users? userModelCurrentInfo;

// Replace with your actual Google Maps API Key when available
const String googleMapKey = "AIzaSyCZ3hh7Ap0wWPDyctG6eogtcfVQnFK2e-s";

List<PlacePrediction> placePredictionList = [];
