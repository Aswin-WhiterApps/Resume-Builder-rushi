import 'package:flutter/material.dart';
import 'package:resume_builder/Presentation/resources/assets_manager.dart';
import 'package:resume_builder/Presentation/resources/color_manager.dart';
import 'package:resume_builder/Presentation/resources/font_manager.dart';
import 'package:resume_builder/Presentation/resources/route_manager.dart';

import '../resources/values_manager.dart';

class Promo1View extends StatelessWidget {
  const Promo1View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: _getPromo1(context),
      ),
    );
  }

  void _getSubscription(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.subscriptionPage);
  }

  Widget _getPromo1(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
      // height: MediaQuery.of(context).size.height*0.75 ,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // height: 200,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              // color: ColorManager.promo1BgColor,
              image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      ColorManager.promo1BgColor, BlendMode.multiply),
                  image: AssetImage(
                    ImageAssets.promoBg1,
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
                  Image.asset(
                    ImageAssets.promo1Logo,
                    height: 200,
                    width: 200,
                  ),

                  // SizedBox(
                  //   height: 20,
                  // ),
                  Container(
                    // height: 70,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Stack(
                                  children: [
                                    Text(
                                      "Upagrade Now !",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: FontFamily.poppins,
                                          // color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: FontSize.s27,
                                          letterSpacing: 3,
                                          foreground: Paint()
                                            ..style = PaintingStyle.stroke
                                            ..strokeWidth = 5
                                            ..color = Colors.white),
                                    ),
                                    Text(
                                      "Upagrade Now !",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: FontFamily.poppins,
                                          color: ColorManager.promo1BgColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: FontSize.s27,
                                          letterSpacing: 3),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "for Unleashed Features",
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
                          left: 300,
                          bottom: 53,
                          child: Image.asset(
                            ImageAssets.goldCrownIc,
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () => _getSubscription(context),
                    style: ElevatedButton.styleFrom(
                        // shape: StadiumBorder(side: BorderSide(color: ColorManager.white,strokeAlign: BorderSide.strokeAlignCenter)),
                        backgroundColor: Colors.transparent),
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: ColorManager.white,
                              strokeAlign: BorderSide.strokeAlignInside,
                              width: 3)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: AppPadding.p8, horizontal: 30),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: ColorManager.promo2buttonColor,
                                strokeAlign: BorderSide.strokeAlignInside,
                                width: 3)),
                        child: Text(
                          "Go Add-Free",
                          textScaleFactor: 1.5,
                          style: TextStyle(
                              color: ColorManager.promo2buttonColor,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Where Innovation\nMeets Exclusivity",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3),
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
    );
  }
}
