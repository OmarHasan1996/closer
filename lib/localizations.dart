// TODO Implement this library.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate = AppLocalizationsDelegate();

  AppLocalizations(this.locale);


  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }


  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString = await rootBundle.loadString('lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  List<String> currency = ['TL', 'RS'];
  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    String s = '';
    if(key == 'TRY'){
      return currency[1];
    }
    try{
      _localizedStrings[key] == 'null'? s = '' : s = _localizedStrings[key]!;
    }catch(e){
      s = key.toString();
    }
    return s;
  }

  // Your keys defined below
  /*String get title {
    return Intl.message(
      'Hello World',
      name: 'title',
      desc: 'Title for the Localized application',
    );
  }

  String welcome(String name) {
    return Intl.message(
      'Welcome {name}',
      name: 'welcome',
      desc: 'Welcome message',
      args: [name],
    );
  }
*/
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  // Override with your list of supported language codes
  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale('en', 'US'),
      Locale('fr', 'FR'),
      Locale('ar', 'AR'),
      Locale('tr', 'TR'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}