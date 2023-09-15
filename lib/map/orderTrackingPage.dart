import 'dart:async';
import 'package:closer/api/api_service.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/constant/app_size.dart';
import 'package:closer/constant/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
class OrderTrackingPage extends StatefulWidget {
  final String orderServiceId;
  final LatLng distination;
  OrderTrackingPage({Key? key, required this.orderServiceId, required this.distination}) : super(key: key);
  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}
class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
 // static const LatLng sourceLocation = LatLng(25.297593, 55.378071);
  late final LatLng destination;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  //LocationData? currentLocation;
  LatLng? currentWorkerLocation;


  @override
  void initState() {
    destination = widget.distination;
    getCurrentLocation();
    //setCustomMarkerIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getPolyPoints();
    return Scaffold(
      body: currentWorkerLocation == null
          ? const Center(child: Text("Loading"))
          :
          Stack(
            children: [
              googleMaps(),
              Padding(
                padding: EdgeInsets.all(AppPadding.p20),
                child: CloseButton(onPressed: (){
                  if(_timer!=null) _timer!.cancel();
                  Navigator.of(context).pop();
                }, color: AppColors.mainColor,
                ),
              ),   ],
          )
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
        /*Marker(
          markerId: const MarkerId("source"),
          icon: sourceIcon,
          position: sourceLocation,
        ),*/
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
   try{
     PolylinePoints polylinePoints = PolylinePoints();
     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
       Strings.mapKey, // Your Google Map Key
       PointLatLng(currentWorkerLocation!.latitude, currentWorkerLocation!.longitude),
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

   }catch(e){

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

  Timer? _timer;
  void getCurrentLocation() async {
    //Location location = Location();
   // GoogleMapController googleMapController = await _controller.future;
   _timer = Timer.periodic(Duration(seconds: 3), (timer) async{
      await APIService.checkLocation(widget.orderServiceId).then(
            (location) {
          //currentLocation = location;
              if(location!=null) currentWorkerLocation = LatLng(location!.latitude, location!.longitude);
        },
      );
      /*googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
            target: currentWorkerLocation!,
          ),
        ),
      );*/
      setState(() {});
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