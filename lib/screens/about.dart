import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:closer/color/MyColors.dart';
import 'package:closer/localizations.dart';

class about extends StatefulWidget {
  @override
  _aboutState createState() => _aboutState();
}

class _aboutState extends State<about> {
  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      color: AppColors.blue,
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 3,
          child: Container(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.translate('name'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 10,
                        color: AppColors.white,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(AppLocalizations.of(context)!.translate('v'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 20,
                          color: AppColors.WhiteSelver,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),
                  Image.asset('assets/images/Logo1.png',
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height / 4,
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                _info(
                    Icons.mail_outline_outlined,
                    AppLocalizations.of(context)!.translate('email'),
                    "mailto:MrserviceOnlineGodigi@gmail.com?Subject=FeedBack MR-Services"),
                _info(
                    Icons.facebook_outlined,
                    AppLocalizations.of(context)!.translate('facebook'),
                    "http://facebook.com"),
                _info(
                    Icons.album_outlined,
                    AppLocalizations.of(context)!.translate('instgram'),
                    "http://instagram.com", image: 'assets/images/instgram_icon.png'),
                _info(
                    Icons.call_end_outlined,
                    '+963 938 025 347',
                    'tel: 0938025347'),
              ],
            ),
          )
          /*
                  Flexible(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        _info(
                            'assets/main_image/email_icon.svg',
                            AppLocalizations.of(context)
                                .translate('info_email'),
                            "mailto:info@subhengineering.com?Subject=FeedBack Application"),
                        _info(
                            'assets/main_image/facebook_icon.svg',
                            AppLocalizations.of(context)
                                .translate('info_facebook'),
                            "https://www.facebook.com/Subh.Engineering/"),
                        _info(
                            'assets/main_image/instgram_icon.svg',
                            AppLocalizations.of(context)
                                .translate('info_instgram'),
                            "https://www.instagram.com/subh.engineering/")
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/main_image/mobile.svg',
                        ),
                        SizedBox(
                          height: 0,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset('assets/main_image/logo_subh.png',),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      child: Text(
                          AppLocalizations.of(context).translate('companyname'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .display2
                              .copyWith(color: color.red, fontSize: 18)),
                      onTap: () async {
                        if (await canLaunch('http://subhengineering.com/')) {
                          await launch('http://subhengineering.com/');
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          )*/
        ],
      ),
    );
  }

  _info(icon, String txt, String url, {String? image}) {
    return Padding(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width *0.04,right: MediaQuery.of(context).size.width *0.04, top: MediaQuery.of(context).size.height *0.02, bottom: MediaQuery.of(context).size.height *0.02),
      child: Row(
        children: <Widget>[
          image == null ? Icon(icon, size: MediaQuery.of(context).size.width / 14, color: AppColors.yellow,)
          :Image.asset(image, height: MediaQuery.of(context).size.width / 14,),
          SizedBox(
            width: MediaQuery.of(context).size.width *0.05,
          ),
          GestureDetector(
            child: Text(
              txt,
              textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 19,
                    color: AppColors.white,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.underline),
            ),
            onTap: () async {
              if (await canLaunch(url)) {
                await launch(url);
              }
            },
          ),
        ],
      ),
    );
  }

}
