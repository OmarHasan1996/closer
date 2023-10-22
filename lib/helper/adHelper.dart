import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {

  static BannerAd? bannerAd;

  static String? get getBannerAdUnitId {
    if (Platform.isIOS) {
      return 'ca-app-pub-5051441163313137/1086082504';
    } else if (Platform.isAndroid) {
      //return 'ca-app-pub-3940256099942544/6300978111';
      return 'ca-app-pub-5051441163313137/4753864776';
    }
    return null;
  }

  static String? get getInterstitialAdUnitId {
    if (Platform.isIOS) {
      return 'ca-app-pub-5051441163313137/3128957760';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-5051441163313137/3065378587';
    }
    return null;
  }

  static String? get getRewardBasedVideoAdUnitId {
    if (Platform.isIOS) {
      return 'ca-app-pub-5051441163313137/6613741359';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-5051441163313137/3361672304';
    }
    return null;
  }

  static loadBanner(){
    BannerAd(
      adUnitId: getBannerAdUnitId??'',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
            bannerAd = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }
}