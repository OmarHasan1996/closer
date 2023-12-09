import 'dart:async';
import 'dart:ffi';

import 'package:closer/MyWidget.dart';
import 'package:closer/api/api_service.dart';
import 'package:closer/api/respons/matrixApiData.dart' as mmm;
import 'package:closer/color/MyColors.dart';
import 'package:closer/const.dart';
import 'package:closer/constant/app_size.dart';
import 'package:closer/constant/functions.dart';
import 'package:closer/helper/adHelper.dart';
import 'package:closer/localizations.dart';
import 'package:closer/screens/signin.dart';
import 'package:flutter/material.dart';

class DriverList extends StatefulWidget {
  final service, orderId;
  const DriverList({super.key, required this.service, this.orderId});

  @override
  State<DriverList> createState() => _DriverListState();
}

class _DriverListState extends State<DriverList> {
  bool _loading = true, _chCircle = false;
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
            isMain: false,
            withoutCart: true,
            key: _key),
        drawer: MyWidget(context).drawer(
          barHight,
          MediaQuery.of(context).size.height / 80 * 3,
          () => _setState(),
        ),
        backgroundColor: Colors.grey[100],
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MyWidget.topYellowDriver(),
          SizedBox(
            height: MediaQuery.of(context).size.height / 160,
          ),
          Expanded(
            child: Stack(
              children: [
                FutureBuilder(
                    future: _loading?APIService.getDriverListUser():null,
                    builder: (BuildContext context, AsyncSnapshot snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        _loading = true;
                        return MyWidget.jumbingDotes(_loading);
                        return SizedBox();
                      } else {
                        //return SizedBox();
                        _loading = false;
                        return ListView.builder(
                          itemCount: driversList.length,
                          itemBuilder: (context, index) {
                            return driverContainer(driversList[index]);
                          },
                          addAutomaticKeepAlives: false,
                        );
                      }
                    }),
                //_loading ? MyWidget(context).transScreen() : SizedBox()
              ],
            ),
          ),
          MyWidget.loadBannerAdd(),
        ]),
      ),
    );
  }

  _setState() {
    setState(() {});
  }

  Widget driverContainer(DriverDetails driverList) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: AppWidth.w4, vertical: AppWidth.w2),
      margin:
          EdgeInsets.symmetric(horizontal: AppWidth.w4, vertical: AppHeight.h1),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mainColor1, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(AppWidth.w4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyWidget(context).textHead10(driverList.name, color: AppColors.mainColor, scale: 0.5),
          SizedBox(
            height: AppHeight.h1,
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                Icon(Icons.social_distance_outlined),
                SizedBox(
                  width: AppWidth.w2,
                ),
                MyWidget(context).textBlack20(driverList.matrixApi!=null?driverList.matrixApi!.rows[0].elements[0].distance.text:'....'),
                Spacer(),
              ],
            ),
          ),
          SizedBox(
            height: AppHeight.h1,
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                Icon(Icons.timer_outlined),
                SizedBox(
                  width: AppWidth.w2,
                ),
                MyWidget(context).textBlack20(driverList.matrixApi!=null?driverList.matrixApi!.rows[0].elements[0].duration.text:'....'),
              ],
            ),
          ),
          SizedBox(
            height: AppHeight.h1,
          ),
          MyWidget(context).raisedButton(
              AppLocalizations.of(context)!.translate('Add Task'),
              () => _addTask(driverList),
              AppWidth.w80,
              driverList.addTaskNow),
        ],
      ),
    );
  }

  _addTask(DriverDetails driver) async{
    setState(() {
      driver.addTaskNow = true;
    });
    navigat(){
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
    //task.clear();
    var startDateTime = "${DateTime.now().add(timeDiff).toString().replaceAll(" ", "T")}Z";
        bool upload = false;
        upload = await APIService(context: context).createWorkerTask(
            widget.orderId,
            driver.id,
            widget.service['Id'],
            'des',
            startDateTime,
            ' endDate',
            'workerNotes',
            token,
            driver.fcmToken,
            AppLocalizations.of(context)!.translate('Deliver'),
          );
        if (upload) {
          APIService.flushBar(AppLocalizations.of(context)!.translate('has been added to') + driver.name);
           setState(() {
            _chCircle = false;
          });
          var duration = new Duration(seconds:2);
          return Timer(duration, navigat);
        }
        //await api!.createWorkerTask(orderId, workerId, serviceId, supervisorNotes, startDate, endDate, workerNotes, token);
    setState(() {
      driver.addTaskNow = false;
    });

  }
}

class DriverDetails {
  mmm.MatrixApi? matrixApi;
  String id, fcmToken, image, name, phone, long, lat;
  bool addTaskNow = false;
  DriverDetails(
      {required this.image,
      required this.name,
      required this.phone,
      required this.lat,
      required this.long,
      required this.id,
      required this.fcmToken}) {
    ;
  }
  Future<bool> calckDriverMatrix()async{
    matrixApi = await MyApplication.bearingFromMyLocation(long, lat);
    return true;
  }
}
