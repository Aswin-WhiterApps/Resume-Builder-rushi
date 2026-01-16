import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../resources/assets_manager.dart';
import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/route_manager.dart';
import '../resources/values_manager.dart';

class Promo2View extends StatelessWidget {
  const Promo2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: _getPromo2(context),
      ),
    );
  }

  void _getSubscription(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.subscriptionPage);
  }

  Widget _getPromo2(BuildContext context) {
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
                    height: 20,
                  ),
                  Container(
                    // height: 70,
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
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () => _getSubscription(context),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Text(
                      "UPGRADE NOW",
                      style: TextStyle(
                          color: ColorManager.promo2buttonColor,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 20,
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
