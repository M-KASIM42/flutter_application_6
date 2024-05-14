import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostLocation extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int balik_adet;
  final String balik_turu;
  const PostLocation({Key? key, required this.latitude, required this.longitude,required this.balik_adet,required this.balik_turu}) : super(key: key);

  @override
  State<PostLocation> createState() => _PostLocationState();
}

class _PostLocationState extends State<PostLocation> {
  late double lati;
  late double longi;
  late int balik_adet;
  late String balik_turu;
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> myMarker = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lati = widget.latitude;
    longi = widget.longitude;
    balik_adet = widget.balik_adet;
    balik_turu = widget.balik_turu;
    myMarker.add(Marker(markerId: MarkerId('1'), position: LatLng(lati, longi), infoWindow: InfoWindow(title: balik_turu, snippet: balik_adet.toString() + ' adet')));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(lati, longi), zoom: 14
      ), onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      mapType: MapType.satellite,
      markers: Set<Marker>.of(myMarker),
    ));
  }
}