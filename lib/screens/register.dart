import 'dart:async';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:closer/constant/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:closer/api/api_service.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/localizations.dart';
import 'package:closer/screens/signin.dart';
import 'dart:convert';
import 'package:closer/screens/valid_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:get/get.dart';
import 'package:closer/screens/signin.dart';

import 'package:closer/MyWidget.dart';
import 'package:closer/const.dart';
import 'package:closer/localization_service.dart';
import 'main_screen.dart';


class Register extends StatefulWidget {
  bool autoVer = false;
  Map? mapDate;
  Register(this.autoVer, {Key? key, this.mapDate}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState(autoVer, mapDate: mapDate);
}

class _RegisterState extends State<Register> {
  var _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  TextEditingController cardNumberController = new TextEditingController();
  var requiredValidator = RequiredValidator(errorText: 'Required'.tr);
  bool _secureText = true;
  bool chLogIn = false;
  String value="";
  int doubleBackToExitPressed = 1;
  bool _autoVer = false;
  Map? mapDate;
  _RegisterState(this._autoVer, {this.mapDate});

  String token = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
    if(_autoVer){
      firstNameController.text = mapDate!['Name'];
      lastNameController.text = mapDate!['LastName'];
      emailController.text = mapDate!['Email'];
      phoneController.text = mapDate!['Mobile'];
    }
  }

  @override
  Widget build(BuildContext context) {
    requiredValidator = RequiredValidator(errorText: AppLocalizations.of(context)!.translate('Required'));
    return Scaffold(
        //resizeToAvoidBottomInset :false,
        backgroundColor: AppColors.blue,
        body: DoubleBackToCloseApp(
          child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height /25,
                    horizontal: MediaQuery.of(context).size.width / 15
                ),
                  child: Column(
                    children:[
                   Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.keyboard_backspace, color: AppColors.yellow, size: MediaQuery.of(context).size.width/10,)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width/9,
                        ),
                        Text(
                          AppLocalizations.of(context)!.translate('Sign Up'),
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: MediaQuery.of(context).size.width/10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans'),
                        ),
                      ],
                    ),
                   ),
                   Expanded(
                        flex:15,
                        child: ListView(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(MediaQuery.of(context).size.height/75),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: MyWidget(context).textFiled(firstNameController, '', AppLocalizations.of(context)!.translate('First Name'))),

                                       SizedBox(
                                         width: MediaQuery.of(context).size.height/75,
                                       ),
                                      Expanded(
                                        child: MyWidget(context).textFiled(lastNameController, '', AppLocalizations.of(context)!.translate('Last Name')),),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(MediaQuery.of(context).size.height/75),
                                  child: MyWidget(context).textFiled(emailController, '', AppLocalizations.of(context)!.translate('Email Address'), email: true),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(MediaQuery.of(context).size.height/75),
                                  child: IntlPhoneField(
                                    //keyboardType: TextInputType.number,
                                    //validator: requiredValidator,
                                    invalidNumberMessage: '',
                                    //autovalidateMode: AutovalidateMode.onUserInteraction,
                                    //controller: phoneController,
                                    style: TextStyle(color: AppColors.white, fontSize: min(MediaQuery.of(context).size.width/25,MediaQuery.of(context).size.height/55)),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.translate('Phone Number'),
                                      labelStyle: TextStyle(
                                        fontSize: min(MediaQuery.of(context).size.width/25, MediaQuery.of(context).size.height/55),
                                        color: AppColors.white,
                                      ),
                                      errorStyle: TextStyle(
                                          fontSize:min(MediaQuery.of(context).size.width/25, MediaQuery.of(context).size.height/55)
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height/12),
                                          borderSide: BorderSide(color: Colors.grey, width: 2)),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height/12),
                                        borderSide: BorderSide(color: Colors.grey, width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height/12),
                                        borderSide: BorderSide(color: Colors.red, width: 2),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height/12),
                                        borderSide: BorderSide(color: AppColors.red, width: 2),
                                      ),
                                    ),
                                    initialCountryCode: WidgetsBinding.instance.window.locale.countryCode,
                                    onChanged: (phone) {
                                      phoneController.text =  phone.completeNumber;
                                      print(phone.completeNumber);
                                    },
                                  ),
                                 /* buildContainer(phoneController, AppLocalizations.of(context)!.translate('Phone Number'),
                                      TextInputType.number, requiredValidator,false),*/
                                ),
                                Padding(
                                  padding: EdgeInsets.all(MediaQuery.of(context).size.height/75),
                                  child: MyWidget(context).textFiled(passwordController, '', AppLocalizations.of(context)!.translate('Password'), password: true, clickIcon: ()=>{
                                  setState(() {
                                  _secureText = !_secureText;
                                  })
                                  }, obscureText: _secureText),
                                ),
                                // SizedBox(
                                //   height: 20.0,
                                // ),
                                Padding(
                                  padding: EdgeInsets.all(MediaQuery.of(context).size.height/75),
                                  child: MyWidget(context).textFiled(confirmPasswordController, '', AppLocalizations.of(context)!.translate('Confirm Password'), password: true, clickIcon: ()=>{
                                    setState(() {
                                      _secureText = !_secureText;
                                    })
                                  }, obscureText: _secureText, passwordText: passwordController.text),
                                ),
                                // SizedBox(
                                //   height: 20.0,
                                // ),
                                // Padding(
                                //   padding: EdgeInsets.all(MediaQuery.of(context).size.height/75),
                                //   child: buildContainerCardNumber(
                                //       cardNumberController,
                                //       'Your Card Number',
                                //       TextInputType.number,false),
                                // ),
                                // SizedBox(
                                //   height: 20.0,
                                // ),
                              ],
                            ),
                      ),

                   Expanded(
                            flex: 2,
                            child: MyWidget(context).raisedButton(AppLocalizations.of(context)!.translate('Sign Up'), ()=> {
                              if(_formKey.currentState!.validate()) {
                                //print('tttt: api');
                                registration(),
                              }
                              else
                                print('fail'),
                            }, MediaQuery.of(context).size.width/1.5, chLogIn, colorText: Color(0xff343434), buttonText: AppColors.yellow),
                          ),
                    ]
                  ),
                ),
              ),
            snackBar:  SnackBar(
                content: Text(AppLocalizations.of(context)!.translate('Tap back again to leave')),
        )),
    );
  }


  Container buildContainerConfirmPassword(
      TextEditingController controller, String labelText, TextInputType type) {
    return Container(
      // alignment: Alignment.centerLeft,
      height: MediaQuery.of(context).size.height/12,

      child: TextFormField(
        obscureText: true,
        keyboardType: type,
        controller: controller,
        validator: (val){
          if (val != passwordController.value.text){
            return AppLocalizations.of(context)!.translate('Password Do not Match');
          }
        },

        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: TextStyle(color: AppColors.white, fontSize: MediaQuery.of(context).size.width/25),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.width/20,
            color:AppColors.white,
          ),
          errorStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.width/24,
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height/12),
              borderSide: BorderSide(color: Colors.grey, width: 2)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height/12),
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height/12),
            borderSide: BorderSide(color: AppColors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height/12),
            borderSide: BorderSide(color: AppColors.red, width: 2),
          ),
        ),
      ),
    );
  }


  Future registration() async{
    setState(()=>chLogIn =true);
    var t = await APIService.register(firstName: firstNameController.text, lastName: lastNameController.text, mobile: phoneController.text, email: emailController.text, password: passwordController.text);
    setState(()=>chLogIn =false);
    if(t != null){
      value = t.data.first.id;
      _save();
      if(!_autoVer || emailController.text != this.mapDate!['Email']) {
        // ignore: use_build_context_synchronously
        MyApplication.navigateTo(context, Verification(value: value ,email: emailController.text, password: passwordController.text, ));
      } else {
        await ver(t.data.first.id, t.data.first.verificationCode);
        await signIn(emailController.text, passwordController.text);
      }
    }
  }

  void _afterLayout(Duration timeStamp) {
    if(!_autoVer)_read();
  }

  _save() async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('email', emailController.text);
    sharedPreferences.setString('password', passwordController.text);
    sharedPreferences.setString('name', firstNameController.text);
    sharedPreferences.setString('lastName', lastNameController.text);
    sharedPreferences.setString('phone', phoneController.text);
  }

  _read() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    emailController.text = sharedPreferences.getString('email')??'';
    passwordController.text = sharedPreferences.getString('password')??'';
    firstNameController.text = sharedPreferences.getString('name')??'';
    lastNameController.text = sharedPreferences.getString('lastName')??'';
    phoneController.text = sharedPreferences.getString('phone')??'';
  }

  ver(value, code)async{
    var apiUrl = Uri.parse('$apiDomain/Main/SignUp/SignUp_Verify');
    Map mapDate = {
      "guidParam": value,
      "txtParam": code,
    };
    http.Response response = await http.post(apiUrl, body: jsonEncode(mapDate), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
    });
    print(response.statusCode);
    print(response.body);
/*
    if (response.statusCode == 200) {
      print(response.body);
/*      try {
        if (jsonDecode(response.body)["Data"][0]['txtParam'].toString() ==
            code) {

          http.Response response = await http.post(
              Uri.parse('https://mr-service.online/api/Auth/login'),
              body: jsonEncode({"UserName": email, "Password": password}),
              headers: {
                "Accept": "application/json",
                "content-type": "application/json",
              });
          if (response.statusCode == 200) {
            print(response.body);
            setState(() {
              if (jsonDecode(response.body)['error_des'] == "") {
               var tokenn =
                    jsonDecode(response.body)["content"]["Token"].toString();
                getServiceData(tokenn);

              }
            });
          }




        }
      } catch (e) {
        if (jsonDecode(response.body)['success'].toString() == "false") {
          setState(() => chVer = false);

          Flushbar(
            icon: Icon(
              Icons.error_outline,
              size: 32,
              color: Colors.white,
            ),
            duration: Duration(seconds: 3),
            shouldIconPulse: false,
            flushbarPosition: FlushbarPosition.TOP,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            backgroundColor: Colors.grey.withOpacity(0.5),
            barBlur: 20,
            message: 'Wrong Code'.tr,
          ).show(context);
        }
      }*/
      // Navigator.of(context).pushNamed('sign_in');
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder:(context)=>SignIn()));
    } else {
      //Navigator.of(context).pushNamed('main_screen');
      print(response.statusCode);
      print('A network error occurred');
    }
*/
  }

  signIn(String email, String password) async {
    setState(() => chLogIn = true);
    http.Response? response;
    response = await apiService.login(email, password);
    // ignore: unnecessary_null_comparison
    if(response == null) {
      setState(() => chLogIn = false);
    }
    if (response!.statusCode == 200) {
      print("we're good");
      userData = jsonDecode(response.body);
      editTransactionUserData(transactions![0], userData);
      setState(() {
        if (jsonDecode(response!.body)['error_des'] == "") {
          isLogIn = true;
          token = jsonDecode(response.body)["content"]["Token"].toString();
          updateUserInfo(userData["content"]["Id"]);
        } else {
          isLogIn = false;
          setState(() => chLogIn = false);
          Flushbar(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 30),
            icon: Icon(
              Icons.error_outline,
              size: MediaQuery.of(context).size.height / 30,
              color: AppColors.white,
            ),
            duration: Duration(seconds: 3),
            shouldIconPulse: false,
            flushbarPosition: FlushbarPosition.TOP,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            backgroundColor: Colors.grey.withOpacity(0.5),
            barBlur: 20,
            message: jsonDecode(response.body)['error_des'],
            messageSize: MediaQuery.of(context).size.height / 37,
          ).show(context);
        }
      });
    } else {
      print('A network error occurred');
    }

    if (isLogIn) {
      getServiceData();
    }
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('token', token);
  }

  void updateUserInfo(var id) async {
    print("flag1");
    print(id);
    var url = Uri.parse("$apiDomain/Main/Users/SignUp_Read?filter=Id~eq~'$id'");

    http.Response response = await http.get(url, headers: {"Authorization": token,});
    if (response.statusCode == 200) {
      print("flag2");
      userInfo = jsonDecode(response.body)['result']['Data'][0];
      editTransactionUserUserInfo(transactions![0], userInfo);
      print(jsonDecode(response.body));
      print("flag3");
    } else {
      print("flag4");
      print(response.statusCode);
    }
    print("flag5");
    //await Future.delayed(Duration(seconds: 1));
  }
  List service = [];

  void getServiceData() async {
    //var url = Uri.parse('https://mr-service.online/Main/Services/Services_Read?filter=IsMain~eq~true');
    var url = Uri.parse('$apiDomain/Main/Services/Services_Read?filter=ServiceParentId~eq~null');
    //var url = Uri.parse('https://mr-service.online/Main/Services/Services_Read?');
    http.Response response = await http.get(url, headers: {
      "Authorization": token,
    });
    print("we're here now");
    if (response.statusCode == 200) {
      var item = json.decode(response.body)["result"]['Data'];
      setState(() {
        editTransactionService(transactions![0], service);
        /*for(int i =0; i<item.length; i++){
          if(item[i]['ServiceParentId']==null){
            item.removeAt(i);
            i--;
          }
        }*/
        service = item;
      });
      setState(() => chLogIn = false);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MainScreen(
            token: token,
            service: service,selectedIndex: 0,
            initialOrderTab: 0,
          )));
    } else {
      setState(() {
        service = [];
      });
    }
  }

}
