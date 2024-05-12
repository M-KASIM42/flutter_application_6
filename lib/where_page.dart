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
  @override
  void initState() {
    super.initState();
    _getLocations();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.satellite,
      initialCameraPosition: _initialPosition,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: Set<Marker>.of(myMarker),
    );
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
          // Extract latitude and longitude
          double latitude = location.latitude;
          double longitude = location.longitude;
          debugPrint('Latitude: $latitude, Longitude: $longitude');

          // Create a marker for the location
          myMarker.add(
            Marker(
              markerId: MarkerId(date.toString()),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(title: balikturu),
            ),
          );
        }
      }
      // After adding all markers, update the state to trigger a rebuild
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }
}
