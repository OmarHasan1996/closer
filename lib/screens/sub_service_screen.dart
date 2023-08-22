import 'dart:convert';
import 'dart:math';

//import 'package:admob_flutter/admob_flutter.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:closer/api/api_service.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/localizations.dart';
import 'package:closer/screens/sub_service_dec.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:closer/MyWidget.dart';
import 'package:closer/const.dart';

// ignore: must_be_immutable
class SubServiceScreen extends StatefulWidget {
  String token;
  List subservice = [];
  List subservicedec = [];
  SubServiceScreen({
    required this.token,
    required this.subservice,
  });

  @override
  _SubServiceScreenState createState() =>
      _SubServiceScreenState(this.token, this.subservice);
}

class _SubServiceScreenState extends State<SubServiceScreen> {
  String? lng;
  String token;
  List _subservice = [];
  List subservice = [];
  List subservicedec = [];
  getSubServiceDecData(var id) async {
   try{
     // print(id);
     var url = Uri.parse('$apiDomain/Main/Services/Services_Read?filter=IsMain~eq~false~and~Id~eq~$id');
     http.Response response = await http.get(url, headers: {
       "Authorization": token,
     });
     if (response.statusCode == 200) {
       var item = json.decode(response.body)["result"]['Data'];
       setState(() {
         subservicedec = item;
         editTransactionUserUserInfo(transactions![0], userInfo);
         editTransactionServiceDec(transactions![0], subservicedec, id);
         //print(subservicedec);
       });
       Navigator.push(
           context,
           MaterialPageRoute(
               builder: (context) =>
                   SubServiceDec(token: token, subservicedec: subservicedec))).then((_) {setState(() {});});
     } else {
       setState(() {
         subservicedec = [];
       });
     }
   }catch(e){
     subservicedec = transactions![0].subServiceDec;
     if(subservicedec.isEmpty){
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
     } else if(subservicedec[0]["Id"]==id) {
       Navigator.push(
           context,
           MaterialPageRoute(
               builder: (context) =>
                   SubServiceDec(token: token, subservicedec: subservicedec))).then((_) {setState(() {});});
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

  _SubServiceScreenState(this.token, this.subservice);
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  loadBannerAdd(){
    return SizedBox();
    /*return AdmobBanner(
      adUnitId: getBannerAdUnitId()!,
      adSize: AdmobBannerSize.ADAPTIVE_BANNER(
        // height: MediaQuery.of(context).size.height.toInt()-40,
        width: MediaQuery.of(context).size.width.toInt(), // considering EdgeInsets.all(20.0)
      ),
      listener: (AdmobAdEvent event,
          Map<String, dynamic>? args) {
       // handleEvent(event, args, 'Banner');
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

  APIService? api;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _subservice.clear();
    for(int i = 0; i<subservice.length; i++){
      _subservice.add(subservice[i]);
    }
    allSubServices.add(subservice);
    // print(subservice);
  }
  bool _loading = false, _transScreen = false;

  @override
  Widget build(BuildContext context) {
    var barHight = MediaQuery.of(context).size.height / 5.7;
    //getServiceData();
    api = APIService(context: context);
    var id = _subservice[_subservice.indexWhere((element) => element.length<2)]['id'];
    _subservice.sort((a, b) {
      return a['Name'].toString().toLowerCase().compareTo(b['Name'].toString().toLowerCase());
    });
    _subservice.removeWhere((element) => element.length<2);
    _subservice.add({'id':id});
    return SafeArea(
        child: Scaffold(
          key: _key,
          appBar: new AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: barHight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(MediaQuery.of(context).size.height / 80 * 3),
                  bottomLeft: Radius.circular(MediaQuery.of(context).size.height / 80 * 3)),
            ),
            backgroundColor: AppColors.blue,
            title: MyWidget(context).appBarTittle(barHight, _key),
            actions: [new IconButton(
                icon: new Icon(Icons.arrow_back_outlined),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          endDrawer: MyWidget(context).drawer(barHight, MediaQuery.of(context).size.height / 80 * 3, ()=>_setState()),
          backgroundColor: Colors.grey[100],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            _topYellowDriver(),
            SizedBox(
              height: MediaQuery.of(context).size.height / 160,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 40,
                  horizontal: MediaQuery.of(context).size.width / 22),
              child: Container(
                //alignment: Alignment.topLeft,
                child: MyWidget(context).textTitle15(_subservice.length>1?_subservice[0]['Service']['Name']:'Empty',scale: 1.2)
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  //vertical: MediaQuery.of(context).size.height / 37,
                  horizontal: MediaQuery.of(context).size.width / 10),
              child: Container(
                //alignment: Alignment.topLeft,
                child: MyWidget(context).textBlack20((_subservice.length - 1).toString() + ' ' +AppLocalizations.of(context)!.translate('Services in ...'),bold: false),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    itemCount: _subservice.length-1,
                    itemBuilder: (context, index) {
                      return serviceRow(_subservice[index]);
                    },
                    addAutomaticKeepAlives: false,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: _jumbingDotes(_loading),
                  ),
                  _transScreen?
                  MyWidget(context).transScreen():SizedBox()
                ],
              ),
            ),
            loadBannerAdd(),

            /* Container(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 90,
                      decoration: BoxDecoration(
                        color: Color(0xffffca05),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 10,
                      decoration: BoxDecoration(
                        color: Color(0xff2e3191),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: MediaQuery.of(context).size.width / 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.home_outlined,
                                  color: Color(0xffffca05),
                                  size: MediaQuery.of(context).size.width / 9,
                                ),
                                Text(
                                  'Home'.tr,
                                  style: TextStyle(
                                    color: Color(0xffffca05),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.white,
                                  size: MediaQuery.of(context).size.width / 9,
                                ),
                                Text(
                                  'My Order'.tr,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.face,
                                  color: Colors.white,
                                  size: MediaQuery.of(context).size.width / 9,
                                ),
                                Text(
                                  'My profile'.tr,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            //icons(Icons.home_outlined, "Home",),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))*/
          ]),
        ),
    );
  }

  /*Column icons(IconData c, String t) {
    return Column(
      children: [
        Icon(
          c,
          size: MediaQuery.of(context).size.width / 9,
          color: Colors.white,
        ),
        Text(
          t,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width / 30,
          ),
        )
      ],
    );
  }*/

  Padding serviceRow(ser) {
    var desc = ser['Desc'];
    var name = ser['Name'];
    var imagepath = ser['ImagePath'];
    var price = ser['Price'];

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width *0.03,
          horizontal: MediaQuery.of(context).size.width / 22),
      child: Row(
        children: [
          GestureDetector(
            onTap: ()=> APIService(context: context).showImage(imagepath),
            child: Container(
                alignment: Alignment.center,
                width: min(MediaQuery.of(context).size.width * 0.20, MediaQuery.of(context).size.height * 0.092),
                height: min(MediaQuery.of(context).size.height / 10, MediaQuery.of(context).size.width /4.4),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
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
                  borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height / 51)),
                )),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.045,
          ),
          GestureDetector(
            onTap: () async{
              setState(() {
                _loading = true;
                _transScreen = true;
              });
              var id = ser['Id'];
              if(ser['IsMain']) await getSubServiceData(id);
              else await getSubServiceDecData(id);
              setState(() {
                _loading = false;
                _transScreen = false;
              });
            },
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.85 - min(MediaQuery.of(context).size.width * 0.20, MediaQuery.of(context).size.height * 0.092),
              height: min(MediaQuery.of(context).size.height / 10, MediaQuery.of(context).size.width /4.4),
             decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height / 51)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height / 80,
                    horizontal: MediaQuery.of(context).size.width / 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: MyWidget(context).textTitle15(name, scale: 0.95),
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              child: MyWidget(context).textTap25(
                                  (ser['IsMain'])?desc.toString(): price.toString() + ' ${AppLocalizations.of(context)!.translate('TRY')}',
                                  ),
                              /*child: Text(
                                //AppLocalizations.of(context)!.translate('From') + price.toString() + ' .${AppLocalizations.of(context)!.translate('TRY')}',
                                  (ser['IsMain'])?desc.toString(): price.toString() + ' ${AppLocalizations.of(context)!.translate('TRY')}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: MediaQuery.of(context).size.width / 25,
                                ),
                              ),*/
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      size: min(MediaQuery.of(context).size.height / 45, MediaQuery.of(context).size.width /20),
                      color: Colors.grey,
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

  _topYellowDriver(){
    return   Center(
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width / 1.2,
        height: MediaQuery.of(context).size.height / 80,
        decoration: BoxDecoration(
          color: AppColors.yellow,
          borderRadius:
          BorderRadius.vertical(bottom: Radius.circular(MediaQuery.of(context).size.height / 80)),
        ),
      ),
    );
  }

  _setState(){
    setState(() {});
  }

  getSubServiceData(var id) async {
    try{
      var url = Uri.parse('$apiDomain/Main/Services/Services_Read?filter=ServiceParentId~eq~$id');
      //var url = Uri.parse('https://mr-service.online/Main/Services/Services_Read?');
      //var url = Uri.parse('https://mr-service.online/Main/Services/Services_Read?filter=IsMain~eq~false~and~ServiceParentId~eq~$id');
      http.Response response = await http.get(
        url,
        headers: {
          "Authorization": token,
        },
      );
      if (response.statusCode == 200) {
        var item = json.decode(response.body)["result"]['Data'];
            //editTransactionService(transactions![0], service);
            //editTransactionUserUserInfo(transactions![0], userInfo);
        if (item.length==0) {
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
            message: AppLocalizations.of(context)!.translate('This service will coming soon'),
            messageSize: MediaQuery.of(context).size.width / 22,
          ).show(context);
        } else {
          _subservice = item;
          editTransactionSubService(transactions![0], _subservice, id);
          Navigator.push(context, new MaterialPageRoute(builder: (context) => new SubServiceScreen(token: token, subservice: _subservice),),).then((_) {
            // This block runs when you have returned back to the 1st Page from 2nd.
            setState(() {
              allSubServices.removeAt(allSubServices.length-1);
              _subservice = allSubServices[allSubServices.length-1];
              // Call setState to refresh the page.
            });
          });
        }
      } else {
        setState(
              () {
            _subservice = [];
          },
        );
      }
    }catch(e){
      _subservice = transactions![0].subService;
      if(_subservice.length==1){
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
      } else if(_subservice[_subservice.length-1]["id"]==id) {
        Navigator.push(context, new MaterialPageRoute(builder: (context) => new SubServiceScreen(token: token, subservice: _subservice),),);
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

  _jumbingDotes(bool loading){
    if(loading)
      return Container(
        height: double.infinity,
        color: Colors.white24,
        child:  JumpingDotsProgressIndicator(
          fontSize: 40.0,
          numberOfDots:7,
        ),
      );
    else
      return SizedBox();
  }

}
