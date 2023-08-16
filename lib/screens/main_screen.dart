import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

//import 'package:admob_flutter/admob_flutter.dart';
import 'package:another_flushbar/flushbar.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:closer/api/api_service.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/localizations.dart';
import 'package:closer/model/transaction.dart';
import 'package:closer/screens/Payment.dart';
import 'package:closer/screens/loading_screen.dart';
import 'package:closer/screens/orderID.dart';
import 'package:closer/screens/sub_service_screen.dart';
import 'package:closer/screens/taskId.dart';
import 'package:closer/screens/valid_code.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:closer/MyWidget.dart';
import 'package:closer/boxes.dart';
import 'package:closer/const.dart';
import 'package:closer/localization_service.dart';
import 'package:closer/main.dart';
import 'checkout.dart';
import 'edit_profile_screen.dart';
import 'manege_address.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:closer/localization_service.dart' as trrrr;
//import 'package:admob_flutter/admob_flutter.dart';

var globalPrice = 0.0;

//var id ;
// ignore: must_be_immutable
class MainScreen extends StatefulWidget {
  String token;
  List service = [];

  MainScreen(
      {required this.token,
      required this.service,
      required this.selectedIndex,
      required this.initialOrderTab});

  int selectedIndex = 0;
  int initialOrderTab = 0;

  @override
  _MainScreenState createState() => _MainScreenState(
      this.token, this.service, this.selectedIndex, this.initialOrderTab);
}

class _MainScreenState extends State<MainScreen> {
  String? lng;
  String token;
  List service = [];
  List subservice = [];
  DateTime? pickDate;
  TimeOfDay? time;

  /*void handleEvent(
      AdmobAdEvent event, Map<String, dynamic>? args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        //showSnackBar('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        //showSnackBar('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        //showSnackBar('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
        //showSnackBar('Admob $adType failed to load. :(');
        break;
      case AdmobAdEvent.rewarded:
        /*showDialog(
          context: _key.currentContext!,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                return true;
              },
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Reward callback fired. Thanks Andrew!'),
                    Text('Type: ${args!['type']}'),
                    Text('Amount: ${args['amount']}'),
                  ],
                ),
              ),
            );
          },
        );*/
        break;
      default:
    }
  }*/

  void showSnackBar(String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  loadBannerAdd(){
    /*bannerSize = AdmobBannerSize.ADAPTIVE_BANNER(
      // height: MediaQuery.of(context).size.height.toInt()-40,
      width: MediaQuery.of(context).size.width.toInt(), // considering EdgeInsets.all(20.0)
    );
    return AdmobBanner(
      adUnitId: getBannerAdUnitId()!,
      adSize: bannerSize!,
      listener: (AdmobAdEvent event,
          Map<String, dynamic>? args) {
        handleEvent(event, args, 'Banner');
      },
      onBannerCreated:
          (AdmobBannerController controller) {
        // Dispose is called automatically for you when Flutter removes the banner from the widget tree.
        // Normally you don't need to worry about disposing this yourself, it's handled.
        // If you need direct access to dispose, this is your guy!
        // controller.dispose();
      },
    );*/
  }

  initAdds(){
    // You should execute `Admob.requestTrackingAuthorization()` here before showing any ad.

   /* bannerSize = AdmobBannerSize.BANNER;


    interstitialAd = AdmobInterstitial(
      adUnitId: getInterstitialAdUnitId()!,
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
        handleEvent(event, args, 'Interstitial');
      },
    );

    rewardAd = AdmobReward(
      adUnitId: getRewardBasedVideoAdUnitId()!,
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
        if (event == AdmobAdEvent.closed) rewardAd.load();
         handleEvent(event, args, 'Reward');
      },
    );

    interstitialAd.load();
    rewardAd.load();*/
  }

  /*
Test Id's from:
https://developers.google.com/admob/ios/banner
https://developers.google.com/admob/android/banner

App Id - See README where these Id's go
Android: ca-app-pub-3940256099942544~3347511713
iOS: ca-app-pub-3940256099942544~1458002511

Banner
Android: ca-app-pub-3940256099942544/6300978111
iOS: ca-app-pub-3940256099942544/2934735716

Interstitial
Android: ca-app-pub-3940256099942544/1033173712
iOS: ca-app-pub-3940256099942544/4411468910

Reward Video
Android: ca-app-pub-3940256099942544/5224354917
iOS: ca-app-pub-3940256099942544/1712485313
*/

  Future _getServiceData(tokenn) async {
    //token = tokenn;
    print(tokenn);
    //var url = Uri.parse('https://mr-service.online/Main/Services/Services_Read?filter=IsMain~eq~true');
    var url = Uri.parse('$apiDomain/Main/Services/Services_Read?filter=ServiceParentId~eq~null');
    http.Response response = await http.get(url, headers: {"Authorization": tokenn!,},);
    if (response.statusCode == 200) {
      var item = await json.decode(response.body)["result"]['Data'];
      service = item;
      editTransactionService(transactions![0], service);
      //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen(token: tokenn, service: service,selectedIndex: 0, initialOrderTab: 0,),),);
    } else {
      //service = [];
      /*Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SignIn(),
        ),
      );*/
    }
  }

  _getServiceDataOffline(_service){
    service = _service;
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen(token: tokenn, service: service,selectedIndex: 0, initialOrderTab: 0,),),);
  }

  void getSubServiceData(var id) async {
    try{
      //var url = Uri.parse('https://mr-service.online/Main/Services/Services_Read?');
      var url = Uri.parse('$apiDomain/Main/Services/Services_Read?filter=ServiceParentId~eq~$id');
      //var url = Uri.parse('https://mr-service.online/Main/Services/Services_Read?filter=IsMain~eq~false~and~ServiceParentId~eq~$id');
      http.Response response = await http.get(
        url,
        headers: {
          "Authorization": token,
        },
      );
      if (response.statusCode == 200) {
        //print(json.decode(response.body));
        var item = json.decode(response.body)["result"]['Data'];
        setState(
              () {
            subservice = item;
            editTransactionService(transactions![0], service);
            editTransactionSubService(transactions![0], subservice, id);
            editTransactionUserUserInfo(transactions![0], userInfo);
          },
        );
        if (subservice.length==1) {
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
            message: 'This service will coming soon'.tr,
            messageSize: MediaQuery.of(context).size.width / 22,
          ).show(context);
        } else {
          allSubServices.clear();
          Navigator.push(context, MaterialPageRoute(builder: (context) => new SubServiceScreen(token: token, subservice: subservice),),).then((_) {
            // This block runs when you have returned back to the 1st Page from 2nd.
            setState(() {
              // Call setState to refresh the page.
            });
          });
        }
      } else {
        setState(
              () {
            subservice = [];
          },
        );
      }
    }
    catch(e){
      subservice = transactions![0].subService;
      if(subservice.length==1){
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
          message: 'This service will coming soon'.tr,
          messageSize: MediaQuery.of(context).size.width / 22,
        ).show(context);
      } else if(subservice[subservice.length-1]["id"]==id) {
        allSubServices.clear();
        Navigator.push(context, MaterialPageRoute(builder: (context) => SubServiceScreen(token: token, subservice: subservice),),).then((_) {
          // This block runs when you have returned back to the 1st Page from 2nd.
          setState(() {
            // Call setState to refresh the page.
          });
        });
      }else{
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
          message: 'This service will coming soon'.tr,
          messageSize: MediaQuery.of(context).size.width / 22,
        ).show(context);
      }
    }
  }

  _MainScreenState(this.token, this.service, this._selectedIndex, this._initialOrderTab);

  @override
  void dispose() {
    //Hive.close();
    //interstitialAd.dispose();
    //rewardAd.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    updateUserInfo(userData["content"]["Id"]);
    api.getGroupUsers(groupId);
    getMyOrders(userData["content"]["Id"]);
    super.initState();

    initAdds();
    getAddress(userData["content"]["Id"]);
    //getWorkersGroup(userData["content"]["Id"]);
    print("************************************************");
    print(userInfo);
    print("Token");
    print(token);
    pickDate = DateTime.now();
    time = TimeOfDay.now();

    //LocalNotificationService.initialize(context);

    ///gives you the message on which user taps
    ///and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        runApp(MyApp());
      }
    });
    ///forground work
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification!.body);
        print(message.notification!.title);

        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: ListTile(
                    title: Text(message.notification!.title.toString(),style: TextStyle(fontSize: MediaQuery.of(context).size.width/25),),
                    subtitle: Text(message.notification!.body.toString(),style: TextStyle(fontSize: MediaQuery.of(context).size.width/20)),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () => {
                              setState(() {
                                _selectedIndex = 1;
                                _initialOrderTab = 1;
                                new Timer(Duration(seconds:2), ()=>setState(() {}));
                                Navigator.pop(context);
                              }),
                            },
                        child: Icon(
                          Icons.check,
                          color: MyColors.yellow,
                        ))
                  ],
                ));
      }

      //LocalNotificationService.display(message);
    });
    ///When the app is in background but opened and user taps
    ///on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      //final routeFromMessage = message.data["main_screen"];
      if(!worker) Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(token: token, service: service, selectedIndex: 1, initialOrderTab: 1,)),
            (Route<dynamic> route) => false,
      );
      else Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(token: token, service: service, selectedIndex: 1, initialOrderTab: 0,)),
            (Route<dynamic> route) => false,
      );

      /*Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MainScreen(
                token: token,
                service: service,
                selectedIndex: 1,
                initialOrderTab: 1,
              )));
      final routeFromMessage = "main_screen";

      Navigator.of(context).restorablePushReplacementNamed(routeFromMessage);*/
    });
    mainService = service;
    api.userLang(trrrr.LocalizationService.getCurrentLangInt(), userData["content"]["Id"]);
  }

  void _afterLayout(Duration timeStamp) {
    /*new Timer(Duration(seconds:5), ()=>setState(()
    {
      getMyOrders(
        userData["content"]["Id"]);
      _loading = false;
    }));*/
  }

  /*
  static Future<bool> sendFcmMessage(String title, String message) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization":
        "key=your_server_key",
      };
      var request = {
        'notification': {'title': title, 'body': message},
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': 'COMMENT'
        },
        'to': 'fcmtoken'
      };
      var client = new Client();
      var response =
      await client.post(url, headers: header, body: json.encode(request));
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }
  */

  _saveDeviceToken() async {
    /*final FirebaseFirestore _db = FirebaseFirestore.instance;
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    String userId = 'omar';
    User user = await FirebaseAuth.instance.currentUser!;
    String? fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      var tokenRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('tokens')
          .doc(fcmToken);
      await tokenRef.set({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }*/
  }

  int _selectedIndex = 0;
  int _initialOrderTab = 0;
  APIService api = APIService();
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  bool _loading = true, _transScreen = false;

  @override
  Widget build(BuildContext context) {
    //api.getGroupUsers(groupId);
    //isBoss = false;
    //getMyOrders(userData["content"]["Id"]);
    //getMyOrders('9cbc8ff2-0bc3-4ed0-f6ce-08d97b89b8984444');
    //showRewardAdd();
    api = APIService(context: context);
    if(worker && _selectedIndex == 0)
      _selectedIndex = 1;
    var totalPrice = globalPrice;
    var barHight = MediaQuery.of(context).size.height / 5.7;
    var profileHieght = MediaQuery.of(context).size.height *0.02;
    //getServiceData();
    TextStyle optionStyle = TextStyle(
        fontSize: 30 /*MediaQuery.of(context).size.width / 22*/,
        fontWeight: FontWeight.bold);
    List<Widget> _widgetOptions = <Widget>[
      Container(
        child: DoubleBackToCloseApp(
          child: Stack(
            children: [
              /*Align(
                alignment: Alignment.topCenter,
                child: circularMenu(),
              ),*/
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                //yellow driver
                _topYellowDriver(),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 160,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height / 37,
                      horizontal: MediaQuery.of(context).size.width / 20),
                  child: Container(
                    //alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 20,
                        right: MediaQuery.of(context).size.width / 20),
                    child: MyWidget(context).textTitle15(AppLocalizations.of(context)!.translate('Our Services'), scale: 1.2),
                  ),
                ),
                Expanded(
                  child:FutureBuilder(
                    future: _getServiceData(token),
                    builder : (BuildContext context, AsyncSnapshot snap){
                      if(snap.connectionState == ConnectionState.waiting){
                        _loading = true;
                        return _jumbingDotes(_loading);
                        return SizedBox();
                      }
                      else{
                        //return SizedBox();
                        _loading = false;
                        return ListView.builder(
                          itemCount: service.length,
                          itemBuilder: (context, index) {
                            return serviceRow(service[index]);
                          },
                          addAutomaticKeepAlives: false,
                        );
                      }
                    },
                  ),
                ),
                loadBannerAdd(),
                _bottomYellowDriver(),
              ]),
              _transScreen?
              MyWidget(context).transScreen():SizedBox()
            ],
          ),
          snackBar: SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('Tap back again to leave')),
          ),
        ),
      ),
      //My order
      Container(
        child: !worker?DoubleBackToCloseApp(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topYellowDriver(),
              ////////////////////////////////////////////////////////////////////
              ////////////////////////////////////////////////////////////////////
              SizedBox(
                height: MediaQuery.of(context).size.height / 300,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height / 100,
                    horizontal: MediaQuery.of(context).size.width / 20),
                child: Container(
                  //alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 20,
                      right: MediaQuery.of(context).size.width / 20),
                  child: MyWidget(context).textTitle15(AppLocalizations.of(context)!.translate('My Order'))
                ),
              ),
              Expanded(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        //vertical: MediaQuery.of(context).size.width / 22,
                        horizontal: MediaQuery.of(context).size.width / 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        DefaultTabController(
                          length: 3, // length of tabs
                          initialIndex: _initialOrderTab,
                          child: Container(
                            decoration: new BoxDecoration(
                              color: MyColors.White,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    MediaQuery.of(context).size.height / 51),
                                topRight: Radius.circular(
                                    MediaQuery.of(context).size.height / 51),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Container(
                                  decoration: new BoxDecoration(
                                    color: MyColors.WhiteSelver,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                          MediaQuery.of(context).size.height /
                                              51),
                                      topRight: Radius.circular(
                                          MediaQuery.of(context).size.height /
                                              51),
                                    ),
                                  ),
                                  child: TabBar(
                                    indicatorColor: Colors.transparent,
                                    labelColor: MyColors.yellow,
                                    unselectedLabelColor: Colors.grey,
                                    indicator: BoxDecoration(
                                      color: MyColors.White,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                    ),
                                    tabs: [
                                      _tap(AppLocalizations.of(context)!
                                          .translate('NewOrders')),
                                      _tap(AppLocalizations.of(context)!
                                          .translate('CurrentOrders')),
                                      _tap(AppLocalizations.of(context)!
                                          .translate('FinishedOrders')),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height /
                                      2.05, //height of TabBarView
                                  /*decoration: BoxDecoration(
                                            border: Border(
                                                top: BorderSide(
                                                    color: Colors.grey,
                                                    width: 0.5))),*/
                                  child: TabBarView(
                                    physics: NeverScrollableScrollPhysics(),
                                    children: <Widget>[
                                      ////////// Tab1
                                      Container(
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: order.length == 0
                                                    ? 0
                                                    : order.length,
                                                itemBuilder: (context, index) {
                                                  //totalPrice =0;s
                                                  return GestureDetector(
                                                    onTap: () {
                                                      //getMyOrders(userInfo["Id"]);
                                                      /*print(
                                                          "------------------");
                                                      print(myOrders.length);
                                                      print(
                                                          "------------------");
                                                      print(
                                                          myOrders['Data'][0]);
                                                      print(
                                                          "------------------");*/
                                                      // order details
                                                      //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                      //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                      //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                    },
                                                    child:
                                                    MyWidget(context).orderlist(order[index],1,()=>_setState()),
                                                  );
                                                },
                                                addAutomaticKeepAlives: false,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          22),
                                              child: Column(
                                                children: [
                                                  MyWidget(context).textBlack20(AppLocalizations.of(
                                                      context)!.translate('TOTAL')),
                                                  MyWidget(context).textTitle15("${AppLocalizations.of(context)!.translate('TRY')} ${sumPrice().toStringAsFixed(3)}", color: Colors.blue),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / 200,),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.2,
                                                      // ignore: deprecated_member_use
                                                      child: MyWidget(context).raisedButton(AppLocalizations.of(
                                                          context)!.translate('Finished Order'), () => _finishOrder(),  MediaQuery.of(context).size.width/1.7, false)
                                                      ,
                                                      /*child: RaisedButton(
                                                        onPressed: () async {
                                                          setState(() {
                                                            adr.clear();
                                                          });
                                                          setState(() {
                                                            getAddress(userData[
                                                                    "content"]
                                                                ["Id"]);
                                                          });
                                                          await Future.delayed(
                                                              Duration(
                                                                  seconds: 1));
                                                          if (order
                                                              .isNotEmpty) {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                                    MaterialPageRoute(
                                                              builder: (context) =>
                                                                  new CheckOutScreen(
                                                                token: token,
                                                                service:
                                                                    service,
                                                              ),
                                                            ));
                                                          }
                                                        },
                                                        // padding: EdgeInsets.symmetric(vertical: 0,horizontal: MediaQuery.of(context).size.width/6),
                                                        color: MyColors.yellow,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(
                                                                Radius.circular(
                                                                    MediaQuery.of(context)
                                                                            .size
                                                                            .height /
                                                                        12))),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                190,
                                                          ),
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)!.translate('Finished Order'),
                                                            style: TextStyle(
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    24,
                                                                color: MyColors
                                                                    .buttonTextColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),*/
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ////////// Tab2
                                      Container(child: Column(
                                          children: [
                                            Expanded(
                                                child: 
                                                FutureBuilder(
                                                    future: getMyOrders(userData["content"]["Id"]),
                                                    builder : (BuildContext context, AsyncSnapshot snap){
                                                      if(snap.connectionState == ConnectionState.waiting){
                                                        _loading = true;
                                                        return _jumbingDotes(_loading);
                                                      return SizedBox();
                                                      }
                                                      else{
                                                        //return SizedBox();
                                                        _loading = false;
                                                        return ListView.builder(
                                                          itemCount:
                                                          orderData != null
                                                              ? orderData.length
                                                              : 0,
                                                          itemBuilder: (context, index) {
                                                            //totalPrice =0;
                                                            return GestureDetector(
                                                              onTap: () {
                                                                _showOrderDetails(
                                                                    orderData[index],
                                                                    index + 1);
                                                                // order details
                                                                //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                                //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                                //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                              },
                                                              child: myOrderlist(
                                                                  orderData[index],
                                                                  index + 1),
                                                            );
                                                          },
                                                          addAutomaticKeepAlives: false,
                                                        );
                                                      }
                                                    },
                                                ),
                                            )
                                          ],
                                        ),),
                                      ////////// Tab3
                                      Container(
                                        child: Column(
                                          children: [
                                            Expanded(
                                                child:
                                                FutureBuilder(
                                                  future: getMyOrders(userData["content"]["Id"]),
                                                  builder : (BuildContext context, AsyncSnapshot snap){
                                                    if(snap.connectionState == ConnectionState.waiting){
                                                      _loading = true;
                                                      return _jumbingDotes(_loading);
                                                      return SizedBox();
                                                    }
                                                    else{
                                                      //return SizedBox();
                                                      _loading = false;
                                                      return ListView.builder(
                                                        itemCount:
                                                        finishedOrderData.length,
                                                        itemBuilder: (context, index) {
                                                          //totalPrice =0;
                                                          return GestureDetector(
                                                            onTap: () {
                                                              /*_showOrderDetails(
                                                                  orderData[index],
                                                                  index + 1);*/
                                                              // order details
                                                              //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                              //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                              //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                            },
                                                            child: myOrderlist(
                                                                finishedOrderData[index],
                                                                index + 1),
                                                          );
                                                        },
                                                        addAutomaticKeepAlives: false,
                                                      );
                                                    }
                                                  },
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _bottomYellowDriver(),
            ],
          ),
          snackBar: SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('Tap back again to leave')),
          ),
        ):
        _workerOrder(),
      ),
      //My profile
      Container(
        child: DoubleBackToCloseApp(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _topYellowDriver(),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 80,
                ),
                Expanded(
                  flex: 3,
                  child: FutureBuilder(
                    future: updateUserInfo(userData["content"]["Id"]),
                    builder : (BuildContext context, AsyncSnapshot snap){
                      if(snap.connectionState == ConnectionState.waiting){
                        _loading = true;
                        return _jumbingDotes(_loading);
                        return SizedBox();
                      }
                      else{
                        //return SizedBox();
                        _loading = false;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.20,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: userInfo == null || userInfo.isEmpty || userInfo['ImagePath'] == '$apiDomain/ProfilesFiles/${userInfo["Id"]} '
                                      ? AssetImage('assets/images/profile.jpg') as ImageProvider : NetworkImage(userInfo['ImagePath']),
                                  //https://t3.ftcdn.net/jpg/03/46/83/96/360_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg
                                  /*image: NetworkImage(
                                  'https://th.bing.com/th/id/OIP.kZO7eZdhGa4hJ_QJAWN7ngAAAA?pid=ImgDet&w=400&h=411&rs=1'),*/
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 3,
                                    offset:
                                    Offset(0, 1), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.all(Radius.circular(
                                    MediaQuery.of(context).size.height / 40)),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              //child: Text(),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyWidget(context).textTitle15('${userInfo == null || userInfo.isEmpty ? "" : userInfo["Name"]}'),
                                MyWidget(context).textTap25('${userInfo == null || userInfo.isEmpty ? "" : userInfo["Email"]}'),
                              ],
                            )
                          ],
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Divider(
                    height: 1,
                    thickness: 2,
                    color: Colors.grey[400],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      userInfo.length==0?api.flushBar(AppLocalizations.of(context)!.translate('Error Connection')):
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              new EditProfileScreen(token: token),
                        ),
                      );
                    },
                    child: MyWidget(context).rowIconProfile(Icons.person_outlined, AppLocalizations.of(context)!.translate("Edit Profile")),
                  ),
                ),
                SizedBox(
                  height: profileHieght,
                  //child: Text(),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              new MagageAddressScreen(token: token),
                        ),
                      );
                    },
                    child: MyWidget(context).rowIconProfile(Icons.pin_drop_outlined, AppLocalizations.of(context)!.translate("Manage Address")),
                  ),
                ),
                SizedBox(
                  height: profileHieght,
                  //child: Text(),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, 'changeLang'),
                    child: MyWidget(context).rowIconProfile(Icons.language_outlined, AppLocalizations.of(context)!.translate("Change Language")),
                  ),
                ),
                SizedBox(
                  height: profileHieght,
                  //child: Text(),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => _changePassword(userInfo["Email"]),
                    child: MyWidget(context).rowIconProfile(Icons.lock_outline, AppLocalizations.of(context)!.translate("Change Password")),
                  ),
                ),
                SizedBox(
                  height: profileHieght,
                  //child: Text(),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: MyWidget(context).rowIconProfile(Icons.more_horiz, "FAQs".tr),
                   // onTap: ()=> showRewardAdd(),
                  ),
                ),
                SizedBox(
                  height: profileHieght,
                  //child: Text(),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: MyWidget(context).rowIconProfile(Icons.mail_outline, AppLocalizations.of(context)!
                        .translate("Contact Us"),),
                    onTap: _goAbout,
                  ),
                ),
                SizedBox(
                  height: profileHieght,
                  //child: Text(),
                ),
                Divider(
                  height: 1,
                  thickness: 2,
                  color: Colors.grey[400],
                ),
                SizedBox(
                  height: profileHieght,
                  //child: Text(),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => api.logOut(),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: MediaQuery.of(context).size.height / 20,
                            child: Icon(
                              Icons.logout,
                              color: MyColors.black,
                              size: min(MediaQuery.of(context).size.width / 12, MediaQuery.of(context).size.height / 28),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width / 22),
                            child: Container(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate("Log Out"),
                                style: TextStyle(
                                  fontSize: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45),
                                  color: MyColors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //_bottomYellowDriver(),
              ],
            ),
          ),
          snackBar: SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('Tap back again to leave')),
          ),
        ),
      )
    ];

    void _onItemTapped(int index) {
      setState(
        () {
          _selectedIndex = index;
        },
      );
    }

    return Scaffold(
          resizeToAvoidBottomInset: true,
          key: _key,
          appBar: new AppBar(
            toolbarHeight: barHight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(
                    MediaQuery.of(context).size.height / 80 * 3),
                bottomLeft: Radius.circular(
                    MediaQuery.of(context).size.height / 80 * 3),
              ),
            ),
            backgroundColor: MyColors.blue,
            // bottom: PreferredSize(
            //   preferredSize: Size.fromHeight(MediaQuery.of(context).size.height/5.5),
            //   child: SizedBox(),
            // ),
            //leading: Image.asset('assets/images/Logo1.png'),
            title: MyWidget(context).appBarTittle(barHight, _key),
          ),
          endDrawer: MyWidget(context).drawer(barHight, MediaQuery.of(context).size.height / 80 * 3, ()=>_setState()),
      backgroundColor: Color(0xffF4F4F9),
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                // ignore: deprecated_member_use
                label: AppLocalizations.of(context)!.translate('Home'),

              ),
              BottomNavigationBarItem(
                icon: !worker? Icon(Icons.shopping_cart_outlined) : Icon(Icons.work),
                // ignore: deprecated_member_use
                label: !worker? AppLocalizations.of(context)!.translate('My Order') :isBoss? AppLocalizations.of(context)!.translate('My Order'): AppLocalizations.of(context)!.translate('MY TASK'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                // ignore: deprecated_member_use
                label: AppLocalizations.of(context)!.translate('My profile'),
              ),
            ],
            currentIndex: _selectedIndex,
            //fixedColor: Colors.white,
            selectedItemColor: MyColors.yellow,
            backgroundColor: MyColors.blue,
            unselectedItemColor: MyColors.White,
            iconSize: MediaQuery.of(context).size.width / 9,
            onTap: _onItemTapped,
          ),
        )
      ;
  }

  _finishOrder() async {
    setState(() {
      adr.clear();
    });
    setState(() {
      getAddress(userData[
      "content"]
      ["Id"]);
    });
    await Future.delayed(
        Duration(
            seconds: 1));
    if (order
        .isNotEmpty) {
      Navigator.of(
          context)
          .push(
          MaterialPageRoute(
            builder: (context) =>
            new CheckOutScreen(
              token: token,
              service:
              service,
            ),
          ));
    }
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

  _workerOrder(){
    if(isBoss)
      return DoubleBackToCloseApp(
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topYellowDriver(),
          ////////////////////////////////////////////////////////////////////
          ////////////////////////////////////////////////////////////////////
          SizedBox(
            height: MediaQuery.of(context).size.height / 160,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 40,
                horizontal: MediaQuery.of(context).size.width / 20),
            child: Container(
              //alignment: Alignment.topLeft,
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 20,
              right: MediaQuery.of(context).size.width / 20),
              child: MyWidget(context).textTitle15(AppLocalizations.of(context)!.translate('Supervisor')),
            ),
          ),
          Expanded(
            child: Container(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  //vertical: MediaQuery.of(context).size.width / 22,
                    horizontal: MediaQuery.of(context).size.width / 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DefaultTabController(
                      length: 3, // length of tabs
                      initialIndex: _initialOrderTab,
                      child: Container(
                        decoration: new BoxDecoration(
                          color: MyColors.White,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                MediaQuery.of(context).size.height / 51),
                            topRight: Radius.circular(
                                MediaQuery.of(context).size.height / 51),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              decoration: new BoxDecoration(
                                color: MyColors.WhiteSelver,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                      MediaQuery.of(context).size.height /
                                          51),
                                  topRight: Radius.circular(
                                      MediaQuery.of(context).size.height /
                                          51),
                                ),
                              ),
                              child: TabBar(
                                indicatorColor: Colors.transparent,
                                labelColor: MyColors.yellow,
                                unselectedLabelColor: Colors.grey,
                                indicator: BoxDecoration(
                                  color: MyColors.White,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                ),
                                tabs: [
                                  _tap(AppLocalizations.of(context)!
                                      .translate('NewOrders')),
                                  _tap(AppLocalizations.of(context)!
                                      .translate('Current Tasks')),
                                  _tap(AppLocalizations.of(context)!
                                      .translate('FinishedOrders')),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height /
                                  2.15, //height of TabBarView
                              /*decoration: BoxDecoration(
                                            border: Border(
                                                top: BorderSide(
                                                    color: Colors.grey,
                                                    width: 0.5))),*/
                              child: TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  ////////// Tab1
                                  Container(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: FutureBuilder(
                                            future: getMyOrders(userData["content"]["Id"]),
                                            builder : (BuildContext context, AsyncSnapshot snap){
                                              if(snap.connectionState == ConnectionState.waiting){
                                                _loading = true;
                                                return _jumbingDotes(_loading);
                                                return SizedBox();
                                              }
                                              else{
                                                //return SizedBox();
                                                _loading = false;
                                                return ListView.builder(
                                                  itemCount:
                                                  superNewOrderData != null
                                                      ? superNewOrderData.length
                                                      : 0,
                                                  itemBuilder: (context, index) {
                                                    //totalPrice =0;
                                                    return GestureDetector(
                                                      onTap: () {
                                                        api.getGroupUsers(groupId);
                                                        Navigator.push(this.context, MaterialPageRoute(builder: (context) => OrderId(token, superNewOrderData[index]),),).then((_) {
                                                          setState(() {});
                                                        });
                                                        // order details
                                                        //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                        //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                        //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                      },
                                                      child:myNewOrderSuperVisorlist(
                                                          superNewOrderData[index], index + 1),
                                                    );
                                                  },
                                                  addAutomaticKeepAlives: false,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ////////// Tab2
                                  Container(
                                    child: Column(
                                      children: [
                                        Expanded(
                                            child: FutureBuilder(
                                              future: getMyOrders(userData["content"]["Id"]),
                                              builder : (BuildContext context, AsyncSnapshot snap){
                                                if(snap.connectionState == ConnectionState.waiting){
                                                  _loading = true;
                                                  return _jumbingDotes(_loading);
                                                  return SizedBox();
                                                }
                                                else{
                                                  //return SizedBox();
                                                  _loading = false;
                                                  return ListView.builder(
                                                    itemCount:
                                                    orderData != null
                                                        ? orderData.length
                                                        : 0,
                                                    itemBuilder: (context, index) {
                                                      //totalPrice =0;
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(this.context, MaterialPageRoute(builder: (context) => TaskId(token, orderData[index]),),).then((_) {
                                                            setState(() {});
                                                          });
                                                          // order details
                                                          //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                          //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                          //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                        },
                                                        child: tasklist(
                                                            orderData[index],
                                                            index + 1),
                                                      );
                                                    },
                                                    addAutomaticKeepAlives: false,
                                                  );
                                                }
                                              },
                                            ),),
                                      ],
                                    ),
                                  ),
                                  ////////// Tab3
                                  Container(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: FutureBuilder(
                                            future: getMyOrders(userData["content"]["Id"]),
                                            builder : (BuildContext context, AsyncSnapshot snap){
                                              if(snap.connectionState == ConnectionState.waiting){
                                                _loading = true;
                                                return _jumbingDotes(_loading);
                                                return SizedBox();
                                              }
                                              else{
                                                //return SizedBox();
                                                _loading = false;
                                                return ListView.builder(
                                                  itemCount:
                                                  finishedOrderData.length,
                                                  itemBuilder: (context, index) {
                                                    //totalPrice =0;
                                                    return GestureDetector(
                                                      onTap: () {
                                                        /*_showOrderDetails(
                                                            finishedOrderData[index],
                                                            index + 1);*/
                                                        // order details
                                                        //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                        //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                        //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                                      },
                                                      child: myNewOrderSuperVisorlist(
                                                          finishedOrderData[index],
                                                          index + 1),
                                                    );
                                                  },
                                                  addAutomaticKeepAlives: false,
                                                );
                                              }
                                            },
                                          ),),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _bottomYellowDriver(),
        ],
      ),
      snackBar: SnackBar(
        content: Text(AppLocalizations.of(context)!
            .translate('Tap back again to leave')),
      ),
    );
    else
      return DoubleBackToCloseApp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topYellowDriver(),
            ////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////
            SizedBox(
              height: MediaQuery.of(context).size.height / 200,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 60,
                  horizontal: MediaQuery.of(context).size.width / 20),
              child: Container(
                //alignment: Alignment.topLeft,
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 20,
                right: MediaQuery.of(context).size.width / 20),
                child: MyWidget(context).textTitle15(AppLocalizations.of(context)!.translate('Worker')),
              ),
            ),
            Expanded(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    //vertical: MediaQuery.of(context).size.width / 22,
                      horizontal: MediaQuery.of(context).size.width / 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DefaultTabController(
                        length: 2, // length of tabs
                        initialIndex: _initialOrderTab,
                        child: Container(
                          decoration: new BoxDecoration(
                            color: MyColors.White,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                  MediaQuery.of(context).size.height / 51),
                              topRight: Radius.circular(
                                  MediaQuery.of(context).size.height / 51),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                decoration: new BoxDecoration(
                                  color: MyColors.WhiteSelver,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        MediaQuery.of(context).size.height /
                                            51),
                                    topRight: Radius.circular(
                                        MediaQuery.of(context).size.height /
                                            51),
                                  ),
                                ),
                                child: TabBar(
                                  indicatorColor: Colors.transparent,
                                  labelColor: MyColors.yellow,
                                  unselectedLabelColor: Colors.grey,
                                  indicator: BoxDecoration(
                                    color: MyColors.White,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                  ),
                                  tabs: [
                                    /*_tap(AppLocalizations.of(context)!
                                        .translate('NewOrders')),*/
                                    _tap(AppLocalizations.of(context)!
                                        .translate('New Tasks')),
                                    _tap(AppLocalizations.of(context)!
                                        .translate('Finished Tasks')),
                                  ],
                                ),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height /
                                    2.15, //height of TabBarView
                                /*decoration: BoxDecoration(
                                            border: Border(
                                                top: BorderSide(
                                                    color: Colors.grey,
                                                    width: 0.5))),*/
                                child: TabBarView(
                                  physics: NeverScrollableScrollPhysics(),
                                  children: <Widget>[
                                    ////////// Tab1
                                    ////////// Tab2
                                    Container(
                                      child: Column(
                                        children: [
                                          Expanded(
                                              child: FutureBuilder(
                                                future: getMyOrders(userData["content"]["Id"]),
                                                builder : (BuildContext context, AsyncSnapshot snap){
                                                  if(snap.connectionState == ConnectionState.waiting){
                                                    _loading = true;
                                                    return _jumbingDotes(_loading);
                                                  }
                                                  else{
                                                    _loading = false;
                                                    return ListView.builder(
                                      itemCount:
                                      orderData != null
                                          ? orderData.length
                                          : 0,
                                      itemBuilder: (context, index) {
                                        //totalPrice =0;
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(this.context, MaterialPageRoute(builder: (context) => TaskId(token, orderData[index]),),).then((_) {
                                              setState(() {});
                                            });
                                            /*_showOrderDetails(
                                                orderData[index],
                                                index + 1);*/
                                            // order details
                                            //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                            //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                            //**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**
                                          },
                                          child: tasklist(
                                              orderData[index],
                                              index + 1),
                                        );
                                      },
                                      addAutomaticKeepAlives: false,
                                    );
                                                  }
                                                  },
                                              ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ////////// Tab3
                                    Container(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: FutureBuilder(
                                              future: getMyOrders(userData["content"]["Id"]),
                                              builder : (BuildContext context, AsyncSnapshot snap){
                                                if(snap.connectionState == ConnectionState.waiting){
                                                  _loading = true;
                                                  return _jumbingDotes(_loading);
                                                }
                                                else{
                                                  _loading = false;
                                                  return ListView.builder(
                                                    itemCount:
                                                    finishedOrderData.length,
                                                    itemBuilder: (context, index) {
                                                      //totalPrice =0;
                                                      return GestureDetector(
                                                        onTap: () {
                                                          /*_showOrderDetails(
                                                              orderData[index],
                                                              index + 1);*/
                                                          },
                                                        child: tasklist(
                                                            finishedOrderData[index],
                                                            index + 1),
                                                      );
                                                    },
                                                    addAutomaticKeepAlives: false,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _bottomYellowDriver(),
          ],
        ),
        snackBar: SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('Tap back again to leave')),
        ),
      );
  }

  bool chCircle = false;
  _button(text, click(),width) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 100,
      ),
      child: Container(
        width: width,
        // ignore: deprecated_member_use
          child: MyWidget(context).raisedButton(text, () => click(),  width, chCircle),
      ),
    );
  }

  _goAbout() {
    Navigator.pushNamed(context, 'about');
  }

  _topYellowDriver() {
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width / 1.2,
        height: MediaQuery.of(context).size.height / 80,
        decoration: BoxDecoration(
          color: MyColors.yellow,
          borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(MediaQuery.of(context).size.height / 80)),
        ),
      ),
    );
  }

  _bottomYellowDriver() {
    return Container(
        child: Column(
      children: [
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 90,
          decoration: BoxDecoration(
            color: MyColors.yellow,
          ),
        ),
      ],
    ));
  }

  _tap(String text) {
    return Tab(
      height: min(MediaQuery.of(context).size.width/15, MediaQuery.of(context).size.height/35)*2,
      child: Center(
        child: GestureDetector(
          onDoubleTap: () {
            setState(() {
            });
          },
          child: MyWidget(context).textTap25(text),
        ),
      ),
    );
  }

  Padding serviceRow(ser) {
    var name = ser['Name'];
    var imagepath = ser['ImagePath'];
    // id = ser['Id'];
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.015,
          horizontal: MediaQuery.of(context).size.width / 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            width: min(MediaQuery.of(context).size.width * 0.28, MediaQuery.of(context).size.height * 0.18),
            height: min(MediaQuery.of(context).size.width / 3.5, MediaQuery.of(context).size.height / 8.5),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(imagepath),
              ),
              borderRadius: BorderRadius.horizontal(
                  left: trrrr.LocalizationService.getCurrentLangInt() == 3? Radius.circular(0): Radius.circular(MediaQuery.of(context).size.height / 51)
                  ,right: trrrr.LocalizationService.getCurrentLangInt() == 3? Radius.circular(MediaQuery.of(context).size.height / 51) : Radius.circular(0)
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.03,
            //child: Text(),
          ),
          GestureDetector(
            onTap: () {
              var id = ser['Id'];
              print("id-name");
              print(id);
              print(name);
              setState(() {
                _transScreen = true;
              });
              getSubServiceData(id);
              setState(() {
                _transScreen = false;
              });
            },
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.85 - min(MediaQuery.of(context).size.width * 0.28, MediaQuery.of(context).size.height * 0.18),
              height: min(MediaQuery.of(context).size.width / 3.5, MediaQuery.of(context).size.height / 8.5),
              decoration: BoxDecoration(
                color: Color(0x1bffca05),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.horizontal(
                    right: trrrr.LocalizationService.getCurrentLangInt() == 3? Radius.circular(0): Radius.circular(MediaQuery.of(context).size.height / 51)
                    ,left: trrrr.LocalizationService.getCurrentLangInt() == 3? Radius.circular(MediaQuery.of(context).size.height / 51) : Radius.circular(0)
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height / 37,
                    horizontal: MediaQuery.of(context).size.width / 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        child: MyWidget(context).textBlack20(name,bold: false),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      size: min(MediaQuery.of(context).size.width / 15, MediaQuery.of(context).size.height / 35),
                      color: MyColors.yellow,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /*Padding orderlist(ord,scale) {
    var Id = ord[0][0]['Id'];
    var name = ord[0][0]['Name'];
    var imagepath = ord[0][0]['ImagePath'];
    var price = ord[0][0]['Price'].toString();
    var date = Text(
      '${pickDate!.day}-${pickDate!.month}-${pickDate!.year} / ${time!.hour}:${time!.minute}',
      style: TextStyle(
        color: MyColors.black,
        fontSize: MediaQuery.of(context).size.width / 30,
        fontWeight: FontWeight.bold,
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 80,
          horizontal: MediaQuery.of(context).size.width / 50),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.20 * scale,
                  height: MediaQuery.of(context).size.height / 10 * scale,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(imagepath),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: Offset(0, 1), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(
                        MediaQuery.of(context).size.height / 100)),
                  )),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01 * scale,
                //child: Text(),
              ),
              Container(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 22),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.65 * scale,
                height: MediaQuery.of(context).size.height / 10 * scale,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width / 20 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          date,
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        price + ' .TRY',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: MediaQuery.of(context).size.width / 24 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            deleteOrder(order, Id);
                          });
                        },
                        child: Icon(
                          Icons.close_outlined,
                          size: MediaQuery.of(context).size.width / 20 * scale,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
*/

  myOrderlist(ord, index) {
    var serial;!worker? serial = ord['Serial'] : serial= ord['OrderService']['Order']['Serial'];
    var Id;!worker? Id = ord['Servicess'][0]['OrderId'] : Id= ord['OrderService']['OrderId'];
    var amount; !worker? amount = ord['Amount'].toString(): amount = ord['OrderService']['Order']['Amount'];
    var date; !worker? date = ord['OrderDate']:date = ord['OrderService']['Order']['OrderDate'];
    var addressArea; !worker? addressArea = ord['Address']['Area']['Name']:addressArea = ord['OrderService']['Order']['Address']['Area']['Name'];
    var addressCity; !worker? addressCity = ord['Address']['Area']['City']['Name']: addressCity = ord['OrderService']['Order']['Address']['Area']['City']['Name'];
    var statusCode; !worker? statusCode = ord['Status'].toString():statusCode = ord['Status'].toString();
    amount = amount.toString() +" \.${AppLocalizations.of(context)!.translate('TRY')} ";
    //statusCode = '2';
    String status = "";
    Color statusColor = Colors.grey;
    switch (statusCode) {
      case "8":
        {
          //return SizedBox(height: 0.001,);
          status = AppLocalizations.of(context)!.translate("finished");
          statusColor = Colors.grey;
        }
        break;
      case "7":
        {
          //return SizedBox(height: 0.001,);
          status = AppLocalizations.of(context)!.translate("Pending");
          statusColor = Colors.grey;
        }
        break;
      case "6":
        {
          //return SizedBox(height: 0.001,);
          status = AppLocalizations.of(context)!.translate("payed");
          statusColor = MyColors.green;
        }
        break;
      case "5":
        {
          status = AppLocalizations.of(context)!.translate("Rejected");
          statusColor = MyColors.red;
        }
        break;
      case "4":
        {
          status = AppLocalizations.of(context)!.translate("Pending");
          statusColor = MyColors.blue;
        }
        break;
      case "3":
        {
          status = AppLocalizations.of(context)!.translate("Change Date");
          statusColor = MyColors.blue;
        }
        break;
      case "2":
        {
          if(!worker){
            status = AppLocalizations.of(context)!.translate("Accepted");
            statusColor = MyColors.yellow;
          }else{
            status = AppLocalizations.of(context)!.translate("finished");
            statusColor = MyColors.blue;
          }
        }
        break;
      case "1":
        {
          status = AppLocalizations.of(context)!.translate("Pending");
          statusColor = Colors.grey;
        }
        break;
      default:
        {
          status = AppLocalizations.of(context)!.translate("Pending");
          statusColor = Colors.grey;
        }
        break;
    }
    String address = addressCity + " / " + addressArea;
    return _orderCard(index, statusColor, status, addressArea, amount, date, statusCode, Id, serial);
  }

  tasklist(ord, index) {
    var serial;!worker? serial = ord['Serial'] : serial= ord['OrderService']['Order']['Serial'];
    var taskName = ord['Name'];
    var Id;!worker? Id = ord['Servicess'][0]['OrderId'] : Id= ord['OrderService']['OrderId'];
    var workerName; !worker? workerName = ord['Amount'].toString(): workerName = ord['User']['Name'] + ' ' + ord['User']['LastName'];
    var date; !worker? date = ord['OrderDate']:date = ord['StartDate'];
    var addressArea; !worker? addressArea = ord['Address']['Area']['Name']:addressArea = ord['OrderService']['Order']['Address']['Area']['Name'];
    var addressCity; !worker? addressCity = ord['Address']['Area']['City']['Name']: addressCity = ord['OrderService']['Order']['Address']['Area']['City']['Name'];
    var statusCode; !worker? statusCode = ord['Status'].toString():statusCode = ord['Status'].toString();
    //statusCode = '2';
    String status = "";
    Color statusColor = Colors.grey;
    switch (statusCode) {
      case "8":
        {
          //return SizedBox(height: 0.001,);
          status = AppLocalizations.of(context)!.translate("finished");
          statusColor = Colors.grey;
        }
        break;
      case "7":
        {
          //return SizedBox(height: 0.001,);
          status = AppLocalizations.of(context)!.translate("Pending");
          statusColor = Colors.grey;
        }
        break;
      case "6":
        {
          //return SizedBox(height: 0.001,);
          status = AppLocalizations.of(context)!.translate("payed");
          statusColor = MyColors.green;
        }
        break;
      case "5":
        {
          status = AppLocalizations.of(context)!.translate("Rejected");
          statusColor = MyColors.red;
        }
        break;
      case "4":
        {
          status = AppLocalizations.of(context)!.translate("Pending");
          statusColor = MyColors.blue;
        }
        break;
      case "3":
        {
          status = AppLocalizations.of(context)!.translate("Change Date");
          statusColor = MyColors.blue;
        }
        break;
      case "2":
        {
          if(!worker){
            status = AppLocalizations.of(context)!.translate("Accepted");
            statusColor = MyColors.yellow;
          }else{
            status = AppLocalizations.of(context)!.translate("finished");
            statusColor = MyColors.blue;
          }
        }
        break;
      case "1":
        {
          status = AppLocalizations.of(context)!.translate("Pending");
          statusColor = Colors.grey;
        }
        break;
      default:
        {
          status = AppLocalizations.of(context)!.translate("Pending");
          statusColor = Colors.grey;
        }
        break;
    }
    String address = addressCity + " / " + addressArea;
    return _orderCard(index, statusColor, status, addressArea, workerName, date, statusCode, Id, serial, taskName: taskName);
  }

  myNewOrderSuperVisorlist(ord, index) {
    var serial; serial= ord['Serial'];
    var Id; ord['Servicess'].length>0? Id = ord['Servicess'][0]['OrderId']:Id=0;
    var amount = ord['Amount'].toString();
    var date = ord['OrderDate'];
    var addressArea = ord['Address']['Area']['Name'];
    var addressCity = ord['Address']['Area']['City']['Name'];
    var statusCode = ord['Status'].toString();
    //statusCode = '2';
    String status = "";
    amount = amount.toString() +" \.${AppLocalizations.of(context)!.translate('TRY')} ";
    Color statusColor = Colors.grey;
    for(int i = 0; i < task.length; i++){
      if(task[i][0]['OrderId'] == Id)
        statusColor = MyColors.blue;
    }
    String address = addressCity + " / " + addressArea;
    return _orderCard(index, statusColor, null, addressArea, amount, date, 1, Id, serial);
  }

  myFinishedOrderlist(ord, index) {
    var serial;!worker? serial = ord['Servicess'][0]['OrderId'] : serial= ord['OrderService']['OrderId'];
    var Id = ord['Servicess'][0]['OrderId'];
    var amount = ord['Amount'].toString();
    var date = ord['OrderDate'];
    var addressArea = ord['Address']['Area']['Name'];
    var addressCity = ord['Address']['Area']['City']['Name'];
    var statusCode = ord['Status'].toString();
    //statusCode = '5';
    String status = "";
    Color statusColor = Colors.grey;
    switch (statusCode) {
      case "6":
        {
          status = AppLocalizations.of(context)!.translate("payed");
          statusColor = MyColors.green;
          return SizedBox(
            height: 0.001,
          );
        }
        break;
      default:
        {
          return SizedBox(
            height: 0.001,
          );
          status = AppLocalizations.of(context)!.translate("Pending");
          statusColor = Colors.grey;
        }
        break;
    }
    String address = addressCity + " / " + addressArea;
    return _orderCard(
        index, statusColor, status, addressArea, amount, date, statusCode, Id, serial);
  }

  _orderCard(index, statusColor, status, addressArea, amount,String date, statusCode, Id, serial, {String? taskName}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 200,
          horizontal: MediaQuery.of(context).size.width / 40),
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(MediaQuery.of(context).size.height / 51),
            side: BorderSide(
              color: statusColor,
              width: 2.0,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyWidget(context).textBlack20(taskName == null? AppLocalizations.of(context)!.translate('Order Id: ') + serial.toString(): taskName, scale: 0.85),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01,
                            //child: Text(),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width / 22 * 0),
                            alignment: Alignment.centerRight,
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height / 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [Text("")],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: status != null? GestureDetector(
                                    onTap: () {},
                                    child:
                                    MyWidget(context).textBlack20(status, scale: 0.85, color: statusColor),
                                    /*Icon(
                                Icons.close_outlined,
                                size: MediaQuery.of(context).size.width / 18,
                                color: Colors.grey,
                              ),*/
                                  ):SizedBox(height: 0,),//IconButton(onPressed: () => rejectOrder(), icon: Icon(Icons.delete_forever_outlined)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          MyWidget(context).textGrayk28(addressArea, color: Colors.grey)
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 80,
                      ),
                      Divider(
                        color: Colors.grey[900],
                        height: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyWidget(context).textBlack20(amount.toString(), scale: 0.85),
                         /* SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01,
                            //child: Text(),
                          ),*/
                          Container(
                            alignment: Alignment.centerRight,
                            //width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height / 10,
                            child:
                            MyWidget(context).textBlack20(DateTime.parse(date.replaceAll('T', ' ')).add(-timeDiff).toString().split(' ')[0], scale: 0.85)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _cardButton(statusCode, statusColor, Id, index),
              ),
            ],
          )),
    );
  }

  double sumPrice() {
    double price = 0.0;
    for (int i = 0; i < order.length; i++) {
      price = price + order[i][0][0]["Price"] * int.parse(order[i][1]);
      print(price);
    }
    return price;
  }
/*
  void deleteOrder(ord, id) {
    ord.removeWhere((item) => item[0][0]['Id'] == id);
  }
*/
  List orderData = [];
  List finishedOrderData = [];
  List superNewOrderData = [];

  Future getMyOrders(var id,) async {
    try{
      var url;
      !worker?
        url = Uri.parse("$apiDomain/Main/Orders/Orders_Read?filter=CustomerId~eq~'$id'")
          :isBoss?
      //url = Uri.parse("https://mr-service.online/Main/Orders/Orders_Read?filter=GroupId~eq~$groupId"):
      //url = Uri.parse("https://mr-service.online/Main/Orders/Orders_Read?filter=Servicess.Group.Id~eq~$groupId"):
      url = Uri.parse("$apiDomain/Main/Orders/Orders_Read?"):
      url = Uri.parse('');
      http.Response response = await http.get(
        url, headers: {"Authorization": token,},
      );
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        print("getOrderders success");
        myOrders = await jsonDecode(response.body);
        editTransactionMyOrders(transactions![0], myOrders);
        //print(myOrders);
        //print("****************************");
        //print(jsonDecode(response.body));
      }
      else{
        myOrders.clear();
      }
    }catch(e){
      //myOrders = transactions![0].myOrders;
    }
    print('here');
    if(worker && isBoss){
      NewOrdersSupervisor = myOrders;
      try{
        /*filter=UserId~eq~'$id'*/
        //var url = Uri.parse("https://mr-service.online/Main/WorkerTask/WorkerTask_Read?filter=OrderService.Order.GroupId~eq~$groupId");
        var url = Uri.parse("https://mr-service.online/Main/WorkerTask/WorkerTask_Read?filter=OrderService.GroupId~eq~$groupId");
        //var url = Uri.parse("https://mr-service.online/Main/WorkerTask/WorkerTask_Read?");
        http.Response response = await http.get(
          url, headers: {
          "Authorization": token,
        },);
        print(jsonDecode(response.body));
        if (response.statusCode == 200) {
          print("getOrderders success");
          myOrders = await jsonDecode(response.body);
          editTransactionMyOrders(transactions![0], myOrders);
          print(jsonDecode(response.body));
          //print(myOrders);
          //print("****************************");
          //print(jsonDecode(response.body));
        }
        else{
          myOrders.clear();
        }
      }catch(e){
        //myOrders.clear();
        //myOrders = transactions![0].myOrders;
      }
    }else if(worker && !isBoss){
      NewOrdersSupervisor.clear();
      try{
        /*filter=UserId~eq~'$id'*/
        //var url = Uri.parse("https://mr-service.online/Main/WorkerTask/WorkerTask_Read?filter=WorkerId~eq~'$id'");
        //var url = Uri.parse("https://mr-service.online/Main/WorkerTask/WorkerTask_Read?filter=OrderService.Order.GroupId~eq~$groupId~and~WorkerId~eq~'$id'");
        var url = Uri.parse("https://mr-service.online/Main/WorkerTask/WorkerTask_Read?filter=WorkerId~eq~'$id'");
        //var url = Uri.parse("https://mr-service.online/Main/WorkerTask/WorkerTask_Read?");
        //var url = Uri.parse("https://mr-service.online/Main/WorkerTask/WorkerTask_Read?filter=OrderService.Order.GroupId~eq~$groupId");
        http.Response response = await http.get(url, headers: {
          "Authorization": token,
        },);
        print(jsonDecode(response.body));
        if (response.statusCode == 200) {
          print("getOrderders success");
          myOrders = await jsonDecode(response.body);
          editTransactionMyOrders(transactions![0], myOrders);
          //print(myOrders);
          //print("****************************");
          //print(jsonDecode(response.body));
        }
      }catch(e){
        myOrders.clear();
        //myOrders = transactions![0].myOrders;
      }
    }
    if(myOrders.length > 0){
      var k = myOrders['Total'];
      orderData.clear();
      for (int i = 0; i < k; i++) {
        orderData.add(myOrders['Data'][i]);
      }
      /*myOrders.forEach((key, value) {
        //if(key == 'Data')
        orderData.add(myOrders[key]);
      });*/
      if(!worker){
        orderData.sort((a, b) {
          var adate = a['OrderDate'/*'InsertDate'*/]; //before -> var adate = a.expiry;
          var bdate = b['OrderDate'/*'InsertDate'*/]; //before -> var bdate = b.expiry;
          return bdate.compareTo(adate);
        });
        finishedOrderData.clear();
        //finishedOrderData.add(orderData[0]);
        for(int i=0; i<orderData.length; i++){
          if(orderData[i]['Status'] == 8){
            finishedOrderData.add(orderData[i]);
            orderData.removeAt(i);
            i--;
          }
        }
      }
      else{
        orderData.sort((a, b) {
          var adate = a['StartDate']; //before -> var adate = a.expiry;
          var bdate = b['StartDate']; //before -> var bdate = b.expiry;
          return adate.compareTo(bdate);
        });
        if(!isBoss){
          finishedOrderData.clear();
          for(int i=0; i<orderData.length; i++){
            if(orderData[i]['Status'] == 2){
              finishedOrderData.add(orderData[i]);
              orderData.removeAt(i);
              i--;
            }
          }
        }
        else{
          for(int i=0; i<orderData.length; i++){
            if(orderData[i]['OrderService']['Order']['Status'] == 8){
              //finishedOrderData.add(orderData[i]);
              orderData.removeAt(i);
              i--;
            }
          }
        }
      }
    }
    else{
      orderData.clear();
    }
    if(NewOrdersSupervisor.length > 0){
      var k = NewOrdersSupervisor['Total'];
      superNewOrderData.clear();
      for (int i = 0; i < k; i++) {
        for(int j = 0; j<NewOrdersSupervisor['Data'][i]['Servicess'].length; j++){
          try{
            if(NewOrdersSupervisor['Data'][i]['Servicess'][j]['GroupId'] == groupId){
              superNewOrderData.add(NewOrdersSupervisor['Data'][i]);
              j = NewOrdersSupervisor['Data'][i]['Servicess'].length;
            }
          }catch(e){

          }
        }
      }
      superNewOrderData.sort((a, b) {
        var adate = a['OrderDate'/*'InsertDate'*/]; //before -> var adate = a.expiry;
        var bdate = b['OrderDate'/*'InsertDate'*/]; //before -> var bdate = b.expiry;
        return bdate.compareTo(adate);
      });
      if(superNewOrderData.length > 0)
        finishedOrderData.clear();
      for(int i=0; i<superNewOrderData.length; i++){
        if(superNewOrderData[i]['Status']== 8){
          finishedOrderData.add(superNewOrderData[i]);
          superNewOrderData.removeAt(i);
          i--;
        }
      }
    }
  }

  Future updateUserInfo(var id) async {
    try{
      print("flag1");
      var url = Uri.parse(
          "$apiDomain/Main/Users/SignUp_Read?filter=Id~eq~'$id'");
      http.Response response = await http.get(
        url,
        headers: {
          "Authorization": token,
        },
      );
      if (response.statusCode == 200) {
        print("flag2");
        /*setState(
              () {
                print(jsonDecode(response.body)['result']);
            userInfo = jsonDecode(response.body)['result']['Data'][0];
            editTransactionUserUserInfo(transactions![0], userInfo);
          },
        );*/
        print(jsonDecode(response.body)['result']);
        userInfo = jsonDecode(response.body)['result']['Data'][0];
        editTransactionUserUserInfo(transactions![0], userInfo);
        print(jsonDecode(response.body));
        if(userInfo['GroupUsers'].length>0)
          _checkWorkerType(userInfo['Type'], userInfo['GroupUsers'][0]['isBoss']);
        else{
          _checkWorkerType(0, false);
        }
        print("flag3");
      } else {
        print("flag4");
        print(response.statusCode);
      }
      print("flag5");
      //await Future.delayed(Duration(seconds: 1));
    }catch(e){
      userInfo = transactions![0].userInfo;
    }
    try{
      groupId = userInfo['GroupUsers'][0]['GroupId'];
      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setInt('groupId', groupId);
    }catch(e){

    }
  }

  void getAddress(var id) async {
    try{
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
          },
        );
      } else {
        print(response.statusCode);
        setState(
              () {
            Address = [];
          },
        );
      }
    }catch(e){
      Address = transactions![0].Address;
    }
  }

  _changePassword(email) async {
    http.Response response = await http.post(
        Uri.parse(
            '$apiDomain/main/SignUp/RequestResetPassword?UserEmail=$email'),
        headers: {
          "accept": "application/json",
        });
    print(jsonDecode(response.body));
    //curl -X POST "https://mr-service.online/Main/SignUp/RequestResetPassword?UserEmail=www.osh.themyth%40gmail.com" -H "accept: */*"
    //curl -X POST "https://mr-service.online/api/Auth/login" -H "accept: text/plain" -H "Content-Type: application/json-patch+json" -d "{\"UserName\":\"www.osh.themyth@gmail.com\",\"Password\":\"0938025347\"}"
    if (response.statusCode == 200) {
      print("we're good");
      //userData = jsonDecode(response.body);
      setState(() {
        if (jsonDecode(response.body)['Errors'] == "") {
          //isLogIn = true;
          //token = jsonDecode(response.body)["content"]["Token"].toString();
          //updateUserInfo(userData["content"]["Id"]);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Verification(
              value: 'value',
              email: email,
              password: '',
            ),
          ));
        } else if (jsonDecode(response.body)['data'] ==
            "Wait one hour and retry") {
          //setState(() => chLogIn = false);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Verification(
              value: 'value',
              email: email,
              password: '',
            ),
          ));
        } else {
          //setState(() => chLogIn = false);
          Flushbar(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 30),
            icon: Icon(
              Icons.error_outline,
              size: MediaQuery.of(context).size.height / 30,
              color: MyColors.White,
            ),
            duration: Duration(seconds: 3),
            shouldIconPulse: false,
            flushbarPosition: FlushbarPosition.TOP,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            backgroundColor: Colors.grey.withOpacity(0.5),
            barBlur: 20,
            message: jsonDecode(response.body)['Errors'],
            messageSize: MediaQuery.of(context).size.height / 37,
          ).show(context);
        }
      });
    } else {
      print('A network error occurred');
    }
  }

  _cardButton(statusCode, color, id, index) {
    if(worker)
      return SizedBox(
        width: 0.1,
      );
    var apiUrl;
    Map? mapDate;
    String text = '';
    switch (statusCode) {
      case "6":
        {
          text = AppLocalizations.of(context)!.translate("payed");
          return SizedBox(
            width: 0.1,
          );
        }
        break;
      case "5":
        {
          text = AppLocalizations.of(context)!.translate("Destroy");
        }
        break;
      case "4":
        {
          text = AppLocalizations.of(context)!.translate("Pending");
          return SizedBox(
            width: 0.1,
          );
        }
        break;
      case "3":
        {
          text = AppLocalizations.of(context)!.translate("Update");
          return SizedBox(
            width: 0.1,
          );
        }
        break;
      case "2":
        {
          text = AppLocalizations.of(context)!.translate("go to pay");
        }
        break;
      case "1":
        {
          text = AppLocalizations.of(context)!.translate("Pending");
          return SizedBox(
            width: 0.1,
          );
        }
        break;
      default:
        {
          text = AppLocalizations.of(context)!.translate("Pending");
          return SizedBox(
            width: 0.1,
          );
        }
        break;
    }
    return Container(
        //width: MediaQuery.of(context).size.width / 4,
        // ignore: deprecated_member_use
      //padding: EdgeInsets.only(top: MediaQuery.of(context).size.height/5),
      //height: double.infinity,
      alignment: Alignment.bottomCenter,
        child: MyWidget(context).raisedButton(text, () => _clickCardButton(statusCode, id, index),  MediaQuery.of(context).size.width / 4, chCircle, buttonText: color, colorText: Colors.grey, roundBorder:  MediaQuery.of(context).size.height / 60, padV: MediaQuery.of(context).size.height / 60),
    );
  }

  _clickCardButton(statusCode, id, index) async {
    switch (statusCode) {
      case "6":
        {}
        break;
      case "5":
        {
          bool _suc = await api.destroyOrder(id);
          if (_suc){
            setState(() {});
            api.flushBar(AppLocalizations.of(context)!.translate('Order Destroy'));
            new Timer(Duration(seconds:1), ()=>setState(() {}));
            //setState(() {});
          }
        }
        break;
      case "4":
        {

        }
        break;
      case "3":
        {

        }
        break;
      case "2":
        {
          _goToPay(index-1);
        }
        break;
      case "1":
        {}
        break;
      default:
        {}
        break;
    }
  }

  void _goToPay(i) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Payment(orderData[i], token))).then((_) {setState(() {});});
  }

  _card(widget) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 200,
        horizontal: MediaQuery.of(context).size.width / 40
      ),
      //alignment: Alignment.l,
      width: MediaQuery.of(context).size.width / 1.2,
      //height: MediaQuery.of(context).size.height / 7,
      decoration: BoxDecoration(
        color: MyColors.White,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.all(
            Radius.circular(MediaQuery.of(context).size.height / 80)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 20,
          vertical: MediaQuery.of(context).size.height / 80,
        ),
        child: widget,
      ),
    );
  }

  String? _setTime, _setDate;

  TextEditingController _dateController = TextEditingController();
  DateTime? selectedDate;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate as DateTime,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        selectedDate = picked;
        print("this is the Date");
        print(selectedDate);
        print("timeZone");
        print(DateTime.now().timeZoneName);
        print(DateTime.now().timeZoneOffset);
        _dateController.text =
            DateFormat.yMd().format(selectedDate as DateTime);
      });
  }

  TimeOfDay? selectedTime;
  TextEditingController _timeController = TextEditingController();

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime as TimeOfDay,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        print("this is the Time");
        print(selectedTime!.hour);
        var _hour = selectedTime!.hour.toString();
        var _minute = selectedTime!.minute.toString();
        var _time = _hour + ' : ' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime!.hour, selectedTime!.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  _dateCard(bool change) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 160,
        horizontal: MediaQuery.of(context).size.width / 40,
      ),
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width / 1.2,
      height: MediaQuery.of(context).size.height / 12,
      decoration: BoxDecoration(
        color: MyColors.White,
        boxShadow: [
          BoxShadow(
            color: change? MyColors.blue : Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.all(
            Radius.circular(MediaQuery.of(context).size.height / 80)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 40,
          vertical: MediaQuery.of(context).size.height / 60*0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.date_range, color: change? MyColors.blue : MyColors.black,),
            Expanded(
              flex: 1,
              child:InkWell(
                onTap: () {
                  if(change)
                    _selectDate(context);
                },
                child: TextFormField(
                  style:
                  TextStyle(fontSize: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45), color: change ? MyColors.blue: MyColors.black),
                  textAlign: TextAlign.center,
                  enabled: false,
                  keyboardType: TextInputType.text,
                  controller: _dateController,
                  onSaved: (String? val) {
                    _setDate = val;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _timeCard(bool change) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 160,
        horizontal: MediaQuery.of(context).size.width / 40,
      ),
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width / 1.2,
      height: MediaQuery.of(context).size.height / 12,
      decoration: BoxDecoration(
        color: MyColors.White,
        boxShadow: [
          BoxShadow(
            color: change? MyColors.blue :Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.all(
            Radius.circular(MediaQuery.of(context).size.height / 80)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 40,
          vertical: MediaQuery.of(context).size.height / 60*0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.timer_outlined, color: change? MyColors.blue : MyColors.black),
            Expanded(
              flex: 1,
              child:InkWell(
                onTap: () {
                  if(change)
                    _selectTime(context);
                },
                child: TextFormField(
                  style:
                  TextStyle(fontSize: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45), color: change ? MyColors.blue: MyColors.black),
                  textAlign: TextAlign.center,
                  enabled: false,
                  keyboardType: TextInputType.text,
                  controller: _timeController,
                  onSaved: (String? val) {
                    _setTime = val;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? image = null;
  String? path ;
  XFile? xFile;
  _showOrderDetails(ord, index,{bool? dateIsSelected}) {
    dateIsSelected??=false;
    _uploadImage(){
      return GestureDetector(
        onTap: () async {
          final ImagePicker _picker = ImagePicker();
          xFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 25);
          path = xFile!.path;
          print(path);
          image = FileImage(File(path!));
          Navigator.of(context).pop();
          _showOrderDetails(ord, index);
          /*final bytes = await XFile(path).readAsBytes();
                          final img.Image image = img.decodeImage(bytes);*/
        },
        child: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * 0.70,
        decoration: image == null && ord['WorkerTaskAttatchs'].length == 0  ? BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 3,
              offset:
              Offset(0, 1), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width / 30)),
        ) : image == null && ord['WorkerTaskAttatchs'].length > 0  ? BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(ord['WorkerTaskAttatchs'][0]['FilePath']) as ImageProvider,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 3,
              offset:
              Offset(0, 1), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width / 30)),
        ):BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: image as ImageProvider,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 3,
              offset:
              Offset(0, 1), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width / 30)),
        ),
        child:  Center(
            child: image == null? Icon(Icons.upload_file_outlined, size: MediaQuery.of(context).size.height / 12,):
            SizedBox(width:  MediaQuery.of(context).size.width/ 2, height: MediaQuery.of(context).size.height / 7,),
          ),
        ),
      );
    }
    var Id;
    //var amount = ord['Amount'].toString();
    !worker? Id = ord['Servicess'][0]['OrderId'] : Id= ord['OrderService']['OrderId'];
    var serial;!worker? serial = ord['Serial'] : serial= ord['OrderService']['Order']['Serial'];
    var amount; !worker? amount = ord['Amount'].toString(): amount = ord['OrderService']['Order']['Amount'];
    var date;
    var time;
    try{
      !worker? ord['OrderDate'] = DateTime.parse(ord['OrderDate'].replaceAll('T', ' ')).add(-timeDiff).toString()
          : ord['StartDate'] = DateTime.parse(ord['StartDate'].replaceAll('T', ' ')).add(-timeDiff).toString();
      !worker? date = ord['OrderDate'].split(" ")[0]: date = ord['StartDate'].split(" ")[0];
      !worker? time = ord['OrderDate'].split(" ")[1]: time = ord['StartDate'].split(" ")[1];
      !worker? ord['OrderDate'] = DateTime.parse(ord['OrderDate'].replaceAll('T', ' ')).add(timeDiff).toString()
          : ord['StartDate'] = DateTime.parse(ord['StartDate'].replaceAll('T', ' ')).add(timeDiff).toString();
    }catch(e){
      !worker? ord['OrderDate'] = DateTime.parse(ord['OrderDate'].replaceAll('T', ' ')).add(-timeDiff).toString()
          : ord['OrderService']['Order']['OrderDate'] = DateTime.parse(ord['OrderService']['Order']['OrderDate'].replaceAll('T', ' ')).add(-timeDiff).toString();
      !worker? date = ord['OrderDate'].split(" ")[0]: date = ord['OrderService']['Order']['OrderDate'].split(" ")[0];
      !worker? time = ord['OrderDate'].split(" ")[1]: time = ord['OrderService']['Order']['OrderDate'].split(" ")[1];
      !worker? ord['OrderDate'] = DateTime.parse(ord['OrderDate'].replaceAll('T', ' ')).add(timeDiff).toString()
          : ord['OrderService']['Order']['OrderDate'] = DateTime.parse(ord['OrderService']['Order']['OrderDate'].replaceAll('T', ' ')).add(timeDiff).toString();
    }
    //selectedTime = TimeOfDay.now();
    if(!dateIsSelected){
      selectedTime = TimeOfDay(hour: int.parse(time.split(':')[0]),minute: int.parse(time.split(':')[1]));
      //selectedDate = DateTime.now();
      selectedDate = DateTime.parse(date +" " + time);
      _dateController.text=date;
      _timeController.text=time;
    }
    var addressArea; !worker? addressArea = ord['Address']['Area']['Name']:addressArea = ord['OrderService']['Order']['Address']['Area']['Name'];
    var addressCity; !worker? addressCity = ord['Address']['Area']['City']['Name']: addressCity = ord['OrderService']['Order']['Address']['Area']['City']['Name'];
    var addressNotes; !worker? addressNotes = ord['Address']['notes']: addressNotes = ord['OrderService']['Order']['Address']['notes'];
    var addressBuilding; !worker? addressBuilding = ord['Address']['building']: addressBuilding = ord['OrderService']['Order']['Address']['building'];
    var addressFloor; !worker? addressFloor = ord['Address']['floor']: addressFloor = ord['OrderService']['Order']['Address']['floor'];
    var addressAppartment; !worker? addressAppartment = ord['Address']['appartment']: addressAppartment = ord['OrderService']['Order']['Address']['appartment'];
    var statusCode = ord['Status'].toString();
    bool change = false;
    if(statusCode == "3")
      change = true;
    //change = true;
    List service = [];
    if(worker){
      if(!isBoss){
        api.getGroupUsers(groupId);
      }
      for(int i =0; i < 1; i++){
        var imagePath = 'https://controlpanel.mr-service.online' + ord['OrderService']['Service']['ImagePath'];
        if(ord['WorkerTaskAttatchs'].length > 0)
          imagePath = ord['WorkerTaskAttatchs'][0]['FilePath'];
        service.add({'name':ord['OrderService']['Service']['Name'].toString(),'worker':ord['User']['Name']+ ' ' + ord['User']['LastName'], 'imagePath':imagePath});
      }
    }
    else{
      for(int i =0; i < ord['Servicess'].length; i++){
        service.add({'name':ord['Servicess'][i]['Service']['Name'].toString(),'price':ord['Servicess'][i]['Service']['Price'].toString()});
      }
    }
    var userName;  !worker? userName = ord['User']['Name']: userName = ord['OrderService']['Order']['User']['Name'];
    var userLastName; !worker? userLastName = ord['User']['LastName']: userLastName = ord['OrderService']['Order']['User']['LastName'];
    var userMobile; !worker? userMobile = ord['User']['Mobile']: userMobile = ord['OrderService']['Order']['User']['Mobile'];
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 80,
            horizontal: MediaQuery.of(context).size.width / 50,
          ),
          child: SingleChildScrollView(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    /*Align(
                    alignment: Alignment.topRight,
                    child: IconButton(icon: Icon(Icons.close),color : MyColors.black, onPressed: ()=>Navigator.pop(context),),
                  ),*/
                    Text(
                      AppLocalizations.of(context)!.translate('Order Id: ') + serial.toString(),
                      style: TextStyle(
                        color: MyColors.black,
                        fontSize: MediaQuery.of(context).size.width / 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    /*Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width / 23),
                      child: Text(
                        addressArea,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),*/
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height/160,),
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _textHeader(AppLocalizations.of(context)!.translate("User Name")),
                      _text(userName + " " + userLastName),
                    ],
                  ),
                ),
                _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textHeader(
                        AppLocalizations.of(context)!.translate("Address")),
                    _text(addressArea +
                        " / " +
                        addressNotes +
                        " / " +
                        addressBuilding +
                        " / " +
                        addressFloor +
                        " / " +
                        addressAppartment),
                  ],
                ),
                ),
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _textHeader(AppLocalizations.of(context)!
                          .translate("Phone Number")),
                      _text(userMobile),
                    ],
                  ),
                ),
                _dateCard(change),
                _timeCard(change),
                SizedBox(height: MediaQuery.of(context).size.height/200,),
                _textHeader(AppLocalizations.of(context)!.translate('Services')),
                SizedBox(height: MediaQuery.of(context).size.height/200,),
                SizedBox(
                  height: MediaQuery.of(context).size.height/7,
                  child: worker && !isBoss ? _uploadImage() : ListView.builder(
                    itemCount:service.length,
                    itemBuilder: (context, index) {
                      return  !worker? _card(Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: _text(service[index]['name'])),
                          SizedBox(width: MediaQuery.of(context).size.width/30,),
                          _textHeader(amount.toString()/*service[index]['price']*/),
                        ],
                      ),):
                      _rowServiceWorker(service[index]['name'], service[index]['worker'], service[index]['imagePath']);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _button(change ? AppLocalizations.of(context)!.translate('Save') :!worker? AppLocalizations.of(context)!.translate('Ok') :isBoss? AppLocalizations.of(context)!.translate('Ok') : AppLocalizations.of(context)!.translate('Finish Task'), () => _save(ord,change,index),MediaQuery.of(context).size.width/1.7),
                    // _button(AppLocalizations.of(context)!.translate('Close'), _close),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _textHeader(text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey,
        fontSize: MediaQuery.of(context).size.width / 28,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  _text(text) {
    return Padding(padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/200),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text(
        text,
        style: TextStyle(
          color: MyColors.black,
          fontSize: MediaQuery.of(context).size.width / 20,
          fontWeight: FontWeight.normal,
        ),
      ),
    )
    ,);
  }

  circularMenu() {
    var width = MediaQuery.of(context).size.width;
    List<CircularMenuItem> menuItems = [];
    menuItems.add(
      CircularMenuItem(
        // menu item callback
        onTap: () {},
        // menu item appearance properties
        icon: Icons.home,//Image.asset('name')as IconData?,
        color: MyColors.blue,
        //elevation: 4.0,
        iconColor: Colors.white,
        iconSize: width/28,
        //margin: 10.0,
        //padding: 10.0,
        //when 'animatedIcon' is passed,above 'icon' will be ignored
        //animatedIcon: // AnimatedIcon(),
      ),
    );
    menuItems.add(
      CircularMenuItem(
        // menu item callback
        onTap: () {},
        // menu item appearance properties
        icon: Icons.home,//Image.asset('name')as IconData?,
        color: MyColors.blue,
        //elevation: 4.0,
        iconColor: Colors.white,
        iconSize: width/20,
        //margin: 10.0,
        //padding: 10.0,
        //when 'animatedIcon' is passed,above 'icon' will be ignored
        //animatedIcon: // AnimatedIcon(),
      ),
    );
    return Container(
      padding: EdgeInsets.only(left: width/5),
      height: width/5,
      width: width/2.5,
      child: CircularMenu(
        // menu alignment
        alignment: Alignment.center,
        // menu radius
        radius: width/7,
        // widget in the background holds actual page content
        // backgroundWidget: Icon(Icons.shopping_bag_outlined),
        // global key to control the animation anywhere in the code.
        //key: // GlobalKey<CircularMenuState>(),
        // animation duration
        animationDuration: Duration(milliseconds: 500),
        // animation curve in forward
        curve: Curves.bounceOut,
        // animation curve in reverse
        reverseCurve: Curves.fastOutSlowIn,
        // first item angle
        startingAngleInRadian: 0,
        // last item angle
        endingAngleInRadian: pi,
        // toggle button callback
        //toggleButtonOnPressed: () {
        //callback},
        // toggle button appearance properties
        toggleButtonAnimatedIconData : AnimatedIcons.search_ellipsis,
        toggleButtonColor: MyColors.yellow,
        toggleButtonBoxShadow: [
          BoxShadow(
            color: MyColors.blue,
            blurRadius: 10,
          ),
        ],
        toggleButtonIconColor: MyColors.White,
        //toggleButtonMargin: 10.0,
        //toggleButtonPadding: 10.0,
        toggleButtonSize: width/20,
        items: menuItems,
      ),
    );
  }

  _save(ord,bool change, index) async{
    //change = true;
    if(!change && !isBoss && worker){
      setState(() {
        chCircle = true;
      });
      Navigator.pop(context);
      _showOrderDetails(ord, index);
      String endDate = DateFormat('yyyy-MM-dd hh:mm:ss.sss').format(DateTime.now().add(timeDiff)).replaceAll(" ", "T") + "Z";
      bool _suc;
      var fcmToken = '';
      for(int i =0; i< groupUsers.length; i++){
        if(groupUsers[i]['isBoss'] == true)
          fcmToken = groupUsers[i]['Users']['FBKey'];
      }
      if(xFile != null)
        _suc = await api.updateWorkerTask(ord['Id'], ord['WorkerId'], ord['OrderServicesId'], ord['Notes'], ord['StartDate'], endDate, 'workerNotes', token, ord['Name'], File(xFile!.path),fcmToken);
      else
        _suc = await api.updateWorkerTask(ord['Id'], ord['WorkerId'], ord['OrderServicesId'], ord['Notes'], ord['StartDate'], endDate, 'workerNotes', token, ord['Name'], 'File(xFile!.path)',fcmToken);
      if (_suc){
        Navigator.pop(context);
        api.flushBar(AppLocalizations.of(context)!.translate('Task is Finished'));
        setState(() {
          chCircle = false;
        });
        //new Timer(Duration(seconds:2), ()=>setState(() {}));
        //setState(() {});
      }
      return;
    }
    if(!change){
      Navigator.pop(context);
      return;
    }
    var date = ord['OrderDate'].split(" ")[0];
    var time = ord['OrderDate'].split(" ")[1];
    //selectedTime = TimeOfDay.now();
    //selectedTime = TimeOfDay(hour: int.parse(time.split(':')[0]),minute: int.parse(time.split(':')[1]));
    //selectedDate = DateTime.now();
    //selectedDate = DateTime.parse(date +" " + time);
    if(selectedDate == DateTime.parse(date +" " + time) && selectedTime == TimeOfDay(hour: int.parse(time.split(':')[0]),minute: int.parse(time.split(':')[1]))){
      Navigator.pop(context);
      return;
    }
    setState(() {
      chCircle = true;
    });
    Navigator.pop(context);
    _showOrderDetails(ord, index, dateIsSelected: true);
    bool _suc = await api.updateOrder(token, ord, 4, null, selectedDate, selectedTime);
    if (_suc){
      Navigator.pop(context);
      api.flushBar(AppLocalizations.of(context)!.translate('Order Saved'));
      new Timer(Duration(seconds:2), ()=>setState(() {}));
      //setState(() {});
    }
    setState(() {
      chCircle = false;
    });

  }

  _close() {
    Navigator.pop(context);
  }

  _setState() {
    setState(() {

    });
  }

  _checkWorkerType(type, bool? _isBoss)async{
    if(type==2){
      isBoss = _isBoss!;
      worker = true;
    }
    else
      worker = false;
    //worker = false;
    //isBoss = false;
    //worker = true;
    //isBoss = true;
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('worker', worker);
    sharedPreferences.setBool('isBoss', isBoss);
    print("worker = $worker");
  }

  rejectOrder() {

  }

  _rowServiceWorker(serviceName, workerName, netWorkImage){
    var scale = 1;
    return Container(
      width: MediaQuery.of(context).size.width * 0.7 * scale,
      height: MediaQuery.of(context).size.height / 5 * scale,
      child: SingleChildScrollView(
        //mainAxisAlignment: MainAxisAlignment.center,
        child: Column(
          children: [
            MyWidget(context).textBlack20(serviceName, scale: 0.85),
            SizedBox(height: MediaQuery.of(context).size.height/200,),
            MyWidget(context).textBlack20(workerName, scale: 0.66),
            GestureDetector(
              onTap: () => api.showImage(netWorkImage),
              child: Container(
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width * 0.7 * scale,
                  height: MediaQuery.of(context).size.height / 7 * scale,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(netWorkImage),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: Offset(0, 1), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(
                        MediaQuery.of(context).size.height / 100)),
                  )),
            ),
          ],
        ),
      ),
    );
  }

}
