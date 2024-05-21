import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WherePage extends StatefulWidget {
  const WherePage({super.key});

  @override
  State<WherePage> createState() => _WherePageState();
}

class _WherePageState extends State<WherePage> {
  static const CameraPosition _initialPosition =
      CameraPosition(target: LatLng(41.5077902, 36.1142925), zoom: 14);
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> myMarker = [];
  String selectedFishType = "";

  @override
  void initState() {
    super.initState();
    _getLocations();
  }

  Future<void> _getLocations() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("users").get();

      for (QueryDocumentSnapshot userDoc in querySnapshot.docs) {
        QuerySnapshot imageSnapshot = await userDoc.reference
            .collection('fotograflarim')
            .orderBy('tarih', descending: true)
            .get();

        for (QueryDocumentSnapshot imageDoc in imageSnapshot.docs) {
          GeoPoint location = imageDoc['nerede'];
          int date = imageDoc['tarih'];
          String balikturu = imageDoc["balik_turu"];
          int balikadet = imageDoc["balik_adet"];

          // Extract latitude and longitude
          double latitude = location.latitude;
          double longitude = location.longitude;

          // Create a marker for the location if the fish type matches
          if (selectedFishType.isEmpty || balikturu == selectedFishType) {
            myMarker.add(
              Marker(
                markerId: MarkerId(date.toString()),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(
                  title: balikturu,
                  snippet: '$balikadet adet',
                ),
              ),
            );
          }
        }
      }
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onFishTypeChanged(String? newType) {
    setState(() {
      selectedFishType = newType ?? "";
      myMarker.clear(); // Clear existing markers
      _getLocations(); // Fetch locations again with the new filter
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: selectedFishType.isEmpty ? null : selectedFishType,
            hint: Text("Balık türü seçin"),
            items: <String>[
              'alabalik',
              'aslanbaligi',
              'balonbaligi',
              'barbun',
              'cipura',
              'hamsi',
              'iskorpit',
              'istavrit',
              'kalkan',
              'karides',
              'kefal',
              'levrek',
              'lufer',
              'palamut',
              'rina',
              'sazan',
              'tekir',
              'vatoz'
            ] // Example fish types
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: _onFishTypeChanged,
          ),
        ),
        Expanded(
          child: GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: Set<Marker>.of(myMarker),
          ),
        ),
      ],
    );
  }
}
