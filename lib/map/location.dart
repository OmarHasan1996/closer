import 'dart:async';

import 'package:closer/const.dart';
import 'package:closer/screens/signin.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

LocationData? currentLocation;

getCurrentLocation() async {
  Location location = Location();
  await location.getLocation().then(
    (location) {
      currentLocation = location;
    },
  );}

updateWokerLocationPackground() async {
    Timer.periodic(Duration(seconds: 2), (timer) async{
      await getCurrentLocation();
      try{
        print("Native called background task: "); //simpleTask will be emitted here.
        var apiUrl = Uri.parse('$apiDomain/Main/Users/SignUp_UpdateInfo?');
        var request = http.MultipartRequest('POST', apiUrl);
        request.fields['Id'] = userData!.content!.id;
        request.fields['Name'] = userInfo["Name"];
        request.fields['LastName'] = userInfo["LastName"];
        request.fields['Mobile'] = userInfo["Mobile"];
        request.fields['Email'] = userInfo["Email"];
        request.fields['Password'] = userInfo["Password"];
        request.fields['Type'] = userInfo["Type"].toString();
        request.fields['lat'] = currentLocation!.latitude.toString()??'';
        request.fields['lng'] = currentLocation!.longitude.toString()??'';
        Map<String, String> headers = {
          "Accept": "application/json",
          "Content-type": "multipart/form-data",
          "Authorization": token,
        };
        request.headers.addAll(headers);
        var response = await request.send();
        if (response.statusCode == 200) {
          print(await response.stream.bytesToString());
      } else {
      print(response.statusCode);
      print('fail');
      }
      }catch(e){
      print('object');

      }
    });


}

