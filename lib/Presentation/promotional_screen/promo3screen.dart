import 'package:flutter/material.dart';

import '../resources/assets_manager.dart';
import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/route_manager.dart';
import '../resources/values_manager.dart';
class Promo3View extends StatelessWidget {
  const Promo3View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: _getPromo3(context),
      ),
    );
  }
  void _getSubscription(BuildContext context){
    Navigator.of(context).pushReplacementNamed(Routes.subscriptionPage);
  }
  Widget _getPromo3(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
      height: MediaQuery.of(context).size.height*0.75 ,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // height: 200,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: ColorManager.white,
              image: DecorationImage(
                  colorFilter: ColorFilter.mode( ColorManager.white.withOpacity(0.7), BlendMode.hardLight),
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
                                child:
                                Stack(children: [
                                  Text(
                                    "Upagrade to Premium",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      // fontFamily: FontFamily.poppins,
                                      // color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: FontSize.s20,letterSpacing: 3,
                                        foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 10..color = ColorManager.promo1BgColor
                                    ),
                                  ),
                                  Text(
                                    "Upagrade to Premium",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      // fontFamily: FontFamily.poppins,
                                        color: ColorManager.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: FontSize.s20,letterSpacing: 3
                                    ),
                                  ),
                                ],),
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
                    onPressed: () => _getSubscription(context),
                    style: ElevatedButton.styleFrom(

                        shape: StadiumBorder(side: BorderSide(color: ColorManager.promo1BgColor,strokeAlign: BorderSide.strokeAlignCenter,width: 3)),
                        backgroundColor: Colors.white70),

                    child: Text(
                      "Unloack Now !",
                      textScaleFactor: 1.5,
                      style: TextStyle(
                          color: ColorManager.promo2buttonColor,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _getSubscription(context),
                    style: ElevatedButton.styleFrom(

                        shape: StadiumBorder(side: BorderSide(color: ColorManager.promo1BgColor,strokeAlign: BorderSide.strokeAlignCenter,width: 3)),
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
                        color: ColorManager.promo2buttonColor, fontWeight: FontWeight.w600,letterSpacing: 1),
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
