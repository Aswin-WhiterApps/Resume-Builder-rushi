// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:resume_builder/Presentation/promotional_screen/promo2screen.dart';
// import 'package:resume_builder/Presentation/promotional_screen/promo_screen.dart';
// import 'package:resume_builder/Presentation/resources/assets_manager.dart';
// import 'package:resume_builder/Presentation/resources/route_manager.dart';
// import 'package:resume_builder/Presentation/resume_builder/tabs/additional_tab.dart';
// import 'package:resume_builder/Presentation/resume_builder/tabs/cl_templates_tab.dart';
// import 'package:resume_builder/Presentation/resume_builder/tabs/contacts_tab.dart';
// import 'package:resume_builder/Presentation/resume_builder/tabs/coverLetter_tab.dart';
// import 'package:resume_builder/Presentation/resume_builder/tabs/education_tab.dart';
// import 'package:resume_builder/Presentation/resume_builder/tabs/intro_tab.dart';
// import 'package:resume_builder/Presentation/resume_builder/tabs/sign_tab.dart';
// import 'package:resume_builder/Presentation/resume_builder/tabs/summary_tab.dart';
// import 'package:resume_builder/Presentation/resume_builder/tabs/templates_tab.dart';
// import 'package:resume_builder/Presentation/resume_builder/tabs/work_tab.dart';
// import 'package:resume_builder/blocs/work/work_bloc.dart';
// import 'package:resume_builder/blocs/work/work_event.dart';
// import 'package:resume_builder/generated/assets.dart';
// import 'package:resume_builder/menu/my_menu.dart';
// import 'package:resume_builder/model/model.dart';
// import 'package:resume_builder/shared_preference/shared_preferences.dart';
// import 'package:resume_builder/my_singleton.dart';
// import '../../firestore/user_firestore.dart';
// import '../resources/color_manager.dart';
// import '../resources/font_manager.dart';
// import '../resources/strings_manager.dart';
// import '../resources/values_manager.dart';
//
// class ResumeBuilderView extends StatefulWidget {
//   ResumeBuilderView({super.key});
//   @override
//   State<ResumeBuilderView> createState() => _ResumeBuilderViewState();
// }
//
// class _ResumeBuilderViewState extends State<ResumeBuilderView>
//     with TickerProviderStateMixin {
//   TabController? _tabController;
//   bool _isLoading = true; // Start in a loading state
//
//   final GlobalKey<IntroTabViewState> _introTabKey = GlobalKey<IntroTabViewState>();
//   final GlobalKey<ContactsTabViewState> _contactTabKey = GlobalKey<ContactsTabViewState>();
//   final GlobalKey<SummaryTabViewState> _summaryTabKey = GlobalKey<SummaryTabViewState>();
//
//   final FireUser _fireUser = FireUser();
//
//   @override
//   void initState() {
//     super.initState();
//     // --- FIX: Move all async and controller initialization to a separate method ---
//     _initializeScreen();
//   }
//
//   // --- FIX: New robust initialization method ---
//   void _initializeScreen() async {
//     // 1. Fetch all necessary asynchronous data first.
//     await _getCurrentUserDetails();
//
//     final userId = MySingleton.userId;
//     final resumeId = MySingleton.resumeId;
//
//     if (userId != null && resumeId != null) {
//       // It's safe to use context here because this is called from initState.
//       context.read<WorkBloc>().add(LoadWorkList(userId: userId, id: resumeId));
//     }
//
//     // 2. Now that all data is loaded, initialize the TabController.
//     _tabController = TabController(
//       initialIndex: MySingleton.currentIndex,
//       length: 10, // Total number of tabs
//       vsync: this,
//     );
//
//     _tabController!.addListener(() {
//       if (!_tabController!.indexIsChanging && mounted) {
//         setState(() {
//           MySingleton.currentIndex = _tabController!.index;
//           _setSkipVisibilty(currentIndex: _tabController!.index);
//         });
//       }
//     });
//
//     // 3. Update the state to stop loading and build the main UI.
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//         _setSkipVisibilty(currentIndex: MySingleton.currentIndex);
//       });
//     }
//   }
//
//   Future<void> _getCurrentUserDetails() async {
//     final uid = await SharedPrefHelper.getUserUid();
//     if (uid != null) {
//       MySingleton.loggedInUser = await _fireUser.getCurrentUser(uid);
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController?.dispose();
//     super.dispose();
//   }
//
//   // --- FIX: Logic corrected to be simpler and use Firestore ---
//   void _onPageChanged() async {
//     bool canProceed = true;
//     final userId = MySingleton.userId;
//     final resumeId = MySingleton.resumeId;
//
//     if (userId == null || resumeId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No active resume.")));
//       return;
//     }
//
//     if (MySingleton.currentIndex == 0) {
//       final introState = _introTabKey.currentState;
//       if (introState != null) {
//         final savedIntro = await introState.saveIntroData();
//         if (savedIntro == null || (savedIntro.firstName?.trim().isEmpty ?? true)) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("First name is required.")));
//           }
//           canProceed = false;
//         }
//       }
//     } else if (MySingleton.currentIndex == 1) {
//       final contactState = _contactTabKey.currentState;
//       if (contactState != null) {
//         contactState.saveContact();
//         final email = contactState.emailController.text.trim();
//         final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//         if (email.isEmpty || !emailRegex.hasMatch(email)) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A valid email is required.")));
//           }
//           canProceed = false;
//         }
//       }
//     }
//     // No validation is needed for the work tab here.
//
//     if (canProceed && MySingleton.currentIndex < tabList().length - 1) {
//       setState(() {
//         MySingleton.currentIndex++;
//         _setSkipVisibilty(currentIndex: MySingleton.currentIndex);
//         _tabController?.animateTo(MySingleton.currentIndex);
//       });
//     }
//   }
//
//   void _setSkipVisibilty({required int currentIndex}) {
//     // This logic is fine, but we wrap it in setState for safety.
//     setState(() {
//       if (currentIndex >= 2 && currentIndex <= 7) {
//         MySingleton.skipBtnVisible = true;
//       } else {
//         MySingleton.skipBtnVisible = false;
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // --- FIX: Show a loading indicator until the controller is ready ---
//     if (_isLoading || _tabController == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     // Once loading is complete, build the main scaffold.
//     return WillPopScope(
//       onWillPop: () async {
//         MySingleton.resumeId = null;
//         Navigator.pushReplacementNamed(context, Routes.homescreen);
//         return false;
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         appBar: AppBar(
//           leading: IconButton(
//               onPressed: () {
//                 MySingleton.resumeId = null;
//                 Navigator.pushReplacementNamed(context, Routes.homescreen);
//               },
//               icon: SvgPicture.asset(ImageAssets.backIc)),
//           centerTitle: true,
//           backgroundColor: Colors.white,
//           elevation: AppSize.s0,
//           systemOverlayStyle:  SystemUiOverlayStyle(
//             statusBarColor: ColorManager.white,
//             statusBarBrightness: Brightness.dark,
//             statusBarIconBrightness: Brightness.dark,
//           ),
//           title: Text(AppStrings.appBarTitle, style: TextStyle(color: Colors.black, fontSize: FontSize.s20, fontWeight: FontWeight.bold)),
//           actions: [
//             IconButton(
//                 onPressed: () => showSimpleDialog(context),
//                 icon: SvgPicture.asset(ImageAssets.menuIc)),
//           ],
//           bottom: TabBar(
//             tabs: tabList(),
//             isScrollable: true,
//             indicatorColor: Colors.transparent,
//             indicator: const BoxDecoration(),
//             controller: _tabController,
//             onTap: (index) {
//               setState(() {
//                 MySingleton.currentIndex = index;
//                 _setSkipVisibilty(currentIndex: index);
//               });
//             },
//           ),
//         ),
//         body: TabBarView(
//           physics: const NeverScrollableScrollPhysics(),
//           controller: _tabController,
//           children: tabsViewList(),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//         bottomSheet: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _getSkipButton(),
//             _getNextButton(),
//             const SizedBox(height: 50),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- HELPER WIDGETS ---
//   // (These are mostly unchanged but include null safety now)
//
//   List<Widget> tabList() => [
//     _getTab(pos: 0, title: AppStrings.t1, activeIc: ImageAssets.t1ActiveIc, inactiveIc: ImageAssets.t1InactiveIc),
//     _getTab(pos: 1, title: AppStrings.t2, activeIc: ImageAssets.t2ActiveIc, inactiveIc: ImageAssets.t2InactiveIc),
//     _getTab(pos: 2, title: AppStrings.t3, activeIc: ImageAssets.t3ActiveIc, inactiveIc: ImageAssets.t3InactiveIc),
//     _getTab(pos: 3, title: AppStrings.t4, activeIc: ImageAssets.t4ActiveIc, inactiveIc: ImageAssets.t4InactiveIc),
//     _getTab(pos: 4, title: AppStrings.t5, activeIc: ImageAssets.t5ActiveIc, inactiveIc: ImageAssets.t5InactiveIc),
//     _getTab(pos: 5, title: AppStrings.t6, activeIc: ImageAssets.t6ActiveIc, inactiveIc: ImageAssets.t6InactiveIc),
//     _getTab(pos: 6, title: AppStrings.t7, activeIc: (MySingleton.loggedInUser?.subscribed ?? false) ? ImageAssets.t7ActiveSubscribedIc : ImageAssets.t7ActiveUnubscribedIc, inactiveIc: (MySingleton.loggedInUser?.subscribed ?? false) ? ImageAssets.t7InactiveSubscribedIc : ImageAssets.t7InactiveUnsubscribedIc),
//     _getTab(pos: 7, title: AppStrings.t8, activeIc: (MySingleton.loggedInUser?.subscribed ?? false) ? ImageAssets.t8ActiveSubscribeIc : ImageAssets.t8ActiveUnsubscribeIc, inactiveIc: (MySingleton.loggedInUser?.subscribed ?? false) ? ImageAssets.t8InactiveSubscribedIc : ImageAssets.t8InactiveUnsubscribedIc),
//     _getTab(pos: 8, title: AppStrings.t9, activeIc: (MySingleton.loggedInUser?.subscribed ?? false) ? ImageAssets.t9ActiveSubscribedIc : ImageAssets.t9ActiveUnsubscribedIc, inactiveIc: (MySingleton.loggedInUser?.subscribed ?? false) ? ImageAssets.t9InactiveSubscribedIc : ImageAssets.t9InactiveUnsubscribedIc),
//     _getTab(pos: 9, title: AppStrings.t10, activeIc: (MySingleton.loggedInUser?.subscribed ?? false) ? ImageAssets.t10ActiveSubscribedIc : ImageAssets.t7ActiveUnubscribedIc, inactiveIc: (MySingleton.loggedInUser?.subscribed ?? false) ? ImageAssets.t7InactiveSubscribedIc : ImageAssets.t7InactiveUnsubscribedIc),
//   ];
//
//   List<Widget> tabsViewList() => [
//     IntroTabView(key: _introTabKey),
//     ContactsTabView(key: _contactTabKey),
//     EducationTabView(),
//     WorkTabView(),
//     SummaryTabView(key: _summaryTabKey),
//     AdditionalView(),
//     // --- FIX: Add promo screen fallbacks for unsubscribed users ---
//     (MySingleton.loggedInUser?.subscribed ?? false) ? CoverLetterTabView() : const Promo1View(),
//     (MySingleton.loggedInUser?.subscribed ?? false) ? SignTabView() : const Promo2View(),
//     TemplateTabView(),
//     (MySingleton.loggedInUser?.subscribed ?? false) ? CoverLetterTemplatesView() : const Promo1View(),
//   ];
//
//   Widget _getTab({required int pos, required String title, required String activeIc, required String inactiveIc}) {
//     bool isActive = MySingleton.currentIndex == pos;
//     return Tab(
//       iconMargin: EdgeInsets.zero,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SvgPicture.asset(isActive ? activeIc : inactiveIc),
//           const SizedBox(height: 4),
//           Text(title, style: TextStyle(color: isActive ? ColorManager.secondary : Colors.grey, fontSize: FontSize.s10)),
//           if (isActive) ...[
//             const SizedBox(height: 2),
//             SvgPicture.asset(Assets.imagesTabActiveBar),
//           ]
//         ],
//       ),
//     );
//   }
//
//   Widget _getSkipButton() {
//     return Visibility(
//       visible: MySingleton.skipBtnVisible,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: AppPadding.p4),
//         child: ElevatedButton(
//           onPressed: () {
//             if (MySingleton.currentIndex < tabList().length - 1) {
//               setState(() {
//                 MySingleton.currentIndex++;
//                 _setSkipVisibilty(currentIndex: MySingleton.currentIndex);
//                 _tabController?.animateTo(MySingleton.currentIndex);
//               });
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: ColorManager.skipBack,
//             elevation: AppSize.s0,
//             fixedSize: Size(MediaQuery.of(context).size.width, AppSize.s45),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
//           ),
//           child: Text(AppStrings.skip, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: FontSize.s20)),
//         ),
//       ),
//     );
//   }
//
//   Widget _getNextButton() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 18.0),
//       child: ElevatedButton(
//         onPressed: _onPageChanged,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: ColorManager.secondary,
//           elevation: AppSize.s0,
//           fixedSize: Size(MediaQuery.of(context).size.width, AppSize.s45),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
//         ),
//         child: Text(AppStrings.next, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: FontSize.s20)),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:resume_builder/DB/db.dart';
import 'package:resume_builder/Presentation/resources/assets_manager.dart';
import 'package:resume_builder/Presentation/resources/route_manager.dart';
import 'package:resume_builder/Presentation/resume_builder/tabs/additional_tab.dart';
import 'package:resume_builder/Presentation/resume_builder/tabs/cl_templates_tab.dart';
import 'package:resume_builder/Presentation/resume_builder/tabs/contacts_tab.dart';
import 'package:resume_builder/Presentation/resume_builder/tabs/coverLetter_tab.dart';
import 'package:resume_builder/Presentation/resume_builder/tabs/education_tab.dart';
import 'package:resume_builder/Presentation/resume_builder/tabs/intro_tab.dart';
import 'package:resume_builder/Presentation/resume_builder/tabs/sign_tab.dart';
import 'package:resume_builder/Presentation/resume_builder/tabs/summary_tab.dart';
import 'package:resume_builder/Presentation/resume_builder/tabs/templates_tab.dart';
import 'package:resume_builder/Presentation/resume_builder/tabs/work_tab.dart';
import 'package:resume_builder/blocs/work/work_bloc.dart';
import 'package:resume_builder/blocs/work/work_event.dart';
import 'package:resume_builder/generated/assets.dart';
import 'package:resume_builder/menu/my_menu.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/shared_preference/shared_preferences.dart';
import 'package:resume_builder/my_singleton.dart';
import '../../blocs/work/work_state.dart';
import '../../firestore/user_firestore.dart';
import '../../google_ads/ads.dart';
import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';

class ResumeBuilderView extends StatefulWidget {
  ResumeBuilderView({super.key});

  @override
  State<ResumeBuilderView> createState() => _ResumeBuilderViewState();
}

class _ResumeBuilderViewState extends State<ResumeBuilderView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final GlobalKey<IntroTabViewState> _introTabKey =
      GlobalKey<IntroTabViewState>();
  final GlobalKey<ContactsTabViewState> _contactTabKey =
      GlobalKey<ContactsTabViewState>();
  final GlobalKey<EducationTabViewState> _educationTabKey =
      GlobalKey<EducationTabViewState>();
  final GlobalKey<WorkTabViewState> _workTabKey = GlobalKey<WorkTabViewState>();
  final GlobalKey<SummaryTabViewState> _summaryTabKey =
      GlobalKey<SummaryTabViewState>();

  _ResumeBuilderViewState();

  late String id;

  final _sectionStreamController =
      StreamController<List<SectionModel>?>.broadcast();
  late List<SectionModel>? sectionsList;

  Future<bool> _workListIsEmpty() async {
    final list = await DbHelper.instance
        .getAllWork(MySingleton.userId!, MySingleton.resumeId!);
    return list == null || list.isEmpty;
  }

  List<Widget> tabList() => [
        _getTab(
            pos: 0,
            title: AppStrings.t1,
            activeIc: ImageAssets.t1ActiveIc,
            inactiveIc: ImageAssets.t1InactiveIc),
        _getTab(
            pos: 1,
            title: AppStrings.t2,
            activeIc: ImageAssets.t2ActiveIc,
            inactiveIc: ImageAssets.t2InactiveIc),
        _getTab(
            pos: 2,
            title: AppStrings.t3,
            activeIc: ImageAssets.t3ActiveIc,
            inactiveIc: ImageAssets.t3InactiveIc),
        _getTab(
            pos: 3,
            title: AppStrings.t4,
            activeIc: ImageAssets.t4ActiveIc,
            inactiveIc: ImageAssets.t4InactiveIc),
        _getTab(
            pos: 4,
            title: AppStrings.t5,
            activeIc: ImageAssets.t5ActiveIc,
            inactiveIc: ImageAssets.t5InactiveIc),
        _getTab(
            pos: 5,
            title: AppStrings.t6,
            activeIc: ImageAssets.t6ActiveIc,
            inactiveIc: ImageAssets.t6InactiveIc),
        _getTab(
            pos: 6,
            title: AppStrings.t8,
            activeIc: MySingleton.loggedInUser!.subscribed!
                ? ImageAssets.t8ActiveSubscribeIc
                : ImageAssets.t8ActiveUnsubscribeIc,
            inactiveIc: MySingleton.loggedInUser!.subscribed!
                ? ImageAssets.t8InactiveSubscribedIc
                : ImageAssets.t8InactiveUnsubscribedIc),
        _getTab(
            pos: 7,
            title: AppStrings.t9,
            activeIc: MySingleton.loggedInUser!.subscribed!
                ? ImageAssets.t9ActiveSubscribedIc
                : ImageAssets.t9ActiveUnsubscribedIc,
            inactiveIc: MySingleton.loggedInUser!.subscribed!
                ? ImageAssets.t9InactiveSubscribedIc
                : ImageAssets.t9InactiveUnsubscribedIc),
        _getTab(
            pos: 8,
            title: AppStrings.t7,
            activeIc: MySingleton.loggedInUser!.subscribed!
                ? ImageAssets.t7ActiveSubscribedIc
                : ImageAssets.t7ActiveUnubscribedIc,
            inactiveIc: MySingleton.loggedInUser!.subscribed!
                ? ImageAssets.t7InactiveSubscribedIc
                : ImageAssets.t7InactiveUnsubscribedIc),
        _getTab(
            pos: 9,
            title: AppStrings.t10,
            activeIc: MySingleton.loggedInUser!.subscribed!
                ? ImageAssets.t10ActiveSubscribedIc
                : ImageAssets.t7ActiveUnubscribedIc,
            inactiveIc: MySingleton.loggedInUser!.subscribed!
                ? ImageAssets.t7InactiveSubscribedIc
                : ImageAssets.t7InactiveUnsubscribedIc),
      ];

  List<Widget> tabsViewList() => [
        //intro Tab
        tab1(),
        tab2(),
        tab3(),
        tab4(),
        tab5(),
        tab6(),
        tab8(),
        tab9(),
        tab7(),
        tab10(),
      ];

  void initDb() async {
    await DbHelper.instance.database;
  }

  CreateAd createAd = CreateAd();

  @override
  void initState() {
    super.initState();
    _getCurrentUserDetails();
    id = MySingleton.resumeId!;
    initDb();
    _getAllSections();

    BlocProvider.of<WorkBloc>(context).add(
      LoadWorkList(userId: MySingleton.userId!, id: MySingleton.resumeId!),
    );

    _tabController = TabController(
      initialIndex: 0,
      length: tabList().length,
      vsync: this,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          MySingleton.currentIndex = _tabController.index;
        });
      }
    });

    MySingleton.loggedInUser!.subscribed!
        ? null
        : createAd.loadResumeBuilderAd();
    CreateAd.resumebuilderBanner.load();
  }

  Future<void> _getCurrentUserDetails() async {
    final uid = await SharedPrefHelper.getUserUid();
    if (uid != null) {
      MySingleton.loggedInUser = await FireUser().getCurrentUser(uid);
    }
  }

  Future<void> _getAllSections() async {
    sectionsList = await _returnAllSections();
    _sectionStreamController.sink
        .add(await DbHelper.instance.getAllSections(id: MySingleton.resumeId!));
  }

  Future<List<SectionModel>?> _returnAllSections() async {
    sectionsList =
        await DbHelper.instance.getAllSections(id: MySingleton.resumeId!);
    return sectionsList;
  }

  @override
  void dispose() {
    _tabController.dispose();
    MySingleton.currentIndex = 0;
    MySingleton.skipBtnVisible = false;
    CreateAd.resumebuilderBanner.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabList().length,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 10,
              onPressed: () {
                MySingleton.resumeId = null;
                Navigator.pushReplacementNamed(context, Routes.homescreen);
              },
              icon: SvgPicture.asset(ImageAssets.backIc)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: AppSize.s0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: ColorManager.white,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ),
          title: Text(
            AppStrings.appBarTitle,
            style: TextStyle(
                color: Colors.black,
                fontSize: FontSize.s20,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            //Menu Button
            IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 18,
                onPressed: () {
                  showSimpleDialog(context);
                },
                icon: SvgPicture.asset(ImageAssets.menuIc)),
          ],
          bottom: TabBar(
            tabs: tabList(),
            isScrollable: true,
            indicatorColor: Colors.blue,
            indicatorWeight: 1,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(),
            controller: _tabController,
            onTap: (index) {
              setState(() {
                MySingleton.currentIndex = index;
                _setSkipVisibilty(currentIndex: MySingleton.currentIndex);
              });
            },
          ),
        ),
        body: TabBarView(
          //  physics: AlwaysScrollableScrollPhysics(),
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: tabsViewList(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          color: Colors.white,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getSkipButton(),
                _getNextButton(),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTab(
      {required int pos,
      required String title,
      required String activeIc,
      required inactiveIc}) {
    return Tab(
        iconMargin: EdgeInsets.zero,
        child: Semantics(
          label: '$title Tab',
          selected: MySingleton.currentIndex == pos,
          child: MySingleton.currentIndex == pos
              ? Column(
                  children: [
                    SvgPicture.asset(
                      activeIc,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                          color: ColorManager.secondary,
                          fontSize: FontSize.s10),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    SvgPicture.asset(Assets.imagesTabActiveBar),
                  ],
                )
              : Column(
                  children: [
                    SvgPicture.asset(inactiveIc),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      title,
                      style:
                          TextStyle(color: Colors.grey, fontSize: FontSize.s10),
                    ),
                  ],
                ),
        ));
  }

  Widget _getSkipButton() {
    return Visibility(
      visible: MySingleton.skipBtnVisible,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: AppPadding.p4),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              MySingleton.currentIndex++;
              _setSkipVisibilty(currentIndex: MySingleton.currentIndex);
              _tabController.animateTo(MySingleton.currentIndex);
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.skipBack,
            elevation: AppSize.s0,
            fixedSize: Size(MediaQuery.of(context).size.width, AppSize.s45),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80.0)),
          ),
          // padding: EdgeInsets.all(0.0),
          child: Semantics(
            button: true,
            label: 'Skip Step',
            child: Container(
              // constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
              alignment: Alignment.center,
              child: Text(
                AppStrings.skip,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: FontSize.s20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: ElevatedButton(
        onPressed: _onPageChanged,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.secondary,
          elevation: AppSize.s0,
          fixedSize: Size(MediaQuery.of(context).size.width, AppSize.s45),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        ),
        // padding: EdgeInsets.all(0.0),
        child: Semantics(
          button: true,
          label: 'Next Step',
          child: Container(
            // constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
              AppStrings.next,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: FontSize.s20),
            ),
          ),
        ),
      ),
    );
  }

  void _onPageChanged() async {
    bool canProceed = true;

    if (MySingleton.currentIndex == 0) {
      final introState = _introTabKey.currentState;
      if (introState == null) {
        canProceed = false;
      } else {
        final savedIntro = await introState.saveIntroData();
        if (savedIntro == null || savedIntro.firstName!.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("First name is required!")),
            );
          }
          canProceed = false;
        }
      }
    } else if (MySingleton.currentIndex == 1) {
      final contactState = _contactTabKey.currentState;
      if (contactState == null) {
        canProceed = false;
      } else {
        // Trigger validation and save. This will show error messages in the UI if invalid.
        if (!contactState.validateAndSave()) {
          canProceed = false;
        }
      }
    } else if (MySingleton.currentIndex == 2) {
      String schName = MySingleton.schoolNameController.text.trim();
      String from = MySingleton.schoolFromController.text.trim();
      String to = MySingleton.schoolToController.text.trim();
      bool present = MySingleton.presentEdu;

      if (schName.isNotEmpty || from.isNotEmpty) {
        EducationModel education = EducationModel(
          id: id,
          schoolName: schName,
          dateFrom: from,
          dateTo: to,
          present: present,
        );
        DbHelper.instance.insertEducation(educationModel: education);
      }
    } else if (MySingleton.currentIndex == 3) {
      final currentState = context.read<WorkBloc>().state;

      if (currentState is WorkLoaded && currentState.works.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please add at least one work experience.")),
        );
        canProceed = false;
      }
    } else if (MySingleton.currentIndex == 4) {
      final summaryState = _summaryTabKey.currentState;
      if (summaryState == null) {
        canProceed = false;
      } else {
        summaryState.saveSummary(); // Trigger the save event
        print("Proceeding from Summary tab. Save triggered.");
      }
    } else if (MySingleton.currentIndex == 5) {
      List<SectionModel> additionalDetails = MySingleton.additionDetails;

      for (var i in additionalDetails) {
        DbHelper.instance.updateSectionDetails(sectionModel: i, resumeId: id);
      }
    } else if (MySingleton.currentIndex == 6) {
      // ✅ Cover Letter Tab Validation
      String text = MySingleton.coverLetterController.text.trim();

      if (text.isNotEmpty) {
        CoverLetterModel coverLetterModel = CoverLetterModel(
          id: id,
          text: text,
        );
        DbHelper.instance.insertCoverLetter(coverLetterModel: coverLetterModel);
      }
    }

    // ✅ Move to Next Tab
    // setState(() {
    //   MySingleton.currentIndex++;
    //   _setSkipVisibilty(currentIndex: MySingleton.currentIndex);
    //   _tabController.animateTo(MySingleton.currentIndex);
    // });
    // setState(() {
    //   MySingleton.currentIndex++;
    //   _setSkipVisibilty(currentIndex: MySingleton.currentIndex);
    //   _tabController.animateTo(MySingleton.currentIndex);
    // }

    if (canProceed && MySingleton.currentIndex < tabList().length - 1) {
      setState(() {
        MySingleton.currentIndex++;
        _setSkipVisibilty(currentIndex: MySingleton.currentIndex);
        _tabController.animateTo(MySingleton.currentIndex);
      });
    }
  }

  void _setSkipVisibilty({required int currentIndex}) {
    if (currentIndex >= 2 && currentIndex <= 7) {
      MySingleton.skipBtnVisible = true;
    } else {
      MySingleton.skipBtnVisible = false;
    }
  }

  Widget tab1() {
    return IntroTabView(key: _introTabKey);
  }

  Widget tab2() {
    return ContactsTabView(key: _contactTabKey);
  }

  Widget tab3() {
    return EducationTabView(key: _educationTabKey);
  }

  Widget tab4() {
    return WorkTabView(key: _workTabKey);
  }

  // Widget tab4() {
  //   return BlocProvider(
  //     create: (_) => WorkBloc(dbHelper: DbHelper.instance)
  //       ..add(LoadWorkList(MySingleton.resumeId!)),
  //     child: WorkTabView(),
  //   );
  // }

  Widget tab5() {
    return SummaryTabView(key: _summaryTabKey);
  }

  Widget tab6() {
    return AdditionalView(id: id);
  }

  Widget tab7() {
    return MySingleton.loggedInUser!.subscribed!
        ? CoverLetterTabView()
        : CoverLetterTabView();
  }

  Widget tab8() {
    return MySingleton.loggedInUser!.subscribed!
        ? SignTabView()
        : SignTabView();
  }

  Widget tab9() {
    return TemplateTabView();
  }

  Widget tab10() {
    return MySingleton.loggedInUser!.subscribed!
        ? CoverLetterTemplatesView()
        : CoverLetterTemplatesView();
  }
}
