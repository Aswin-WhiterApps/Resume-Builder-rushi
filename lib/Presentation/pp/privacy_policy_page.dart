import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:resume_builder/Presentation/pp/pp_content.dart';

import '../resources/assets_manager.dart';
import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/route_manager.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';
class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              // MySingleton.id = null;
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
      ),
      // body: Container(
      //   padding: EdgeInsets.all(20),
      //   child:PDF().cachedFromUrl(
      //     'https://firebasestorage.googleapis.com/v0/b/resumebuilder-c5d4d.appspot.com/o/Documents%2FPrivacy%20Policy%20-%20Resume%20Builder%20(1).pdf?alt=media&token=09b81645-07ce-4646-bf5f-3a96c102aa4a',
      //     placeholder: (progress) => Center(child: Text('$progress %')),
      //     errorWidget: (error) => Center(child: Text(error.toString())),
      //   ),
      // ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text("Privacy Policy",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 30),textAlign: TextAlign.center)),
              SizedBox(height: 10,),
              Text("${PpContent.p1}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p2}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p3}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p4b}",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p5}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p6}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p7}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p8}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p9}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p10}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p11}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p12}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p13}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p14b}",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p15}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p16b}",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p17}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p18}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p19}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p20}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p21}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p22}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p23}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p24}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p25}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p26}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p27b}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p28}",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p29}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p30}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p31}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p32b}",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p33}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p34}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p35}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p36}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p37b}",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p38}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p39}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p40}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p41}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p42}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p43}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p44}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p45}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p46}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p47}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p48}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p49}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p50b}",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p51}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p52}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p53}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p54b}",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p55}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p56}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p57}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p58b}",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p59}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p60b}",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p61}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p62b}",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.justify,softWrap: true,),
              Text("${PpContent.p63}",style:TextStyle(color: Colors.black),textAlign: TextAlign.justify,softWrap: true,),

            ],
          ),
        ),),
    );
  }
}
