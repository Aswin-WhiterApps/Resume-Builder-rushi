import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:resume_builder/Presentation/tou/tou_content.dart';

import '../resources/assets_manager.dart';
import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';

class TouView extends StatelessWidget {
  const TouView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(ImageAssets.backIc),
        ),
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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Text("Terms of Use",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                        textAlign: TextAlign.center)),
                SizedBox(
                  height: 10,
                ),
                Text(TouContent.p1,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p2,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p3,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p4,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p5,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p6b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p7,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p8b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p9,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p10,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p11b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p12,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p13b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p14,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p15,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p16,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p17,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p18b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p19,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p20b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p21,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p22b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p23,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p24b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p25,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p26b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p27,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p28b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p29,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p30b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p31,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p32b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p33,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p34b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p35,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
                Text(TouContent.p36b,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify),
                Text(TouContent.p37,
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.justify),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
