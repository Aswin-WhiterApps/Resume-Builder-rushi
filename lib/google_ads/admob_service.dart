import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'adunits.dart';

class AdMobService {
  static bool _isInitialized = false;

  /// Initialize AdMob with appropriate configuration based on build mode
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configuration check for testing
      // We skip initialization if we're in a test environment to avoid MissingPluginException
      // which occurs because native platform channels are not available in Dart-only tests.
      try {
        if (Platform.environment.containsKey('FLUTTER_TEST')) {
          print('AdMob initialization skipped: running in test environment');
          _isInitialized = true; // Mark as "initialized" so we don't try again
          return;
        }
      } catch (_) {
        // Platform.environment might throw on Web, though this app seems mobile-focused
      }

      // Configure request for testing devices
      RequestConfiguration configuration = RequestConfiguration(
        testDeviceIds: kDebugMode ? ["D716483E2D403B5311D4A2FAB428C47B"] : [],
      );

      MobileAds.instance.updateRequestConfiguration(configuration);
      await MobileAds.instance.initialize();

      _isInitialized = true;

      // Log configuration for debugging
      if (kDebugMode) {
        print('AdMob initialized with TEST ads');
        print('All Ad Unit IDs: ${AdUnitId.getAllAdUnitIds()}');
      } else {
        print('AdMob initialized with PRODUCTION ads');
      }
    } on MissingPluginException catch (e) {
      print(
          'AdMob initialization skipped: Missing plugin implementation (expected in tests): $e');
      _isInitialized = true;
    } on PlatformException catch (e) {
      if (e.code == 'MissingPluginException' ||
          e.message?.contains('No implementation found') == true) {
        print('AdMob initialization skipped: Platform channel not found: $e');
      } else {
        print('AdMob initialization failed with PlatformException: $e');
      }
      _isInitialized = true;
    } catch (e) {
      print('AdMob initialization failed: $e');
      // We don't rethrow here to prevent the app from crashing during tests or if AdMob fails
      _isInitialized = true;
    }
  }

  /// Check if AdMob is initialized
  static bool get isInitialized => _isInitialized;

  /// Get current ad mode
  static String get currentMode => kDebugMode ? 'TEST' : 'PRODUCTION';

  /// Validate ad unit IDs are properly configured
  static bool validateAdUnitIds() {
    final allIds = AdUnitId.getAllAdUnitIds();

    for (final entry in allIds.entries) {
      final id = entry.value;

      // Check if production IDs are still placeholders
      if (!kDebugMode && (id.contains('YOUR_') || id.contains('here'))) {
        print('ERROR: Production ad unit ID not set for ${entry.key}');
        return false;
      }
    }

    return true;
  }

  /// Create banner ad with proper configuration
  static BannerAd createBannerAd({
    required String adUnitId,
    required AdSize adSize,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    required Function(Ad ad) onAdLoaded,
  }) {
    return BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => onAdLoaded(ad),
        onAdFailedToLoad: (Ad ad, LoadAdError error) =>
            onAdFailedToLoad(ad, error),
      ),
    );
  }

  /// Load interstitial ad
  static Future<InterstitialAd?> loadInterstitialAd({
    required String adUnitId,
    required Function(InterstitialAd ad) onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) async {
    try {
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            );
            onAdLoaded(ad);
          },
          onAdFailedToLoad: (LoadAdError error) => onAdFailedToLoad(error),
        ),
      );
    } catch (e) {
      print('Error loading interstitial ad: $e');
      return null;
    }
    return null;
  }

  /// Load rewarded ad
  static Future<RewardedAd?> loadRewardedAd({
    required String adUnitId,
    required Function(RewardedAd ad) onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) async {
    try {
      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            );
            onAdLoaded(ad);
          },
          onAdFailedToLoad: (LoadAdError error) => onAdFailedToLoad(error),
        ),
      );
    } catch (e) {
      print('Error loading rewarded ad: $e');
      return null;
    }
    return null;
  }
}
