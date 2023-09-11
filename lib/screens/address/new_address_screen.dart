import 'dart:convert';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:closer/constant/app_size.dart';
import 'package:closer/constant/functions.dart';
import 'package:closer/constant/strings.dart';
import 'package:closer/map/location.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:closer/api/api_service.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/const.dart';
import 'package:closer/localizations.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../../MyWidget.dart';
import 'manege_address.dart';
import 'package:geocoding/geocoding.dart';

var areaId;

// ignore: must_be_immutable
class NewAddressScreen extends StatefulWidget {
  String token;
  List<Placemark>? newPlace;
  String? id;

  NewAddressScreen({required this.token, this.newPlace});

  @override
  _NewAddressScreenState createState() => _NewAddressScreenState(this.token);
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  String? lng;
  String token;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _nearController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _aprController = TextEditingController();
  Color homeColor = Colors.blueGrey;
  Color workColor = Colors.blueGrey;
  String home = '';
  String work = '';
  String? value;
  final bool _getDataFromServer = false;
  bool _saving = false;
  String autocompletePlace = "null";
  Prediction? initialValue;
  Geometry? position;

  _setAddress() {
    if (widget.newPlace != null) {
        _titleController.text = widget.newPlace!.first.name??'';
        _countryController.text = widget.newPlace!.first.country??'';
        _cityController.text = widget.newPlace!.first.locality??'';
        _areaController.text = widget.newPlace!.first.subLocality??'';
        _nearController.text = widget.newPlace!.first.street??'';
    }
  }

  void _showPlacePicker() async {
    getCurrentLocation();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MapLocationPicker(
            apiKey: Strings.mapKey,
            canPopOnNextButtonTaped: true,
            currentLatLng: currentLocation == null
                ? LatLng(29.146727, 76.464895)
                : LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
            onNext: (GeocodingResult? result) async{
              if(result != null)
              {
                position = result.geometry;
                widget.newPlace = await placemarkFromCoordinates(position!.location.lat, position!.location.lng);
                _setAddress();
              }},
            onSuggestionSelected: (PlacesDetailsResponse? result) {
              if (result != null) {
                setState(() {
                  autocompletePlace = result.result.formattedAddress ?? "";
                });
              }
            },
          );
        },
      ),
    );
  }

  _NewAddressScreenState(
    this.token,
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getCountryData();
    //getCityData();
    // print(subservice);
  }

  _save() async {
    print('begin');
    if(position == null){
      await Flushbar(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 20),
        icon: Icon(
          Icons.error_outline,
          size: MediaQuery.of(context).size.width / 18,
          color: Colors.white,
        ),
        duration: Duration(seconds: 3),
        shouldIconPulse: false,
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: BorderRadius.all(
          Radius.circular(MediaQuery.of(context).size.height / 37),
        ),
        backgroundColor: Colors.grey.withOpacity(0.5),
        barBlur: 20,
        message: AppLocalizations.of(context)!.translate('Select location on map'),
        messageSize: MediaQuery.of(context).size.width / 22,
      ).show(context);
      return;
    }
    if (_titleController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _areaController.text.isNotEmpty) {
      setState(() {
        _saving = true;
      });
      print('t');
      await addAdrees();
      setState(() {
        getAddress(userData!.content!.id);
      });
      showInterstitialAdd();
      print('finish');
      country.clear();
      city.clear();
      area.clear();
      await Future.delayed(Duration(seconds: 1));
      setState(() {});
      // ignore: use_build_context_synchronously
      MyApplication.navigateToReplace(context, MagageAddressScreen(token: token,));
    } else {
      await Flushbar(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 20),
        icon: Icon(
          Icons.error_outline,
          size: MediaQuery.of(context).size.width / 18,
          color: Colors.white,
        ),
        duration: Duration(seconds: 3),
        shouldIconPulse: false,
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: BorderRadius.all(
          Radius.circular(MediaQuery.of(context).size.height / 37),
        ),
        backgroundColor: Colors.grey.withOpacity(0.5),
        barBlur: 20,
        message: AppLocalizations.of(context)!.translate('Area is required'),
        messageSize: MediaQuery.of(context).size.width / 22,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var barHight = MediaQuery.of(context).size.height / 5.5;

    return SafeArea(
      child: Scaffold(
        appBar: MyWidget.appBar(title: AppLocalizations.of(context)!.translate('Address')),
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Center(
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width / 1.2,
                height: MediaQuery.of(context).size.height / 80,
                decoration: const BoxDecoration(
                  color: Color(0xffffca05),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
              ),
            ),
            _getDataFromServer
                ? Center(child: MyWidget.jumbingDotes(_getDataFromServer))
                : SizedBox(
                    height: MediaQuery.of(context).size.height / 80,
                  ),

            /*Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      //vertical: MediaQuery.of(context).size.height / 160,
                      horizontal: MediaQuery.of(context).size.width / 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(
                                () {
                                  homeColor = Color(0xffffca05);
                                  workColor = Colors.blueGrey;
                                  home = "home";
                                  work = '';
                                },
                              );
                            },
                            child: MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate("home"), color: homeColor, scale: 1.3),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(
                                () {
                                  workColor = Color(0xffffca05);
                                  homeColor = Colors.blueGrey;
                                  home = "";
                                  work = 'work';
                                },
                              );
                            },
                            child: MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate("Work"), color: workColor, scale: 1.3),
                          )
                        ],
                      ),
                      Divider(
                        thickness: 2,
                        color: Color(0xffffca05),
                      )
                    ],
                  ),
                ),
              ),*/
            MyWidget(context).raisedButton(
                AppLocalizations.of(context)!.translate('Pick from map'),
                () => _showPlacePicker(),
                AppWidth.w90,
                false),
            Expanded(
              flex: 10,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height / 100,
                  ),
                  child: Column(
                    children: [
                      /*Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height / 160,
                              horizontal:
                                  MediaQuery.of(context).size.width / 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width / 20),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: cityValue,
                                  isExpanded: true,
                                  iconSize: 0.0,
                                  hint: Row(
                                    children: [
                                      Expanded(
                                        flex: 9,
                                        child: MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate("City"), bold: false)
                                      ),
                                    ],
                                  ),
                                  items: city.map(buildMenuItem1).toList(),
                                  onChanged: (cityValue) {
                                    setState(() => this.cityValue = cityValue);
                                    area.clear();
                                    getAreaData(cityValue);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height / 160,
                              horizontal:
                                  MediaQuery.of(context).size.width / 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width / 20),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: areaValue,
                                  isExpanded: true,
                                  iconSize: 0.0,
                                  hint: Row(
                                    children: [
                                      Expanded(
                                        flex: 9,
                                      child: MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate("Area"), bold: false)
                                      )],
                                  ),
                                  items: area.map(buildMenuItem2).toList(),
                                  onChanged: (areaValue) {
                                    setState(() => this.areaValue = areaValue);
                                    getAreaId(areaValue);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),*/
                      MyWidget(context).textFiledAddress(_titleController,
                          AppLocalizations.of(context)!.translate('Title')),
                      MyWidget(context).textFiledAddress(_countryController,
                          AppLocalizations.of(context)!.translate('Country')),
                      MyWidget(context).textFiledAddress(_cityController,
                          AppLocalizations.of(context)!.translate('City')),
                      MyWidget(context).textFiledAddress(_areaController,
                          AppLocalizations.of(context)!.translate('Area')),
                      MyWidget(context).textFiledAddress(_nearController,
                          AppLocalizations.of(context)!.translate('Near by')),
                      MyWidget(context).textFiledAddress(
                          _buildingController,
                          AppLocalizations.of(context)!
                              .translate('Building number/name')),
                      MyWidget(context).textFiledAddress(_floorController,
                          AppLocalizations.of(context)!.translate('Floor')),
                      MyWidget(context).textFiledAddress(
                          _aprController,
                          AppLocalizations.of(context)!
                              .translate('Apartment number')),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height / 160,
                            horizontal: MediaQuery.of(context).size.width / 20),
                        child: Container(
                          alignment: Alignment.bottomRight,
                          // ignore: deprecated_member_use
                          child: MyWidget(context).raisedButton(
                              AppLocalizations.of(context)!.translate('Save'),
                              () => _save(),
                              MediaQuery.of(context).size.width / 1.2,
                              _saving,
                              buttonText: Color(0xffffca05),
                              colorText: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Expanded(
            //   flex: 2,
            //   child:
            // ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Row(
          children: [
            Text(
              item,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
  DropdownMenuItem<String> buildMenuItem1(String item) => DropdownMenuItem(
        value: item,
        child: Row(
          children: [
            Text(
              item,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
  DropdownMenuItem<String> buildMenuItem2(String item) => DropdownMenuItem(
        value: item,
        child: Row(
          children: [
            Text(
              item,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
  Future addAdrees() async {
    print('AddAddress function is called');
    print('AddAddress function is called');
    var apiUrl =
    Uri.parse('$apiDomain/Main/ProfileAddress/ProfileAddress_Create?');
    Map mapDate = {
      "UserId": userData!.content!.id,
       "notes": _nearController.text,
      "building": _buildingController.text,
      "floor": _floorController.text,
      "appartment": _aprController.text,
      "lat": position!.location.lat,
      "lng": position!.location.lng,
      "Title": _titleController.text
    };
    http.Response response =
    await http.post(apiUrl, body: jsonEncode(mapDate), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token,
    });
    if (response.statusCode == 200) {
      print(response.body);
      print('success');
    } else {
      print('fail');
    }
    print('AddAddress function is finished');
    setState(() {
      getAddress(userData!.content!.id);
    });
  }

  Future updateAddress() async {
    print('AddAddress function is called');
    print('AddAddress function is called');
    var apiUrl =
    Uri.parse('$apiDomain/Main/ProfileAddress/ProfileAddress_Update?');
    Map mapDate = {
      "id": widget.id,
      "UserId": userData!.content!.id,
       "notes": _nearController.text,
      "building": _buildingController.text,
      "floor": _floorController.text,
      "appartment": _aprController.text,
      "lat": position!.location.lat,
      "lng": position!.location.lng,
      "Title": _titleController.text
    };
    http.Response response =
    await http.post(apiUrl, body: jsonEncode(mapDate), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token,
    });
    if (response.statusCode == 200) {
      print(response.body);
      print('success');
    } else {
      print('fail');
    }
    print('AddAddress function is finished');
    setState(() {
      getAddress(userData!.content!.id);
    });
  }

  void getAddress(var id) async {
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
      Address = item;
    } else {
      Address = [];
    }
    _saving = false;
  }
  /*
  void getCountryData() async {

    _getDataFromServer = true;
    var url = Uri.parse('$apiDomain/Main/Country/Country_Read');

    http.Response response = await http.get(
      url,
      headers: {
        "Authorization": token,
      },
    );
    if (response.statusCode == 200) {
      var item = json.decode(response.body);
      setState(
        () {
          //country = item;
          for (int i = 0; i < item.length; i++) {
            if (item["Data"][i]["Name"] == 'C') {
              country.add(item["Data"][i]["Name"]);
            }
          }

          // print(country);
          // print(item);
        },
      );
    } else {
      setState(
        () {
/*
          print(response.statusCode);
*/
          print(99999);

          //country = [];
        },
      );
    }
    _getDataFromServer = false;
  }

  void getCityData() async {
    _getDataFromServer = true;
    print("getCityData is called");
    city.clear();
    var url = Uri.parse('$apiDomain/Main/City/City_Read');

    http.Response response = await http.get(
      url,
      headers: {
        "Authorization": token,
      },
    );
    if (response.statusCode == 200) {
      print("response.statusCode is 200");
      var item = json.decode(response.body);
      setState(
        () {
          //country = item;
          for (int i = 0; i < item["Data"].length; i++) {
            if (item["Data"][i]["Country"]['Name']== 'Turkey') {
/*
              print(item["Data"][i]["Name"]);
*/
              city.add(item["Data"][i]["Name"]);
            }
          }
        },
      );
    } else {
      setState(
        () {
/*
          print("response.statusCode is NOT 200");
*/

          //country = [];
        },
      );
    }
    print("getCityData finished");
    _getDataFromServer = false;
  }

  void getAreaData(val) async {
    _getDataFromServer = true;
    area.clear();
    print("getAreaData is called");
    var url = Uri.parse('$apiDomain/Main/Area/Area_Read');
    http.Response response = await http.get(
      url,
      headers: {
        "Authorization": token,
      },
    );
    if (response.statusCode == 200) {
      var item = json.decode(response.body);
/*      print("Areas");*/
      setState(
        () {
          areaa = item;
          //area.add(item["Data"][0]["Name"]);
          for (int i = 0; i < item["Data"].length; i++) {
            if (item["Data"][i]["City"]['Name'] == val) {
              area.add(item["Data"][i]["Name"]);
            }
          }
        },
      );
    } else {
      setState(
        () {
          print(99999);
        },
      );
    }
    print("getAreaData is finished");
    _getDataFromServer = false;
  }

  void getAreaId(val) {
    print("****************************************");
    for (int i = 0; i < areaa["Data"].length; i++) {
      //print(areaa["Data"][i]['Name']);
      if (areaa["Data"][i]['Name'] == val) {
        areaId = areaa["Data"][i]["Id"];
        print(areaId);
      }
    }
    print("****************************************");
  }
*/

}
