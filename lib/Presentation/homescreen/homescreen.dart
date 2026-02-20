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
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
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
    _scrollController.addListener(_onScroll);
    _getAllResumes();
    _getCurrentUserDetails();
    // loadBanner moved to didChangeDependencies
    print("CurrentUserEmail = ${MySingleton.loggedInUser?.email}");
    print("CurrentUserUsername = ${MySingleton.loggedInUser?.userName}");
    print("CurrentUserUID = ${MySingleton.loggedInUser?.uid}");
    print("CurrentUserSubscribed = ${MySingleton.loggedInUser?.subscribed}");
    _getStoragePermission();
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 10 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
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
    _scrollController.dispose();
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  bool _isAdLoading = false;
  bool adLoaded = false;
  BannerAd? _bannerAd;

  void loadBanner({int attempt = 0}) async {
    if (adLoaded || _isAdLoading) return;

    // Check if the user is subscribed before attempting to load
    bool isSubscribed = MySingleton.loggedInUser?.subscribed ?? false;
    if (isSubscribed) return;

    _isAdLoading = true;

    try {
      // Get an AnchoredAdaptiveBannerAdSize.
      final AnchoredAdaptiveBannerAdSize? size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
              MediaQuery.of(context).size.width.truncate());

      AdSize finalSize = size ?? AdSize.banner;

      if (size == null) {
        print(
            'Unable to get height of anchored banner, falling back to standard banner.');
      }

      _bannerAd = BannerAd(
          size: finalSize,
          adUnitId: AdUnitId.homeScreenBanner,
          listener: BannerAdListener(onAdLoaded: (ad) {
            print("Homescreen Banner Ad Has been Loaded");
            if (mounted) {
              setState(() {
                adLoaded = true;
                _isAdLoading = false;
              });
            }
          }, onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _bannerAd = null;
            print("Homescreen Banner Ad Has Failed To Load because $error");

            if (mounted) {
              setState(() {
                adLoaded = false;
                _isAdLoading = false;
              });

              // Retry logic: try again after a delay if it's not a terminal error
              // Limit retries to 3 times to avoid infinite loops
              if (attempt < 3) {
                print("Retrying ad load in 5 seconds (attempt ${attempt + 1})");
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted) {
                    loadBanner(attempt: attempt + 1);
                  }
                });
              }
            }
          }),
          request: const AdRequest())
        ..load();
    } catch (e) {
      print("Error creating/loading BannerAd: $e");
      if (mounted) {
        setState(() {
          _isAdLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: blue_background,
        appBar: AppBar(
          leading: Container(
            width: 32,
            height: 32,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () async {
                setState(() {
                  showSimpleDialog(context);
                });
              },
              child: Center(
                child: SvgPicture.asset(
                  ImageAssets.menuIc,
                  fit: BoxFit.scaleDown,
                  width: 18, // Further reduced icon size
                  height: 18,
                  colorFilter: _isScrolled
                      ? ColorFilter.mode(ColorManager.white, BlendMode.srcIn)
                      : null,
                ),
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor:
              _isScrolled ? ColorManager.secondary : Colors.transparent,
          elevation: AppSize.s0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor:
                _isScrolled ? ColorManager.secondary : Colors.transparent,
            statusBarBrightness:
                _isScrolled ? Brightness.light : Brightness.dark,
            statusBarIconBrightness:
                _isScrolled ? Brightness.light : Brightness.dark,
          ),
          title: Text(
            "${AppStrings.appBarTitle}",
            style: TextStyle(
                color:
                    _isScrolled ? ColorManager.white : ColorManager.secondary,
                fontSize: FontSize.s20,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                padding: EdgeInsets.all(10),
                constraints: const BoxConstraints(),
                splashRadius: 18,
                onPressed: () async {
                  _showLogoutDialog();
                },
                tooltip: 'Logout',
                icon: Icon(
                  Icons.power_settings_new_outlined,
                  color:
                      _isScrolled ? ColorManager.white : ColorManager.secondary,
                  semanticLabel: 'Logout Button',
                ))
          ],
        ),
        bottomNavigationBar:
            (MySingleton.loggedInUser?.subscribed ?? false) == false &&
                    (adLoaded || _isAdLoading)
                ? Container(
                    color: Colors.white,
                    child: SafeArea(
                      top: false,
                      left: false,
                      right: false,
                      child: adLoaded && _bannerAd != null
                          ? Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              height: _bannerAd!.size.height.toDouble(),
                              child: AdWidget(ad: _bannerAd!))
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                                    SizedBox(width: 10),
                                    Text("Loading Ad..."),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  )
                : null,
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
                final isSubscribed =
                    MySingleton.loggedInUser?.subscribed ?? false;
                return Container(
                  child: isSubscribed
                      ? GridView.count(
                          controller: _scrollController,
                          crossAxisCount: 2,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          childAspectRatio: 0.85,
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
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
                              for (int i = 0; i < snapshot.data!.length; i++)
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child:
                                      _getResumeListItem(snapshot.data![i], i),
                                ),
                          ],
                        )
                      : GridView.count(
                          controller: _scrollController,
                          crossAxisCount: 2,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          childAspectRatio: 0.85,
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
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
                              for (int i = 0; i < snapshot.data!.length; i++)
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child:
                                      _getResumeListItem(snapshot.data![i], i),
                                ),
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
        title: "Resume", // Service will re-order and number this
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
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) {
        Widget cancelButton = TextButton(
          child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          onPressed: () {
            if (Navigator.canPop(dialogContext)) {
              Navigator.pop(dialogContext);
            }
          },
        );
        Widget deleteButton = TextButton(
          child: Text(
            "${AppStrings.delete.toUpperCase()}",
            style: TextStyle(color: ColorManager.error),
          ),
          onPressed: () async {
            final userId = MySingleton.userId;
            if (userId == null) {
              print("Cannot delete: not logged in.");
              if (Navigator.canPop(dialogContext)) Navigator.pop(dialogContext);
              return;
            }
            await _fireUser.deleteResume(userId: userId, resumeId: id);
            _getAllResumes();

            if (Navigator.canPop(dialogContext)) {
              Navigator.pop(dialogContext);
            }
          },
        );

        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          title: const Text("Are You Sure?",
              style: TextStyle(color: Colors.black)),
          content: const Text(
              "This action cannot be undone. Tap 'DELETE' to confirm.",
              style: TextStyle(color: Colors.black)),
          actions: [
            cancelButton,
            deleteButton,
          ],
        );
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
    return ScaleButton(
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
            const SizedBox(
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
    return ScaleButton(
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
            const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 45,
            ),
            const SizedBox(
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

    // Display stored title, fallback to "Resume" if null (shouldn't happen with new logic)
    String resumeTitle = resume.title ?? "Resume";

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: PopupMenuButton(
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
                textColor = ColorManager.secondary;
              });
            },
            onSelected: (String value) => value,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close PopupMenu first
                          _showRenameDialog(context, resume);
                        },
                        child: Text("Rename",
                            style: TextStyle(color: ColorManager.primary)),
                      ),
                      TextButton(
                        onPressed: () => _getCurrentUserDetails()
                            .then((_) => _getResumeById(resume.id)),
                        child: Text("Edit",
                            style: TextStyle(color: ColorManager.secondary)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close PopupMenu first
                          _deleteResume(context, resume.id);
                        },
                        child:
                            Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ];
            },
            child: Ink(
              decoration: BoxDecoration(
                color: backColor,
                border: Border.all(
                  color: ColorManager.secondary,
                  width: 3,
                ),
                boxShadow: const [BoxShadow(color: Colors.black38)],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: double.infinity, // Take full height of GridView cell
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                margin: const EdgeInsets.symmetric(vertical: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(icon, fit: BoxFit.scaleDown),
                    const SizedBox(height: 15),
                    Text(
                      resumeTitle,
                      style:
                          TextStyle(fontSize: FontSize.s16, color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
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

  void _showRenameDialog(BuildContext context, ResumeModel resume) {
    final TextEditingController controller =
        TextEditingController(text: resume.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Rename Resume"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter new name",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                final newTitle = controller.text.trim();
                if (newTitle.isNotEmpty && newTitle != resume.title) {
                  final userId = MySingleton.userId;
                  if (userId != null) {
                    await _fireUser.updateResumeTitle(
                      userId: userId,
                      resumeId: resume.id,
                      title: newTitle,
                    );
                    _getAllResumes();
                  }
                }
                Navigator.pop(context);
              },
              child: Text("Rename",
                  style: TextStyle(color: ColorManager.secondary)),
            ),
          ],
        );
      },
    );
  }
}

class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const ScaleButton({Key? key, required this.child, required this.onTap})
      : super(key: key);

  @override
  _ScaleButtonState createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
