import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:closer/api/api_service.dart';
import 'package:closer/color/MyColors.dart';

import 'package:closer/MyWidget.dart';
import 'package:closer/const.dart';
import 'package:closer/localizations.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class TaskId extends StatefulWidget {
  String token;
  var orde;
  TaskId(this.token,this.orde);
  @override
  _TaskIdState createState() => _TaskIdState(token,orde);
}

class _TaskIdState extends State<TaskId> {
  String token;
  APIService? api;
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  DropdownMenuItem<String> buildMenuItem(dynamic item) {
    return DropdownMenuItem(
      value: item['Id'],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              //Icon(Icons.pin_drop_outlined),
              Flexible(
                child: Text(
                  item['name'],
                  style: TextStyle(
                    color: AppColors.black,
                  ),
                ),
              ),
              //Icon(Icons.arrow_drop_down_outlined),
            ],
          ),
        ],
      ),
    );
  }

  String _name = '',_location = '',_phone = '',_orderDetails = '', _orderDate = '', _orderTime = '', _finishDate = '', _finishTime = '', taskName = '', attach = '';
  List orderServices = [{'name':'S 1', 'id':'1'},{'name':'S 2', 'id':'2'}];
  var statusCode = 1;
  var ord;
  _TaskIdState(this.token ,this.ord);
  var id, serial;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print(subservicedec);
    serial= ord['OrderService']['Order']['Serial'];
    id= ord['OrderService']['OrderId'];
    var workerName = ord['User']['Name'] + ' ' + ord['User']['LastName'];
    var date = ord['StartDate'];
    statusCode = ord['Status'];
    taskName = ord['Name'];
    date = DateTime.parse(date.replaceAll('T', ' ')).add(-timeDiff).toString();
    _orderDate= date.split(" ")[0];
    _orderTime  = date.split(" ")[1].toString().split('.')[0];
    if(statusCode == 2){// finished
      date = ord['EndDate'];
      date = DateTime.parse(date.replaceAll('T', ' ')).add(-timeDiff).toString();
      _finishDate = date.split(" ")[0];
      _finishTime = date.split(" ")[1].toString().split('.')[0];
    }
    //selectedTime = TimeOfDay.now();
    var addressArea = ord['OrderService']['Order']['Address']['Area']['Name'];
    var addressCity = ord['OrderService']['Order']['Address']['Area']['City']['Name'];
    var addressNotes = ord['OrderService']['Order']['Address']['notes'];
    var addressBuilding = ord['OrderService']['Order']['Address']['building'];
    var addressFloor = ord['OrderService']['Order']['Address']['floor'];
    var addressAppartment = ord['OrderService']['Order']['Address']['appartment'];
    _name = ord['OrderService']['Order']['User']['Name']+' '+ord['OrderService']['Order']['User']['LastName'];
    _location = addressArea + " / " + addressCity + " / " + addressNotes +
        " / " + addressBuilding + " / " + addressFloor + " / " + addressAppartment;
    _phone = ord['OrderService']['Order']['User']['Mobile'];
    _orderDetails = ord['Notes'];

    try{
      attach = ord['OrderService']['OrderServiceAttatchs'][0]['FilePath'].toString();
    }catch(e){
      attach = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    var barHight = MediaQuery.of(context).size.height / 5.7;
    //getServiceData();
    api = APIService(context: context);
    var leftPadding = MediaQuery.of(context).size.width/12;

    return SafeArea(
        child: Scaffold(
          key: _key,
          resizeToAvoidBottomInset: true,
          appBar: new AppBar(
            toolbarHeight: barHight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(MediaQuery.of(context).size.height / 80 * 3),
                  bottomLeft: Radius.circular(MediaQuery.of(context).size.height / 80 * 3)),
            ),
            backgroundColor: AppColors.blue,
            title: MyWidget(context).appBarTittle(barHight, _key),
            actions: [
              new IconButton(
                icon: new Icon(Icons.keyboard_backspace_outlined),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          endDrawer: MyWidget(context).drawer(barHight, MediaQuery.of(context).size.height / 80 * 3, ()=>_setState()),
          backgroundColor: Colors.grey[100],
          body: SingleChildScrollView(
            child: Column(children: [
              _topYellowDriver(),
              SizedBox(
                height: MediaQuery.of(context).size.height / 180,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: leftPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/25),
                      child: Text(
                        taskName,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: MediaQuery.of(context).size.width / 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 180,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: MediaQuery.of(context).size.height *(0.7*0.95),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        boxShadow: [BoxShadow(
                          color: AppColors.white,//Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 1), // changes position of shadow
                        ),],
                        borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height / 80)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height / 100,
                            horizontal: MediaQuery.of(context).size.width / 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/200),
                              child: Text(
                                AppLocalizations.of(context)!.translate('Address Details'),
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: MediaQuery.of(context).size.width / 22,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            _iconText(Colors.grey, Icons.person, _name, MainAxisAlignment.start),
                            _iconText(Colors.grey, Icons.location_on_outlined, _location, MainAxisAlignment.start),
                            _iconText(Colors.grey, Icons.call, _phone, MainAxisAlignment.start),
                            SizedBox(height: MediaQuery.of(context).size.height/80,),
                            Divider(height: 1, thickness: 2, color: Colors.grey[400],),
                            SizedBox(height: MediaQuery.of(context).size.height/80,),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/200),
                              child: Text(
                                AppLocalizations.of(context)!.translate('Task Details'),
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: MediaQuery.of(context).size.width / 22,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height/30,
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/200),
                              child: Scrollbar(
                                isAlwaysShown: true,
                                child: SingleChildScrollView(
                                  //scrollDirection: Axis.vertical,
                                  child: Text(
                                    _orderDetails,
                                    maxLines: null,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: MediaQuery.of(context).size.width / 30,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height/200,),
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: _iconText(Colors.grey, Icons.timer, _orderTime, MainAxisAlignment.start)
                                ),
                                Expanded(
                                    flex: 3,
                                    child: _iconText(Colors.grey, Icons.date_range_outlined, _orderDate, MainAxisAlignment.end)),
                              ],
                            ),
                            statusCode == 2?
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '→',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: MediaQuery.of(context).size.height / 40,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: _iconText(Colors.grey, Icons.timer, _finishTime, MainAxisAlignment.start)
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: _iconText(Colors.grey, Icons.date_range_outlined, _finishDate, MainAxisAlignment.end)),
                                  ],
                                )
                              ],)
                                :SizedBox(height: 0,),
                            SizedBox(height: MediaQuery.of(context).size.height/80,),
                            Divider(height: 1, thickness: 2, color: Colors.grey[400],),
                            SizedBox(height: MediaQuery.of(context).size.height/80,),
                            Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _netWorkImage(attach),
                                      SizedBox(height: MediaQuery.of(context).size.height/80,),
                                      Divider(height: 1, thickness: 2, color: Colors.grey[400],),
                                      SizedBox(height: MediaQuery.of(context).size.height/80,),
                                      isBoss? _netWorkImage(ord['WorkerTaskAttatchs'].length>0?ord['WorkerTaskAttatchs'][0]['FilePath']:'')
                                          :_uploadImage(),
                                    ],
                                  ),
                                )
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height/80,),
                            MyWidget(context).raisedButton(isBoss?AppLocalizations.of(context)!.translate('Ok'):AppLocalizations.of(context)!.translate('Finish Task'), () => _finishTask(), MediaQuery.of(context).size.width, chCircle)

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
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

  _containerName(desc, padding, height, width, controller, fontSize){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/20),
          child: Text(
            desc,
            style: TextStyle(
              color: Colors.black38,
              fontSize: MediaQuery.of(context).size.width/25,
            ),
          ),
        ),
        SizedBox(height: padding,),
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/20),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 1), // changes position of shadow
            ),],
            borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height / 160)),
          ),
          child: TextField(
            maxLines: null,
            textInputAction: TextInputAction.done,
            //enabled: false,
            readOnly: true,
            textAlign: TextAlign.left,
            controller: controller,
            style: TextStyle(fontSize: fontSize),
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }
/*
  _manageServiceList(){
    return ListView.builder(
      key: UniqueKey(),
      itemCount: orderServices.length,
      itemBuilder: (context, index) {
        var _color = MyColors.black;
        for(int i = 0; i < task.length; i++){
          if(task[i][0]['Service']['Id'] == orderServices[index]['Id'])
            _color = MyColors.blue;
        }
        return Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width/2.8,
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/25*0),
              child: Text(
                orderServices[index]['Service']['Name'],
                maxLines: null,
                //textAlign: TextAlign.center,
                style: TextStyle(
                  color: _color,
                  fontSize: MediaQuery.of(context).size.width/22,
                ),
              ),
            ),
            Expanded(child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/80),
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width/2,
              height: MediaQuery.of(context).size.height/20,
              child: _manageButton(index),
            )
            )
          ],
        );;
      },
      // addAutomaticKeepAlives: false,
    );
  }
*/
  _raisedButton(text , press, width){
    return MyWidget(context).raisedButton(text, ()=>press(), width, chCircle);
    /*return  Container(
      width: width,
      // ignore: deprecated_member_use
      child: RaisedButton(
        onPressed: () => press(),
        padding: EdgeInsets.symmetric(vertical: 0,horizontal: MediaQuery.of(context).size.width/10),
        color: MyColors.yellow,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.height / 12))),
        child: chCircle == true
            ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              MyColors.blue),
          backgroundColor: Colors.grey,
        )
            :Text(
          text,
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width / 22,
              color: MyColors.buttonTextColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );*/
  }

/*
  _manageButton(id){
    // ignore: deprecated_member_use
    return RaisedButton(
      onPressed: ()  {
        Navigator.push(this.context, MaterialPageRoute(builder: (context) => ManageTask(token, _name, _location, _phone, _orderDetails, _orderTime, _orderDate, ord['Id'] ,orderServices[id]),),).then((_) {
          setState(() {});
        });
      },
      ///padding: EdgeInsets.symmetric(vertical: 0, horizontal: MediaQuery.of(context).size.width/6),
      color: MyColors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height / 120))),
      //child: Icon(Icons.add),
      child: Text(AppLocalizations.of(context)!.translate('Manage Tasks'),
          style: TextStyle(fontSize: MediaQuery.of(context).size.width / 25, color: MyColors.White, fontWeight: FontWeight.normal)),
    );
  }
*/
  _iconText(_color, _icon, text, _mainAxisAlignment){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0, vertical: MediaQuery.of(context).size.height/200),
      child: Row(
        mainAxisAlignment: _mainAxisAlignment,
        children: [
          Icon(_icon,color: _color),
          SizedBox(width: MediaQuery.of(context).size.width/30,),
          Expanded(child: SingleChildScrollView(

            scrollDirection: Axis.horizontal,
            child: Text(text, style: TextStyle(fontSize: MediaQuery.of(context).size.width/25, color: AppColors.buttonTextColor),),
          )),
        ],
      ),
    );
  }

  _setState(){
    setState(() {});
  }

  ImageProvider? image = null;
  String? path ;
  XFile? xFile;
  _uploadImage(){
    return GestureDetector(
      onTap: () async {
        final ImagePicker _picker = ImagePicker();
        xFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 25);
        path = xFile!.path;
        print(path);
        image = FileImage(File(path!));
        setState(() {

        });
        /*final bytes = await XFile(path).readAsBytes();
                          final img.Image image = img.decodeImage(bytes);*/
      },
      child: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.12,
        width: MediaQuery.of(context).size.width /1.2,
        decoration: image == null ? BoxDecoration(
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
        ) :
        BoxDecoration(
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

  _netWorkImage(imagePath){
    return GestureDetector(
      onTap: () => api!.showImage(imagePath),
      child:Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 0.11,
      width: MediaQuery.of(context).size.width / 1.2,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(imagePath) as ImageProvider,
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
      )
      ),
    );
  }

  bool chCircle = false;

  _finishTask() async{
    if(isBoss){
      Navigator.pop(context);
      return;
    }
    setState(() {
      chCircle = true;
    });
    String endDate = DateFormat('yyyy-MM-dd hh:mm:ss.sss').format(DateTime.now().add(timeDiff)).replaceAll(" ", "T") + "Z";
    bool _suc;
    var fcmToken = '';
    for(int i =0; i< groupUsers.length; i++){
      if(groupUsers[i]['isBoss'] == true)
        fcmToken = groupUsers[i]['Users']['FBKey'];
    }
    if(xFile != null)
      _suc = await api!.updateWorkerTask(ord['Id'], ord['WorkerId'], ord['OrderServicesId'], ord['Notes'], ord['StartDate'], endDate, 'workerNotes', token, ord['Name'], File(xFile!.path),fcmToken);
    else
      _suc = await api!.updateWorkerTask(ord['Id'], ord['WorkerId'], ord['OrderServicesId'], ord['Notes'], ord['StartDate'], endDate, 'workerNotes', token, ord['Name'], 'File(xFile!.path)',fcmToken);
    if (_suc){
    Navigator.pop(context);
    APIService.flushBar(AppLocalizations.of(context)!.translate('Task is Finished'));
    setState(() {
    chCircle = false;
    });
    //new Timer(Duration(seconds:2), ()=>setState(() {}));
    //setState(() {});
    }
    return;
  }
}
