import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart'as http;
import 'package:closer/color/MyColors.dart';
import 'package:closer/firebase/Firebase.dart';
import 'package:closer/localizations.dart';
import 'package:closer/model/transaction.dart';
import 'dart:convert';

//import 'package:mr_service/module/login_module.dart';
import 'package:closer/screens/loading_screen.dart';
import 'package:closer/screens/newOrder.dart';
import 'package:closer/screens/signin.dart';
import 'package:path/path.dart';

import '../const.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization_service.dart';
import 'package:closer/localizations.dart';
import 'package:closer/localization_service.dart' as trrrr;

class APIService {
  /*Future <LoginResponseModel> loginOld (LoginRequestModel loginRequestModel)async{
   // var url = Uri.parse('https://mr-service.online/api/Auth/login');
   // final response = await http.post(url,body:loginRequestModel.toJson() );
    http.Response response = await http.post(
        Uri.parse('https://mr-service.online/api/Auth/login'),
        body:
        jsonEncode(loginRequestModel),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
        });
    if(response.statusCode == 200 || response.statusCode == 400){
      return LoginResponseModel.fromJson(json.decode(response.body));
    }
    else{
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }*/

  MyFirebase myFirebase = new MyFirebase();
  BuildContext? context;
  APIService({this.context});

  login(email , password) async{
    var fcmToken;
    try{
      fcmToken = await myFirebase.getToken();
      print(fcmToken);
    }
    catch(e){
      fcmToken='';
      print(e);
      flushBar(e.toString());
      chLogIn = false;
    }
    try{
      http.Response response = await http.post(
          Uri.parse('$apiDomain/api/Auth/login?'),
          body: jsonEncode({"UserName": email, "Password": password, "FBKey":fcmToken.toString()}),
          headers: {
            "Accept-Language": trrrr.LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
          });
      //await Hive.initFlutter();
      //Hive.registerAdapter(TransactionAdapter());
      //await Hive.openBox<Transaction>('transactions');
      return response;
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      print(e);
      chLogIn = false;
    }
  }

  userLang(langNum , id) async{
    try{
      http.Response response = await http.post(
          Uri.parse('$apiDomain/Main/Users/UserLang_Update?'),
          body: jsonEncode({"intParam": langNum.toString(), "guidParam": id.toString()}),
          headers: {
            "Accept-Language": trrrr.LocalizationService.getCurrentLocale().languageCode,
            "Accept": "application/json",
            "content-type": "application/json",
            "Authorization": token,
          });
      print(response.body);
    }
    catch(e){
      flushBar(AppLocalizations.of(context!)!.translate('please! check your network connection'));
      print(e);
      chLogIn = false;
    }
  }

  flushBar(text){
    Flushbar(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context!).size.height / 30),
      icon: Icon(
        Icons.error_outline,
        size: MediaQuery.of(context!).size.height / 30,
        color: MyColors.White,
      ),
      duration: Duration(seconds: 3),
      shouldIconPulse: false,
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      backgroundColor: Colors.grey.withOpacity(0.5),
      barBlur: 20,
      message: text,
      messageSize: MediaQuery.of(context!).size.height / 37,
    ).show(context!);
  }

  uploadOrderWithAttach(id,insertDateTime,value3,orderDateTime,token) async {
    /*Dio dio = new Dio();
    String uploadurl = "https://mr-service.online/Main/Orders/Orders_CreateWithAttachs";
    //dont use http://localhost , because emulator don't get that address
    //insted use your local IP address or use live URL
    //hit "ipconfig" in windows or "ip a" in linux to get you local IP
    //dio.options.baseUrl = 'https://mr-service.online/Main';
    dio.options.connectTimeout = 5000000; //5000s
    dio.options.receiveTimeout = 5000000;
    dio.options.headers = {
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token,
    };*/
    var apiUrl = Uri.parse('$apiDomain/Main/Orders/Orders_CreateWithAttachs?');
    var request = http.MultipartRequest("POST", apiUrl);
    var amount = 0.0;
    List<Map<String, dynamic>> serviceTmp = [];
    for (int i = 0; i < order.length; i++) {
      var attach;
      List<Map<String, dynamic>> serviceAttach = [];
      try{
        //attach = await MultipartFile.fromFile(order[i][0][0]['Service']['File'].path.toString(), filename: order[i][0][0]['Service']['File'].name);
        attach = await http.MultipartFile.fromPath("File", order[i][0][0]['Service']['File'].path.toString());
        request.files.add(attach);
        for (int j=0; j<1; j++){
          serviceAttach.add({
            "FilePath": attach.filename,
            "AttNotes": "AttNotes",
            "AttId": "$id",
            "AttFile": {"File": attach}
          });
        }
      }catch(e){
        attach = null;
      }
      amount += (order[i][0][0]['Price']) * int.parse(order[i][1]);
      serviceTmp.add({
        "ServiceId": order[i][0][0]['Id'],
        "Price": order[i][0][0]['Price'],
        "Quantity": int.parse(order[i][1]),
        "ServiceNotes": order[i][0][1]["Notes"],
        "OrderServiceAttatchs": attach == null?'' :  serviceAttach,
        // ignore: equal_keys_in_map
      });
    }

    FormData formdata = FormData.fromMap({
      "CustomerId": "$id",
      "Amount": amount,
      "InsertDate": insertDateTime,
      "Status": 1,
      "PayType": 1,
      "AddressId": value3,
      "OrderDate": orderDateTime,
      "Notes": "string",
      "OrderServices": serviceTmp
    });
    print(token);
    //print(formdata.fields);
    //print(formdata.files);

    //create multipart request for POST or PATCH method
    //add text fields
    request.fields.addAll(Map.fromEntries(formdata.fields));
    request.headers.addAll({
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token,
    });
    print(request.files);
    print(request.fields);
    //create multipart using filepath, string or bytes
    //var pic = await http.MultipartFile.fromPath("file_field", file.path);
    //add multipart to request
    //request.files.add(pic);
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      //Get the response from the server
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      print(responseString);
      try{
        if (jsonDecode(responseString)['Errors'] == null || jsonDecode(responseString)['Errors'] == ''){
          print('success');
          return true;
        }else{
          flushBar(jsonDecode(responseString)['Errors']);
          return false;
        }
      }catch(e){
        return true;
      }
    } else {
      return false;
      print(response.statusCode);
    }
/*
    try{
      Response response = await dio.post(uploadurl, data: formdata,
          options: Options(method: 'POST',) // or ResponseType.JSON
        /*onSendProgress: (int sent, int total) {
        String percentage = (sent/total*100).toStringAsFixed(2);
        setState(() {
          progress = "$sent" + " Bytes of " "$total Bytes - " +  percentage + " % uploaded";
          //update the progress
        });
      },*/);
    }catch(e){
      print(e);
    }
    Response response = await dio.post(uploadurl, data: formdata,
       options: Options(method: 'POST', responseType: ResponseType.json) // or ResponseType.JSON
      /*onSendProgress: (int sent, int total) {
        String percentage = (sent/total*100).toStringAsFixed(2);
        setState(() {
          progress = "$sent" + " Bytes of " "$total Bytes - " +  percentage + " % uploaded";
          //update the progress
        });
      },*/);
    print(response.data);
    print(response.statusCode);
    return response;
*/
  }

  uploadOrderWithAttachNew(id,insertDateTime,value3,orderDateTime,token) async {
    var apiUrl = Uri.parse('$apiDomain/Main/Orders/Orders_CreateWithAttachs?');
    var request = http.MultipartRequest("POST", apiUrl);
    var amount = 0.0;
    List<Map<String, dynamic>> serviceTmp = [];
    for (int i = 0; i < order.length; i++) {
      var attach;
      List<Map<String, dynamic>> serviceAttach = [];
      try{
        var file = order[i][0][0]['Service']['File'];
        String base64Image = base64Encode(file.readAsBytesSync());
        String fileName = file.path.split("/").last;
        attach = 'ok';
        //attach = await http.MultipartFile.fromPath("File", order[i][0][0]['Service']['File'].path.toString());
        for (int j=0; j<1; j++){
          serviceAttach.add({
            "FilePath": fileName,
            "File": base64Image,
            "AttNotes": "AttNotes",
            "AttId": "$id",
          });
        }
      }catch(e){
        attach = null;
      }
      amount += (order[i][0][0]['Price']) * int.parse(order[i][1]);
      serviceTmp.add({
        "ServiceId": order[i][0][0]['Id'],
        "Price": order[i][0][0]['Price'],
        "Quantity": int.parse(order[i][1]),
        "ServiceNotes": order[i][0][1]["Notes"],
        "OrderServiceAttatchs": attach == null?'' :  serviceAttach,
        // ignore: equal_keys_in_map
      });
    }

    FormData formdata = FormData.fromMap({
      "CustomerId": "$id",
      "Amount": amount,
      "InsertDate": insertDateTime,
      "Status": 1,
      "PayType": 1,
      "AddressId": value3,
      "OrderDate": orderDateTime,
      "Notes": "string",
      "OrderServices": serviceTmp
    });
    print(token);

    //create multipart request for POST or PATCH method
    //add text fields
    request.fields.addAll(Map.fromEntries(formdata.fields));
    request.headers.addAll({
      "Accept-Language": trrrr.LocalizationService.getCurrentLocale().languageCode,
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token,
    });
    print(request.files);
    print(request.fields);
    //create multipart using filepath, string or bytes
    //var pic = await http.MultipartFile.fromPath("file_field", file.path);
    //add multipart to request
    //request.files.add(pic);
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      //Get the response from the server
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      print(responseString);
      try{
        if (jsonDecode(responseString)['Errors'] == null || jsonDecode(responseString)['Errors'] == ''){
          print('success');
          return true;
        }else{
          flushBar(jsonDecode(responseString)['Errors']);
          return false;
        }
      }catch(e){
        return true;
      }
    } else {
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      print(responseString);
      flushBar(jsonDecode(responseString)['Errors']);
      return false;
      print(response.statusCode);
    }

  }

  /*uploadOrderWithAttachNew(id,insertDateTime,value3,orderDateTime,token) async {
    var amount = 0.0;
    List<Map<String, dynamic>> serviceTmp = [];
    for (int i = 0; i < order.length; i++) {
      var attach;
      List<Map<String, dynamic>> serviceAttach = [];
      try{
        var file = order[i][0][0]['Service']['File'];
        String base64Image = base64Encode(file.readAsBytesSync());
        String fileName = file.path.split("/").last;
        attach = 'ok';
        for (int j=0; j<1; j++){
          serviceAttach.add({
            "FilePath": fileName,
            "File": base64Image,
            "AttNotes": "AttNotes",
            "AttId": "$id",
          });
        }
      }catch(e){
        attach = null;
      }
      amount += (order[i][0][0]['Price']) * int.parse(order[i][1]);
      serviceTmp.add({
        "ServiceId": order[i][0][0]['Id'],
        "Price": order[i][0][0]['Price'],
        "Quantity": int.parse(order[i][1]),
        "ServiceNotes": order[i][0][1]["Notes"],
        "OrderServiceAttatchs": attach == null?'' :  serviceAttach,
      });
    }

    Map mapDate = {
      "CustomerId": "$id",
      "Amount": amount,
      "InsertDate": insertDateTime,
      "Status": 1,
      "PayType": 1,
      "AddressId": value3,
      "OrderDate": orderDateTime,
      "Notes": "string",
      "OrderServices": serviceTmp
    };
    print(jsonEncode(mapDate));
    print(token);
    var apiUrl = Uri.parse('https://mr-service.online/Main/Orders/Orders_CreateWithAttachs?');

    http.Response response = await http.post(apiUrl, body: jsonEncode(mapDate), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token,
    });
    print(response.statusCode);
    if (response.statusCode == 200) {
      //Get the response from the server
      print(response.body);
      try{
        if (jsonDecode(response.body)['Errors'] == null || jsonDecode(response.body)['Errors'] == ''){
          print('success');
          return true;
        }else{
          flushBar(jsonDecode(response.body)['Errors']);
          return false;
        }
      }catch(e){
        return true;
      }
    } else {
      return false;
    }
  }*/
  //{CustomerId: 90e73cdd-7e7e-4207-9901-08d9a4f69d2a, Amount: 300.0, InsertDate: 2021-12-08T01:29:45.045Z, Status: 1, PayType: 1, AddressId: 66b576f9-d44b-4565-b9e3-08d9a4f82388, OrderDate: 2021-12-08T13:29:00.000Z, Notes: string, OrderServices: [{ServiceId: 18, Price: 300.0, Quantity: 1, ServiceNotes: , OrderServiceAttatchs: }]}
  //{CustomerId: 90e73cdd-7e7e-4207-9901-08d9a4f69d2a, Amount: 300.0, InsertDate: 2021-12-08T01:31:02.002Z, Status: 1, PayType: 1, AddressId: 66b576f9-d44b-4565-b9e3-08d9a4f82388, OrderDate: 2021-12-08T13:29:00.000Z, Notes: string, OrderServices[0][ServiceId]: 18, OrderServices[0][Price]: 300.0, OrderServices[0][Quantity]: 1, OrderServices[0][ServiceNotes]: , OrderServices[0][OrderServiceAttatchs]: }
  uploadOrderWithoutAttach(id,insertDateTime,value3,orderDateTime,token) async {
    var apiUrl = Uri.parse('$apiDomain/Main/Orders/Orders_CreateWithAttachs?');
    //dont use http://localhost , because emulator don't get that address
    //insted use your local IP address or use live URL
    //hit "ipconfig" in windows or "ip a" in linux to get you local IP
    var amount = 0.0;
    List<Map<String, dynamic>> serviceTmp = [];

    for (int i = 0; i < order.length; i++) {
      amount += (order[i][0][0]['Price']) * int.parse(order[i][1]);
      serviceTmp.add({
        "ServiceId": order[i][0][0]['Id'],
        "Price": order[i][0][0]['Price'],
        "Quantity": int.parse(order[i][1]),
        "Notes": "string",
      });
    }

    Map mapDate = {
      "CustomerId": "$id",
      "Amount": amount,
      "InsertDate": insertDateTime,
      "Status": 1,
      "PayType": 1,
      "AddressId": value3,
      "OrderDate": orderDateTime,
      "Notes": "string",
      "OrderServices": serviceTmp
    };
    print(jsonEncode(jsonEncode(mapDate)));

    http.Response response = await http.post(apiUrl, body: jsonEncode(jsonEncode(mapDate)), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token,
    });
    print(response.body);
    /* Response response = await dio.post('order',
        data: formdata,
        //options: Options(method: 'POST', responseType: ResponseType.json) // or ResponseType.JSON
      onSendProgress: (int sent, int total) {
        String percentage = (sent/total*100).toStringAsFixed(2);
        setState(() {
          progress = "$sent" + " Bytes of " "$total Bytes - " +  percentage + " % uploaded";
          //update the progress
        });
      },)*/
    return response;
  }

  uploadOrderWithAttachment(id,insertDateTime,value3,orderDateTime,token) async {
    var request = http.MultipartRequest("POST", Uri.parse("$apiDomain/Main/Orders/Orders_CreateWithAttachs?"));
    var amount = 0.0;
    List<Map<String, dynamic>> serviceTmp = [];
    for (int i = 0; i < order.length; i++) {
      var attach = await http.MultipartFile.fromPath('file_field', order[i][0][0]['Service']['File'].path.toString(), filename:order[i][0][0]['Service']['File'].name);
      List<Map<String, dynamic>> serviceAttach = [];
      for (int j=0; j<1; j++){
        serviceAttach.add({
          "FilePath": attach.filename,
          "AttNotes": "AttNotes",
          "AttId": "new guid",
          "AttFile": {"File" : attach}
        });
      }
      amount += (order[i][0][0]['Price']) * int.parse(order[i][1]);
      serviceTmp.add({
        "ServiceId": order[i][0][0]['Id'],
        "Price": order[i][0][0]['Price'],
        "Quantity": int.parse(order[i][1]),
        "ServiceNotes": "string",
        "OrderServiceAttatchs": serviceAttach
        //"File": await http.MultipartFile.fromPath('file_field', order[i][0][0]['Service']['File'].path.toString(), filename:order[i][0][0]['Service']['File'].name),
      });
    }   //add text fields
    request.fields.addAll({
      "CustomerId": "$id",
      "Amount": amount.toString(),
      "InsertDate": insertDateTime,
      "Status": 1.toString(),
      "PayType": 1.toString(),
      "AddressId": value3,
      "OrderDate": orderDateTime,
      //"GroupId": 1,
      "Notes": "string",
      //"OrderServices": serviceTmp
    });
    request.fields.keys;
    //create multipart using filepath, string or bytes
    //var pic = await http.MultipartFile.fromPath("file_field", file.path);
    //add multipart to request
    //request.files.add(pic);
    var response = await request.send();
    print(request.fields);
    print(response.statusCode);

    //Get the response from the server
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print(responseString);

/*
    var apiUrl = Uri.parse('https://mr-service.online/Main/Orders/Orders_CreateWithAttachs?');
    Map mapDate = {
      "CustomerId": "$id",
      "Amount": amount,
      "InsertDate": insertDateTime,
      "Status": 1,
      "PayType": 1,
      "AddressId": value3,
      "OrderDate": orderDateTime,
      //"GroupId": 1,
      "Notes": "string",
      "OrderServices": serviceTmp
    };
    http.Response response = await http.post(apiUrl,
        body: jsonEncode(mapDate,
      toEncodable: (dynamic object) => (object is MultipartFile) ? object: object.toJson(),),
        headers: {
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token,
    });
    return response;*/
  }

  updateOrder(token, _order, status, payType, selectedDate, selectedTime)async{
    //update
    // ignore: unnecessary_null_comparison
    if(status == null) status = _order['Status'];
    // ignore: unnecessary_null_comparison
    if(payType == null) payType = _order['PayType'];
    // ignore: unnecessary_null_comparison
    String orderDateTime;
    if(selectedDate == null || selectedTime == null) orderDateTime = _order['OrderDate'];
    else{
      orderDateTime = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute).add(timeDiff).toString().replaceAll(" ", "T") + "Z";
    }
    var apiUrl = Uri.parse('$apiDomain/Main/Orders/Orders_Update?');
    var amount = 0.0;
    List<Map<String, dynamic>> serviceTmp = [];
    var k=_order['Servicess'].length;
    for (int i = 0; i < k; i++) {
      serviceTmp.add({
        "Id": _order["Servicess"][i]['Id'],
        "OrderId": _order["Servicess"][i]['OrderId'],
        "ServiceId": _order["Servicess"][i]['ServiceId'],
        "Price": _order["Servicess"][i]['Price'],
        "Quantity": _order["Servicess"][i]['Quantity'],
        "Notes": _order["Servicess"][i]['Notes'],
      });
    }
    Map mapDate = {
      "Id": _order['Id'],
      "CustomerId": _order['CustomerId'],
      "Amount": _order['Amount'],
      "InsertDate": _order['InsertDate'],
      "Status": status,
      "PayType": payType,
      "AddressId": _order["AddressId"],
      "OrderDate": orderDateTime,
      "GroupId": _order["GroupId"],
      "Notes": _order["Notes"],
      "OrderServices": serviceTmp
    };
    print(jsonEncode(mapDate));
    print(token);
    http.Response response = await http.post(apiUrl, body: jsonEncode(mapDate), headers: {
      "Accept-Language": trrrr.LocalizationService.getCurrentLocale().languageCode,
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token,
    });

    if (response.statusCode == 200) {
      print(response.body);
      print('success');
      try{
        if (jsonDecode(response.body)['Errors'] == null || jsonDecode(response.body)['Errors'] == ''){
          if(status == 8){
            _sendPushMessage(_order['User']['FBKey'], 'order' + _order['Serial'], 'your order is finished');
          }
          print('success');
          return true;
        }else{
          flushBar(jsonDecode(response.body)['Errors']);
          return false;
        }
      }catch(e){
        return true;
      }
    } else {
      print(response.body);
      print(response.statusCode);
      return false;
    }
  }

  destroyOrder(id,)async{
    var apiUrl = Uri.parse(
        "$apiDomain/Main/Orders/Orders_Destroy?");
    Map mapDate = {
      "guidParam": id,
    };
    http.Response response =
    await http.post(apiUrl, body: jsonEncode(mapDate), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token,
    });
    print((response));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['Errors'] == null ||
          jsonDecode(response.body)['Errors'] == '') {
        print('success');
        return true;
      } else {
        flushBar('Fail!\n' + jsonDecode(response.body)['Errors']);
        return false;
      }
      //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen(token: token, service: service, selectedIndex: 1,),),);
    } else {
      print(response.statusCode);
      print('fail');
      return false;
    }
  }

  logOut() async {
    final SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();
    sharedPreferences.setString('token', "");
    sharedPreferences.setString('password', "");
    sharedPreferences.setString('facebookEmail', "");
    sharedPreferences.setString('googleEmail', "");
    sharedPreferences.setBool('worker', false);

    //sharedPreferences.setString('email', "");
    Navigator.of(context!).pushReplacement(
      MaterialPageRoute(
        builder: (context) => new LoadingScreen(email: ""),
      ),
    );
    order.clear();
    editTransactionOrder(transactions![0], order);

    // Navigator.of(context).pushNamed('main_screen');
  }

  createWorkerTask(orderId, workerId, serviceId, supervisorNotes, startDate, endDate, workerNotes, token, workerFcmToken, taskName) async {
    var apiUrl = Uri.parse('$apiDomain/Main/WorkerTask/WorkerTask_Create?');
    //dont use http://localhost , because emulator don't get that address
    //insted use your local IP address or use live URL
    //hit "ipconfig" in windows or "ip a" in linux to get you local IP

    Map mapDate = {
      //"Id": orderId.toString(), //orderId
      "WorkerId": workerId.toString(),
      "OrderServicesId": serviceId.toString(), //serviceId
      "Status": 0,
      "Notes": supervisorNotes.toString(), //supervisorNotes
      "StartDate": startDate,
      "Name": taskName,
      //"EndDate": endDate,
      "ResDesc": workerNotes.toString()// workerNotes
    };

    print(jsonEncode(mapDate));

    http.Response response = await http.post(apiUrl, body: jsonEncode(mapDate), headers: {
      "Accept-Language": trrrr.LocalizationService.getCurrentLocale().languageCode,
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token, //b53d0e9a-fd32-4798-a600-59e1a9a4fc7f
    });
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      //Get the response from the server
      var responseString = response.body;
      print(responseString);
      try{
        if (jsonDecode(responseString)['Errors'] == null || jsonDecode(responseString)['Errors'] == ''){
          print('success');
          _sendPushMessage(workerFcmToken, taskName, AppLocalizations.of(context!)!.translate('You Have New Task!'));
          return true;
        }else{
          flushBar(jsonDecode(responseString)['Errors']);
          return false;
        }
      }catch(e){
        _sendPushMessage(workerFcmToken, taskName, AppLocalizations.of(context!)!.translate('You Have New Task!'));
        return true;
      }
    } else {
      flushBar(jsonDecode(response.body)['Errors']);
      return false;
      print(response.statusCode);
    }
    //return response;
  }

  updateWorkerTask(taskId, workerId, serviceId, supervisorNotes, startDate, endDate, workerNotes, token, taskName, file, fcmToken) async {
    var apiUrl = Uri.parse('$apiDomain/Main/WorkerTask/WorkerTask_Update?');
    List<Map<String, dynamic>> serviceTmp = [];
    var attach;
    List<Map<String, dynamic>> serviceAttach = [];
    String base64Image = '', filePath = '';
    try{
      base64Image = base64Encode(file.readAsBytesSync());
      filePath = file.path.split("/").last;
      attach = 'ok';
    }
    catch(e){
      attach = null;
    }

    Map mapDate = {
      "Id": taskId.toString(), //orderId
      "WorkerId": workerId.toString(),
      "OrderServicesId": serviceId.toString(), //serviceId
      "Status": 2,
      "Notes": supervisorNotes.toString(), //supervisorNotes
      "StartDate": startDate,
      "Name": taskName,
      "EndDate": endDate,
      "ResDesc": workerNotes.toString(),// workerNotes
      "WorkerTaskAttatchs": attach == null? '' : [
        {
          "WorkerTaskId": taskId.toString(),
          "FilePath": filePath,
          "FileDase64": base64Image,
          "Notes": "nnnnn"
        }
      ]
    };

    if(attach == null)
      mapDate = {
        "Id": taskId.toString(), //orderId
        "WorkerId": workerId.toString(),
        "OrderServicesId": serviceId.toString(), //serviceId
        "Status": 2,
        "Notes": supervisorNotes.toString(), //supervisorNotes
        "StartDate": startDate,
        "Name": taskName,
        "EndDate": endDate,
        "ResDesc": workerNotes.toString()// workerNotes
      };

    print(jsonEncode(mapDate));

    http.Response response = await http.post(apiUrl, body: jsonEncode(mapDate), headers: {
      "Accept-Language": trrrr.LocalizationService.getCurrentLocale().languageCode,
      "Accept": "application/json",
      "content-type": "application/json",
      "Authorization": token, //b53d0e9a-fd32-4798-a600-59e1a9a4fc7f
    });
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      //Get the response from the server
      var responseString = response.body;
      //print(responseString);
      try{
        if (jsonDecode(responseString)['Errors'] == null || jsonDecode(responseString)['Errors'] == ''){
          print('success');
          _sendPushMessage(fcmToken, taskName, AppLocalizations.of(context!)!.translate('good luck task is finished'));
          return true;
        }else{
          flushBar(jsonDecode(responseString)['Errors']);
          return false;
        }
      }catch(e){
        _sendPushMessage(fcmToken, taskName, AppLocalizations.of(context!)!.translate('good luck task is finished'));
        return true;
      }
    } else {
      flushBar(jsonDecode(response.body)['Errors']);
      return false;
      print(response.statusCode);
    }
    //return response;
  }

  getGroupUsers(var id) async {
    try{
      var url = Uri.parse("$apiDomain/Main/GroupUsers/GroupUsers_Read?filter=GroupId~eq~$id");
      //var url = Uri.parse("https://mr-service.online/Main/GroupUsers/GroupUsers_Read?");
      http.Response response = await http.get(url,
        headers: {
          "Authorization": token,
        },
      );
      //print(json.decode(response.body));
      if (response.statusCode == 200) {
        //print(json.decode(response.body));
        var item = json.decode(response.body)['Data'];
        print(item);
        /*for(int i = 0; i<item.length; i++){
          if(item[i]['UserId'] == id){
            groupId = item[i]['GroupId'];
            i=item.length;
          }
        }
        await item.removeWhere((itm) => itm['GroupId'] != groupId);*/
        groupUsers = item;
      } else {
        print(token);
        print(response.statusCode);
      }
    }catch(e){
      // Workers = transactions![0].Address;
    }
  }

  Future<void> _sendPushMessage(_token, _taskName, _taskBody) async {
    String constructFCMPayload(String? token, _title, _body) {
      return jsonEncode({
        'to': token,
        'data': {
          //'to': token,
          //"registration_ids" : token,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': 'COMMENT',
          'via': 'FlutterFire Cloud Messaging!!!',
          //'count': _messageCount.toString(),
        },
        'notification': {
          'title': _title,
          'body': _body,
        },
      });
    }
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      var _serverKey = 'AAAAOPv0WzU:APA91bHwvAAe8VSqm2XDxAIQaKw1GSepD65_sIaX0FgUuI34ekkGiYvA-Mt3Bh3lc5jM5KQyi3DD2oWmRhJYGDtCPFYSM1mCkvsaFnPjQ2gylYDvU3lGXTrUG4i4ssYBRgB_vCNInn2P';
      //var _serverKey = 'AAAAOPv0WzU:APA91bH_4SPyvOt7K3n2rGhl1v6DgCAogSL5hO6hiSkqQNV6Yqh77kNlGOc-AUwBgp4Avig-6xQp5vXiyJxPBEyg1SEqKSyXX5HbQJ8qG2cNNn0XHwGxVtOx31fK0OBK6xR_fjoF9ntn';
      //var _serverKey = 'AIzaSyD-b9apuimKiEov1Ah0Aom_mg6wwEv5KWs';
      var response = await http.post(
        //Uri.parse('https://api.rnfirebase.io/messaging/send'),
        //Uri.parse('https://fcm.googleapis.com/v1/projects/mr-services-15410/messages:send'),
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$_serverKey',
          'project_id':'244745263925',
        },
        body: constructFCMPayload(_token, _taskBody, _taskName),
      );
      print('FCM request for device sent!');
      print(jsonEncode(response.body));
      print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }

  showImage(src){
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [/*SystemUiOverlay.top,*/ SystemUiOverlay.bottom]);
    showImageViewer(
      context!, Image.network(src).image
    );
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, /*SystemUiOverlay.top*/]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [/*SystemUiOverlay.bottom*/SystemUiOverlay.top]);
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [/*SystemUiOverlay.top,*/ SystemUiOverlay.bottom]);

  }

}
