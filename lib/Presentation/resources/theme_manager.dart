
import 'package:flutter/material.dart';
import 'package:resume_builder/Presentation/resources/style_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';

import 'color_manager.dart';
import 'font_manager.dart';


ThemeData getApplicationTheme(){
  return ThemeData(
    fontFamily: FontFamily.roboto,
    primaryColor: ColorManager.secondary,
    primaryColorLight: ColorManager.primaryOpacity70,
    primaryColorDark: ColorManager.darkPrimary,
    splashColor: ColorManager.primaryOpacity70,// ripple Color
    disabledColor: ColorManager.grey1,
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: ColorManager.grey),


    cardTheme: CardThemeData(
      color: ColorManager.white,
      shadowColor: ColorManager.grey,
      elevation: AppSize.s4
  ),


    appBarTheme: AppBarTheme(
      centerTitle: true,
      color: ColorManager.primary,
      elevation: AppSize.s4,
      shadowColor: ColorManager.primaryOpacity70,
        titleTextStyle: getRegularStyle(color: ColorManager.white,fontSize: FontSize.s16)
    ),


    buttonTheme: ButtonThemeData(
      shape: const StadiumBorder(),
      disabledColor: ColorManager.grey,
      buttonColor: ColorManager.primary,
      splashColor: ColorManager.primaryOpacity70,
    ),

        //Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: getRegularStyle(color: ColorManager.white),
        backgroundColor: ColorManager.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s12)
        )
      )
    ),



    // Text Theme
    textTheme: TextTheme(
      displayLarge: getBoldStyle(color: ColorManager.darkGrey,fontSize: FontSize.s27),
      titleMedium:  getMediumStyle(color: ColorManager.lightGrey, fontSize: FontSize.s14),
      titleSmall:  getMediumStyle(color: ColorManager.primary, fontSize: FontSize.s14),
      bodySmall: getRegularStyle(color: ColorManager.grey1),
      bodyLarge: getRegularStyle(color: Colors.grey,fontSize: FontSize.s20,)
    ),


    // Input Decoration Theme (text formFeild)
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.all(AppPadding.p8),
      hintStyle: getRegularStyle(color: ColorManager.grey1),  // Hint Style
      labelStyle: getMediumStyle(color: ColorManager.darkGrey), //Label Style
      errorStyle: getRegularStyle(color: ColorManager.error),  //Error Style

      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.grey,width: AppSize.s1_5),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
    ),  //Enabled Border

      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.primary,width: AppSize.s1_5),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),  //Focused Border

      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.error,width: AppSize.s1_5),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),  //Error Border

      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.primary,width: AppSize.s1_5),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),  //Focused Error Border
    )
  );
}