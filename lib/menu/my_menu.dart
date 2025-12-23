import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:resume_builder/Presentation/resources/assets_manager.dart';
import 'package:resume_builder/Presentation/resources/color_manager.dart';
import 'package:resume_builder/Presentation/resources/route_manager.dart';
import 'package:resume_builder/Presentation/resources/strings_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showSimpleDialog(BuildContext context) async {
  await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(20))), // <-- SEE HERE
          child: Container(
            // color: ColorManager.secondary,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: AppPadding.p16,
                      right: AppPadding.p16,
                      bottom: AppPadding.p30),
                  child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(ImageAssets.closeDialogIc)),
                ),
                Container(
                  height: 250,
                  width: double.infinity,
                  child: Column(
                    // mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      getTouButton(),
                      //getPPButton(),
                      getShareButton(),
                      getSufButton()
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
}

Future<void> getFeedbackDialog(BuildContext context) async {
  String email = "info@appsait.com";
  String subject = "Resume Builder Feedback";
  await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          title: Text(
            AppStrings.sufButton,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p12, vertical: AppPadding.p30),
              child: Text(AppStrings.sufDialogMessage),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppStrings.cancel,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500),
                      )),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        Uri mail = Uri.parse("mailto:$email?subject=$subject");
                        await launchUrl(mail);
                      },
                      child: Text(
                        AppStrings.sendFeedBack.toUpperCase(),
                        style: TextStyle(
                          color: ColorManager.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              ),
            )
          ],
        );
      });
}

Widget getPPButton() {
  Color backColor = Colors.white;
  Color textColor = ColorManager.primary;
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        // height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)),
            border: Border.all(
                color: ColorManager.primary,
                width: 1.6,
                strokeAlign: BorderSide.strokeAlignOutside)),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(Routes.ppPage);
            setState(() {
              if (backColor == Colors.white) {
                backColor = ColorManager.primary;
              } else if (backColor == ColorManager.primary) {
                backColor = Colors.white;
              }

              if (textColor == Colors.white) {
                textColor = ColorManager.primary;
              } else if (textColor == ColorManager.primary) {
                textColor = Colors.white;
              }
            });
          },
          child: Text(
            "Privacy Policy",
            style: TextStyle(
              color: textColor,
            ),
            textScaleFactor: 2,
          ),
          style: ElevatedButton.styleFrom(
              elevation: AppSize.s8,
              minimumSize: Size(200, 50),
              backgroundColor: backColor,
              shape: StadiumBorder()),
        ),
      );
    },
  );
}

Widget getTouButton() {
  Color backColor = ColorManager.white;
  Color textColor = ColorManager.secondary;
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        // height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)),
            border: Border.all(
                color: ColorManager.secondary,
                width: 1.6,
                strokeAlign: BorderSide.strokeAlignOutside)),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(Routes.touPage);
            setState(() {
              if (backColor == Colors.white) {
                backColor = ColorManager.primary;
              } else if (backColor == ColorManager.secondary) {
                backColor = Colors.white;
              }

              if (textColor == Colors.white) {
                textColor = ColorManager.secondary;
              } else if (textColor == ColorManager.secondary) {
                textColor = Colors.white;
              }
            });
          },
          child: Text(
            AppStrings.touButton,
            style: TextStyle(
              color: textColor,
            ),
            textScaleFactor: 2,
          ),
          style: ElevatedButton.styleFrom(
              elevation: AppSize.s8,
              minimumSize: Size(200, 50),
              backgroundColor: backColor,
              shape: StadiumBorder()),
        ),
      );
    },
  );
}

Widget getShareButton() {
  Color backColor = ColorManager.white;
  Color textColor = ColorManager.secondary;
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        // height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)),
            border: Border.all(
                color: ColorManager.secondary,
                width: 1.6,
                strokeAlign: BorderSide.strokeAlignOutside)),
        child: ElevatedButton(
          onPressed: () async {
            setState(() {
              if (backColor == Colors.white) {
                backColor = ColorManager.secondary;
              } else if (backColor == ColorManager.secondary) {
                backColor = Colors.white;
              }
              if (textColor == Colors.white) {
                textColor = ColorManager.secondary;
              } else if (textColor == ColorManager.secondary) {
                textColor = Colors.white;
              }
            });
            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            final String packageName = packageInfo.packageName;
            final String playstoreLink =
                "https://play.google.com/store/apps/details?id=$packageName";
            Share.share("$playstoreLink");
          },
          child: Text(
            AppStrings.shareButton,
            style: TextStyle(
              color: textColor,
            ),
            textScaler: TextScaler.linear(2),
          ),
          style: ElevatedButton.styleFrom(
              elevation: AppSize.s8,
              minimumSize: Size(200, 50),
              backgroundColor: backColor,
              shape: StadiumBorder()),
        ),
      );
    },
  );
}

Widget getSufButton() {
  Color backColor = ColorManager.white;
  Color textColor = ColorManager.secondary;

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          // height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)),
              border: Border.all(
                  color: ColorManager.secondary,
                  width: 1.6,
                  strokeAlign: BorderSide.strokeAlignOutside)),
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                if (backColor == Colors.white) {
                  backColor = ColorManager.secondary;
                } else if (backColor == ColorManager.secondary) {
                  backColor = Colors.white;
                }

                if (textColor == Colors.white) {
                  textColor = ColorManager.secondary;
                } else if (textColor == ColorManager.secondary) {
                  textColor = Colors.white;
                }
                Navigator.pop(context);
                getFeedbackDialog(context);
              });
            },
            child: Text(
              AppStrings.sufButton,
              style: TextStyle(
                color: textColor,
              ),
              textScaler: TextScaler.linear(2),
            ),
            style: ElevatedButton.styleFrom(
                elevation: AppSize.s8,
                minimumSize: Size(200, 50),
                backgroundColor: backColor,
                shape: StadiumBorder()),
          ));
    },
  );
}
