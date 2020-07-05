import 'dart:io';
import '../common/config.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';

class Ads {
  static InterstitialAd _interstitialAd;
  static BannerAd _bannerAd;
  static MobileAdTargetingInfo _targetingInfo;

  static googleAdInit() {
    FirebaseAdMob.instance.initialize(
      appId: Platform.isAndroid
          ? kAdConfig['androidAppId']
          : kAdConfig['iosAppId'],
    );
    _targetingInfo = MobileAdTargetingInfo(
      keywords: <String>['flutterio', 'beautiful apps'],
      contentUrl: 'https://flutter.io',
      childDirected: false, // or MobileAdGender.female, MobileAdGender.unknown
      testDevices: <String>[], // Android emulators are considered test devices
    );
  }

  static facebookAdInit() {
    FacebookAudienceNetwork.init(
      testingId: kAdConfig['hasdedIdTestingDevice'],
    );
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      // Replace the testAdUnitId with an ad unit id from the AdMob dash.
      // https://developers.google.com/admob/android/test-ads
      // https://developers.google.com/admob/ios/test-ads
      adUnitId: Platform.isAndroid
          ? kAdConfig['androidUnitBanner']
          : kAdConfig['iosUnitBanner'],
      size: AdSize.smartBanner,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
  }

  static void showBanner() {
    if (_bannerAd == null) {
      _bannerAd = createBannerAd();
    }
    _bannerAd.load().then((load) {
      _bannerAd.show(anchorType: AnchorType.bottom);
    });
  }

  static void hideBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  static InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        adUnitId: Platform.isAndroid
            ? kAdConfig['androidUnitInterstitial']
            : kAdConfig['iosUnitInterstitial'],
        listener: (MobileAdEvent event) {
          print("InterstitialAd event is $event");
        });
  }

  static showInterstitialAd() {
    if (_interstitialAd == null) {
      _interstitialAd = createInterstitialAd();
    }
    _interstitialAd.load();
    Future.delayed(
        Duration(seconds: kAdConfig['waitingTimeToDisplayInterstitial']),
        () async {
      if (await _interstitialAd.isLoaded()) {
        _interstitialAd.show(
          anchorType: AnchorType.bottom,
          anchorOffset: 0.0,
          horizontalCenterOffset: 0.0,
        );
      }
    });
  }

  static hideInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  static void showRewardedVideoAd() {
    RewardedVideoAd.instance.load(
        adUnitId: Platform.isAndroid
            ? kAdConfig['androidUnitReward']
            : kAdConfig['iosUnitReward'],
        targetingInfo: _targetingInfo);
    Future.delayed(Duration(seconds: kAdConfig['waitingTimeToDisplayReward']),
        () async {
      RewardedVideoAd.instance.show();
    });
  }

  static void showFacebookInterstitialAd() {
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: kAdConfig['interstitialPlacementId'],
      listener: (result, value) {
        if (result == InterstitialAdResult.LOADED)
          FacebookInterstitialAd.showInterstitialAd(delay: 5000);
      },
    );
  }

  Widget facebookBanner() {
    print(kAdConfig['bannerPlacementId']);
    return FacebookBannerAd(
      placementId: kAdConfig['bannerPlacementId'],
      bannerSize: BannerSize.STANDARD,
      listener: (result, value) {
        switch (result) {
          case BannerAdResult.ERROR:
            print("Error: $value");
            break;
          case BannerAdResult.LOADED:
            print("Loaded: $value");
            break;
          case BannerAdResult.CLICKED:
            print("Clicked: $value");
            break;
          case BannerAdResult.LOGGING_IMPRESSION:
            print("Logging Impression: $value");
            break;
        }
      },
    );
  }

  Widget facebookNative() {
    return FacebookNativeAd(
      placementId: kAdConfig['nativePlacementId'],
      adType: NativeAdType.NATIVE_AD,
      width: double.infinity,
      height: 300,
      backgroundColor: Colors.blue,
      titleColor: Colors.white,
      descriptionColor: Colors.white,
      buttonColor: Colors.deepPurple,
      buttonTitleColor: Colors.white,
      buttonBorderColor: Colors.white,
      listener: (result, value) {
        print("Native Ad: $result --> $value");
      },
    );
  }

  Widget facebookBannerNative() {
    return FacebookNativeAd(
      placementId: kAdConfig["nativeBannerPlacementId"],
      adType: NativeAdType.NATIVE_BANNER_AD,
      bannerAdSize: NativeBannerAdSize.HEIGHT_100,
      width: double.infinity,
      backgroundColor: Colors.blue,
      titleColor: Colors.white,
      descriptionColor: Colors.white,
      buttonColor: Colors.deepPurple,
      buttonTitleColor: Colors.white,
      buttonBorderColor: Colors.white,
      listener: (result, value) {
        print("Native Ad: $result --> $value");
      },
    );
  }
}
