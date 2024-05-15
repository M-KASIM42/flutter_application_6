import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostLocation extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int balikAdet;
  final String balikTuru;
  const PostLocation({Key? key, required this.latitude, required this.longitude,required this.balikAdet,required this.balikTuru}) : super(key: key);

  @override
  State<PostLocation> createState() => _PostLocationState();
}

class _PostLocationState extends State<PostLocation> {
  late double lati;
  late double longi;
  late int balikAdet;
  late String balikTuru;
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> myMarker = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lati = widget.latitude;
    longi = widget.longitude;
    balikAdet = widget.balikAdet;
    balikTuru = widget.balikTuru;
    myMarker.add(Marker(markerId: const MarkerId('1'), position: LatLng(lati, longi), infoWindow: InfoWindow(title: balikTuru, snippet: '$balikAdet adet')));
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
      circles: Set<Circle>.of([
        Circle(
              circleId: CircleId("1"),
              center: LatLng(lati, longi),
              radius: balikAdet.toDouble() * 5,
              fillColor: Colors.blue.withOpacity(0.5),
              strokeWidth: 0,
            ),
      ]),
    ));
  }
}