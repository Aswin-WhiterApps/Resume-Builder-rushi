import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'adunits.dart';

class CreateAd {
  static bool bannerAdLoaded = false;

  static BannerAd resumebuilderBanner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdUnitId.resumeBuilderBanner,
      listener: BannerAdListener(onAdLoaded: (ad) {
        print("resume builder Banner Ad Has been Loaded");
      }, onAdFailedToLoad: (ad, error) {
        ad.dispose();
        print("resume builder Banner Ad Has Failed To Load because $error");
      }),
      request: AdRequest());

  // late InterstitialAd interstitialAd;
  // bool isInterstitialAdLoaded = false;
  Future<void> loadResumeBuilderAd() async {
    await InterstitialAd.load(
        adUnitId: AdUnitId.resumeBuilderInterstitialAd,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.show();
            print("resume builder Interstitial Ad Has been Loaded");
          },
          onAdFailedToLoad: (error) {
            // ad.dispose();
            print(
                "resume builder Interstitial Ad Has Failed To Load because $error");
          },
        ));
  }

  Future<void> loadTemplateTabAd() async {
    await InterstitialAd.load(
        adUnitId: AdUnitId.templatetabInterstitialAd,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.show();
            print("resume builder Interstitial Ad Has been Loaded");
          },
          onAdFailedToLoad: (error) {
            // ad.dispose();
            print(
                "resume builder Interstitial Ad Has Failed To Load because $error");
          },
        ));
  }

  // Future<bool> loadRewardedAd() async {
  //   bool isRewardEarned = false;
  //   await RewardedAd.load(
  //     adUnitId: AdUnitId.resumeBuilderRewardAd,
  //     request: AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         ad.show(
  //             onUserEarnedReward: (adwithoutView,reward){
  //               isRewardEarned = true;
  //               print('Reward From Ads Is True');
  //             });
  //       },
  //       onAdFailedToLoad: (err) {
  //         print('Failed to load a rewarded ad: ${err.message}');
  //       },
  //     ),
  //   );
  //   return isRewardEarned;
  // }
}
