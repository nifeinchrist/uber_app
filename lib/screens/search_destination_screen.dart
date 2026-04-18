import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../assistants/assistant_methods.dart';
import '../global/global.dart';
import '../info_handler/app_info.dart';
import '../widgets/predicted_place_widget.dart';

class SearchDestinationScreen extends StatefulWidget {
  const SearchDestinationScreen({super.key});

  @override
  State<SearchDestinationScreen> createState() =>
      _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {
  TextEditingController pickUpTextController = TextEditingController();
  TextEditingController destinationTextController = TextEditingController();

  List<dynamic> predictedPlaces = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String pickUp = Provider.of<AppInfo>(context, listen: false).userPickUpLocation?.locationName ?? "Not getting address";
      setState(() {
        pickUpTextController.text = pickUp;
      });
    });
  }

  void findPlaceAutoComplete(String searchText) async {
    if (searchText.length > 1) {
      await AssistantMethods.findPlaceAutoCompleteSearch(searchText);
      setState(() {
        predictedPlaces = placePredictionList;
      });
    } else {
      setState(() {
        predictedPlaces = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Search Header ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
              child: Column(
                children: [
                  // Back Button & Title
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                      const Center(
                        child: Text(
                          "Set Destination",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Pick Up Field ──
                  _buildInputRow(
                    icon: Icons.my_location,
                    iconColor: Colors.blueAccent,
                    controller: pickUpTextController,
                    hint: "Pickup Location",
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),

                  // ── Destination Field ──
                  _buildInputRow(
                    icon: Icons.location_on,
                    iconColor: Colors.redAccent,
                    controller: destinationTextController,
                    hint: "Where to go?",
                    onChanged: (value) => findPlaceAutoComplete(value),
                  ),
                ],
              ),
            ),
          ),

          // ── Prediction Results ──────────────────────────────────
          Expanded(
            child: predictedPlaces.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search, size: 60, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text(
                            "Type your destination above",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: predictedPlaces.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Colors.black12),
                    itemBuilder: (context, index) {
                      return PredictedPlaceWidget(
                        predictedPlaceData: predictedPlaces[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow({
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
