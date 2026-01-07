import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resume_builder/Presentation/resources/route_manager.dart';
import 'package:resume_builder/screens/enhanced_download_screen.dart';
import 'package:resume_builder/google_ads/ads.dart';
import 'package:resume_builder/my_singleton.dart';
import '../../../google_ads/adunits.dart';
import '../../resources/assets_manager.dart';
import '../../resources/color_manager.dart';
import '../../resources/font_manager.dart';
import '../../resources/strings_manager.dart';
import '../../resources/values_manager.dart';

class TemplateTabView extends StatefulWidget {
  TemplateTabView({super.key});

  @override
  State<TemplateTabView> createState() => _TemplateTabViewState();
}

class _TemplateTabViewState extends State<TemplateTabView> {
  Future<void> _getStoragePermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      status = await Permission.manageExternalStorage.request();
    }
  }

  CreateAd createAd = CreateAd();
  @override
  void initState() {
    super.initState();
    _getStoragePermission();
    MySingleton.loggedInUser!.subscribed! ? null : createAd.loadTemplateTabAd();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManager.tabBackground,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSize.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: AppPadding.p8,
                    bottom: AppPadding.p20,
                    top: AppPadding.p8),
                child: Text(
                  AppStrings.templatesHeader,
                  style: TextStyle(
                      fontSize: FontSize.s20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 5,
                        color: Colors.black38,
                        offset: Offset.fromDirection(2, 2))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppSize.s8,
                    right: AppSize.s8,
                    top: AppPadding.p12,
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                            left: AppPadding.p8,
                            right: AppPadding.p8,
                            bottom: AppPadding.p18,
                            top: AppPadding.p18),
                        child: Text(
                          AppStrings.templateScreenText,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: FontSize.s12,
                          ),
                        ),
                      ),
                      GridView.count(
                        childAspectRatio: 0.52,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 30,
                        crossAxisSpacing: 20,
                        crossAxisCount: 2,
                        children: _getListWidgets(),
                      ),
                      SizedBox(
                        height: AppSize.s20,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: AppSize.s20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getListWidgets() => [
        _getTemplateItem(
            item_id: "1", thumbnail: ImageAssets.template1, isPremium: false),
        _getTemplateItem(
            item_id: "2", thumbnail: ImageAssets.template2, isPremium: false),
        _getTemplateItem(
            item_id: "3", thumbnail: ImageAssets.template3, isPremium: false),
        _getTemplateItem(
            item_id: "4", thumbnail: ImageAssets.template4, isPremium: true),
        _getTemplateItem(
            item_id: "5", thumbnail: ImageAssets.template5, isPremium: true),
        _getTemplateItem(
            item_id: "6", thumbnail: ImageAssets.template6, isPremium: true),
        _getTemplateItem(
            item_id: "7", thumbnail: ImageAssets.template7, isPremium: true),
        _getTemplateItem(
            item_id: "8", thumbnail: ImageAssets.template8, isPremium: true),
        _getTemplateItem(
            item_id: "9", thumbnail: ImageAssets.template9, isPremium: true),
        _getTemplateItem(
            item_id: "10", thumbnail: ImageAssets.template10, isPremium: true),
        _getTemplateItem(
            item_id: "11", thumbnail: ImageAssets.template11, isPremium: true),
        _getTemplateItem(
            item_id: "12", thumbnail: ImageAssets.template12, isPremium: true),
        _getTemplateItem(
            item_id: "13", thumbnail: ImageAssets.template13, isPremium: true),
        _getTemplateItem(
            item_id: "14", thumbnail: ImageAssets.template14, isPremium: true),
        _getTemplateItem(
            item_id: "15", thumbnail: ImageAssets.template15, isPremium: true),
        _getTemplateItem(
            item_id: "16", thumbnail: ImageAssets.template16, isPremium: true),
        _getTemplateItem(
            item_id: "17", thumbnail: ImageAssets.template17, isPremium: true),
        _getTemplateItem(
            item_id: "18", thumbnail: ImageAssets.template18, isPremium: true),
        _getTemplateItem(
            item_id: "19", thumbnail: ImageAssets.template19, isPremium: true),
        _getTemplateItem(
            item_id: "20", thumbnail: ImageAssets.template20, isPremium: true),
        _getTemplateItem(
            item_id: "21", thumbnail: ImageAssets.template21, isPremium: true),
        _getTemplateItem(
            item_id: "22", thumbnail: ImageAssets.template22, isPremium: true),
        _getTemplateItem(
            item_id: "23", thumbnail: ImageAssets.template23, isPremium: true),
        _getTemplateItem(
            item_id: "24", thumbnail: ImageAssets.template24, isPremium: true),
        _getTemplateItem(
            item_id: "25", thumbnail: ImageAssets.template25, isPremium: true),
        _getTemplateItem(
            item_id: "26", thumbnail: ImageAssets.template26, isPremium: true),
        _getTemplateItem(
            item_id: "27", thumbnail: ImageAssets.template31, isPremium: true),
        _getTemplateItem(
            item_id: "28", thumbnail: ImageAssets.template32, isPremium: true),
        _getTemplateItem(
            item_id: "29", thumbnail: ImageAssets.template33, isPremium: true),
        _getTemplateItem(
            item_id: "30", thumbnail: ImageAssets.template34, isPremium: false),
      ];

  Widget _getTemplateItem(
      {required String item_id,
      required String thumbnail,
      required bool isPremium}) {
    return InkWell(
      onTap: () => _onTapListItem(item_id: item_id, isPremium: isPremium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              AppStrings.templateNames[item_id] ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.primary),
            ),
          ),
          Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: ColorManager.grey),
            ),
            child: Image.asset(
              fit: BoxFit.cover,
              thumbnail,
              height: 100,
              width: 100,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                ImageAssets.pdfDownloadIc,
                height: 20,
                width: 20,
                color: Colors.blue,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Download PDF",
                style: TextStyle(
                    fontSize: FontSize.s12, color: ColorManager.secondary),
              )
            ],
          )
        ],
      ),
    );
  }

  // Enhanced template selection with AI integration
  void _onTapListItem(
      {required String item_id, required bool isPremium}) async {
    if (isPremium && !(MySingleton.loggedInUser?.subscribed ?? false)) {
      _getPromotionalDialog(id: item_id);
      return;
    }

    // Navigate to enhanced download screen with template selection
    final resumeData = await _getResumeData();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedDownloadScreen(
          templateId: item_id,
          resumeData: resumeData,
        ),
      ),
    );
  }

  // Get resume data from the current form
  Future<Map<String, dynamic>> _getResumeData() async {
    // This should be replaced with actual data from your form fields
    // For now, returning sample data structure
    return {
      'firstName':
          MySingleton.loggedInUser?.userName?.split(' ').first ?? 'John',
      'lastName': MySingleton.loggedInUser?.userName?.split(' ').last ?? 'Doe',
      'email': MySingleton.loggedInUser?.email ?? 'john.doe@example.com',
      'phone': '+1-234-567-8900',
      'position': 'Software Engineer',
      'summary':
          'Experienced software engineer with expertise in mobile and web development.',
      'workExperience': [
        {
          'title': 'Senior Software Engineer',
          'company': 'Tech Corp',
          'duration': '2020 - Present',
          'description':
              'Led development of mobile applications using Flutter and React Native.'
        },
        {
          'title': 'Software Engineer',
          'company': 'StartupXYZ',
          'duration': '2018 - 2020',
          'description':
              'Developed web applications using modern JavaScript frameworks.'
        }
      ],
      'education': [
        {
          'degree': 'Bachelor of Computer Science',
          'institution': 'University of Technology',
          'year': '2018'
        }
      ],
      'skills': [
        'Flutter',
        'Dart',
        'React Native',
        'JavaScript',
        'Python',
        'Firebase'
      ],
      'jobDescription':
          'We are looking for a software engineer with experience in mobile development using Flutter and Firebase.'
    };
  }

  // Legacy method for backward compatibility

  void _getSubscription(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.subscriptionPage);
  }

  // *** CHANGE 5: Modified _getAd to handle Template1 navigation ***
  Future<void> _getAd({required String id}) async {
    await InterstitialAd.load(
        adUnitId: AdUnitId.resumeBuilderInterstitialAd,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                // Ad is now showing
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                // Navigate to download screen after ad is dismissed
                _navigateToDownloadScreen(id: id);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                // Navigate if ad fails to show
                _navigateToDownloadScreen(id: id);
              },
            );
            ad.show();
          },
          onAdFailedToLoad: (error) {
            print('Failed to load an interstitial ad: ${error.message}');
            // Navigate even if ad fails to load so user isn't stuck
            _navigateToDownloadScreen(id: id);
          },
        ));
  }

  void _navigateToDownloadScreen({required String id}) async {
    // Navigate to enhanced download screen with template selection
    final resumeData = await _getResumeData();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedDownloadScreen(
          templateId: id,
          resumeData: resumeData,
        ),
      ),
    );
  }

  void _getPromotionalDialog({required String id}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.transparent,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: ColorManager.white,
                        image: DecorationImage(
                            colorFilter: ColorFilter.mode(
                                ColorManager.white.withOpacity(0.7),
                                BlendMode.hardLight),
                            image: AssetImage(
                              ImageAssets.promoBg3,
                            ),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 5,
                              color: Colors.black38,
                              offset: Offset.fromDirection(2, 2))
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: AppSize.s8,
                          right: AppSize.s8,
                          top: AppPadding.p30,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  Positioned(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Center(
                                          child: Stack(
                                            children: [
                                              Text(
                                                "Watch ad to unlock the Template",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: FontSize.s20,
                                                    letterSpacing: 3,
                                                    foreground: Paint()
                                                      ..style =
                                                          PaintingStyle.stroke
                                                      ..strokeWidth = 10
                                                      ..color = ColorManager
                                                          .promo1BgColor),
                                              ),
                                              Text(
                                                "Watch ad to unlock the Template",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: ColorManager.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: FontSize.s20,
                                                    letterSpacing: 3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _getAd(id: id);
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: StadiumBorder(
                                      side: BorderSide(
                                          color: ColorManager.promo1BgColor,
                                          strokeAlign:
                                              BorderSide.strokeAlignCenter,
                                          width: 3)),
                                  backgroundColor: Colors.white70),
                              child: Text(
                                "Watch Ad",
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                    color: ColorManager.promo2buttonColor,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Text(
                              "Your Next-Level Resume Starts Here",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorManager.promo2buttonColor,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
