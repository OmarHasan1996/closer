import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:closer/api/api_service.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/screens/newOrder.dart';
import 'package:closer/screens/signin.dart';

import 'const.dart';
import 'localization_service.dart';
import 'localizations.dart';

class MyWidget{
  BuildContext context;

  MyWidget(this.context) {
    _padButtonV = min(MediaQuery.of(context).size.height / 80, MediaQuery.of(context).size.width / 25);

  }



  textBlack20(text, {color, bold, textAlign, scale}){
    color??= AppColors.black;
    bold??= true;
    scale??= 1.0;
    textAlign??= TextAlign.start;
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
          fontSize: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45) * scale ,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color),
    );
  }

  textTitle15(text, {color, bold, textAlign, scale}){
    color??= AppColors.black;
    bold??= false;
    scale??= 1.0;
    textAlign??= TextAlign.start;
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
          fontSize: min(MediaQuery.of(context).size.width / 15, MediaQuery.of(context).size.height / 34)*scale ,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color),
    );
  }

  textTap25(text, {color, bold, textAlign, scale}){
    color??= AppColors.textColorGray;
    bold??= false;
    textAlign??= TextAlign.center;
    scale??=1.0;
    return Text(
      text,
      maxLines: 2,
      textAlign: textAlign,
      style: TextStyle(
          fontSize: min(MediaQuery.of(context).size.width / 25, MediaQuery.of(context).size.height / 55) * scale ,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color),
    );
  }

  textHead10(text,{scale, color}){
    scale??=1.0;
    color??=AppColors.white;

    return Text(
      text,
      style: TextStyle(
          color: color,
          fontSize: min(MediaQuery.of(context).size.width / 10,MediaQuery.of(context).size.height / 23),
          fontWeight: FontWeight.bold,
          fontFamily: 'OpenSans'),
    );
  }

  textGrayk28(text,{scale, color}){
    scale??=1;
    color??= AppColors.gray;
    return Text(
        text,
        maxLines: 1,
        style: TextStyle(
        color: color,
        fontSize: min(MediaQuery.of(context).size.width / 28, MediaQuery.of(context).size.height / 64) * scale,
          fontWeight: FontWeight.bold,
        ),
    );
  }

  textButton30(text,{scale}){
    scale??=1;
    return Text(
        text,
        maxLines: 1,
        style: TextStyle(
        color: AppColors.buttonTextColor,
        fontSize: min(MediaQuery.of(context).size.width / 28, MediaQuery.of(context).size.height / 65) * scale,
          fontWeight: FontWeight.bold,
        ),
    );
  }

  logoDrawer(barHight, radius,){
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 37,
          horizontal: MediaQuery.of(context).size.width / 20),
      width: double.infinity,
      height: barHight,
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(radius),
            bottomRight: Radius.circular(radius)),
      ),
      child: Image.asset(
        'assets/images/Logo1.png',
        width: MediaQuery.of(context).size.width / 6,
        height: barHight / 2,
      ),
    );
  }

  dropDownLang(List<String> list, setState()){
    String? lng;
    return new DropdownButton<String>(
      dropdownColor: Colors.grey,
      items: list.map(
            (String value) {
          return new DropdownMenuItem<String>(
            value: value,
            child: new Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: min(MediaQuery.of(context).size.height/55, MediaQuery.of(context).size.width/25)),
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
        lng = newVal!;
        LocalizationService().changeLocale(newVal, context);
        setState();
      },
    );
  }

  drawer(barHight, radius, setState()) {
    return Container(
      width: MediaQuery.of(context).size.width/4*3,
      child: Drawer(
          child: Container(
              height: double.infinity,
              //width: MediaQuery.of(context).size.width/4*3,
              color: Color(0xffF4F4F9),
              child: Column(
                children: [
                  logoDrawer(barHight, radius),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height / 37 * 0,
                        horizontal: MediaQuery.of(context).size.width / 12),
                    child: _topYellowDriver(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height / 37,
                        horizontal: MediaQuery.of(context).size.width / 20),
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            textBlack20(AppLocalizations.of(context)!.translate('lang'),),
                            Text("   "),
                            dropDownLang(LocalizationService.langs, ()=>setState()),
                          ],
                        ),
                        // ignore: deprecated_member_use
                        button(
                            AppLocalizations.of(context)!.translate('Log Out'),
                                ()=>APIService(context: context).logOut,
                            MediaQuery.of(context).size.width/1.7),
                        button(
                            AppLocalizations.of(context)!.translate('Contact Us'),
                                ()=>_goAbout,MediaQuery.of(context).size.width/1.7),
                      ],
                    ),
                  ),
                  Expanded(
                    child: !worker?
                    ListView.builder(
                      itemCount: order.length == 0 ? 0 : order.length,
                      itemBuilder: (context, index) {
                        //totalPrice =0;s
                        return orderlist(order[index],0.80,()=>setState());
                      },
                      addAutomaticKeepAlives: false,
                    ):
                    isBoss?
                    ListView.builder(
                      itemCount: task.length == 0 ? 0 : task.length,
                      itemBuilder: (context, index) {
                        //totalPrice =0;s
                        return tasklist(task[index],0.83,()=>setState());
                      },
                      addAutomaticKeepAlives: false,
                    ):SizedBox(),
                  ),
                ],
              ))
      ),
    );
  }

  Padding orderlist(ord,scale,setState()) {
    DateTime  pickDate = DateTime.now();
    TimeOfDay time = TimeOfDay.now();
    var Id = ord[0][0]['Id'];
    var name = ord[0][0]['Name'];
    var imagepath = ord[0][0]['ImagePath'];
    var price = ord[0][0]['Price'].toString();
    var amount = ord[1].toString();
    /*var date = Text(
      '${pickDate.day}-${pickDate.month}-${pickDate.year} / ${time.hour}:${time.minute}',
      maxLines: 1,
      style: TextStyle(
        color: MyColors.black,
        fontSize: MediaQuery.of(context!).size.width / 30 * scale,
        fontWeight: FontWeight.bold,
      ),
    );*/
    var date = textGrayk28(AppLocalizations.of(context)!.translate('Amount').replaceAll(' ', '') + ' = ' + amount,scale: scale);
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
                  width: min(MediaQuery.of(context).size.width * 0.20, MediaQuery.of(context).size.height * 0.92) * scale,
                  height: min(MediaQuery.of(context).size.height / 9, MediaQuery.of(context).size.width / 4) * scale,
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
                width: (MediaQuery.of(context).size.width * 0.85 - min(MediaQuery.of(context).size.width * 0.20, MediaQuery.of(context).size.height * 0.92)) * scale,
                height: min(MediaQuery.of(context).size.height / 9, MediaQuery.of(context).size.width / 4) * scale,
                //height: MediaQuery.of(context).size.height / 9.5 * scale,
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
                              fontSize: min(MediaQuery.of(context).size.width / 24, MediaQuery.of(context).size.height / 55) * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          date,
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        price + ' ' + AppLocalizations.of(context)!.translate('TRY'),
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: min(MediaQuery.of(context).size.width / 24, MediaQuery.of(context).size.height / 55) * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          deleteOrder(order, Id);
                          editTransactionOrder(transactions![0], order);
                          setState();
                        },
                        child: Icon(
                          Icons.close_outlined,
                          size: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45) * scale,
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

  Padding tasklist(_task,scale,setState()) {
    var Id = _task[0]['Service']['Id'];
    var name = _task[0]['TaskName'];
    var imagepath = 'https://controlpanel.mr-service.online' + _task[0]['Service']['Service']['ImagePath'];
    var price = _task[0]['Description'].toString();
    var _workersName = '';
    for(int i = 0; i<_task[0]['Workers'].length; i++){
      if(_workersName != '')
        _workersName = _workersName + ' , ' + _task[0]['Workers'][i][0]['Name'];
      else
        _workersName = _workersName + ' ' + _task[0]['Workers'][i][0]['Name'];
    }
    var workersName = textButton30(
      _workersName,
    );
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 80,
          horizontal: MediaQuery.of(context).size.width / 50),
      child: Column(
        children: [
          Row(
            children: [
              //image
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
                              fontSize: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45) * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          workersName,
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () async{
                          bool upload = false;
                          for(int i=0; i<_task[0]['Workers'].length; i++){
                            upload = await APIService(context: context).createWorkerTask(_task[0]['OrderId'], _task[0]['Workers'][i][0]['Id'], _task[0]['Service']['Id'], _task[0]['Description'], _task[0]['StartDate'],' endDate', 'workerNotes', token, _task[0]['Workers'][i][0]['fcmToken'] ,name);
                          }
                          if(upload) {
                            deleteTask(task, Id, _task[0]['Workers'], name);
                            flushBar(name +  AppLocalizations.of(context)!.translate('has been added to') + _workersName);
                            setState();
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.translate('Send'),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: min(MediaQuery.of(context).size.width / 24, MediaQuery.of(context).size.height / 55) * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          deleteTask(task, Id, _task[0]['Workers'], name);
                          //editTransactionOrder(transactions![0], order);
                          setState();
                        },
                        child: Icon(
                          Icons.close_outlined,
                          size: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45) * scale,
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

  appBarTittle(barHight,_key, {bool? newOrder}){
    barHight = barHight * 0.95;
    newOrder ??= false;
    bool empty = order.isEmpty;
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.height / 80 * 3),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/Logo1.png',
            width: MediaQuery.of(context).size.width / 6,
            height: barHight / 2,
          ),
          Align(
            //alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width/5,),
                  !worker?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      !empty? Text(order.length.toString(),style: TextStyle(color: AppColors.yellow,fontSize: min(MediaQuery.of(context).size.width/20,MediaQuery.of(context).size.height/45)),):SizedBox(height: MediaQuery.of(context).size.width/30,),
                      IconButton(onPressed: () => _iconPress(empty, _key, newOrder: newOrder), icon: Icon(Icons.shopping_cart_outlined,size: min(MediaQuery.of(context).size.width/12, MediaQuery.of(context).size.height/26),))
                    ],
                  ):
                  isBoss?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    /*children: [
                      !task.isEmpty? Text(task.length.toString(),style: TextStyle(color: MyColors.yellow,fontSize: MediaQuery.of(context!).size.width/20),):SizedBox(height: MediaQuery.of(context!).size.width/30,),
                      IconButton(onPressed: () => _iconPress(task.isEmpty, _key), icon: Icon(Icons.work,size: MediaQuery.of(context!).size.width/12,))
                    ],*/
                  ):
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    /*children: [
                      !task.isEmpty? Text(task.length.toString(),style: TextStyle(color: MyColors.yellow,fontSize: MediaQuery.of(context!).size.width/20),):SizedBox(height: MediaQuery.of(context!).size.width/30,),
                      IconButton(onPressed: () => _iconPress(task.isEmpty, _key), icon: Icon(Icons.work,size: MediaQuery.of(context!).size.width/12,))
                    ],*/
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width/60,),
                ],
              )
          ),
        ],
      ),
    );
  }

  _iconPress(empty, _key, {bool? newOrder}){
    newOrder ??= false;
    if(newOrder) return;
    if(empty){
      flushBar(AppLocalizations.of(context)!.translate("There isn't any new order"));
    }else{
      Navigator.push(context, MaterialPageRoute(builder: (context) => NewOrder(token, mainService)));
      //_key.currentState!.openEndDrawer();
    }
  }

  var _padButtonV = 0.0;

  button(text, click(),width) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _padButtonV,
      ),
      child: raisedButton(text, ()=> click(), width, false),
    ) ;
  }

  void deleteOrder(ord, id) {
    ord.removeWhere((item) => item[0][0]['Id'] == id);
    //id++;
  }

  void deleteTask(tas, id, workers, taskName) {
    tas.removeWhere((item) => item[0]['Service']['Id'] == id && item[0]['TaskName'] == taskName && item[0]['Workers'] == workers);
    //id++;
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
          color: AppColors.yellow,
          borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(MediaQuery.of(context).size.height / 80)),
        ),
      ),
    );
  }

  raisedButton(text , press, width, chLogIn, {height, colorText, buttonText, padV, textH, roundBorder}){
    colorText??=AppColors.buttonTextColor;
    buttonText??=AppColors.yellow;
    padV??= min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 46);
    textH??= min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 46);
    roundBorder??= MediaQuery.of(context).size.height / 12;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: width*1,
          // ignore: deprecated_member_use
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: MediaQuery.of(context!).size.width/10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              //color: MyColors.yellow,
              primary: buttonText,
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/20, vertical: padV),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      roundBorder)),
            ),
            //elevation: 5.0,
            child: chLogIn == true
                ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.blue),
              backgroundColor: Colors.grey,
            )
                : Text(text,
              style: TextStyle(
                  fontSize: textH,
                  color: colorText,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () => press(),
          ),
        )
      ],
    )
    ;
  }

  transScreen(){
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.white12,
      child: SizedBox(),
    );
  }

  flushBar(text){
    Flushbar(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 30),
      icon: Icon(
        Icons.error_outline,
        size: min(MediaQuery.of(context).size.width / 10, MediaQuery.of(context).size.height / 30),
        color: AppColors.white,
      ),
      duration: Duration(seconds: 3),
      shouldIconPulse: false,
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      backgroundColor: Colors.grey.withOpacity(0.5),
      barBlur: 20,
      message: text,
      messageSize: MediaQuery.of(context).size.height / 40,
    ).show(context);
  }

  textFiled(textController, hintText, labelText,{email, password, clickIcon()?, obscureText, passwordText}){
     email??=false;
     password??= false;
     obscureText??= false;
     passwordText??= '';
    var _borderRad= min(MediaQuery.of(context).size.height / 12, MediaQuery.of(context).size.width / 5.2);
    return Container(
      alignment: Alignment.centerLeft,
      height: MediaQuery.of(context).size.height / 10,
      child: TextFormField(
        // onSaved: (input)=>requestModel.email = input!,
        controller: textController,
        validator: (val) {
          if (val!.isEmpty) {
            return AppLocalizations.of(context)!.translate('Required');
          }
          if (email & !RegExp(
              "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(val)) {
            return AppLocalizations.of(context)!.translate('enter a valid email address');
          }

          if (passwordText!= '' && val != passwordText){
            return AppLocalizations.of(context)!.translate('Password Do not Match');
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: obscureText,
        style: TextStyle(
            color: Colors.white,
            fontSize: min(MediaQuery.of(context).size.width / 20,MediaQuery.of(context).size.height / 45)),
        decoration: password?
        InputDecoration(
          hintText: hintText,
          labelText: labelText,
          errorStyle: TextStyle(
              fontSize: min(MediaQuery.of(context).size.width / 25,MediaQuery.of(context).size.height / 55)),
          labelStyle: TextStyle(
            fontSize: min(MediaQuery.of(context).size.width / 25,MediaQuery.of(context).size.height / 55),
            color: Colors.white,
          ),
          hintStyle: TextStyle(
            fontSize: min(MediaQuery.of(context).size.width / 25,MediaQuery.of(context).size.height / 55),
            color: Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  _borderRad),
              borderSide:
              BorderSide(color: Colors.grey, width: 2)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                _borderRad),
            borderSide:
            BorderSide(color: Colors.grey, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                _borderRad),
            borderSide:
            BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                _borderRad),
            borderSide:
            BorderSide(color: Colors.red, width: 2),
          ),
          suffixIcon: password ? IconButton(
            padding: EdgeInsets.symmetric(
                horizontal:
                MediaQuery.of(context).size.width / 20),
            icon: Icon(
              Icons.remove_red_eye,
              color: Colors.white,
              size: min(MediaQuery.of(context).size.width / 12,MediaQuery.of(context).size.height / 28),
            ),
            onPressed: () => clickIcon!() ,
          ):SizedBox(width: 0.0,),
        ):
        InputDecoration(
          hintText: hintText,
          labelText: labelText,
          errorStyle: TextStyle(
              fontSize: min(MediaQuery.of(context).size.width / 25,MediaQuery.of(context).size.height / 55)),
          labelStyle: TextStyle(
            fontSize: min(MediaQuery.of(context).size.width / 25,MediaQuery.of(context).size.height / 55),
            color: Colors.white,
          ),
          hintStyle: TextStyle(
            fontSize: min(MediaQuery.of(context).size.width / 25,MediaQuery.of(context).size.height / 55),
            color: Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  _borderRad),
              borderSide:
              BorderSide(color: Colors.grey, width: 2)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                _borderRad),
            borderSide:
            BorderSide(color: Colors.grey, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                _borderRad),
            borderSide:
            BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                _borderRad),
            borderSide:
            BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  textFiledAddress(textController, hintText){
    return Padding(
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
        child: TextFormField(
          textAlign: TextAlign.start,
          obscureText: false,
          keyboardType: TextInputType.text,
          controller: textController,
          autovalidateMode:
          AutovalidateMode.onUserInteraction,
          style: TextStyle(
              color: Colors.black,
              fontSize: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45)
          ),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.height / 5),
              borderSide: BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.height / 5),
              borderSide: BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45),
            ),
          ),
        ),
      ),
    );

  }

  rowIconProfile(icon, text){
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.1,
            height: MediaQuery.of(context).size.height / 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius:
              BorderRadius.all(Radius.circular(10)),
            ),
            child: Icon(
              icon,
              color: Colors.grey[600],
              size: min(MediaQuery.of(context).size.width / 15, MediaQuery.of(context).size.height / 35),
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
                text,
                style: TextStyle(
                  fontSize: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45),
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            child: Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.grey[600],
              size: min(MediaQuery.of(context).size.width / 20, MediaQuery.of(context).size.height / 45),
            ),
          ),
        ),
      ],
    );
  }

}