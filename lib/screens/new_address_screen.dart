import 'dart:convert';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:closer/api/api_service.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/const.dart';
import 'package:closer/localizations.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../MyWidget.dart';
import 'manege_address.dart';

var areaId;

// ignore: must_be_immutable
class NewAddressScreen extends StatefulWidget {
  String token;

  NewAddressScreen({
    required this.token,
  });

  @override
  _NewAddressScreenState createState() => _NewAddressScreenState(this.token);
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  String? lng;
  String token;
  TextEditingController nearController = new TextEditingController();
  TextEditingController buildingController = new TextEditingController();
  TextEditingController floorController = new TextEditingController();
  TextEditingController aprController = new TextEditingController();
  Color homeColor = Colors.blueGrey;
  Color workColor = Colors.blueGrey;
  String home = '';
  String work = '';
  String? value;
  String? cityValue;
  String? areaValue;
  bool _getDataFromServer = false;
  bool _saving = false;


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
  _NewAddressScreenState(
    this.token,
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCountryData();
    getCityData();

    // print(subservice);
  }

  _save() async{
    print('begin');
    print(this.areaValue);
    if (this.areaValue != null) {
      setState(() {
        _saving = true;
      });
      await AddAdrees();
      setState(() {
        getAddress(userData["content"]["Id"]);
      });
      showInterstitialAdd();
      print('finish');
      country.clear();
      city.clear();
      area.clear();
      await Future.delayed(Duration(seconds: 1));
      setState(() {
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
          new MagageAddressScreen(
            token: token,
          ),
        ),
      );
    } else {
      await Flushbar(
          padding: EdgeInsets.symmetric(
          vertical:
          MediaQuery.of(context).size.height /
          20),
    icon: Icon(
    Icons.error_outline,
    size: MediaQuery.of(context).size.width /
    18,
    color: Colors.white,
    ),
    duration: Duration(seconds: 3),
    shouldIconPulse: false,
    flushbarPosition: FlushbarPosition.TOP,
    borderRadius: BorderRadius.all(
    Radius.circular(
    MediaQuery.of(context).size.height /
    37),
    ),
    backgroundColor:
    Colors.grey.withOpacity(0.5),
    barBlur: 20,
    message: AppLocalizations.of(context)!.translate('Area is required'),
    messageSize:
    MediaQuery.of(context).size.width / 22,
    ).show(context);
  }
  }
  @override
  Widget build(BuildContext context) {
    var barHight = MediaQuery.of(context).size.height / 5.5;

    return  SafeArea(
        child: Scaffold(
          appBar: new AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: barHight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24)),
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
                onPressed: () {
                  country.clear();
                  city.clear();
                  area.clear();
                  Navigator.of(context).pop();
                },
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
              _getDataFromServer?
                  Center(child: _jumbingDotes(_getDataFromServer))
              : SizedBox(
                height: MediaQuery.of(context).size.height / 80,
              ),

              Expanded(
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
              ),
              Expanded(
                flex: 10,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height / 100,
                    ),
                    child: Column(
                      children: [
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
                        ),
                        MyWidget(context).textFiledAddress(
                        nearController,
                            AppLocalizations.of(context)!.translate('Near by')),
                        MyWidget(context).textFiledAddress(
                            buildingController,
                            AppLocalizations.of(context)!.translate('Building number/name')),
                        MyWidget(context).textFiledAddress(
                        floorController,
                        AppLocalizations.of(context)!.translate('Floor')),
                        MyWidget(context).textFiledAddress(
                          aprController,
                            AppLocalizations.of(context)!.translate('Apartment number')),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height / 160,
                              horizontal:
                                  MediaQuery.of(context).size.width / 20),
                          child: Container(
                            alignment: Alignment.bottomRight,
                            // ignore: deprecated_member_use
                            child: MyWidget(context).raisedButton(AppLocalizations.of(context)!.translate('Save'), ()=> _save(), MediaQuery.of(context).size.width / 1.2, _saving, buttonText: Color(0xffffca05), colorText: Colors.black),
                            /*RaisedButton(
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.height / 12)),
                              color: Color(0xffffca05),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width / 15),
                                child: _saving == true
                                    ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      MyColors.blue),
                                  backgroundColor: Colors.grey,
                                )
                                    :Text(
                                  AppLocalizations.of(context)!.translate('Save'),
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 25,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                print('begin');
                                print(this.areaValue);
                                if (this.areaValue != null) {
                                  setState(() {
                                    _saving = true;
                                  });
                                  await AddAdrees();
                                  setState(() {
                                    getAddress(userData["content"]["Id"]);
                                  });
                                  showInterstitialAdd();
                                  print('finish');
                                  country.clear();
                                  city.clear();
                                  area.clear();
                                  await Future.delayed(Duration(seconds: 1));
                                  setState(() {
                                  });

                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          new MagageAddressScreen(
                                        token: token,
                                      ),
                                    ),
                                  );
                                } else {
                                  await Flushbar(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            MediaQuery.of(context).size.height /
                                                20),
                                    icon: Icon(
                                      Icons.error_outline,
                                      size: MediaQuery.of(context).size.width /
                                          18,
                                      color: Colors.white,
                                    ),
                                    duration: Duration(seconds: 3),
                                    shouldIconPulse: false,
                                    flushbarPosition: FlushbarPosition.TOP,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          MediaQuery.of(context).size.height /
                                              37),
                                    ),
                                    backgroundColor:
                                        Colors.grey.withOpacity(0.5),
                                    barBlur: 20,
                                    message: AppLocalizations.of(context)!.translate('Area is required'),
                                    messageSize:
                                        MediaQuery.of(context).size.width / 22,
                                  ).show(context);
                                }
                              },
                            ),*/
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

  _jumbingDotes(bool loading){
    if(loading)
      return JumpingDotsProgressIndicator(
        fontSize: 40.0,
        numberOfDots:7,
      );
    else
      return SizedBox();
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

  Future AddAdrees() async {
    print('AddAddress function is called');
    var apiUrl = Uri.parse(
        '$apiDomain/Main/ProfileAddress/ProfileAddress_Create?');
    Map mapDate = {
      "UserId": userData["content"]["Id"],
      "AreaId": areaId.toString(),
      "notes": nearController.text,
      "building": buildingController.text,
      "floor": floorController.text,
      "appartment": aprController.text,
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
/*
      print(response.statusCode);
*/
      print('fail');
    }
    print('AddAddress function is finished');
    setState(() {
      getAddress(userData["content"]["Id"]);
    });
  }

  void getAddress(var id) async {
/*    print("getAddress is called");
    print(id);*/
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
}
