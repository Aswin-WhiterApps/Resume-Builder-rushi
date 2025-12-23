import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class Resume1ThemeModel {
  PdfColor? nameColor;
  PdfColor? headerColor;
  PdfColor? normalColor;
  PdfColor? DividerColor;

  //Fonts
  Font? nameFont;
  Font? headerFont;
  Font? normalFont;

  String? bullet;

  Resume1ThemeModel(
      {this.bullet,
      this.nameColor,
      this.headerColor,
      this.normalColor,
      this.DividerColor,
      this.nameFont,
      this.headerFont,
      this.normalFont});
}

class Resume2ThemeModel {
  PdfColor? imageBorder;
  String? background;
  PdfColor? backgroundColor;
  PdfColor? nameColor;
  PdfColor? headerLight;
  PdfColor? headerDark;
  PdfColor? normalLight;
  PdfColor? normalDark;

  Font? nameFont;
  Font? headerFont;
  Font? normalFont;

  String? bulletDark;
  String? bulletLight;

  Resume2ThemeModel(
      {this.bulletDark,
      this.bulletLight,
      this.imageBorder,
      this.background,
      this.backgroundColor,
      this.nameColor,
      this.headerLight,
      this.headerDark,
      this.normalLight,
      this.normalDark,
      this.nameFont,
      this.headerFont,
      this.normalFont});
}

class Resume3ThemeModel {
  PdfColor? normalTextColor;
  PdfColor? headerDarkColor;
  PdfColor? headerLightColor;
  PdfColor? nameColor;
  PdfColor? imageBorder;
  PdfColor? background;

  String? objHorizontal;
  String? objVertical;
  String? emailIc;
  String? phoneIc;
  String? linkIc;
  String? bullet;

  //Fonts

  Font? headerFont;
  Font? normalFont;

  Resume3ThemeModel(
      {this.bullet,
      this.normalTextColor,
      this.headerDarkColor,
      this.headerLightColor,
      this.nameColor,
      this.imageBorder,
      this.background,
      this.objHorizontal,
      this.objVertical,
      this.emailIc,
      this.phoneIc,
      this.linkIc,
      this.headerFont,
      this.normalFont});

  get homeIc => null;
}

class Resume4ThemeModel {
  PdfColor? normalTextColor;
  PdfColor? headerDarkColor;
  PdfColor? nameColor;
  PdfColor? imageBorder;

  String? imgBorder;
  String? objVertical;
  String? emailIc;
  String? phoneIc;
  String? linkIc;
  String? bullet;
  String? bulletDark;
  String? bulletLight;

  //Fonts
  Font? headerFont;
  Font? normalFont;

  Resume4ThemeModel(
      {this.bullet,
      this.bulletDark,
      this.bulletLight,
      this.normalTextColor,
      this.headerDarkColor,
      this.nameColor,
      this.imageBorder,
      this.imgBorder,
      this.objVertical,
      this.emailIc,
      this.phoneIc,
      this.linkIc,
      this.headerFont,
      this.normalFont});
}

class Resume5ThemeModel {
  String? background;
  String? email;
  String? phone;
  String? link;
  String? bullet;
  String? bulletDark;
  String? bulletLight;

  PdfColor? normalTextColor;
  PdfColor? headerDarkColor;
  PdfColor? nameColor;
  PdfColor? imageBorder;

  Font? normalFont;
  Font? headerFont;

  Resume5ThemeModel(
      {this.bullet,
      this.bulletDark,
      this.bulletLight,
      this.background,
      this.email,
      this.phone,
      this.link,
      this.normalTextColor,
      this.headerDarkColor,
      this.nameColor,
      this.imageBorder,
      this.normalFont,
      this.headerFont});
}

class Resume6ThemeModel {
  String? background;
  String? email;
  String? phone;
  String? link;
  String? bullet;

  PdfColor? normalTextColor;
  PdfColor? headerDarkColor;
  PdfColor? headerLightColor;
  PdfColor? nameColor;
  PdfColor? imageBorder;

  Font? normalFont;
  Font? headerFont;
  Font? nameFont;

  Resume6ThemeModel(
      {this.background,
      this.email,
      this.phone,
      this.link,
      this.bullet,
      this.normalTextColor,
      this.headerDarkColor,
      this.headerLightColor,
      this.nameColor,
      this.imageBorder,
      this.normalFont,
      this.headerFont,
      this.nameFont});
}

class Resume7ThemeModel {
  String? background;
  String? link;

  Font? normalFont;
  Font? headerFont;
  Font? nameFont;

  PdfColor? normalTextColor;
  PdfColor? headerDarkColor;
  PdfColor? headerLightColor;
  PdfColor? dateColor;
  PdfColor? linkColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? imageBorderColor;
  PdfColor? boxColor;

  String? bullet;

  Resume7ThemeModel(
      {this.background,
      this.link,
      this.bullet,
      this.normalFont,
      this.headerFont,
      this.nameFont,
      this.normalTextColor,
      this.headerDarkColor,
      this.headerLightColor,
      this.dateColor,
      this.linkColor,
      this.nameColor,
      this.positionColor,
      // this.imageBorderColor,
      this.boxColor});
}

class Resume8ThemeModel {
  String? link;
  Font? normalFont;
  Font? headerFont;
  Font? nameFont;

  PdfColor? normalTextColor;
  PdfColor? headerDarkColor;
  PdfColor? headerLightColor;
  PdfColor? dateColor;
  PdfColor? linkColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? backgroundColor;
  PdfColor? imageBorder;
  PdfColor? boxColor;

  Resume8ThemeModel(
      {this.link,
      this.normalFont,
      this.headerFont,
      this.nameFont,
      this.normalTextColor,
      this.headerDarkColor,
      // this.headerLightColor,
      this.dateColor,
      this.linkColor,
      this.nameColor,
      this.positionColor,
      this.backgroundColor,
      this.imageBorder,
      this.boxColor,
      required PdfColor imageBorderColor});

  get bulletDarkImage => null;
}

class Resume9ThemeModel {
  Font? font;

  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? backgroundBoxColor;
  PdfColor? boxBottomBorderColor;
  PdfColor? subHeaderColor;

  String? bullet;

  Resume9ThemeModel(
      {this.font,
      this.headerColor,
      this.subHeaderColor,
      this.backgroundBoxColor,
      this.boxBottomBorderColor,
      this.normalTextColor,
      this.nameColor,
      this.positionColor,
      this.bullet});
}

class Resume10ThemeModel {
  Font? normalFont;
  Font? headerFont;
  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? backgroundBoxColor;
  PdfColor? boxBottomBorderColor;
  PdfColor? subHeaderColor;

  String? bullet;
  String? background;
  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? imageBorder1;
  String? rect41;

  Resume10ThemeModel(
      {this.normalFont,
      this.headerFont,
      this.headerColor,
      this.subHeaderColor,
      this.backgroundBoxColor,
      this.boxBottomBorderColor,
      this.normalTextColor,
      this.nameColor,
      this.positionColor,
      this.bullet,
      this.background,
      this.linkIc,
      this.phoneIc,
      this.emailIc,
      this.imageBorder1,
      this.rect41});
}

class Resume11ThemeModel {
  Font? normalFont;
  Font? headerFont;

  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? boxBottomBorderColor;
  PdfColor? boxHorizontalColor;
  PdfColor? boxVerticalColor;
  PdfColor? subHeaderColor;

  String? bullet42;
  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? background;
  String? imageBorder2;
  String? rect42;

  Resume11ThemeModel(
      {this.normalFont,
      this.headerFont,
      this.headerColor,
      this.subHeaderColor,
      this.boxBottomBorderColor,
      this.boxHorizontalColor,
      this.boxVerticalColor,
      this.normalTextColor,
      this.nameColor,
      this.positionColor,
      this.bullet42,
      this.background,
      this.linkIc,
      this.phoneIc,
      this.emailIc,
      this.imageBorder2,
      this.rect42});
}

class Resume12ThemeModel {
  Font? normalFont;
  Font? headerFont;
  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? boxHorizontalColor;
  PdfColor? boxVerticalColor;
  PdfColor? subHeaderColor;

  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? bullet43;
  String? background;
  String? imageBorder3;
  String? rect43;

  Resume12ThemeModel(
      {this.normalFont,
      this.headerFont,
      this.headerColor,
      this.subHeaderColor,
      this.boxHorizontalColor,
      this.boxVerticalColor,
      this.normalTextColor,
      this.nameColor,
      this.positionColor,
      this.bullet43,
      this.background,
      this.linkIc,
      this.phoneIc,
      this.emailIc,
      this.imageBorder3,
      this.rect43});

  PdfColor? get boxBottomBorderColor => null;
}

class Resume13ThemeModel {
  Font? headerFont;
  Font? normalFont;

  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? borderColor;
  PdfColor? boxColor;
  PdfColor? subHeaderColor;

  String? imageBorder51;
  String? back51;
  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? bullet51;
  String? background;

  var boxVerticalColor;

  Resume13ThemeModel({
    this.headerFont,
    this.normalFont,
    this.headerColor,
    this.subHeaderColor,
    this.boxColor,
    this.borderColor,
    this.normalTextColor,
    this.nameColor,
    this.bullet51,
    this.background,
    this.emailIc,
    this.phoneIc,
    this.linkIc,
    this.imageBorder51,
    this.back51,
  });

  get boxBottomBorderColor => borderColor;
  get boxHorizontalColor => boxColor;
}

class Resume14ThemeModel {
  Font? headerFont;
  Font? normalFont;
  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? subHeaderColor;

  String? imageBorder52;
  String? back52;
  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? bullet52;
  String? background;

  Resume14ThemeModel({
    this.normalFont,
    this.headerFont,
    this.headerColor,
    this.subHeaderColor,
    this.normalTextColor,
    this.nameColor,
    this.bullet52,
    this.background,
    this.emailIc,
    this.phoneIc,
    this.linkIc,
    this.imageBorder52,
    this.back52,
  });
}

class Resume15ThemeModel {
  Font? headerFont;
  Font? normalFont;
  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? subHeaderColor;

  String? imageBorder52;
  String? back53;
  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? bullet53;
  String? background;

  Resume15ThemeModel({
    this.headerFont,
    this.normalFont,
    this.headerColor,
    this.subHeaderColor,
    this.normalTextColor,
    this.nameColor,
    this.bullet53,
    this.background,
    this.emailIc,
    this.phoneIc,
    this.linkIc,
    this.imageBorder52,
    this.back53,
  });
}

class Resume16ThemeModel {
  Font? headerFont;
  Font? normalFont;

  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? subHeaderColor;

  String? imageBorder54;
  String? back54;
  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? bullet54;
  String? background;

  Resume16ThemeModel({
    this.headerFont,
    this.normalFont,
    this.headerColor,
    this.subHeaderColor,
    this.normalTextColor,
    this.nameColor,
    this.bullet54,
    this.background,
    this.emailIc,
    this.phoneIc,
    this.linkIc,
    this.back54,
  });
}

class Resume17ThemeModel {
  Font? headerFont;
  Font? normalFont;

  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? subHeaderColor;

  String? imageBorder61;
  String? rect61;
  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? bullet61;
  String? background;

  Resume17ThemeModel({
    this.headerFont,
    this.normalFont,
    this.headerColor,
    this.subHeaderColor,
    this.normalTextColor,
    this.nameColor,
    this.bullet61,
    this.background,
    this.emailIc,
    this.phoneIc,
    this.linkIc,
    this.rect61,
  });
}

class Resume18ThemeModel {
  Font? headerFont;
  Font? normalFont;

  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? subHeaderColor;

  String? imageBorder62;
  String? rect62;
  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? bullet62;
  String? background;

  Resume18ThemeModel({
    this.headerFont,
    this.normalFont,
    this.headerColor,
    this.subHeaderColor,
    this.normalTextColor,
    this.nameColor,
    this.bullet62,
    this.background,
    this.emailIc,
    this.phoneIc,
    this.linkIc,
    this.rect62,
  });
}

class Resume19ThemeModel {
  Font? headerFont;
  Font? normalFont;

  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? subHeaderColor;

  String? imageBorder63;
  String? rect63;
  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? bullet63;
  String? background;

  Resume19ThemeModel({
    this.headerFont,
    this.normalFont,
    this.headerColor,
    this.subHeaderColor,
    this.normalTextColor,
    this.nameColor,
    this.bullet63,
    this.background,
    this.emailIc,
    this.phoneIc,
    this.linkIc,
    this.rect63,
  });
}

class Resume20ThemeModel {
  Font? headerFont;
  Font? normalFont;

  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? subHeaderColor;

  String? imageBorder64;
  String? rect64;
  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? bullet64;
  String? background;

  Resume20ThemeModel({
    this.headerFont,
    this.normalFont,
    this.headerColor,
    this.subHeaderColor,
    this.normalTextColor,
    this.nameColor,
    this.bullet64,
    this.background,
    this.emailIc,
    this.phoneIc,
    this.linkIc,
    this.rect64,
  });
}

class Resume21ThemeModel {
  Font? headerFont;
  Font? normalFont;

  PdfColor? normalTextColor;
  PdfColor? headerColor;
  PdfColor? nameColor;
  PdfColor? positionColor;
  PdfColor? subHeaderColor;
  PdfColor? imageBorderColor;
  PdfColor? dateColor;
  PdfColor? linkColor;

  String? imageBorder71;
  String? rect71;
  String? linkIc;
  String? phoneIc;
  String? emailIc;
  String? bullet71;
  String? background;

  Resume21ThemeModel({
    this.headerFont,
    this.normalFont,
    this.headerColor,
    this.subHeaderColor,
    this.normalTextColor,
    this.nameColor,
    this.bullet71,
    this.background,
    this.emailIc,
    this.phoneIc,
    this.linkIc,
    this.rect71,
    this.positionColor,
    this.imageBorderColor,
    this.dateColor,
    this.linkColor,
  });
}

//**************************************************************************
class CL1ThemeModel {
  Font? normalFont;
  // Font? headerFont ;
  Font? nameFont;

  PdfColor? normalTextColor;
  PdfColor? dividertColor;
  PdfColor? nameColor;
  PdfColor? backgroundColor;

  CL1ThemeModel(
      {this.normalFont,
      // this.headerFont,
      this.nameFont,
      this.normalTextColor,
      this.dividertColor,
      this.nameColor,
      this.backgroundColor});
}

class CL2ThemeModel {
  String? locationimg;
  String? emailimg;
  String? phoneimg;

  Font? normalFont;
  Font? nameFont;

  PdfColor? verticalObjColor;
  PdfColor? normalTextColor;
  PdfColor? imageBorder;
  PdfColor? nameColor;
  PdfColor? backgroundColor;

  CL2ThemeModel(
      {this.locationimg,
      this.emailimg,
      this.phoneimg,
      this.normalFont,
      this.nameFont,
      this.verticalObjColor,
      this.normalTextColor,
      this.imageBorder,
      this.nameColor,
      this.backgroundColor});
}

class CL3ThemeModel {
  Font? normalFont;
  Font? nameFont;

  String? background;

  PdfColor? normalTextColor;
  PdfColor? imageBorder;
  PdfColor? nameColor;

  CL3ThemeModel(
      {this.normalFont,
      this.nameFont,
      this.background,
      this.normalTextColor,
      this.imageBorder,
      this.nameColor});
}

class CL4ThemeModel {
  Font? normalFont;
  Font? nameFont;

  PdfColor? normalTextColor;
  PdfColor? imageBorder;
  PdfColor? nameColor;

  String? background;
  String? borderImage;

  CL4ThemeModel(
      {this.normalFont,
      this.nameFont,
      this.normalTextColor,
      this.imageBorder,
      this.nameColor,
      this.background,
      this.borderImage});
}

class CL5ThemeModel {
  Font? normalFont;
  Font? nameFont;

  String? background;

  PdfColor? normalTextColor;
  PdfColor? imageBorder;
  PdfColor? nameColor;

  CL5ThemeModel(
      {this.normalFont,
      this.nameFont,
      this.background,
      this.normalTextColor,
      this.imageBorder,
      this.nameColor});
}

class CL6ThemeModel {
  Font? normalFont;
  Font? nameFont;

  PdfColor? normalTextColor;
  PdfColor? imageBorder;
  PdfColor? nameColor;

  String? locationImg;
  String? emailImg;
  String? phoneImg;
  String? objBackImg;

  CL6ThemeModel(
      {this.normalFont,
      this.nameFont,
      this.normalTextColor,
      this.imageBorder,
      this.nameColor,
      this.locationImg,
      this.emailImg,
      this.phoneImg,
      this.objBackImg});
}
