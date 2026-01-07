import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resume_builder/DB/db.dart';
import 'package:resume_builder/Presentation/resources/assets_manager.dart';
import 'package:resume_builder/Presentation/resources/font_manager.dart';
import 'package:resume_builder/Presentation/resources/route_manager.dart';
import 'package:resume_builder/Presentation/resources/strings_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:resume_builder/Presentation/resume_builder/resume_builder.dart';
import 'package:resume_builder/auth/auth.dart';
import 'package:resume_builder/constants/colours.dart';
import 'package:resume_builder/google_ads/ads.dart';
import 'package:resume_builder/google_ads/adunits.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/screens/AtsCheckingScreen.dart';
import 'package:resume_builder/shared_preference/shared_preferences.dart';
import 'package:resume_builder/my_singleton.dart';
import '../../firestore/user_firestore.dart';
import '../../menu/my_menu.dart';
import '../resources/color_manager.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  final User? user = Auth().currentUser;

  final FireUser _fireUser = FireUser();

  Future<bool> signOut() async {
    try {
      await Auth().signOut();
      return true;
    } on FirebaseAuthException catch (error) {
      print("Fire Base Problem :- ${error.message}");
      return false;
    }
  }

  Future<bool> signOutGoogle() async {
    try {
      await Auth().signOutGoogle();
      return true;
    } on FirebaseAuthException catch (error) {
      print("Fire Base Problem :- ${error.message}");
      return false;
    }
  }

  final _streamController = StreamController<List<ResumeModel>>();

  GlobalKey floatingKey = LabeledGlobalKey("Floating");
  bool isFloatingOpen = false;
  late OverlayEntry floating;
  List<IntroModel?> introList = [];

  Future<void> _getStoragePermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      status = await Permission.manageExternalStorage.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _getAllResumes();
    _getCurrentUserDetails();
    // loadBanner moved to didChangeDependencies
    print("CurrentUserEmail = ${MySingleton.loggedInUser?.email}");
    print("CurrentUserUsername = ${MySingleton.loggedInUser?.userName}");
    print("CurrentUserUID = ${MySingleton.loggedInUser?.uid}");
    print("CurrentUserSubscribed = ${MySingleton.loggedInUser?.subscribed}");
    _getStoragePermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadBanner();
  }

  Future<void> _getCurrentUserDetails() async {
    final uid = await SharedPrefHelper.getUserUid();
    if (uid == null) return;

    MySingleton.loggedInUser = await FireUser().getCurrentUser(uid);
  }

  Future<void> _getAllResumes() async {
    final userId = MySingleton.userId;
    if (userId == null) {
      /* handle not logged in */ return;
    }
    final resumes = await _fireUser.getResumesForUser(userId);
    _streamController.sink.add(resumes);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    CreateAd.homescreenBanner.dispose();
    super.dispose();
  }

  bool _isAdLoading = false;
  bool adLoaded = false;
  BannerAd? _bannerAd;

  void loadBanner() async {
    if (adLoaded || _isAdLoading) return;
    _isAdLoading = true;

    // Get an AnchoredAdaptiveBannerAdSize.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      _isAdLoading = false;
      return;
    }

    _bannerAd = BannerAd(
        size: size,
        adUnitId: AdUnitId.homeScreenBanner,
        listener: BannerAdListener(onAdLoaded: (ad) {
          print("Homescreen Banner Ad Has been Loaded");
          setState(() {
            adLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print("Homescreen Banner Ad Has Failed To Load because $error");
          _isAdLoading = false;
        }),
        request: AdRequest())
      ..load();
    print("BANNER AD = > $_bannerAd");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: blue_background,
        appBar: AppBar(
          leading: InkWell(
            onTap: () async {
              setState(() {
                showSimpleDialog(context);
              });
            },
            child: SvgPicture.asset(
              ImageAssets.menuIc,
              fit: BoxFit.scaleDown,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: AppSize.s0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: ColorManager.white,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ),
          title: Text(
            "${AppStrings.appBarTitle}",
            style: TextStyle(
                color: ColorManager.secondary,
                fontSize: FontSize.s20,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  _showLogoutDialog();
                },
                icon: Icon(
                  Icons.power_settings_new_outlined,
                  color: ColorManager.secondary,
                ))
          ],
        ),
        bottomSheet: MySingleton.loggedInUser!.subscribed! == false
            ? adLoaded && _bannerAd != null
                ? SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!))
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50, // Default height placeholder
                    child: Align(
                        alignment: Alignment.center,
                        child: Text("Loading Ad...")),
                  )
            : Container(
                height: 0,
              ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImageAssets.homeBackground),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
              child: StreamBuilder(
            stream: _streamController.stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<ResumeModel>> snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: MySingleton.loggedInUser!.subscribed!
                      ? GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          shrinkWrap: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: _getNewResumeBtn(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: _getAtsCheckingBtn(),
                            ),
                            if (snapshot.data != null &&
                                snapshot.data!.isNotEmpty)
                              for (int i = 0; i < snapshot.data!.length; i++)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      _getResumeListItem(snapshot.data![i], i),
                                ),
                          ],
                        )
                      : Column(
                          children: [
                            Flexible(
                              child: GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                                shrinkWrap: true,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: _getNewResumeBtn(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: _getAtsCheckingBtn(),
                                  ),
                                  if (snapshot.data != null &&
                                      snapshot.data!.isNotEmpty)
                                    for (int i = 0;
                                        i < snapshot.data!.length;
                                        i++)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: _getResumeListItem(
                                            snapshot.data![i], i),
                                      ),
                                ],
                              ),
                            ),
                            SizedBox(height: 70),
                          ],
                        ),
                );
              } else if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Text("Something Went Wrong");
              }
            },
          )),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          title: Text('Log Out'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Are you sure to LogOut?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.black, fontSize: FontSize.s16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Logout',
                style: TextStyle(
                    color: ColorManager.secondary, fontSize: FontSize.s16),
              ),
              onPressed: () async {
                try {
                  await Auth().signOut();
                  await SharedPrefHelper.clearUserUid();
                  MySingleton.loggedInUser = null;

                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.splash, (route) => false);
                } catch (e) {
                  print("Logout failed: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getPromo() {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30))),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.p20,
          vertical: AppPadding.p20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      ImageAssets.promoBg2,
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
                    Text(
                      "Your Pathway to a Standout Resume!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Unique",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 3),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Center(
                                    child: Text(
                                  "Premium Templates",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: FontSize.s27,
                                  ),
                                )),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Awaits",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 3),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 290,
                            bottom: 45,
                            child: SvgPicture.asset(
                              ImageAssets.whiteCrownIc,
                              height: 30,
                              width: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () => _getSubscription(context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      child: Text(
                        "UPGRADE NOW",
                        style: TextStyle(
                            color: ColorManager.promo2buttonColor,
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Upgrade | Elevate | Enjoy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getSubscription(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.subscriptionPage);
  }

  Future<void> insertSections({required String id}) async {
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.accomp));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.awards));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.films));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.hobbies));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.interests));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.languages));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.oraganization));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.publications));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.profCertifications));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.projects));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.refernces));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.skills));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.techSkills));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.training));
    await DbHelper.instance.createNewSection(
        section: SectionModel(resumeId: id, id: AppStrings.other));
  }

  void createNewResume() async {
    final userId = MySingleton.userId;
    if (userId == null) {
      print("Cannot create resume. User ID is null.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Not logged in.")),
        );
      }
      return;
    }
    try {
      final String? newResumeId = await _fireUser.createNewResume(
        userId: userId,
        title: "My New Resume",
      );

      if (newResumeId == null) {
        print("Failed to create resume in Firestore.");
        return;
      }

      final defaultIntro = IntroModel(firstName: "", lastName: "");
      await _fireUser.saveIntroForResume(
          userId: userId, resumeId: newResumeId, intro: defaultIntro);

      await _getAllResumes();

      if (!mounted) return;

      MySingleton.resumeId = newResumeId;
      Navigator.pushNamed(context, Routes.resume_builder);
      _clearTextController();
    } catch (e) {
      print("Error in createNewResume flow: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not create resume.")),
        );
      }
    }
  }

  _showDeleteDialog(BuildContext context, {required String id}) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel", style: TextStyle(color: Colors.black)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget deleteButton = TextButton(
      child: Text(
        "${AppStrings.delete.toUpperCase()}",
        style: TextStyle(color: ColorManager.primary),
      ),
      onPressed: () async {
        final userId = MySingleton.userId;
        if (userId == null) {
          print("Cannot delete: not logged in.");
          if (mounted) Navigator.pop(context);
          return;
        }
        await _fireUser.deleteResume(userId: userId, resumeId: id);
        _getAllResumes();

        if (mounted) {
          Navigator.pop(context);
        }
      },
    );

    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      title: const Text("Are You Sure?", style: TextStyle(color: Colors.black)),
      content: const Text(
          "This action cannot be undone. Tap 'DELETE' to confirm.",
          style: TextStyle(color: Colors.black)),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _clearTextController() {
    MySingleton.companyNameController.clear();
    MySingleton.companyLocController.clear();
    MySingleton.companyPosController.clear();
    MySingleton.companyPosFromController.clear();
    MySingleton.companyPosUntilController.clear();
    MySingleton.schoolNameController.clear();
    MySingleton.schoolFromController.clear();
    MySingleton.schoolToController.clear();
    MySingleton.summeryController.clear();
    MySingleton.newSectionController.clear();
    MySingleton.coverLetterController.clear();
  }

  Widget _getNewResumeBtn() {
    return InkWell(
      onTap: createNewResume,
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.secondary,
          border: Border.all(color: ColorManager.secondary, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              ImageAssets.createResumeBtnIC,
              fit: BoxFit.scaleDown,
              height: 45,
              width: 45,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              AppStrings.newResume,
              style: TextStyle(fontSize: FontSize.s16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAtsCheckingBtn() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AtsCheckingScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.promo1BgColor,
          border: Border.all(color: ColorManager.promo1BgColor, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 45,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'ATS Checking',
              style: TextStyle(fontSize: FontSize.s16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getResumeById(String id) async {
    setState(() {
      MySingleton.resumeId = id;
    });
    print("Id From Homescreen ${MySingleton.resumeId}");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResumeBuilderView()),
    );
  }

  Widget _getResumeListItem(ResumeModel resume, int index) {
    Color backColor = Colors.white;
    Color textColor = ColorManager.secondary;
    String icon = ImageAssets.docGradientIc;

    final resumeTitle = "Resume ${index + 1}";

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return PopupMenuButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: EdgeInsets.zero,
          position: PopupMenuPosition.under,
          onOpened: () {
            setState(() {
              backColor = ColorManager.secondary;
              textColor = ColorManager.white;
              icon = ImageAssets.docWhiteIc;
            });
          },
          onCanceled: () {
            setState(() {
              icon = ImageAssets.docGradientIc;
              backColor = Colors.white;
              textColor = ColorManager.primary;
            });
          },
          icon: Container(
            width: MediaQuery.of(context).size.width * 0.40,
            padding: EdgeInsets.symmetric(horizontal: 25),
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: backColor,
              border: Border.all(
                color: ColorManager.secondary,
                width: 3,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              boxShadow: [BoxShadow(color: Colors.black38)],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(icon, fit: BoxFit.scaleDown),
                SizedBox(height: 15),
                Text(
                  resumeTitle,
                  style: TextStyle(fontSize: FontSize.s16, color: textColor),
                ),
              ],
            ),
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _getCurrentUserDetails()
                          .then((_) => _getResumeById(resume.id)),
                      child: Text("Edit",
                          style: TextStyle(color: ColorManager.secondary)),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteResume(context, resume.id);
                        Navigator.pop(context);
                      },
                      child:
                          Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ];
          },
          onSelected: (String value) => value,
        );
      },
    );
  }

  void _deleteResume(BuildContext context, String id) {
    setState(() {
      Future.delayed(
          const Duration(seconds: 0), () => _showDeleteDialog(context, id: id));
    });
    print("Resume $id");
  }
}
