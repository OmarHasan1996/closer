import 'dart:convert';
import 'dart:math';

import 'package:closer/constant/functions.dart';
import 'package:closer/constant/strings.dart';
import 'package:closer/map/location.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:closer/api/api_service.dart';
import 'package:closer/localizations.dart';
import 'package:closer/screens/new_address_screen.dart';

import '../MyWidget.dart';
import '../const.dart';
import 'package:map_location_picker/map_location_picker.dart';

// ignore: must_be_immutable
class MagageAddressScreen extends StatefulWidget {
  String token;

  MagageAddressScreen({
    required this.token,
  });

  @override
  _MagageAddressScreenState createState() =>
      _MagageAddressScreenState(this.token);
}

class _MagageAddressScreenState extends State<MagageAddressScreen> {
  String? lng;
  String token;
  TextEditingController nameController = new TextEditingController();
  TextEditingController mailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();

  /*void getSubServiceDecData(var id) async {
    // print(id);
    var url =
    Uri.parse('https://mr-service.online/Main/Services/Services_Read?filter=IsMain~eq~false~and~Id~eq~$id');

    http.Response response = await http.get(url, headers: {
      "Authorization": token,
    });
    if (response.statusCode == 200) {

      var item = json.decode(response.body)["result"]['Data'];
      setState(() {

        subservicedec = item;
        //print(subservicedec);
      });

      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubServiceDec(token: token,subservicedec:subservicedec)));

    } else {
      setState(() {
        subservicedec = [];
      });
    }


  }*/
  _MagageAddressScreenState(
    this.token,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAddress(userData!.content!.id);
    // print(subservice);
  }

  @override
  Widget build(BuildContext context) {
    var barHight = MediaQuery.of(context).size.height / 5.5;
    //getServiceData();

    return SafeArea(
        child: Scaffold(
          appBar: new AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: barHight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            backgroundColor: Color(0xff2e3191),
            // bottom: PreferredSize(
            //   preferredSize: Size.fromHeight(MediaQuery.of(context).size.height/5.5),
            //   child: SizedBox(),
            // ),
            //leading: Image.asset('assets/images/Logo1.png'),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/Logo1.png',
                width: MediaQuery.of(context).size.width / 6,
                height: barHight / 2,
              ),
            ),
            actions: [
              new IconButton(
                icon: new Icon(Icons.arrow_back_outlined),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          backgroundColor: Colors.grey[100],
          body: Column(
            children: [
              Center(
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: MediaQuery.of(context).size.height / 80,
                  decoration: BoxDecoration(
                    color: Color(0xffffca05),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 80,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height / 40,
                        horizontal: MediaQuery.of(context).size.width / 20,
                      ),
                      child: MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate("Manager Address"),scale: 1.3)
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: Address.length,
                        itemBuilder: (context, index) {
                          //totalPrice =0;
                          return addresslist(Address, index);
                        },
                        addAutomaticKeepAlives: false,
                      ),
                    ),
                    MyWidget(context).raisedButton(AppLocalizations.of(context)!.translate('Add Address'), (){
                      _showPlacePicker();
                      /*MyApplication.navigateTo(context, NewAddressScreen(token: token));
                      setState(() {
                        getAddress(userData!.content!.id);
                      });*/
                    }, MediaQuery.of(context).size.width / 1.2, false, padV: 0.1),
                  ],
                ),
              ),
            ],
          ),
        ),

    );
  }

  Padding addresslist(ord, ind) {
    // getAddress(userData["content"]["Id"]);

    // print("index" + '$index');
    var area = ord[ind]['Area']['Name'];
    var city = ord[ind]['Area']['City']['Name'];
    var country = ord[ind]['Area']['City']['Country']['Name'];
    var building = ord[ind]['building'];
    var floor = ord[ind]['floor'];
    var appartment = ord[ind]['appartment'];

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 160,
          horizontal: MediaQuery.of(context).size.width / 40),
      child: Column(
        children: [
          Container(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width / 22),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 8,
                  child: MyWidget(context).textBlack20(country + '/' + city + '/' + area + '/' + building + '/' + floor + '/' + appartment,),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      setState(
                        () {
                          deletAddress(ord, ind);
                          //getAddress(userData["content"]["Id"]);
                          /*Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  MagageAddressScreen(token: ''),
                            ),
                          );*/
                        },
                      );
                      setState(
                        () {
                          getAddress(userData!.content!.id);
                        },
                      );
                    },
                    child: Icon(
                      Icons.delete,
                      size: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45),
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 80,
          ),
          Divider(
            color: Colors.grey[900],
            height: 1,
          ),
        ],
      ),
    );
  }

  void getAddress(var id) async {
/*
    print(id);
*/
    var url = Uri.parse(
        "$apiDomain/Main/ProfileAddress/ProfileAddress_Read?filter=UserId~eq~'$id'");

    http.Response response = await http.get(
      url,
      headers: {
        "Authorization": token,
      },
    );
    if (response.statusCode == 200) {
      var item = json.decode(response.body)["result"]['Data'];
      setState(
        () {
          Address = item;
          editTransactionUserAddress(transactions![0], item);
        },
      );
    } else {
/*
      print(response.statusCode);
*/
      setState(
        () {
          Address = [];
        },
      );
    }
    print("Address length");
    print(Address.length);
  }

  void deletAddress(ord, ind) async {
    var addid = ord[ind]['Id'];
    var apiUrl = Uri.parse(
        '$apiDomain/Main/ProfileAddress/ProfileAddress_Destroy?');

    Map mapDate = {
      "guidParam": "$addid",
    };

    http.Response response = await http.post(
      apiUrl,
      body: jsonEncode(mapDate),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": token,
      },
    );

    if (response.statusCode == 200) {
/*
      print(response.body);
*/
      print('success');
    } else {
/*
      print(response.statusCode);
*/
      print('fail');
    }
    setState(
      () {
        getAddress(userData!.content!.id);
      },
    );
  }
  String address = "null";
  String autocompletePlace = "null";
  Prediction? initialValue;

  void _showPlacePicker() async {
    getCurrentLocation();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MapLocationPicker(
            apiKey: Strings.mapKey,
            canPopOnNextButtonTaped: true,
            currentLatLng: currentLocation == null? LatLng(29.146727, 76.464895):LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            onNext: (GeocodingResult? result) {
              if (result != null) {
                setState(() {
                  address = result.formattedAddress ?? "";
                });
              }
            },
            onSuggestionSelected: (PlacesDetailsResponse? result) {
              if (result != null) {
                setState(() {
                  autocompletePlace =
                      result.result.formattedAddress ?? "";
                });
              }
            },
          );
        },
      ),
    );
  }
}
