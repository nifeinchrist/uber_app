import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../assistants/assistant_methods.dart';
import '../info_handler/app_info.dart';
import '../models/directions.dart';
import '../models/place_prediction.dart';
import '../widgets/progress_dialog.dart';

class PredictedPlaceWidget extends StatelessWidget {
  final PlacePrediction? predictedPlaceData;

  const PredictedPlaceWidget({super.key, this.predictedPlaceData});

  /// Called when user taps a place — fetches details and returns to the main screen.
  void getPlaceDetailsFromAPI(String humanReadableName, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const ProgressDialog(message: "Setting destination..."),
    );

    var directionDetails = await AssistantMethods.getPlaceDirectionDetails(
      predictedPlaceData!.placeId!,
    );

    if (!context.mounted) return;
    Navigator.pop(context); // close dialog

    // Build a Directions object with the fetched lat/lng
    Directions directions = Directions();
    directions.locationName = humanReadableName;
    directions.locationLatLng = directionDetails.locationLatLng;

    // Save as the drop-off in the app-wide provider
    Provider.of<AppInfo>(context, listen: false)
        .updateDropOffLocationAddress(directions);

    // Return to the previous screen (main_page.dart)
    Navigator.pop(context, "obtainedDropoff");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        String humanReadableName =
            "${predictedPlaceData?.mainText}, ${predictedPlaceData?.secondaryText}";
        getPlaceDetailsFromAPI(humanReadableName, context);
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Location Icon
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Place Name and Address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      predictedPlaceData?.mainText ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      predictedPlaceData?.secondaryText ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
