import 'dart:async';
import 'package:closer/api/api_service.dart';
import 'package:closer/constant/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
class OrderTrackingPage extends StatefulWidget {
  String orderServiceId;
  OrderTrackingPage({Key? key, required this.orderServiceId}) : super(key: key);
  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}
class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation = LatLng(25.297593, 55.378071);
  static const LatLng destination = LatLng(25.2867729,55.3742941);
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  //LocationData? currentLocation;
  LatLng? currentWorkerLocation;


  @override
  void initState() {
    getCurrentLocation();
    //setCustomMarkerIcon();
    getPolyPoints();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    getCurrentLocation();
    return Scaffold(
      body: currentWorkerLocation == null
          ? const Center(child: Text("Loading"))
          :googleMaps(),
    );
  }


  Widget googleMaps(){
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(currentWorkerLocation!.latitude??25.2867729,currentWorkerLocation!.longitude??55.3742941),
        zoom: 13.5,
      ),
      markers: {
        Marker(
          markerId: const MarkerId("currentLocation"),
          icon: currentLocationIcon,
          position: LatLng(
              currentWorkerLocation!.latitude!, currentWorkerLocation!.longitude!),
        ),
        Marker(
          markerId: const MarkerId("source"),
          icon: sourceIcon,
          position: sourceLocation,
        ),
        Marker(
          markerId: const MarkerId("destination"),
          icon: destinationIcon,
          position: destination,
        ),
      },
      polylines: {
        Polyline(
          polylineId: const PolylineId("route"),
          points: polylineCoordinates,
          color: const Color(0xFF7B61FF),
          width: 6,
        ),
      },
      onMapCreated: (mapController) {
        _controller.complete(mapController);
      },
    );
  }

  List<LatLng> polylineCoordinates = [];

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Strings.mapKey, // Your Google Map Key
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
            (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/Pin_source.png")
        .then(
          (icon) {
        sourceIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/Pin_destination.png")
        .then(
          (icon) {
        destinationIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/Badge.png")
        .then(
          (icon) {
        currentLocationIcon = icon;
      },
    );
  }

  void getCurrentLocation() async {
    //Location location = Location();
    GoogleMapController googleMapController = await _controller.future;
    Timer.periodic(Duration(seconds: 2), (timer) async{
      await APIService.checkLocation(widget.orderServiceId).then(
            (location) {
          //currentLocation = location;
              if(location!=null) currentWorkerLocation = LatLng(location!.latitude, location!.longitude);
        },
      );
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
            target: currentWorkerLocation!,
          ),
        ),
      );
      setState(() {});
      setState(() {

      });
    });

    /*location.onLocationChanged.listen(
          (newLoc) {
        //currentWorkerLocation = newLoc;
            currentWorkerLocation = LatLng(newLoc.latitude!, newLoc.longitude!);
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      },
    );*/
  }

}