import 'package:closer/MyWidget.dart';
import 'package:closer/api/api_service.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/constant/app_size.dart';
import 'package:closer/helper/adHelper.dart';
import 'package:closer/localizations.dart';
import 'package:flutter/material.dart';
class DriverList extends StatefulWidget {
  const DriverList({super.key});

  @override
  State<DriverList> createState() => _DriverListState();
}

class _DriverListState extends State<DriverList> {
  bool _loading = false;
  List<DriverDetails> _driverList =[
    DriverDetails(image: 'image', name: 'name', phone: 'phone', lat: '15.12566', long: '33.2543', id: 'id', fcmToken: 'ffff'),
    DriverDetails(image: 'image', name: 'name', phone: 'phone', lat: '15.12566', long: '33.2543', id: 'id', fcmToken: 'ffff'),
    DriverDetails(image: 'image', name: 'name', phone: 'phone', lat: '15.12566', long: '33.2543', id: 'id', fcmToken: 'ffff'),
    DriverDetails(image: 'image', name: 'name', phone: 'phone', lat: '15.12566', long: '33.2543', id: 'id', fcmToken: 'ffff'),
    DriverDetails(image: 'image', name: 'name', phone: 'phone', lat: '15.12566', long: '33.2543', id: 'id', fcmToken: 'ffff'),
  ];
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  @override
  Widget build(BuildContext context) {
    var barHight = MediaQuery.of(context).size.height / 5.7;
    //getServiceData();
    AdHelper.loadBanner();
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: MyWidget.appBar(
            title: AppLocalizations.of(context)!.translate('Available Drivers'),
            isMain: true, withoutCart: true, key: _key),
        drawer: MyWidget(context).drawer(barHight, MediaQuery.of(context).size.height / 80 * 3, () => _setState(), ),
        backgroundColor: Colors.grey[100],
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MyWidget.topYellowDriver(),
          SizedBox(
            height: MediaQuery.of(context).size.height / 160,
          ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: _driverList.length,
                  itemBuilder: (context, index) {
                    return driverContainer(_driverList[index]);
                  },
                  addAutomaticKeepAlives: false,
                ),
                Align(
                  alignment: Alignment.center,
                  child: MyWidget.jumbingDotes(_loading),
                ),
                _loading ? MyWidget(context).transScreen() : SizedBox()
              ],
            ),
          ),
          MyWidget.loadBannerAdd(),
        ]),
      ),
    );
  }

  _setState() {
    setState(() {

    });
  }

  Widget driverContainer(DriverDetails driverList) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppWidth.w4, vertical: AppWidth.w2),
      margin: EdgeInsets.symmetric(horizontal: AppWidth.w4, vertical: AppHeight.h1),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mainColor1, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(AppWidth.w4)),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyWidget(context).textHead10(driverList.name, color: AppColors.black),
         SizedBox(height: AppHeight.h1,),
          Row(
            children: [
              Icon(Icons.pedal_bike),
              SizedBox(width: AppWidth.w2,),
              MyWidget(context).textBlack20('text'),
              Spacer(),
              Icon(Icons.timer_outlined),
              SizedBox(width: AppWidth.w2,),
              MyWidget(context).textBlack20('text'),
            ],
          ),
          SizedBox(height: AppHeight.h1,),
          MyWidget(context).raisedButton(AppLocalizations.of(context)!.translate('Add Task'), ()=> _addTask(), AppWidth.w80, _loading),
        ],
      ),
    );
  }

  _addTask() {}

}
class DriverDetails{
 String id, fcmToken, image, name, phone, long, lat;
 DriverDetails({required this.image, required this.name, required this.phone, required this.lat, required this.long, required this.id, required this.fcmToken});
}