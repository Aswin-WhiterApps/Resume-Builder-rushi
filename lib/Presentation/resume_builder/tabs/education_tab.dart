// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:resume_builder/DB/db.dart';
// import 'package:resume_builder/my_singleton.dart';

// import '../../../model/model.dart';
// import '../../resources/assets_manager.dart';
// import '../../resources/color_manager.dart';
// import '../../resources/font_manager.dart';
// import '../../resources/strings_manager.dart';
// import '../../resources/values_manager.dart';

// class EducationTabView extends StatefulWidget {
//   // String id;

//    EducationTabView({super.key});

//   @override
//   State<EducationTabView> createState() => _EducationTabViewState();
// }

// class _EducationTabViewState extends State<EducationTabView> {
//   // String id;
// //   List<EducationModel?>? _list = [];
// // StreamController<List<EducationModel?>?> _eduStreamcontroller = StreamController<List<EducationModel?>?>.broadcast();
//   late PageController controller=PageController(initialPage: MySingleton.initialEduPage!);
// Future<void> _getEducationList() async {

//  MySingleton.eduStreamcontroller.sink.add(await DbHelper.instance.getAllEducations(MySingleton.resumeId!));

// }

// // List<Widget> pages() => [_getEductionList(_list),_getEducationForm()];
// int _curr=0;
// @override
//   void initState() {
//   _getEducationList();
//     // TODO: implement initState
//     super.initState();

//   }
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     MySingleton.initialEduPage = null;
//     controller.dispose();
//     // _controller.close();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//     resizeToAvoidBottomInset: false, // This Avoids the overlapping error of floating action button
//      body: StreamBuilder(
//           stream: MySingleton.eduStreamcontroller.stream,
//           builder: (BuildContext context,AsyncSnapshot<List<EducationModel?>?> snapshot){
//             if(snapshot.hasData){
//               MySingleton.initialEduPage = 1;
//               return  PageView(
//               // physics: AlwaysScrollableScrollPhysics(),
//                 pageSnapping: false,
//                 children:[
//                   _getEductionList(),
//                   _getEducationForm(),
//                   _getEducationFormEdit()
//                 ],
//                 scrollDirection: Axis.horizontal,

//                  reverse: true,
//                  physics: BouncingScrollPhysics(),
//                 controller: controller,
//                 onPageChanged: (num){
//                   setState(() {
//                     _curr=num;
//                   });
//                 },
//               );
//             }else if(!snapshot.hasData){
//               MySingleton.initialEduPage = 0;
//               return PageView(
//                // physics: AlwaysScrollableScrollPhysics(),
//                 pageSnapping: false,
//                 children:[
//                   _getEductionList(),
//                   _getEducationForm(),
//                   _getEducationFormEdit()
//                 ],
//                 scrollDirection: Axis.horizontal,

//                  reverse: true,
//                  physics: BouncingScrollPhysics(),
//                 controller: controller,
//                 onPageChanged: (num){
//                   setState(() {
//                     _curr=num;
//                   });
//                 },
//               );;
//             }else
//               return Center(child: Text("Something Went Wrong"),);
//       }),

//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 160),
//         child: _getAddInstitutionButton(context: context),
//       ),
//     );
//   }

//   Widget _getEductionList(){
//     return
//       FutureBuilder(
//           future: DbHelper.instance.getAllEducations(MySingleton.resumeId!),
//           builder: (BuildContext context,AsyncSnapshot<List<EducationModel?>?> snapshot){
//             if(snapshot.hasData ){
//               return  Container(
//                 margin: EdgeInsets.symmetric(vertical: AppPadding.p12),
//                 color: ColorManager.tabBackground,
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.all(AppSize.s16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         for(int i = 0; i<snapshot.data!.length;i++)
//                           Container(
//                             margin: EdgeInsets.symmetric(vertical: AppPadding.p8),
//                             padding: EdgeInsets.all(AppPadding.p12),
//                             // height: 200,
//                             width: MediaQuery.of(context).size.width,
//                             decoration: BoxDecoration(
//                               color: ColorManager.white,
//                               borderRadius: BorderRadius.circular(20),
//                               boxShadow: [
//                                 BoxShadow(
//                                     blurRadius: 5,
//                                     color: Colors.black38,
//                                     offset: Offset.fromDirection(2, 2))
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: AppPadding.p12),
//                                   child: Text(snapshot.data![i]!.schoolName!,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: FontSize.s20),),
//                                 ),
//                                 SizedBox(height: FontSize.s10,),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Row(children: [
//                                       TextButton(
//                                           onPressed: () async {
//                                             print("Eductaion SubId is ${snapshot.data![i]!.eid!}");
//                                         // EducationModel? education =  await DbHelper.instance.getSingleEducation(snapshot.data![i]!.id!, snapshot.data![i]!.eid!);
//                                         MySingleton.eid = snapshot.data![i]!.eid!;
//                                         MySingleton.presentEdu=snapshot.data![i]!.present!;
//                                         MySingleton.schoolToController.text = snapshot.data![i]!.dateTo!;
//                                         MySingleton.schoolNameController.text = snapshot.data![i]!.schoolName!;
//                                         MySingleton.schoolFromController.text = snapshot.data![i]!.dateFrom!;
//                                         controller.jumpToPage(2);
//                                       }, child: Text(AppStrings.edit,style: TextStyle(color: ColorManager.secondary,fontWeight:FontWeight.bold),)),

//                                       TextButton(onPressed: () async {

//                                       showDeleteDialog(context,educationModel:snapshot.data![i]!);
//                                       MySingleton.eduStreamcontroller.sink.add(await DbHelper.instance.getAllEducations(MySingleton.resumeId!));

//                                       }, child: Text(AppStrings.delete,style: TextStyle(color: ColorManager.secondary,fontWeight:FontWeight.bold),)),
//                                     ],),
//                                     Row(children: [
//                                       IconButton(onPressed: () async {

//                                         EducationModel temp = EducationModel(
//                                           id: snapshot.data![i]!.id!,
//                                           eid: snapshot.data![i]!.eid!,
//                                           schoolName: snapshot.data![i+1]!.schoolName!,
//                                           dateFrom:  snapshot.data![i+1]!.dateFrom!,
//                                           dateTo:  snapshot.data![i+1]!.dateTo!,
//                                             present: snapshot.data![i+1]!.present!
//                                         );

//                                         EducationModel currDataSwapNext = EducationModel(
//                                             id: snapshot.data![i]!.id!,
//                                             eid: snapshot.data![i]!.eid!+1,
//                                             schoolName: snapshot.data![i]!.schoolName!,
//                                             dateFrom:  snapshot.data![i]!.dateFrom!,
//                                             dateTo:  snapshot.data![i]!.dateTo!,
//                                             present: snapshot.data![i]!.present!
//                                         );

//                                         DbHelper.instance.insertEducation(educationModel: currDataSwapNext);
//                                         DbHelper.instance.insertEducation(educationModel: temp);
//                                         MySingleton.eduStreamcontroller.sink.add(await DbHelper.instance.getAllEducations(MySingleton.resumeId!));
//                                         // _getEducationList();

//                                       }, icon: Icon(Icons.arrow_downward_outlined,color: ColorManager.secondary,)),
//                                       IconButton(onPressed: () async {
//                                         EducationModel temp = EducationModel(
//                                             id: snapshot.data![i]!.id!,
//                                             eid: snapshot.data![i]!.eid!,
//                                             schoolName: snapshot.data![i-1]!.schoolName!,
//                                             dateFrom:  snapshot.data![i-1]!.dateFrom!,
//                                             dateTo:  snapshot.data![i-1]!.dateTo!,
//                                             present: snapshot.data![i-1]!.present!
//                                         );
//                                         EducationModel currDataSwapPrev = EducationModel(
//                                             id: snapshot.data![i]!.id!,
//                                             eid: snapshot.data![i]!.eid!-1,
//                                             schoolName: snapshot.data![i]!.schoolName!,
//                                             dateFrom:  snapshot.data![i]!.dateFrom!,
//                                             dateTo:  snapshot.data![i]!.dateTo!,
//                                             present: snapshot.data![i]!.present!
//                                         );
//                                         DbHelper.instance.insertEducation(educationModel: currDataSwapPrev);
//                                         DbHelper.instance.insertEducation(educationModel: temp);
//                                         MySingleton.eduStreamcontroller.sink.add(await DbHelper.instance.getAllEducations(MySingleton.resumeId!));
//                                         // _getEducationList();
//                                       }, icon: Icon(Icons.arrow_upward_outlined,color: ColorManager.secondary,)),
//                                     ],),
//                                   ],),

//                               ],
//                             ),
//                           ),
//                         SizedBox(
//                           height: 200,
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }else if(!snapshot.hasData){
//               return _getEducationForm();
//             }else
//               return Center(child: Text("SomeThing Went Wrong"),);

//     });

//   }
//   showDeleteDialog(BuildContext context,{required EducationModel educationModel}) {  // set up the buttons
//     Widget cancelButton = TextButton(
//       child: Text("Cancel",style: TextStyle(color: Colors.black)),
//       onPressed:  () async {
//         Navigator.pop(context);
//         MySingleton.eduStreamcontroller.sink.add(await DbHelper.instance.getAllEducations(MySingleton.resumeId!));
//       },
//     );
//     Widget deleteButton = TextButton(
//       child: Text("${AppStrings.delete.toUpperCase()}",style: TextStyle(color: ColorManager.primary),),
//       onPressed:  () async {
//         await DbHelper.instance.removeSingleEducation(id: MySingleton.resumeId!, eid: educationModel.eid!);
//         // _getEducationList();
//         Navigator.pop(context);
//         MySingleton.eduStreamcontroller.sink.add(await DbHelper.instance.getAllEducations(MySingleton.resumeId!));
//       },
//     );  // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
//       title: Text("Are You Sure?",style: TextStyle(color: Colors.black)),
//       content: Text("This action cannot be undone.Tap 'DELETE' to confirm.",style: TextStyle(color: Colors.black)),
//       actions: [
//         cancelButton,
//         deleteButton,
//       ],
//     );  // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//   Widget _getEducationForm()
//   {
//    return Container(
//       color: ColorManager.tabBackground,
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(AppSize.s16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               Container(
//                 // height: 200,
//                 width: MediaQuery.of(context).size.width,
//                 decoration: BoxDecoration(
//                   color: ColorManager.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                         blurRadius: 5,
//                         color: Colors.black38,
//                         offset: Offset.fromDirection(2, 2))
//                   ],
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     left: AppSize.s8,
//                     right: AppSize.s8,
//                     top: AppPadding.p30,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _getInputTextField(
//                           textEditingController: MySingleton.schoolNameController,
//                           question: AppStrings.whtSchool,
//                           hint: AppStrings.whtSchoolHint),
//                       SizedBox(
//                         height: AppSize.s20,
//                       ),
//                       _getInputTextField(
//                           textEditingController: MySingleton.schoolFromController,
//                           question: AppStrings.attendedFrom,
//                           hint: AppStrings.attendedFromHint),
//                       Padding(
//                         padding: EdgeInsets.all(AppPadding.p8),
//                         child: Text(
//                           AppStrings.exDate,
//                           style: TextStyle(
//                               color: Colors.grey, fontSize: FontSize.s12),
//                         ),
//                       ),
//                       SizedBox(
//                         height: AppSize.s20,
//                       ),
//                       _getInputTextField(
//                           textEditingController: MySingleton.schoolToController,
//                           question: AppStrings.to,
//                           hint: AppStrings.attendedFromHint),
//                       const SizedBox(
//                         height: AppSize.s20,
//                       ),
//                       Row(
//                         children: [
//                           Switch(
//                             value: MySingleton.presentEdu,
//                             activeColor: ColorManager.primary,
//                             activeTrackColor:
//                             ColorManager.primaryOpacity70.withOpacity(0.3),
//                             inactiveThumbColor: Colors.white,
//                             inactiveTrackColor: ColorManager.tabBackground,
//                             onChanged: (bool value) {
//                               setState(() {
//                                 MySingleton.presentEdu = value;
//                                 print("Education present $MySingleton.presentEdu");
//                               });
//                             },
//                           ),
//                           Text(
//                             AppStrings.present,
//                             style: TextStyle(
//                                 color: Colors.black, fontSize: FontSize.s12),
//                           ),
//                         ],
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.only(
//                             left: AppPadding.p8,
//                             right: AppPadding.p8,
//                             bottom: AppPadding.p18,
//                             top: AppPadding.p18),
//                         child: Text(
//                           AppStrings.educationScreenText,
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: FontSize.s12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 100,
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _getEducationFormEdit()
//   {
//     return Container(
//       color: ColorManager.tabBackground,
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(AppSize.s16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 // height: 200,
//                 width: MediaQuery.of(context).size.width,
//                 decoration: BoxDecoration(
//                   color: ColorManager.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                         blurRadius: 5,
//                         color: Colors.black38,
//                         offset: Offset.fromDirection(2, 2))
//                   ],
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     left: AppSize.s8,
//                     right: AppSize.s8,
//                     top: AppPadding.p30,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _getInputTextField(
//                           textEditingController: MySingleton.schoolNameController,
//                           question: AppStrings.whtSchool,
//                           hint: AppStrings.whtSchoolHint),
//                       SizedBox(
//                         height: AppSize.s20,
//                       ),
//                       _getInputTextField(
//                           textEditingController: MySingleton.schoolFromController,
//                           question: AppStrings.attendedFrom,
//                           hint: AppStrings.attendedFromHint),
//                       Padding(
//                         padding: EdgeInsets.all(AppPadding.p8),
//                         child: Text(
//                           AppStrings.exDate,
//                           style: TextStyle(
//                               color: Colors.grey, fontSize: FontSize.s12),
//                         ),
//                       ),
//                       SizedBox(
//                         height: AppSize.s20,
//                       ),
//                       _getInputTextField(
//                           textEditingController: MySingleton.schoolToController,
//                           question: AppStrings.to,
//                           hint: AppStrings.attendedFromHint),
//                       const SizedBox(
//                         height: AppSize.s20,
//                       ),
//                       Row(
//                         children: [
//                           Switch(
//                             value: MySingleton.presentEdu,
//                             activeColor: ColorManager.primary,
//                             activeTrackColor:
//                             ColorManager.primaryOpacity70.withOpacity(0.3),
//                             inactiveThumbColor: Colors.white,
//                             inactiveTrackColor: ColorManager.tabBackground,
//                             onChanged: (bool value) {
//                               setState(() {
//                                 MySingleton.presentEdu = value;
//                                 print("Education present $MySingleton.presentEdu");
//                               });
//                             },
//                           ),
//                           Text(
//                             AppStrings.present,
//                             style: TextStyle(
//                                 color: Colors.black, fontSize: FontSize.s12),
//                           ),
//                         ],
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.only(
//                             left: AppPadding.p8,
//                             right: AppPadding.p8,
//                             bottom: AppPadding.p18,
//                             top: AppPadding.p18),
//                         child: Text(
//                           AppStrings.educationScreenText,
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: FontSize.s12,
//                           ),
//                         ),
//                       ),
//                        Padding(
//                         padding: const EdgeInsets.only(
//                             left: AppPadding.p8,
//                             right: AppPadding.p8,
//                             bottom: AppPadding.p18,
//                             top: AppPadding.p18),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                           TextButton(onPressed: (){
//                             MySingleton.presentEdu=false;
//                             MySingleton.schoolToController.clear();
//                             MySingleton.schoolNameController.clear();
//                             MySingleton.schoolFromController.clear();
//                             controller.jumpToPage(0);
//                           }, child: Text(AppStrings.cancel,style: TextStyle(color: ColorManager.primary),),),

//                           SizedBox(width: 20,),

//                           TextButton(onPressed: () async {

//                             EducationModel education;
//                             String schName, from, to;
//                             bool present = MySingleton.presentEdu;
//                             schName = MySingleton.schoolNameController.text.toString();
//                             from = MySingleton.schoolFromController.text.toString();
//                             to = MySingleton.schoolToController.text.toString();
//                             education = EducationModel(
//                                 id: MySingleton.resumeId!,
//                                 eid: MySingleton.eid!,
//                                 schoolName: schName,
//                                 dateFrom: from,
//                                 dateTo: to,
//                                 present: present);
//                             DbHelper.instance.insertEducation(educationModel: education);
//                             // _list.clear();

//                             // _controller.sink.add(await DbHelper.instance.getAllEducations(MySingleton.resumeId!));
//                             MySingleton.presentEdu=false;
//                             MySingleton.schoolToController.clear();
//                             MySingleton.schoolNameController.clear();
//                             MySingleton.schoolFromController.clear();

//                             controller.jumpToPage(0);

//                           }, child: Text(AppStrings.edit,style: TextStyle(color: ColorManager.primary),),),
//                         ],)
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 100,
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _getInputTextField(
//       {required TextEditingController textEditingController,
//         required String question,
//         required String hint}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           question,
//           style: TextStyle(color: Colors.black, fontSize: FontSize.s12),
//         ),
//         TextField(
//           controller: textEditingController,
//           style: TextStyle(
//               color: Colors.black,
//               fontSize: FontSize.s20,
//               fontWeight: FontWeight.normal),
//           decoration: InputDecoration(
//             hintText: "  ${hint}",
//             hintStyle: TextStyle(
//                 color: Colors.grey,
//                 fontSize: FontSize.s20,
//                 fontWeight: FontWeight.normal),
//             enabledBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.grey), //<-- SEE HERE
//             ),
//             focusedBorder: UnderlineInputBorder(
//               borderSide:
//               BorderSide(color: ColorManager.primary), //<-- SEE HERE
//             ),
//             border: UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.grey), //<-- SEE HERE
//             ),
//           ),
//         ),
//       ],
//     );
//   }

// Widget _getAddInstitutionButton({required BuildContext context}) {
//   return Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: Container(
//       // margin: EdgeInsets.only(bottom: 170),
//       child: InkWell(
//         onTap: () async {
//           EducationModel education;
//           String schName, from, to;
//           bool present = MySingleton.presentEdu;
//           schName = MySingleton.schoolNameController.text.toString();
//           from = MySingleton.schoolFromController.text.toString();
//           to = MySingleton.schoolToController.text.toString();
//           if(schName != null && schName.isNotEmpty){
//             education = EducationModel(
//                 id: MySingleton.resumeId!,
//                 schoolName: schName,
//                 dateFrom: from,
//                 dateTo: to,
//                 present: present);
//             DbHelper.instance.insertEducation(educationModel: education);
//             MySingleton.presentEdu=false;
//             MySingleton.schoolToController.clear();
//             MySingleton.schoolNameController.clear();
//             MySingleton.schoolFromController.clear();

//           }
//           setState(() {
//             // _getEducationList();
//             controller.jumpToPage(1);
//           });
//           MySingleton.eduStreamcontroller.sink.add(await DbHelper.instance.getAllEducations(MySingleton.resumeId!));
//         },
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SvgPicture.asset(ImageAssets.addSectIc),
//            SizedBox(width: 10,),
//            Text(AppStrings.addinstitution,style: TextStyle(color: ColorManager.secondary,fontWeight: FontWeight.w500),),
//           ],
//         ),
//       ),
//     ),
//   );
// }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:resume_builder/my_singleton.dart';
import '../../../firestore/user_firestore.dart';
import '../../../model/model.dart';
import '../../resources/assets_manager.dart';
import '../../resources/color_manager.dart';
import '../../resources/font_manager.dart';
import '../../resources/strings_manager.dart';
import '../../resources/values_manager.dart';

class EducationTabView extends StatefulWidget {
  EducationTabView({super.key});

  @override
  State<EducationTabView> createState() => EducationTabViewState();
}

class EducationTabViewState extends State<EducationTabView> {
  List<EducationModel> _educationList = [];
  final _formKey = MySingleton.EducaionFormKey;

  final FireUser _fireUser = FireUser();

  @override
  void initState() {
    _fetchEducationList();
    super.initState();
  }

  Future<void> _fetchEducationList() async {
    String id = MySingleton.resumeId!;
    final userId = MySingleton.userId!;
    List<EducationModel> list =
        await _fireUser.getEducations(userId: userId, resumeId: id);
    //List<EducationModel?>? list = await DbHelper.instance.getAllEducations(id);

    setState(() {
      _educationList = (list
              .where((education) => education != null)
              .cast<EducationModel>()
              .toList());
      // Sort by sortOrder to ensure correct order
      _educationList
          .sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

      // Ensure all items have unique sequential sortOrder values
      // This guarantees that swapping will work correctly
      for (int i = 0; i < _educationList.length; i++) {
        final currentItem = _educationList[i];
        // Assign sequential sortOrder values based on current position
        if (currentItem.sortOrder != i) {
          _educationList[i] = EducationModel(
            id: currentItem.id,
            eid: currentItem.eid,
            schoolName: currentItem.schoolName,
            dateFrom: currentItem.dateFrom,
            dateTo: currentItem.dateTo,
            present: currentItem.present,
            sortOrder: i,
          );
        }
      }
    });
  }

  void _showEducationForm({EducationModel? education}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EducationForm(
        education: education,
        onSave: () {
          Navigator.pop(context);
          _fetchEducationList();
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String eid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content:
              Text("This action cannot be undone. Tap 'Delete' to confirm."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteEducation(eid);
              },
              child: Text("DELETE", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // void _deleteEducation(String eid) async {
  //   await DbHelper.instance
  //       .removeSingleEducation(eid: eid, id: MySingleton.resumeId!);
  //   _fetchEducationList();
  // }

  void _deleteEducation(String educationId) async {
    final userId = MySingleton.userId!;
    final resumeId = MySingleton.resumeId!;
    await _fireUser.deleteEducation(
        userId: userId, resumeId: resumeId, educationId: educationId);
    _fetchEducationList();
  }

/*
  Future<void> _selectDate(TextEditingController controller) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primaryColor: Colors.blue,
            hintColor: Colors.blueAccent,
            dialogBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedDate =
          "${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      controller.text = formattedDate;
    }
  }
*/

  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 2) {
        final month = int.parse(parts[0]);
        final year = int.parse(parts[1]);
        return DateTime(year, month);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> _selectMonthYear(
      BuildContext context, TextEditingController controller,
      {DateTime? minDate}) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: minDate ?? DateTime(1950),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorManager.secondary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedDate =
          "${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      controller.text = formattedDate;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorManager.tabBackground,
        body: Stack(
         
          children: [
          _educationList.isEmpty
              ? Container(
                  child: Padding(
                      padding: EdgeInsets.only(
                        top: 16,
                      ),
                      child: _getEducationForm()))
              : Padding(
                  padding:
                      EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 26),
                      
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 150,
                    ),
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: _educationList.length,
                    itemBuilder: (context, index) {
                      EducationModel education = _educationList[index];

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: AppPadding.p8),
                        padding: EdgeInsets.all(AppPadding.p12),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: ColorManager.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 5,
                                color: Colors.black38,
                                offset: Offset.fromDirection(2, 2))
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: AppPadding.p12,
                              top: 7,
                              bottom: AppPadding.p12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                education.schoolName!,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: FontSize.s20),
                              ),
                              SizedBox(
                                height: FontSize.s18,
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showEducationForm(
                                        education: education),
                                    child: Text(
                                      AppStrings.edit,
                                      style: TextStyle(
                                          color: ColorManager.secondary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: FontSize.s35,
                                  ),
                                  GestureDetector(
                                    onTap: () => _showDeleteConfirmationDialog(
                                        context, education.id),
                                    child: Text(
                                      AppStrings.delete,
                                      style: TextStyle(
                                        color: ColorManager.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                      onPressed:
                                          index == _educationList.length - 1
                                              ? null
                                              : () => _moveDown(index),
                                      icon: Icon(
                                        Icons.arrow_downward_outlined,
                                        color:
                                            index == _educationList.length - 1
                                                ? Colors.grey
                                                : ColorManager.secondary,
                                      )),
                                  IconButton(
                                    onPressed: index == 0
                                        ? null
                                        : () => _moveUp(index),
                                    icon: Icon(
                                      Icons.arrow_upward_outlined,
                                      color: index == 0
                                          ? Colors.grey
                                          : ColorManager.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                      
                ),
              
          if (_educationList.isNotEmpty)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: FloatingActionButton.extended(
                  onPressed: () => _showEducationForm(),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  icon: SvgPicture.asset(
                    ImageAssets.addSectIc,
                    height: 24,
                    color: ColorManager.secondary,
                  ),
                  label: Text(
                    AppStrings.addinstitution,
                    style: TextStyle(
                      color: ColorManager.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ]));
  }

  Widget _getEducationForm() {
    return LayoutBuilder(
      
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.only(
                  left: AppSize.s16, right: AppSize.s16, bottom: AppSize.s16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: ColorManager.white,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _getInputTextField(
                                textEditingController:
                                    MySingleton.schoolNameController,
                                question: AppStrings.whtSchool,
                                hint: AppStrings.whtSchoolHint,
                                isRequired: true),
                            SizedBox(height: AppSize.s20),
                            GestureDetector(
                              onTap: () => _selectMonthYear(
                                context,
                                MySingleton.schoolFromController,
                              ),
                              child: AbsorbPointer(
                                child: _getInputTextField(
                                  textEditingController:
                                      MySingleton.schoolFromController,
                                  question: AppStrings.attendedFrom,
                                  hint: AppStrings.attendedFromHint,
                                  isRequired: true,
                                ),
                              ),
                            ),
                            // ...inside the _getWorkForm() column, replace this block:
                            SizedBox(height: AppSize.s4),
                            GestureDetector(
                              onTap: () {
                                if (MySingleton
                                    .schoolFromController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Please select 'From' date first")),
                                  );
                                  return;
                                }
                                final fromDate = _parseDate(
                                    MySingleton.schoolFromController.text);
                                if (fromDate == null) return;

                                _selectMonthYear(
                                  context,
                                  MySingleton.schoolToController,
                                  minDate: fromDate,
                                );
                              },
                              child: AbsorbPointer(
                                child: _getInputTextField(
                                  textEditingController:
                                      MySingleton.schoolToController,
                                  question: AppStrings.to,
                                  hint: AppStrings.attendedFromHint,
                                  isEnabled: !MySingleton.presentEdu,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Switch(
                                  value: MySingleton.presentEdu,
                                  activeColor: ColorManager.secondary,
                                  activeTrackColor:
                                      ColorManager.secondary.withOpacity(0.3),
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor:
                                      ColorManager.tabBackground,
                                  onChanged: (bool value) {
                                    setState(() {
                                      MySingleton.presentEdu = value;
                                      if (value) {
                                        MySingleton.schoolToController.clear();
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  AppStrings.present,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: FontSize.s12),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppPadding.p18, top: AppPadding.p18),
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorManager.secondary,
                                  ),
                                  onPressed: () async {
                                    if (MySingleton
                                        .EducaionFormKey.currentState!
                                        .validate()) {
                                      // Validate date range
                                      /*if (!MySingleton.presentEdu &&
                                          MySingleton.schoolToController.text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text("Please select an end date or check 'Present'")),
                                        );
                                        return;
                                      }*/

                                      final fromDate = _parseDate(MySingleton
                                          .schoolFromController.text);
                                      final toDate = _parseDate(
                                          MySingleton.schoolToController.text);

                                      if (!MySingleton.presentEdu &&
                                          fromDate != null &&
                                          toDate != null &&
                                          toDate.isBefore(fromDate)) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "End date cannot be before start date")),
                                        );
                                        return;
                                      }

                                      EducationModel education = EducationModel(
                                        id: MySingleton.resumeId!,
                                        schoolName: MySingleton
                                            .schoolNameController.text,
                                        dateFrom: MySingleton
                                            .schoolFromController.text,
                                        dateTo:
                                            MySingleton.schoolToController.text,
                                        present: MySingleton.presentEdu,
                                      );

                                      // await DbHelper.instance
                                      //     .insertEducation(educationModel: education);
                                      final userId = MySingleton.userId!;
                                      await _fireUser.addEducation(
                                          userId: userId,
                                          resumeId: MySingleton.resumeId!,
                                          education: education);
                                      _fetchEducationList();

                                      MySingleton.schoolNameController.clear();
                                      MySingleton.schoolFromController.clear();
                                      MySingleton.schoolToController.clear();
                                      setState(
                                          () => MySingleton.presentEdu = false);
                                    }
                                  },
                                  child: Text(
                                    "Save",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 100,
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

  Widget _getInputTextField({
    required TextEditingController textEditingController,
    required String question,
    required String hint,
    bool isRequired = false,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
              color: Colors.black,
              fontSize: FontSize.s14,
              fontWeight: FontWeight.bold),
        ),
        TextFormField(
          controller: textEditingController,
          enabled: isEnabled,
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
          style: TextStyle(
              color: Colors.black,
              fontSize: FontSize.s20,
              fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            hintText: "  $hint",
            hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: FontSize.s20,
                fontWeight: FontWeight.normal),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorManager.secondary)),
          ),
        ),
      ],
    );
  }

  // void _moveUp(int index) async {
  //   if (index > 0) {
  //     setState(() {
  //       final temp = _educationList[index];
  //       _educationList[index] = _educationList[index - 1];
  //       _educationList[index - 1] = temp;
  //     });
  //
  //     // update sortOrder in DB
  //     await DbHelper.instance
  //         .updateEducationSortOrder(_educationList[index].eid!, index);
  //     await DbHelper.instance
  //         .updateEducationSortOrder(_educationList[index - 1].eid! as int, index - 1);
  //   }
  // }
  //
  // void _moveDown(int index) async {
  //   if (index < _educationList.length - 1) {
  //     setState(() {
  //       final temp = _educationList[index];
  //       _educationList[index] = _educationList[index + 1];
  //       _educationList[index + 1] = temp;
  //     });
  //
  //     // update sortOrder in DB
  //     await DbHelper.instance
  //         .updateEducationSortOrder(_educationList[index].eid! as int, index);
  //     await DbHelper.instance
  //         .updateEducationSortOrder(_educationList[index + 1].eid! as int, index + 1);
  //   }
  // }

// In _education_tab.dart

  void _moveUp(int index) async {
    if (index > 0) {
      final userId = MySingleton.userId!;
      final resumeId = MySingleton.resumeId!;

      // Get the two items to swap
      final itemA = _educationList[index];
      final itemB = _educationList[index - 1];

      // Get their actual current sort orders from the list items
      // If null or same, use their current indices to ensure unique values
      int sortOrderA = itemA.sortOrder ?? index;
      int sortOrderB = itemB.sortOrder ?? (index - 1);

      // If sortOrders are the same, assign based on current position
      // This ensures swapping will actually change positions
      if (sortOrderA == sortOrderB) {
        sortOrderA = index;
        sortOrderB = index - 1;
      }

      // Store original list for potential rollback
      final originalList = List<EducationModel>.from(_educationList);

      // Optimistically update the UI immediately
      final newList = List<EducationModel>.from(_educationList);

      // Find items by ID to update (more reliable than using index)
      final indexA = newList.indexWhere((e) => e.id == itemA.id);
      final indexB = newList.indexWhere((e) => e.id == itemB.id);

      if (indexA != -1 && indexB != -1) {
        // Update items with swapped sort orders
        newList[indexA] = EducationModel(
          id: itemA.id,
          eid: itemA.eid,
          schoolName: itemA.schoolName,
          dateFrom: itemA.dateFrom,
          dateTo: itemA.dateTo,
          present: itemA.present,
          sortOrder: sortOrderB,
        );
        newList[indexB] = EducationModel(
          id: itemB.id,
          eid: itemB.eid,
          schoolName: itemB.schoolName,
          dateFrom: itemB.dateFrom,
          dateTo: itemB.dateTo,
          present: itemB.present,
          sortOrder: sortOrderA,
        );
      }

      // Sort by sortOrder and update UI
      newList.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
      setState(() {
        _educationList = newList;
      });

      // Then sync with Firestore
      try {
        await _fireUser.updateEducationSortOrder(
            userId: userId,
            resumeId: resumeId,
            educationId: itemA.id,
            newSortOrder: sortOrderB);
        await _fireUser.updateEducationSortOrder(
            userId: userId,
            resumeId: resumeId,
            educationId: itemB.id,
            newSortOrder: sortOrderA);
      } catch (e) {
        // Rollback on error
        setState(() {
          _educationList = originalList;
        });
      }
    }
  }

  void _moveDown(int index) async {
    if (index < _educationList.length - 1) {
      final userId = MySingleton.userId!;
      final resumeId = MySingleton.resumeId!;

      // Get the two items to swap
      final itemA = _educationList[index];
      final itemB = _educationList[index + 1];

      // Get their actual current sort orders from the list items
      // If null or same, use their current indices to ensure unique values
      int sortOrderA = itemA.sortOrder ?? index;
      int sortOrderB = itemB.sortOrder ?? (index + 1);

      // If sortOrders are the same, assign based on current position
      // This ensures swapping will actually change positions
      if (sortOrderA == sortOrderB) {
        sortOrderA = index;
        sortOrderB = index + 1;
      }

      // Store original list for potential rollback
      final originalList = List<EducationModel>.from(_educationList);

      // Optimistically update the UI immediately
      final newList = List<EducationModel>.from(_educationList);

      // Find items by ID to update (more reliable than using index)
      final indexA = newList.indexWhere((e) => e.id == itemA.id);
      final indexB = newList.indexWhere((e) => e.id == itemB.id);

      if (indexA != -1 && indexB != -1) {
        // Update items with swapped sort orders
        newList[indexA] = EducationModel(
          id: itemA.id,
          eid: itemA.eid,
          schoolName: itemA.schoolName,
          dateFrom: itemA.dateFrom,
          dateTo: itemA.dateTo,
          present: itemA.present,
          sortOrder: sortOrderB,
        );
        newList[indexB] = EducationModel(
          id: itemB.id,
          eid: itemB.eid,
          schoolName: itemB.schoolName,
          dateFrom: itemB.dateFrom,
          dateTo: itemB.dateTo,
          present: itemB.present,
          sortOrder: sortOrderA,
        );
      }

      // Sort by sortOrder and update UI
      newList.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
      setState(() {
        _educationList = newList;
      });

      // Then sync with Firestore
      try {
        await _fireUser.updateEducationSortOrder(
            userId: userId,
            resumeId: resumeId,
            educationId: itemA.id,
            newSortOrder: sortOrderB);
        await _fireUser.updateEducationSortOrder(
            userId: userId,
            resumeId: resumeId,
            educationId: itemB.id,
            newSortOrder: sortOrderA);
      } catch (e) {
        // Rollback on error
        setState(() {
          _educationList = originalList;
        });
      }
    }
  }
}

class EducationForm extends StatefulWidget {
  EducationForm({this.education, required this.onSave});

  final EducationModel? education;
  final VoidCallback onSave;

  @override
  State<EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _schoolFromController = TextEditingController();
  final TextEditingController _schoolToController = TextEditingController();

  final FireUser _fireUser = FireUser();

  bool _presentEdu = false;

  @override
  void initState() {
    super.initState();
    if (widget.education != null) {
      _schoolNameController.text = widget.education!.schoolName!;
      _schoolFromController.text = widget.education!.dateFrom!;
      _schoolToController.text = widget.education!.dateTo!;
      _presentEdu = widget.education!.present!;
    }
  }

  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 2) {
        final month = int.parse(parts[0]);
        final year = int.parse(parts[1]);
        return DateTime(year, month);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void _saveEducation() async {
    if (_formKey.currentState!.validate()) {
      DateTime? startDate = _parseDate(_schoolFromController.text);
      DateTime? endDate =
          _presentEdu ? null : _parseDate(_schoolToController.text);

      if (!_presentEdu &&
          startDate != null &&
          endDate != null &&
          endDate.isBefore(startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("End date cannot be before start date")),
        );
        return;
      }
      EducationModel education = EducationModel(
        id: MySingleton.resumeId!,
        eid: widget.education?.eid,
        schoolName: _schoolNameController.text,
        dateFrom: _schoolFromController.text,
        dateTo: _schoolToController.text,
        present: _presentEdu,
      );

      // if (widget.education == null) {
      //   await DbHelper.instance.insertEducation(educationModel: education);
      // } else {
      //   await DbHelper.instance.updateEducation(educationModel: education);
      // }
      final userId = MySingleton.userId!;
      final resumeId = MySingleton.resumeId!;

      if (widget.education == null) {
        // This is a new entry, call addEducation
        await _fireUser.addEducation(
            userId: userId, resumeId: resumeId, education: education);
      } else {
        // This is an existing entry, call updateEducation
        await _fireUser.updateEducation(
            userId: userId, resumeId: resumeId, education: education);
      }
      widget.onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSize.s16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.education == null ? "Add Education" : "Edit Education",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: FontFamily.roboto),
                ),
                SizedBox(height: AppSize.s20),
                _buildTextField(_schoolNameController, AppStrings.whtSchoolHint,
                    AppStrings.whtSchool,
                    isRequired: true, maxLines: 1),
                SizedBox(height: AppSize.s20),
                _buildDatePickerField(
                    _schoolFromController,
                    AppStrings.attendedFromHint,
                    AppStrings.attendedFrom,
                    context,
                    isRequired: true),
                SizedBox(height: AppSize.s20),
                _buildDatePickerField(_schoolToController,
                    AppStrings.attendedFromHint, AppStrings.to, context),
                SizedBox(height: AppSize.s12),
                Row(
                  children: [
                    Switch(
                      value: _presentEdu,
                      activeColor: Colors.lightBlue,
                      activeThumbImage: AssetImage(ImageAssets.thumbActiveIc),
                      activeTrackColor: Colors.lightBlueAccent.withOpacity(0.3),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: ColorManager.tabBackground,
                      onChanged: (val) {
                        setState(() {
                          _presentEdu = val;

                          // Clear the "Until" date if Present is ON
                          if (val) {
                            _schoolToController.clear();
                          }
                        });
                      },
                    ),
                    Text(
                      AppStrings.present,
                      style: TextStyle(
                          color: Colors.black, fontSize: FontSize.s12),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.secondary,
                  ),
                  onPressed: _saveEducation,
                  child: Text("Save",
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String company,
      {int? maxLines, bool isRequired = false}) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company,
            style: TextStyle(
              color: Colors.black,
              fontSize: FontSize.s14,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            controller: controller,
            maxLines: maxLines ?? 1,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "$label is required";
                    }
                    return null;
                  }
                : null,
            style: TextStyle(
              color: Colors.black,
              fontSize: FontSize.s20,
              fontWeight: FontWeight.normal,
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: FontSize.s20,
                fontWeight: FontWeight.normal,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorManager.secondary),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMonthYear(
    BuildContext context,
    TextEditingController controller, {
    DateTime? minDate,
  }) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: minDate ?? DateTime(1950),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primaryColor: Colors.blue,
            hintColor: Colors.blueAccent,
            dialogBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedDate =
          "${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      controller.text = formattedDate;
    }
  }

  Widget _buildDatePickerField(TextEditingController controller, String label,
      String company, BuildContext context,
      {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          company,
          style: TextStyle(
            color: Colors.black,
            fontSize: FontSize.s14,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          //       onTap: () => _selectMonthYear(
          // Navigator.of(context).overlay!.context, controller),

          onTap: () {
            if (controller == _schoolFromController && _presentEdu) {
              return; // Don't open date picker if "Present" is ON
            }

            if (controller == _schoolToController) {
              DateTime? fromDate = _parseDate(_schoolFromController.text);
              _selectMonthYear(
                  Navigator.of(context).overlay!.context, controller,
                  minDate: fromDate);
            } else {
              _selectMonthYear(
                  Navigator.of(context).overlay!.context, controller);
            }
          },

          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              enabled: controller != _schoolToController || !_presentEdu,
              validator: isRequired
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "$company is required";
                      }
                      return null;
                    }
                  : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: TextStyle(
                color: Colors.black,
                fontSize: FontSize.s20,
                fontWeight: FontWeight.normal,
              ),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: FontSize.s20,
                  fontWeight: FontWeight.normal,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorManager.secondary),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
