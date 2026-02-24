import 'package:flutter/foundation.dart';

class AdUnitId {
    // Test Ad Unit IDs (Google's official test IDs)
  static const String _testHomeBanner = "ca-app-pub-3940256099942544/6300978111";
  static const String _testResumeBanner = "ca-app-pub-3940256099942544/2934735716";
  static const String _testATSInterstitial = "ca-app-pub-3940256099942544/1033173712";
  static const String _testTemplateInterstitial = "ca-app-pub-3940256099942544/4411468910";
  static const String _testResumeReward = "ca-app-pub-3940256099942544/5224354917";
  
  // Production Ad Unit IDs (replace with your actual AdMob IDs)
  static const String _prodHomeBanner = "ca-app-pub-8430205067438219/7877162697";
  static const String _prodResumeBanner = "ca-app-pub-8430205067438219/7274790793";
  static const String _prodATSInterstitial = "ca-app-pub-8430205067438219/7250778056";
  static const String _prodTemplateInterstitial = "ca-app-pub-8430205067438219/7250778056";
  static const String _prodResumeReward = "ca-app-pub-8430205067438219/6388891016";
  
  // AdMob App IDs
  static const String _testAppId = "ca-app-pub-3940256099942544~3347511713";
  static const String _prodAppId = "ca-app-pub-8430205067438219~5745823378";
  
  // Get appropriate Ad Unit ID based on build mode
  static String get homeScreenBanner => kDebugMode ? _testHomeBanner : _prodHomeBanner;
  static String get resumeBuilderBanner => kDebugMode ? _testResumeBanner : _prodResumeBanner;
  static String get atsInterstitialAd => kDebugMode ? _testATSInterstitial : _prodATSInterstitial;
  static String get resumeBuilderInterstitialAd => kDebugMode ? _testATSInterstitial : _prodATSInterstitial;
  static String get templatetabInterstitialAd => kDebugMode ? _testTemplateInterstitial : _prodTemplateInterstitial;
  static String get resumeBuilderRewardAd => kDebugMode ? _testResumeReward : _prodResumeReward;
  
  // Get appropriate App ID based on build mode
  static String get appId => kDebugMode ? _testAppId : _prodAppId;
  
  // Check if using test ads
  static bool get isUsingTestAds => kDebugMode;
  
  // Helper method to get all ad unit IDs for debugging
  static Map<String, String> getAllAdUnitIds() {
    return {
      'homeScreenBanner': homeScreenBanner,
      'resumeBuilderBanner': resumeBuilderBanner,
      'atsInterstitialAd': atsInterstitialAd,
      'resumeBuilderInterstitialAd': resumeBuilderInterstitialAd,
      'templatetabInterstitialAd': templatetabInterstitialAd,
      'resumeBuilderRewardAd': resumeBuilderRewardAd,
      'appId': appId,
    };
  }
}