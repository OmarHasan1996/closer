// ignore_for_file: file_names, prefer_typing_uninitialized_variables

// import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:closer/api/respons/matrixApiData.dart';
import 'package:closer/constant/strings.dart';
import 'package:closer/map/location.dart';
import 'package:closer/navigationAnimation/fadeTransaction.dart';
import 'package:closer/navigationAnimation/scalePage.dart';
import 'package:closer/navigationAnimation/sizeTransaction.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';

class MyApplication {
  // static Future<bool> checkConnection() async {
  //   var connectivityResult;

  //   connectivityResult = await (Connectivity().checkConnectivity());

  //   {
  //     return connectivityResult == ConnectivityResult.none ? false : true;
  //   }
  // }

  static void navigateToReplace(BuildContext context, Widget page) async {
//    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => page));
    Navigator.of(context).pushReplacement(FadeRoute(page: page));// MaterialPageRoute(builder: (context) => page));
  }

  static void navigateTo(BuildContext context, Widget page) async {
    Navigator.of(context).push(FadeRoute(page: page));//MaterialPageRoute(builder: (context) => page));
  }

  static Future<void> navigateTorePlaceUntil(BuildContext context, Widget page) async {
    await Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: page),//MaterialPageRoute(builder: (context) => page),
          (route) => false,
    );
  }

  static Future<int> distanceFromMyLocation(long, lat) async{
    await getCurrentLocation();
    if(currentLocation!= null){
      double distance = Geolocator.distanceBetween(
        currentLocation!.longitude!,
        currentLocation!.latitude!,
        double.parse(long.toString()),
        double.parse(lat.toString()),
      )*1000;
      return distance.round();
    }
    return 0;
  }

  static Future<MatrixApi?> bearingFromMyLocation(long, lat) async{
    await getCurrentLocation();
    if(currentLocation!= null){
      try {
        var response = await Dio().get('https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${currentLocation!.latitude!},${currentLocation!.longitude!}&origins=$lat,$long&key=${Strings.mapKey}');
        var a = MatrixApi.fromJson(response.data);
        return a;
      } catch (e) {
        print(e);
      }
     // return distance.round();
    }
    return null;
  }

}
