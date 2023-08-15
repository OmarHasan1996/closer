import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:closer/MyWidget.dart';
import 'package:closer/api/api_service.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/localizations.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'dart:convert';
import '../const.dart';
import 'main_screen.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:get/get.dart';
import 'package:closer/screens/signin.dart';

import 'package:form_field_validator/form_field_validator.dart';
import 'package:closer/localization_service.dart' as trrrr;


bool chVer = false;
String token = '';
List service = [];

// ignore: must_be_immutable
class Verification extends StatefulWidget {
  String value;
  String email;
  String password;

  Verification(
      {required this.value, required this.email, required this.password});
  @override
  _VerificationState createState() =>
      _VerificationState(this.value, this.email, this.password);
}

class _VerificationState extends State<Verification> {
  void getServiceData(tokenn) async {
    var url =
    Uri.parse('https://mr-service.online/Main/Services/Services_Read?filter=IsMain~eq~true');

    http.Response response = await http.get(url, headers: {
      "Authorization": tokenn,
    });
    if (response.statusCode == 200) {
      var item = json.decode(response.body)["result"]['Data'];
      setState(() {
        service = item;
      });
      setState(() => chVer = false);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MainScreen(token: tokenn ,service: service,selectedIndex: 0, initialOrderTab: 0,)));
      print(item);
    } else {
      setState(() {
        service = [];
      });
    }


  }
  String value;
  String email;
  String password;
  bool newPassword = false;

  _VerificationState(this.value, this.email, this.password){
    password  == ''? newPassword = true: newPassword = false;
  }

  int codeLength = 0;
  String code = "";
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  var requiredValidator = RequiredValidator(errorText: 'Required'.tr);
  bool _secureText = true;

  @override
  void initState() {
    super.initState();
    chVer = false;
  }

  @override
  Widget build(BuildContext context) {
    requiredValidator = RequiredValidator(errorText: AppLocalizations.of(context)!.translate('Required'));
    var active;
    if (codeLength == 6) {
      active = () {
        print(value);
        ver();
      };
    } else {
      active = null;
    }
    var heightSpace = MediaQuery.of(context).size.height/40;
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: MyColors.blue,
          body: DoubleBackToCloseApp(
              child: Container(
                //height: MediaQuery.of(context).size.height/1.5,
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/20, horizontal: MediaQuery.of(context).size.width/10),
                  child: ListView(
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      !newPassword?
                        Image.asset(
                          'assets/images/code.png',
                          width: MediaQuery.of(context).size.width/2,
                          height: MediaQuery.of(context).size.height/3,
                        ):
                      Container(
                          //height: MediaQuery.of(context).size.height/30,
                          child: Column(
                            children: [
                              /*Image.asset(
                                'assets/images/code.png',
                                width: MediaQuery.of(context).size.width/5,
                                height: MediaQuery.of(context).size.height/7,
                              ),*/
                              SizedBox(
                                height: heightSpace*2,
                              ),
                              Padding(
                                padding: EdgeInsets.all(MediaQuery.of(context).size.height/70),
                                child: MyWidget(context).textFiled(passwordController, '', AppLocalizations.of(context)!.translate('newPassword'), password: true,
                                    obscureText: _secureText, clickIcon: ()=> {
                                    setState(() {
                                    _secureText = !_secureText;
                                    })
                                }),
                              ),
                              Padding(
                                padding: EdgeInsets.all(MediaQuery.of(context).size.height/70),
                                child: MyWidget(context).textFiled(confirmPasswordController, '', AppLocalizations.of(context)!.translate('Confirm Password'), password: true,
                                    obscureText: _secureText, clickIcon: ()=> {
                                      setState(() {
                                        _secureText = !_secureText;
                                      })
                                    }, passwordText: passwordController.text),
                              ),
                              SizedBox(
                                height: heightSpace*2,
                              ),
                            ],
                          ),
                        ),
                       SizedBox(
                        height: heightSpace*2,
                      ),
                      Column(
                             //height: MediaQuery.of(context).size.height/5,
                             children: [
                               Padding(
                                 padding:  EdgeInsets.symmetric(
                                     vertical: 0, horizontal: MediaQuery.of(context).size.width/20),
                                 child: MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate("Enter the 6-digit code sent to your phone"), color: MyColors.White, textAlign: TextAlign.center, ),
                               ),
                               SizedBox(
                                 height: heightSpace/2,
                               ),
                               buildCodeBox(first: true, last: false),
                             ],
                        ),
                      //Expanded(child: Container()),
                      SizedBox(
                        height: heightSpace*7,
                      ),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyWidget(context).textBlack20(AppLocalizations.of(context)!.translate("Didn't receive the code?"), color: MyColors.White, bold: false),
                            SizedBox(
                              width: 2,
                            ),
                            GestureDetector(
                              onTap: () {
                                _resend();
                              },
                              child: MyWidget(context).textBlack20( AppLocalizations.of(context)!.translate('Resend'), color: MyColors.yellow, bold: false),
                            )
                          ],
                        ),
                      SizedBox(
                        height: heightSpace,
                      ),
                      MyWidget(context).raisedButton(AppLocalizations.of(context)!.translate('Confirm'), active, MediaQuery.of(context).size.width/1.3, chVer),
                    ],
                ),
              ),
            snackBar:  SnackBar(
                  content: Text(AppLocalizations.of(context)!.translate('Tap back again to leave')),
          ),
        ),
      ),
    );
  }

  Widget buildCodeBox({required bool first, last}) {
    return Center(
        child: OTPTextField(
      keyboardType: TextInputType.number,
      otpFieldStyle: OtpFieldStyle(
        borderColor: MyColors.White,
        focusBorderColor: MyColors.yellow,
        disabledBorderColor: MyColors.White,
        enabledBorderColor: MyColors.White,
      ),
      length: 6,
      width: MediaQuery.of(context).size.width,
      textFieldAlignment: MainAxisAlignment.center,
      fieldWidth:  MediaQuery.of(context).size.width/9,
      fieldStyle: FieldStyle.box,
      outlineBorderRadius: MediaQuery.of(context).size.height/90,
      style: TextStyle(
        fontSize: min(MediaQuery.of(context).size.width/15,MediaQuery.of(context).size.height/35),
        color: MyColors.White,
      ),
      onChanged: (pin) {
        codeLength = pin.length;
        code = pin;
      },
      onCompleted: (pin) {
      },

    )


        );
  }

  Future ver() async {
    setState(() => chVer = true);
    if(newPassword){
      _newPasswordVer(passwordController.text);
    }else{
      _firstVer();
    }
  }

  _firstVer() async{
    var apiUrl = Uri.parse('$apiDomain/Main/SignUp/SignUp_Verify');
    Map mapDate = {
      "guidParam": value,
      "txtParam": code,
    };
    http.Response response = await http.post(apiUrl, body: jsonEncode(mapDate), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
    });

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

  }

  _newPasswordVer(String newPassword) async{
    //curl -X POST "https://mr-service.online/Main/SignUp/ResetPassword?UserEmail=www.osh.themyth2%40gmail.com&code=160679&password=0938025347" -H "accept: */*"
    var apiUrl = Uri.parse('$apiDomain/Main/SignUp/ResetPassword?UserEmail=${email}&code=$code&password=$newPassword');

    print(apiUrl.toString());
    http.Response response = await http.post(apiUrl, headers: {
      "Accept": "application/json",
    });
    if (response.statusCode == 200) {
      print("we're good");
      print(jsonDecode(response.body));
      //userData = jsonDecode(response.body);
      setState(() {
        if (jsonDecode(response.body)['Errors'] == "") {
          Navigator.of(context).pushNamed('sign_in');
          //isLogIn = true;
          //token = jsonDecode(response.body)["content"]["Token"].toString();
          //updateUserInfo(userData["content"]["Id"]);
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
          chVer = false;
        }
      });
    }
    else {
      print(response.statusCode);
      print('A network error occurred');
    }

  }

  void _resend() async{
   // curl -X POST "https://mr-service.online/Main/SignUp/ReSendVerificationCode?UserEmail=www.osh.themyth%40gmail.com" -H "accept: */*"
    var apiUrl = Uri.parse('$apiDomain/Main/SignUp/ReSendVerificationCode?UserEmail=$email');
    http.Response response = await http.post(apiUrl, headers: {
      "Accept-Language": trrrr.LocalizationService.getCurrentLocale().languageCode,
      "Accept": "application/json",
    });
    print(jsonDecode(response.body).toString());
    if (response.statusCode == 200) {
      print("we're good");
      //userData = jsonDecode(response.body);
      setState(() {
        if (jsonDecode(response.body)['Errors'] == "") {
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
         /* Navigator.of(context).pushNamed('sign_in');
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
          ).show(context);*/
          //isLogIn = true;
          //token = jsonDecode(response.body)["content"]["Token"].toString();
          //updateUserInfo(userData["content"]["Id"]);
        }
        else {
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
    }
    else {
      print(response.statusCode);
      print('A network error occurred');
    }

  }

}
