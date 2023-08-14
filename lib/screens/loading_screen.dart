import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mr_service/api/api_service.dart';
import 'package:mr_service/color/MyColors.dart';
import 'package:mr_service/const.dart';
import 'package:mr_service/firebase/Firebase.dart';
import 'package:mr_service/localization_service.dart';
import 'package:mr_service/localizations.dart';
import 'package:mr_service/model/transaction.dart';
import 'package:mr_service/screens/main_screen.dart';
import 'package:mr_service/screens/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../MyWidget.dart';
import '../boxes.dart';

bool x = true;
List service = [];

// ignore: must_be_immutable
class LoadingScreen extends StatefulWidget {
  String email;
  LoadingScreen({required this.email});
  /*static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_LoadingScreenState>()!.restartApp();
  }*/

  @override
  _LoadingScreenState createState() => _LoadingScreenState(this.email);
}

class _LoadingScreenState extends State<LoadingScreen> {
  //String? lng;
  Key key = UniqueKey();
/*
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }
*/
  String email;
  _LoadingScreenState(this.email);
  MyFirebase myFirebase = new MyFirebase();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    checkLastLogin();
    super.initState();
    print(token);
     // ignore: unnecessary_null_comparison
    _addTrans();
    print('We Are Here');
    startTime();
    apiService = APIService(context: context);
    //lng = LocalizationService().getCurrentLang();
    DateTime date = DateTime.now();
    var duration = date.timeZoneOffset;
    timeDiff = new Duration(hours: -duration.inHours, minutes: -duration.inMinutes %60);
    print(timeDiff);
  }

  //service[] , chLogIn , response and navigate to mainScreen Or SignIn
  //only used in checkLoginMethod
  Future getServiceData(tokenn) async {
    token = tokenn;
    print(tokenn);
    //var url = Uri.parse('https://mr-service.online/Main/Services/Services_Read?filter=IsMain~eq~true');
    var url = Uri.parse('$apiDomain/Main/Services/Services_Read?filter=ServiceParentId~eq~null');
    //var url = Uri.parse('https://mr-service.online/Main/Services/Services_Read?');
    http.Response response = await http.get(url, headers: {"Authorization": tokenn!,},);
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      var item = await json.decode(response.body)["result"]['Data'];
      /*for(int i =0; i<item.length; i++){
        if(item[i]['ServiceParentId']==null){
          item.removeAt(i);
          i--;
        }
      }*/
      setState(() {service = item;},);
      editTransactionService(transactions![0], service);
      setState(() => chLogIn = false);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen(token: tokenn, service: service,selectedIndex: 0, initialOrderTab: 0,),),);
    } else {
      setState(
        () {
          service = [];
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SignIn(),
            ),
          );
        },
      );
    }
  }

  getServiceDataOffline(tokenn, _service){
    token = tokenn;
    setState(() {service = _service;},);
    setState(() => chLogIn = false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen(token: tokenn, service: service,selectedIndex: 0, initialOrderTab: 0,),),);
  }

  //SignIn Or fill UserData and getServiceData
  Future<void> checkLogin() async {
    if(letsGo)
      return;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var email = sharedPreferences.getString('email');
    var password = sharedPreferences.getString('password');
    var facebookEmail = sharedPreferences.getString('facebookEmail');
    var googleEmail = sharedPreferences.getString('googleEmail');
    var _token = sharedPreferences.getString('token');
    var _worker = sharedPreferences.getBool('worker');
    var _isBoss = sharedPreferences.getBool('isBoss');
    var _groupId = sharedPreferences.getInt('groupId');
    if(_worker!=null)
      worker = _worker;
    if(_isBoss!=null)
      isBoss = _isBoss;
    if(_groupId!=null)
      groupId = _groupId;
    //var service = sharedPreferences.getStringList('service');
    _addTrans();
    if(facebookEmail != '' && facebookEmail != null ){
      password = "FB_P@ssw0rd_FB";
    }
    if (_token == null && facebookEmail == null && googleEmail == null) {
      Navigator.pushNamed(context, 'sign_in');
    }
    else if (_token == '' && facebookEmail == '' && googleEmail == '') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignIn(),),
      );
    }
    else {
      token = _token!;
      http.Response response;
      try{
         response = await apiService.login(email, password);
      }catch(e){
        if(!transactions![0].userData.isEmpty){
          userData = transactions![0].userData;
          getServiceDataOffline(_token, transactions![0].service);
        }
        return;
      }
      if (response.statusCode == 200) {
        userData = jsonDecode(response.body);
        editTransactionUserData(transactions![0], userData);
        var tokenn = jsonDecode(response.body)["content"]["Token"].toString();
        getServiceData(tokenn);
      }
      else{
        Navigator.pushNamed(context, 'sign_in');
      }
    }
    letsGo = true;
  }

  Future<void> checkLastLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var email = sharedPreferences.getString('email');
    var password = sharedPreferences.getString('password');
    var facebookEmail = sharedPreferences.getString('facebookEmail');
    var googleEmail = sharedPreferences.getString('googleEmail');
    var _token = sharedPreferences.getString('token');
    var _worker = sharedPreferences.getBool('worker');
    var _isBoss = sharedPreferences.getBool('isBoss');
    if(_worker!=null)
      worker = _worker;
    if(_isBoss!=null)
      isBoss = _isBoss;
    //var service = sharedPreferences.getStringList('service');
    _addTrans();
    /*if(facebookEmail != '' && facebookEmail != null ){
      password = "FB_P@ssw0rd_FB";
    }*/
    if (_token == null && facebookEmail == null && googleEmail == null) {
      //Navigator.pushNamed(context, 'sign_in');
    }
    else if (_token == '' && facebookEmail == '' && googleEmail == '') {
      /*Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignIn(),),
      );*/
    }
    else {
      letsGo = true;
      token = _token!;
      http.Response response;
      try{
         response = await apiService.login(email, password);
      }catch(e){
        if(!transactions![0].userData.isEmpty){
          userData = transactions![0].userData;
          getServiceDataOffline(_token, transactions![0].service);
        }
        return;
      }
      if (response.statusCode == 200) {
        userData = jsonDecode(response.body);
        editTransactionUserData(transactions![0], userData);
        var tokenn = '';
        try{
          tokenn = jsonDecode(response.body)["content"]["Token"].toString();
        }catch(e){
          return;
        }
        await getServiceData(tokenn);
      }
      else{
       // Navigator.pushNamed(context, 'sign_in');
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return KeyedSubtree(
      key: key,
      child: SafeArea(
          child: Scaffold(
            backgroundColor: MyColors.blue,
            body: ValueListenableBuilder<Box<Transaction>>(
              valueListenable: Boxes.getTransactions().listenable(),
              builder: (context, box, _) {
                final transactions = box.values.toList().cast<Transaction>();
                return Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height / 37,
                      horizontal: MediaQuery.of(context).size.width / 22),
                  child: buildPhoneAppVertical(),
                );
              },
            ),
          ),
        ),
    );
  }

  Widget buildPhoneAppVertical() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 37,
          horizontal: MediaQuery.of(context).size.width / 22),
      child: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Image.asset(
                  'assets/images/Logo1.png',
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height / 4,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 10,
              ),
              Expanded(
                  flex: 4,
                  child: Image.asset(
                    'assets/images/home.png',
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.height / 2,
                  )),
              SizedBox(
                height: MediaQuery.of(context).size.height / 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate('lang'), color: MyColors.White),
                  Text("   "),
                  MyWidget(context).dropDownLang(LocalizationService.langs, () => {setState(() {},)})
                  /*new DropdownButton<String>(
                    dropdownColor: Colors.blueGrey,
                    items: LocalizationService.langs.map(
                      (String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(
                            value,
                            style: TextStyle(color: MyColors.White),
                          ),
                        );
                      },
                    ).toList(),
                    value: LocalizationService().getCurrentLang(),
                    underline: Container(
                      color: Colors.grey,
                    ),
                    isExpanded: false,
                    onChanged: (newVal) {
                      setState(
                        () {
                          LocalizationService().changeLocale(newVal!,context);
                        },
                      );
                    },
                  ),*/
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 20,
              ),
              //start button

              Expanded(
                flex: 1,
                // ignore: deprecated_member_use
                child:MyWidget(context).raisedButton(AppLocalizations.of(context)!.translate('start_button'), ()=>checkLogin(), MediaQuery.of(context).size.width / 2, letsGo, padV: MediaQuery.of(context).size.width/40),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 30,
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate('Already have an account?'), color:MyColors.White, bold: false),

                    SizedBox(
                      width: MediaQuery.of(context).size.width / 72,
                    ),
                    GestureDetector(
                      onTap: () {
                        checkLogin();
                      },
                      child: MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate('Login'), color:MyColors.yellow, bold: false),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _afterLayout(Duration timeStamp) {
    LocalizationService().changeLocale(LocalizationService().getCurrentLang(),context);
  }

  startTime() async {
    var duration = new Duration(seconds:10000000);
    final _keyWelcome = 'welcome';
    final prefs = await SharedPreferences.getInstance();
    //welcom = prefs.getBool(_keyWelcome) ?? true;
    //new Timer(Duration(seconds:4), () => letsGo=true);
    return new Timer(duration, checkLogin);
  }

  bool letsGo = false;
  _addTrans(){
    var box = Boxes.getTransactions();
    transactions = box.values.toList();
    if(transactions!.isEmpty)
      addTransaction(service, [], [], userData, myOrders, userInfo, Address, order);
    else{
      order = transactions![0].order;
    }
  }
}
