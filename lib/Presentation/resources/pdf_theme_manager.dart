import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:resume_builder/Presentation/resources/pdf_assets.dart';

import '../../model/resume_theme_model.dart';

class Resume1Theme1 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume1ThemeModel resume1theme1dec;
  Future<Resume1ThemeModel?> getModel() async {
    await getFonts();
    resume1theme1dec = Resume1ThemeModel(
        nameColor: PdfColor.fromHex("#6A3232"),
        headerColor: PdfColor.fromHex("#896565"),
        normalColor: PdfColor.fromHex("#896565"),
        DividerColor: PdfColor.fromHex("#C0C0C0"),
        bullet: PdfAssets.bullet11,
        nameFont: nameFont,
        headerFont: headerFont,
        normalFont: normalFont);
    return resume1theme1dec;
  }

  Future<void> getFonts() async {
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    headerFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class Resume1Theme2 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume1ThemeModel resume1theme1dec;
  Future<Resume1ThemeModel?> getModel() async {
    await getFonts();
    resume1theme1dec = Resume1ThemeModel(
        nameColor: PdfColor.fromHex("#243029"),
        headerColor: PdfColor.fromHex("#243029"),
        normalColor: PdfColor.fromHex("#235938"),
        DividerColor: PdfColor.fromHex("#DDF0E2"),
        bullet: PdfAssets.bullet12,
        nameFont: nameFont,
        headerFont: headerFont,
        normalFont: normalFont);
    return resume1theme1dec;
  }

  Future<void> getFonts() async {
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    headerFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class Resume1Theme3 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume1ThemeModel resume1theme1dec;
  Future<Resume1ThemeModel?> getModel() async {
    await getFonts();
    resume1theme1dec = Resume1ThemeModel(
        nameColor: PdfColor.fromHex("#06043F"),
        headerColor: PdfColor.fromHex("#06043F"),
        normalColor: PdfColor.fromHex("#414085"),
        DividerColor: PdfColor.fromHex("#D1CDE3"),
        bullet: PdfAssets.bullet13,
        nameFont: nameFont,
        headerFont: headerFont,
        normalFont: normalFont);
    return resume1theme1dec;
  }

  Future<void> getFonts() async {
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    headerFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class Resume2Theme1 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume2ThemeModel resume2theme1;
  Future<void> getModel() async {
    resume2theme1 = await getFonts().then((value) => Resume2ThemeModel(
        imageBorder: PdfColor.fromHex("#F8EDED"),
        // verticalObjColor:PdfColor.fromHex("#B27B80"),
        backgroundColor: PdfColor.fromHex("#F8EDED"),
        nameColor: PdfColor.fromHex("#F8EDED"),
        headerLight: PdfColor.fromHex("#F8EDED"),
        headerDark: PdfColor.fromHex("#B27B80"),
        normalLight: PdfColor.fromHex("#F8EDED"),
        normalDark: PdfColor.fromHex("#B27B80"),
        background: PdfAssets.back21,
        bulletDark: PdfAssets.bullet21dark,
        bulletLight: PdfAssets.bullet21light,
        nameFont: nameFont,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    headerFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class Resume2Theme2 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume2ThemeModel resume2theme2;
  Future<void> getModel() async {
    resume2theme2 = await getFonts().then((value) => Resume2ThemeModel(
        imageBorder: PdfColor.fromHex("#F8F8F8"),
        // verticalObjColor:PdfColor.fromHex("#8C7C65"),
        backgroundColor: PdfColor.fromHex("#F0E2CD"),
        nameColor: PdfColor.fromHex("#E9E9E9"),
        headerLight: PdfColor.fromHex("#F0E2CD"),
        headerDark: PdfColor.fromHex("#514534"),
        normalLight: PdfColor.fromHex("#F0E2CD"),
        normalDark: PdfColor.fromHex("#514534"),
        background: PdfAssets.back22,
        bulletDark: PdfAssets.bullet22dark,
        bulletLight: PdfAssets.bullet22light,
        nameFont: nameFont,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    headerFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class Resume2Theme3 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume2ThemeModel resume2theme3;
  Future<void> getModel() async {
    resume2theme3 = await getFonts().then((value) => Resume2ThemeModel(
        imageBorder: PdfColor.fromHex("#F8F8F8"),
        // verticalObjColor:PdfColor.fromHex("#61AFC1"),
        backgroundColor: PdfColor.fromHex("#ECFBFF"),
        nameColor: PdfColor.fromHex("#E9E9E9"),
        headerLight: PdfColor.fromHex("#ECFBFF"),
        headerDark: PdfColor.fromHex("#0B4451"),
        normalLight: PdfColor.fromHex("#ECFBFF"),
        normalDark: PdfColor.fromHex("#0B4451"),
        background: PdfAssets.back23,
        bulletDark: PdfAssets.bullet23dark,
        bulletLight: PdfAssets.bullet23light,
        nameFont: nameFont,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    headerFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class Resume3Theme1 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume3ThemeModel resume3theme1;
  Future<void> getModel() async {
    resume3theme1 = await getFonts().then((value) => Resume3ThemeModel(
        imageBorder: PdfColor.fromHex("#4FC3F7"), // Light Blue
        normalTextColor: PdfColor.fromHex("#455A64"), // Blue Grey
        headerDarkColor: PdfColor.fromHex("#0288D1"), // Darker Light Blue
        headerLightColor: PdfColor.fromHex("#81D4FA"), // Light Blue
        background: PdfColor.fromHex("#77AEB5"), // Very Light Blue Background
        nameColor: PdfColor.fromHex("#0288D1"), // Darker Light Blue
        bullet: PdfAssets.bullet31,
        objHorizontal: PdfAssets.objH31,
        objVertical: PdfAssets.objV31,
        emailIc: PdfAssets.email3,
        phoneIc: PdfAssets.phone3,
        linkIc: PdfAssets.link3,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class Resume3Theme2 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume3ThemeModel resume3theme2;
  Future<void> getModel() async {
    resume3theme2 = await getFonts().then((value) => Resume3ThemeModel(
        imageBorder: PdfColor.fromHex("#A6C480"),
        normalTextColor: PdfColor.fromHex("#64754F"),
        headerDarkColor: PdfColor.fromHex("#656100"),
        headerLightColor: PdfColor.fromHex("#656100"),
        background: PdfColor.fromHex("#FAFFF4"),
        nameColor: PdfColor.fromHex("#FFFFF4"),
        bullet: PdfAssets.bullet32,
        objHorizontal: PdfAssets.objH32,
        objVertical: PdfAssets.objV32,
        emailIc: PdfAssets.email3,
        phoneIc: PdfAssets.phone3,
        linkIc: PdfAssets.link3,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.gravitasOneRegular();
    normalFont = await PdfGoogleFonts.arimoRegular();
  }
}

class Resume3Theme3 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume3ThemeModel resume3theme3;
  Future<void> getModel() async {
    resume3theme3 = await getFonts().then((value) => Resume3ThemeModel(
        imageBorder: PdfColor.fromHex("#77AEB5"),
        normalTextColor: PdfColor.fromHex("#134349"),
        headerDarkColor: PdfColor.fromHex("#595959"),
        headerLightColor: PdfColor.fromHex("#595959"),
        background: PdfColor.fromHex("#FAFAFF"),
        nameColor: PdfColor.fromHex("#E9E9E9"),
        bullet: PdfAssets.bullet33,
        objHorizontal: PdfAssets.objH33,
        objVertical: PdfAssets.objV33,
        emailIc: PdfAssets.email3,
        phoneIc: PdfAssets.phone3,
        linkIc: PdfAssets.link3,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.gravitasOneRegular();
    normalFont = await PdfGoogleFonts.arimoRegular();
  }
}

class Resume4Theme1 {
  // static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume4ThemeModel resume4theme1;
  Future<void> getModel() async {
    resume4theme1 = await getFonts().then((value) => Resume4ThemeModel(
        imageBorder: PdfColor.fromHex("#FFFFFF"),
        normalTextColor: PdfColor.fromHex("#474D7F"),
        headerDarkColor: PdfColor.fromHex("#151B4B"),
        nameColor: PdfColor.fromHex("#151B4B"),
        bullet: PdfAssets.bullet41,
        bulletDark: PdfAssets.bullet21dark,
        bulletLight: PdfAssets.bullet21light,
        imgBorder: PdfAssets.border41,
        objVertical: PdfAssets.back21,
        emailIc: PdfAssets.email41,
        phoneIc: PdfAssets.phone41,
        linkIc: PdfAssets.link41,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume4Theme2 {
  // static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume4ThemeModel resume4theme2;
  Future<void> getModel() async {
    resume4theme2 = await getFonts().then((value) => Resume4ThemeModel(
        imageBorder: PdfColor.fromHex("#FFFFFF"),
        normalTextColor: PdfColor.fromHex("#082C41"),
        headerDarkColor: PdfColor.fromHex("#082C41"),
        nameColor: PdfColor.fromHex("#082C41"),
        bullet: PdfAssets.bullet,
        imgBorder: PdfAssets.border42,
        objVertical: PdfAssets.objV42,
        phoneIc: PdfAssets.phone42,
        linkIc: PdfAssets.link42,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume4Theme3 {
  // static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume4ThemeModel resume4theme3;
  Future<void> getModel() async {
    resume4theme3 = await getFonts().then((value) => Resume4ThemeModel(
        imageBorder: PdfColor.fromHex("#FFFFFF"),
        normalTextColor: PdfColor.fromHex("#1D331B"),
        headerDarkColor: PdfColor.fromHex("#194B15"),
        nameColor: PdfColor.fromHex("#194B15"),
        bullet: PdfAssets.bullet42,
        imgBorder: PdfAssets.border43,
        objVertical: PdfAssets.objV43,
        emailIc: PdfAssets.email43,
        phoneIc: PdfAssets.phone43,
        linkIc: PdfAssets.link43,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume5Theme1 {
  static late Font headerFont;
  static late Font normalFont;

  late Resume5ThemeModel resume5theme1;
  Future<void> getModel() async {
    resume5theme1 = await getFonts().then((value) => Resume5ThemeModel(
        imageBorder: PdfColor.fromHex("#4895E0"),
        normalTextColor: PdfColor.fromHex("#46535F"),
        headerDarkColor: PdfColor.fromHex("#B87397"),
        nameColor: PdfColor.fromHex("#B87397"),
        background: PdfAssets.back22,
        email: PdfAssets.email51,
        phone: PdfAssets.phone51,
        link: PdfAssets.link51,
        bullet: PdfAssets.bullet51,
        bulletDark: PdfAssets.bullet22dark,
        bulletLight: PdfAssets.bullet22light,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume5Theme2 {
  static late Font headerFont;
  static late Font normalFont;

  late Resume5ThemeModel resume5theme2;
  Future<void> getModel() async {
    resume5theme2 = await getFonts().then((value) => Resume5ThemeModel(
        imageBorder: PdfColor.fromHex("#B87397"),
        normalTextColor: PdfColor.fromHex("#46535F"),
        headerDarkColor: PdfColor.fromHex("#02358A"),
        nameColor: PdfColor.fromHex("#02358A"),
        background: PdfAssets.back22,
        email: PdfAssets.email52,
        phone: PdfAssets.phone52,
        link: PdfAssets.link52,
        bullet: PdfAssets.bullet52,
        bulletDark: PdfAssets.bullet22dark,
        bulletLight: PdfAssets.bullet22light,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume5Theme3 {
  static late Font headerFont;
  static late Font normalFont;

  late Resume5ThemeModel resume5theme3;
  Future<void> getModel() async {
    resume5theme3 = await getFonts().then((value) => Resume5ThemeModel(
        imageBorder: PdfColor.fromHex("#99C364"),
        normalTextColor: PdfColor.fromHex("#5F5D51"),
        headerDarkColor: PdfColor.fromHex("#796601"),
        nameColor: PdfColor.fromHex("#796601"),
        background: PdfAssets.back22,
        email: PdfAssets.email53,
        phone: PdfAssets.phone53,
        link: PdfAssets.link53,
        bullet: PdfAssets.bullet53,
        bulletDark: PdfAssets.bullet22dark,
        bulletLight: PdfAssets.bullet22light,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume5Theme4 {
  static late Font headerFont;
  static late Font normalFont;

  late Resume5ThemeModel resume5theme4;
  Future<void> getModel() async {
    resume5theme4 = await getFonts().then((value) => Resume5ThemeModel(
        imageBorder: PdfColor.fromHex("#796601"),
        normalTextColor: PdfColor.fromHex("#676C60"),
        headerDarkColor: PdfColor.fromHex("#476324"),
        nameColor: PdfColor.fromHex("#476324"),
        background: PdfAssets.back22,
        email: PdfAssets.email54,
        phone: PdfAssets.phone54,
        link: PdfAssets.link54,
        bullet: PdfAssets.bullet54,
        bulletDark: PdfAssets.bullet22dark,
        bulletLight: PdfAssets.bullet22light,
        headerFont: headerFont,
        normalFont: normalFont));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume6Theme1 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume6ThemeModel resume6theme1;
  Future<void> getModel() async {
    // Using standard fonts locally to match T2 style
    nameFont = Font.timesBold();
    headerFont = Font.timesBold();
    normalFont = Font.times();

    resume6theme1 = Resume6ThemeModel(
      imageBorder: PdfColors.white,
      normalTextColor: PdfColor.fromHex("#455A64"),
      headerLightColor: PdfColor.fromHex("#2E7D32"),
      headerDarkColor: PdfColor.fromHex("#2E7D32"),
      nameColor: PdfColor.fromHex("#2E7D32"),
      background: PdfAssets.back23,
      email: PdfAssets.email61,
      phone: PdfAssets.phone61,
      link: PdfAssets.link61,
      bullet: PdfAssets.bullet61,
      headerFont: headerFont,
      normalFont: normalFont,
      nameFont: nameFont,
    );
  }

  Future<void> getFonts() async {
    // No-op or load other fonts if needed, but we are using standard fonts above.
    // Keeping method signature for compatibility if called elsewhere (though getModel calls it internally in original code, we removed the call)
    // Actually getModel is Void here, so we just set the static vars.
  }
}

class Resume6Theme2 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume6ThemeModel resume6theme2;
  Future<void> getModel() async {
    resume6theme2 = await getFonts().then((value) => Resume6ThemeModel(
          imageBorder: PdfColor.fromHex("#8D8572"),
          normalTextColor: PdfColor.fromHex("#413822"),
          headerLightColor: PdfColor.fromHex("#F8F7F3"),
          headerDarkColor: PdfColor.fromHex("#413822"),
          nameColor: PdfColor.fromHex("#8D8572"),
          background: PdfAssets.back22,
          email: PdfAssets.email62,
          phone: PdfAssets.phone62,
          link: PdfAssets.link62,
          bullet: PdfAssets.bullet62,
          headerFont: headerFont,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.rozhaOneRegular();
    nameFont = await PdfGoogleFonts.rozhaOneRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume6Theme3 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume6ThemeModel resume6theme3;
  Future<void> getModel() async {
    resume6theme3 = await getFonts().then((value) => Resume6ThemeModel(
          imageBorder: PdfColor.fromHex("#5F725F"),
          normalTextColor: PdfColor.fromHex("#0D490E"),
          headerLightColor: PdfColor.fromHex("#EAEFEB"),
          headerDarkColor: PdfColor.fromHex("#0D490E"),
          nameColor: PdfColor.fromHex("#5F725F"),
          background: PdfAssets.back22,
          email: PdfAssets.email63,
          phone: PdfAssets.phone63,
          link: PdfAssets.link63,
          bullet: PdfAssets.bullet63,
          headerFont: headerFont,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.rozhaOneRegular();
    nameFont = await PdfGoogleFonts.rozhaOneRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume6Theme4 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume6ThemeModel resume6theme4;
  Future<void> getModel() async {
    resume6theme4 = await getFonts().then((value) => Resume6ThemeModel(
          imageBorder: PdfColor.fromHex("#54616A"),
          normalTextColor: PdfColor.fromHex("#0D3049"),
          headerLightColor: PdfColor.fromHex("#EAEFEB"),
          headerDarkColor: PdfColor.fromHex("#0D3049"),
          nameColor: PdfColor.fromHex("#54616A"),
          background: PdfAssets.back22,
          email: PdfAssets.email64,
          phone: PdfAssets.phone64,
          link: PdfAssets.link64,
          bullet: PdfAssets.bullet64,
          headerFont: headerFont,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.rozhaOneRegular();
    nameFont = await PdfGoogleFonts.rozhaOneRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume7Theme1 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume7ThemeModel resume7theme1;

  Future<void> getModel() async {
    resume7theme1 = await getFonts().then((value) => Resume7ThemeModel(
          normalTextColor: PdfColor.fromHex("#FCFBF7"),
          headerLightColor: PdfColor.fromHex("#FCFBF7"),
          headerDarkColor: PdfColor.fromHex("#C69AFF"),
          nameColor: PdfColor.fromHex("#FCFBF7"),
          positionColor: PdfColor.fromHex("#C69AFF"),
          boxColor: PdfColor.fromHex("#5A249E"),
          dateColor: PdfColor.fromHex("#E0DFDC"),
          linkColor: PdfColor.fromHex("#E0DFDC"),
          background: PdfAssets.t31Horizontal,
          link: PdfAssets.link7,
          bullet: PdfAssets.bullet7,
          headerFont: headerFont,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.dMSansRegular();
    normalFont = await PdfGoogleFonts.dMSansRegular();
  }
}

class Resume7Theme2 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume7ThemeModel resume7theme2;
  Future<void> getModel() async {
    resume7theme2 = await getFonts().then((value) => Resume7ThemeModel(
          // imageBorderColor:PdfColor.fromHex("#54616A"),
          normalTextColor: PdfColor.fromHex("#FCFBF7"),
          headerLightColor: PdfColor.fromHex("#FCFBF7"),
          headerDarkColor: PdfColor.fromHex("#9ADBFF"),
          nameColor: PdfColor.fromHex("#FCFBF7"),
          positionColor: PdfColor.fromHex("#9ADBFF"),
          boxColor: PdfColor.fromHex("#478FB6"),
          dateColor: PdfColor.fromHex("#E0DFDC"),
          linkColor: PdfColor.fromHex("#E0DFDC"),

          background: PdfAssets.t31Horizontal,
          link: PdfAssets.link7,
          bullet: PdfAssets.bullet7,

          headerFont: headerFont,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.dMSansRegular();
    normalFont = await PdfGoogleFonts.dMSansRegular();
  }
}

class Resume7Theme3 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume7ThemeModel resume7theme3;
  Future<void> getModel() async {
    resume7theme3 = await getFonts().then((value) => Resume7ThemeModel(
          // imageBorderColor:PdfColor.fromHex("#54616A"),
          normalTextColor: PdfColor.fromHex("#FCFBF7"),
          headerLightColor: PdfColor.fromHex("#FCFBF7"),
          headerDarkColor: PdfColor.fromHex("#FFC49A"),
          nameColor: PdfColor.fromHex("#FCFBF7"),
          positionColor: PdfColor.fromHex("#FFC49A"),
          boxColor: PdfColor.fromHex("#C18C66"),
          dateColor: PdfColor.fromHex("#E0DFDC"),
          linkColor: PdfColor.fromHex("#E0DFDC"),

          background: PdfAssets.t31Horizontal,
          link: PdfAssets.link7,
          bullet: PdfAssets.bullet7,

          headerFont: headerFont,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.dMSansRegular();
    normalFont = await PdfGoogleFonts.dMSansRegular();
  }
}

class Resume8Theme1 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume8ThemeModel resume8theme1;
  Future<void> getModel() async {
    await getFonts();
    resume8theme1 = Resume8ThemeModel(
      imageBorderColor: PdfColor.fromHex("#54616A"),
      normalTextColor: PdfColor.fromHex("#4E410F"),
      // headerLightColor:  PdfColor.fromHex("#4E410F"),
      headerDarkColor: PdfColor.fromHex("#4E410F"),
      nameColor: PdfColor.fromHex("#4E410F"),
      positionColor: PdfColor.fromHex("#2F2F2F"),
      boxColor: PdfColor.fromHex("#FFFFFF"),
      dateColor: PdfColor.fromHex("#4E410F"),
      linkColor: PdfColor.fromHex("#4E410F"),
      backgroundColor: PdfColor.fromHex("#FFFFFF"),

      link: PdfAssets.link81,

      headerFont: headerFont,
      normalFont: normalFont,
      nameFont: nameFont,
    );
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.dMSansRegular();
    normalFont = await PdfGoogleFonts.dMSansRegular();
  }
}

class Resume8Theme2 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume8ThemeModel resume8theme2;
  Future<void> getModel() async {
    await getFonts();
    resume8theme2 = Resume8ThemeModel(
      imageBorderColor: PdfColor.fromHex("#54616A"),
      normalTextColor: PdfColor.fromHex("#0F374E"),
      headerDarkColor: PdfColor.fromHex("#0F374E"),
      nameColor: PdfColor.fromHex("#0F374E"),
      positionColor: PdfColor.fromHex("#004B77"),
      boxColor: PdfColor.fromHex("#FFFFFF"),
      dateColor: PdfColor.fromHex("#4E410F"),
      linkColor: PdfColor.fromHex("#0F374E"),
      backgroundColor: PdfColor.fromHex("#FFFFFF"),
      // headerLightColor:  PdfColor.fromHex("#4E410F"),

      link: PdfAssets.link82,

      headerFont: headerFont,
      normalFont: normalFont,
      nameFont: nameFont,
    );
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.dMSansRegular();
    normalFont = await PdfGoogleFonts.dMSansRegular();
  }
}

class Resume8Theme3 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume8ThemeModel resume8theme3;
  Future<void> getModel() async {
    await getFonts();
    resume8theme3 = Resume8ThemeModel(
      imageBorderColor: PdfColor.fromHex("#54616A"),
      normalTextColor: PdfColor.fromHex("#70725E"),
      // headerLightColor:  PdfColor.fromHex("#4E410F"),
      headerDarkColor: PdfColor.fromHex("#70725E"),
      nameColor: PdfColor.fromHex("#70725E"),
      positionColor: PdfColor.fromHex("#6C714D"),
      boxColor: PdfColor.fromHex("#FFFFFF"),
      dateColor: PdfColor.fromHex("#70725E"),
      linkColor: PdfColor.fromHex("#70725E"),
      backgroundColor: PdfColor.fromHex("#FFFFFF"),

      link: PdfAssets.link83,

      headerFont: headerFont,
      normalFont: normalFont,
      nameFont: nameFont,
    );
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.dMSansRegular();
    normalFont = await PdfGoogleFonts.dMSansRegular();
  }
}

class Resume9Theme1 {
  static late Font font;
  late Resume9ThemeModel resume9theme1;
  Future<void> getModel() async {
    resume9theme1 = await getFonts().then((value) => Resume9ThemeModel(
          normalTextColor: PdfColor.fromHex("#000000"),
          headerColor: PdfColor.fromHex("#030094"),
          nameColor: PdfColor.fromHex("#E6E6E6"),
          positionColor: PdfColor.fromHex("#84AEFF"),
          boxBottomBorderColor: PdfColor.fromHex("#04025B"),
          backgroundBoxColor: PdfColor.fromHex('#030094'),
          subHeaderColor: PdfColor.fromHex("#000000"),
          bullet: PdfAssets.bullet91,
          font: font,
        ));
  }

  Future<void> getFonts() async {
    font = await PdfGoogleFonts.outfitRegular();
  }
}

class Resume10Theme1 {
  static late Font headerFont;
  static late Font normalFont;
  late Resume10ThemeModel resume10theme1;
  Future<void> getModel() async {
    resume10theme1 = await getFonts().then((value) => Resume10ThemeModel(
          normalTextColor: PdfColor.fromHex("#000000"),
          headerColor: PdfColor.fromHex("#1E2A5A"),
          nameColor: PdfColor.fromHex("#1E2A5A"),
          positionColor: PdfColor.fromHex("#84AEFF"),
          boxBottomBorderColor: PdfColor.fromHex("#1E2A5A"),
          backgroundBoxColor: PdfColor.fromHex('#940000'),
          subHeaderColor: PdfColor.fromHex("#1E2A5A"),
          imageBorder1: PdfAssets.border41,
          bullet: PdfAssets.bullet41,
          background: PdfAssets.rect41,
          normalFont: normalFont,
          headerFont: headerFont,
          emailIc: PdfAssets.email41,
          phoneIc: PdfAssets.phone41,
          linkIc: PdfAssets.link41,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume11Theme1 {
  static late Font headerFont;
  static late Font normalFont;
  late Resume11ThemeModel resume11theme1;

  get resume12theme1 => null;
  Future<void> getModel() async {
    resume11theme1 = await getFonts().then((value) => Resume11ThemeModel(
          normalTextColor: PdfColor.fromHex("#000000"),
          headerColor: PdfColor.fromHex("#030094"),
          nameColor: PdfColor.fromHex("#000000"),
          positionColor: PdfColor.fromHex("#1E1E1E"),
          boxBottomBorderColor: PdfColor.fromHex("#1E2A5A"),
          boxHorizontalColor: PdfColor.fromHex("#FCD1F2"),
          boxVerticalColor: PdfColor.fromHex('#F8A0E4'),
          subHeaderColor: PdfColor.fromHex("#000000"),
          bullet42: PdfAssets.bullet42,
          background: PdfAssets.rect42,
          emailIc: PdfAssets.emailIc42,
          phoneIc: PdfAssets.phone42,
          linkIc: PdfAssets.link42,
          imageBorder2: PdfAssets.imageBorder2,
          headerFont: headerFont,
          normalFont: normalFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume12Theme1 {
  static late Font headerFont;
  static late Font normalFont;
  late Resume12ThemeModel resume12theme1;
  Future<void> getModel() async {
    resume12theme1 = await getFonts().then((value) => Resume12ThemeModel(
          normalTextColor: PdfColor.fromHex("#0D490E"),
          headerColor: PdfColor.fromHex("#0D490E"),
          nameColor: PdfColor.fromHex("#0D490E"),
          positionColor: PdfColor.fromHex("#84AEFF"),
          boxHorizontalColor: PdfColor.fromHex("#1E1E1E"),
          boxVerticalColor: PdfColor.fromHex('#F8A0E4'),
          subHeaderColor: PdfColor.fromHex("#0D490E"),
          bullet43: PdfAssets.bullet43,
          emailIc: PdfAssets.emailIc43,
          phoneIc: PdfAssets.phoneIc43,
          linkIc: PdfAssets.linkIc43,
          imageBorder3: PdfAssets.imageBorder3,
          background: PdfAssets.rect43,
          headerFont: headerFont,
          normalFont: normalFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume13Theme1 {
  static late Font headerFont;
  static late Font normalFont;
  late Resume13ThemeModel resume13theme1;
  Future<void> getModel() async {
    resume13theme1 = await getFonts().then((value) => Resume13ThemeModel(
          normalTextColor: PdfColor.fromHex("#000000"),
          headerColor: PdfColor.fromHex("#B87397"),
          nameColor: PdfColor.fromHex("#B87397"),
          boxColor: PdfColor.fromHex("#E9FBA2"),
          borderColor: PdfColor.fromHex("#6E6666"),
          subHeaderColor: PdfColor.fromHex("#B87397"),
          bullet51: PdfAssets.bullet51,
          emailIc: PdfAssets.email51,
          phoneIc: PdfAssets.phone51,
          linkIc: PdfAssets.link51,
          imageBorder51: PdfAssets.imageBorder51,
          background: PdfAssets.back51,
          headerFont: headerFont,
          normalFont: normalFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume14Theme1 {
  static late Font headerFont;
  static late Font normalFont;
  late Resume14ThemeModel resume14theme1;
  Future<void> getModel() async {
    resume14theme1 = await getFonts().then((value) => Resume14ThemeModel(
          normalTextColor: PdfColor.fromHex("#000000"),
          headerColor: PdfColor.fromHex("#1E3A8A"),
          nameColor: PdfColor.fromHex("#1E3A8A"),
          subHeaderColor: PdfColor.fromHex("#1E3A8A"),
          bullet52: PdfAssets.bullet52,
          background: PdfAssets.back52,
          emailIc: PdfAssets.email52,
          phoneIc: PdfAssets.phone52,
          linkIc: PdfAssets.link52,
          headerFont: headerFont,
          normalFont: normalFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume15Theme1 {
  static late Font headerFont;
  static late Font normalFont;
  late Resume15ThemeModel resume15theme1;
  Future<void> getModel() async {
    resume15theme1 = await getFonts().then((value) => Resume15ThemeModel(
          normalTextColor: PdfColor.fromHex("#000000"),
          headerColor: PdfColor.fromHex("#030094"),
          nameColor: PdfColor.fromHex("#000000"),
          subHeaderColor: PdfColor.fromHex("#000000"),
          bullet53: PdfAssets.bullet53,
          background: PdfAssets.back53,
          emailIc: PdfAssets.email53,
          phoneIc: PdfAssets.phone53,
          linkIc: PdfAssets.link53,
          headerFont: headerFont,
          normalFont: normalFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume16Theme1 {
  static late Font headerFont;
  static late Font normalFont;
  late Resume16ThemeModel resume16theme1;
  Future<void> getModel() async {
    await getFonts();
    resume16theme1 = Resume16ThemeModel(
      normalTextColor: PdfColor.fromHex("#000000"),
      headerColor: PdfColor.fromHex("#0D490E"),
      nameColor: PdfColor.fromHex("#0D490E"),
      subHeaderColor: PdfColor.fromHex("#0D490E"),
      bullet54: PdfAssets.bullet54,
      background: PdfAssets.back54,
      emailIc: PdfAssets.email54,
      phoneIc: PdfAssets.phone54,
      linkIc: PdfAssets.link54,
      headerFont: headerFont,
      normalFont: normalFont,
    );
    print("Resume16Theme1: back54 path set to: ${resume16theme1.back54}");
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume17Theme1 {
  static late Font headerFont;
  static late Font normalFont;
  late Resume17ThemeModel resume17theme1;
  Future<void> getModel() async {
    resume17theme1 = await getFonts().then((value) => Resume17ThemeModel(
          normalTextColor: PdfColor.fromHex("#000000"),
          headerColor: PdfColor.fromHex("#030094"),
          nameColor: PdfColor.fromHex("#000000"),
          subHeaderColor: PdfColor.fromHex("#000000"),
          bullet61: PdfAssets.bullet61,
          background: PdfAssets.rect61,
          emailIc: PdfAssets.email61,
          phoneIc: PdfAssets.phone61,
          linkIc: PdfAssets.link61,
          headerFont: headerFont,
          normalFont: normalFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume18Theme1 {
  static late Font headerFont;
  static late Font normalFont;
  late Resume18ThemeModel resume18theme1;
  Future<void> getModel() async {
    resume18theme1 = await getFonts().then((value) => Resume18ThemeModel(
          normalTextColor: PdfColor.fromHex("#000000"),
          headerColor: PdfColor.fromHex("#030094"),
          nameColor: PdfColor.fromHex("#000000"),
          subHeaderColor: PdfColor.fromHex("#000000"),
          bullet62: PdfAssets.bullet62,
          background: PdfAssets.rect62,
          emailIc: PdfAssets.email62,
          phoneIc: PdfAssets.phone62,
          linkIc: PdfAssets.link62,
          headerFont: headerFont,
          normalFont: normalFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume19Theme1 {
  static late Font headerFont;
  static late Font normalFont;
  late Resume19ThemeModel resume19theme1;
  Future<void> getModel() async {
    resume19theme1 = await getFonts().then((value) => Resume19ThemeModel(
          normalTextColor: PdfColor.fromHex("#000000"),
          headerColor: PdfColor.fromHex("#030094"),
          nameColor: PdfColor.fromHex("#000000"),
          subHeaderColor: PdfColor.fromHex("#000000"),
          bullet63: PdfAssets.bullet63,
          background: PdfAssets.rect63,
          emailIc: PdfAssets.email63,
          phoneIc: PdfAssets.phone63,
          linkIc: PdfAssets.link63,
          headerFont: headerFont,
          normalFont: normalFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume20Theme1 {
  static late Font headerFont;
  static late Font normalFont;
  late Resume20ThemeModel resume20theme1;
  Future<void> getModel() async {
    resume20theme1 = await getFonts().then((value) => Resume20ThemeModel(
          normalTextColor: PdfColor.fromHex("#000000"),
          headerColor: PdfColor.fromHex("#030094"),
          nameColor: PdfColor.fromHex("#000000"),
          subHeaderColor: PdfColor.fromHex("#000000"),
          bullet64: PdfAssets.bullet64,
          background: PdfAssets.rect64,
          emailIc: PdfAssets.email64,
          phoneIc: PdfAssets.phone64,
          linkIc: PdfAssets.link64,
          headerFont: headerFont,
          normalFont: normalFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class Resume21Theme1 {
  static late Font nameFont;
  static late Font headerFont;
  static late Font normalFont;

  late Resume21ThemeModel resume21theme1;
  Future<void> getModel() async {
    resume21theme1 = await getFonts().then((value) => Resume21ThemeModel(
          // normalTextColor: PdfColor.fromHex("#FCFBF7"),
          // headerColor: PdfColor.fromHex("#C69AFF"),
          // nameColor: PdfColor.fromHex("#FCFBF7"),
          // subHeaderColor: PdfColor.fromHex("#C69AFF"),
          // positionColor: PdfColor.fromHex("#C69AFF"),

          normalTextColor: PdfColor.fromHex("#FCFBF7"),
          headerColor: PdfColor.fromHex("#C69AFF"),
          nameColor: PdfColor.fromHex("#FCFBF7"),
          positionColor: PdfColor.fromHex("#C69AFF"),
          subHeaderColor: PdfColor.fromHex("#5A249E"),
          imageBorderColor: PdfColor.fromHex("#C69AFF"),
          dateColor: PdfColor.fromHex("#5A249E"),
          linkColor: PdfColor.fromHex("#C69AFF"),

          background: PdfAssets.back71,
          linkIc: PdfAssets.link7,
          bullet71: PdfAssets.bullet7,

          headerFont: headerFont,
          normalFont: normalFont,
        ));
  }

  Future<void> getFonts() async {
    headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.dMSansRegular();
    normalFont = await PdfGoogleFonts.dMSansRegular();
  }
}

//*****************************************************************************
class CL1Theme1 {
  static late Font nameFont;
  // static late Font headerFont;
  static late Font normalFont;

  late CL1ThemeModel cl1themeModel;
  Future<void> getModel() async {
    cl1themeModel = await getFonts().then((value) => CL1ThemeModel(
          dividertColor: PdfColor.fromHex("#C0C0C0"),
          normalTextColor: PdfColor.fromHex("#896565"),
          nameColor: PdfColor.fromHex("#6A3232"),
          backgroundColor: PdfColor.fromHex("#F9F4F4"),

          // headerFont: headerFont,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class CL1Theme2 {
  static late Font nameFont;
  // static late Font headerFont;
  static late Font normalFont;

  late CL1ThemeModel cl1themeModel;
  Future<void> getModel() async {
    cl1themeModel = await getFonts().then((value) => CL1ThemeModel(
          dividertColor: PdfColor.fromHex("#DDF0E2"),
          normalTextColor: PdfColor.fromHex("#235938"),
          nameColor: PdfColor.fromHex("#243029"),
          backgroundColor: PdfColor.fromHex("#F8FBF8"),

          // headerFont: headerFont,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class CL1Theme3 {
  static late Font nameFont;
  // static late Font headerFont;
  static late Font normalFont;

  late CL1ThemeModel cl1themeModel;
  Future<void> getModel() async {
    cl1themeModel = await getFonts().then((value) => CL1ThemeModel(
          dividertColor: PdfColor.fromHex("#D1CDE3"),
          normalTextColor: PdfColor.fromHex("#414085"),
          nameColor: PdfColor.fromHex("#06043F"),
          backgroundColor: PdfColor.fromHex("#FDFEFF"),

          // headerFont: headerFont,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class CL2Theme1 {
  static late Font nameFont;
  static late Font normalFont;

  late CL2ThemeModel cl2themeModel;
  Future<void> getModel() async {
    cl2themeModel = await getFonts().then((value) => CL2ThemeModel(
          imageBorder: PdfColor.fromHex("#F8EDED"),
          verticalObjColor: PdfColor.fromHex("#B27B80"),
          normalTextColor: PdfColor.fromHex("#46535F"),
          nameColor: PdfColor.fromHex("#F8EDED"),
          backgroundColor: PdfColor.fromHex("#F8EDED"),
          emailimg: PdfAssets.email21,
          phoneimg: PdfAssets.phone21,
          locationimg: PdfAssets.loc21,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class CL2Theme2 {
  static late Font nameFont;
  static late Font normalFont;

  late CL2ThemeModel cl2themeModel;
  Future<void> getModel() async {
    cl2themeModel = await getFonts().then((value) => CL2ThemeModel(
          imageBorder: PdfColor.fromHex("#F0E2CD"),
          verticalObjColor: PdfColor.fromHex("#8C7C65"),
          normalTextColor: PdfColor.fromHex("#514534"),
          nameColor: PdfColor.fromHex("#F0E2CD"),
          backgroundColor: PdfColor.fromHex("#F0E2CD"),
          emailimg: PdfAssets.email22,
          phoneimg: PdfAssets.phone22,
          locationimg: PdfAssets.loc22,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class CL2Theme3 {
  static late Font nameFont;
  static late Font normalFont;

  late CL2ThemeModel cl2themeModel;
  Future<void> getModel() async {
    cl2themeModel = await getFonts().then((value) => CL2ThemeModel(
          imageBorder: PdfColor.fromHex("#ECFBFF"),
          verticalObjColor: PdfColor.fromHex("#61AFC1"),
          normalTextColor: PdfColor.fromHex("#0B4451"),
          nameColor: PdfColor.fromHex("#ECFBFF"),
          backgroundColor: PdfColor.fromHex("#ECFBFF"),
          emailimg: PdfAssets.email23,
          phoneimg: PdfAssets.phone23,
          locationimg: PdfAssets.loc23,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.inknutAntiquaRegular();
    normalFont = await PdfGoogleFonts.interRegular();
  }
}

class CL3Theme1 {
  static late Font nameFont;
  static late Font normalFont;

  late CL3ThemeModel cl3themeModel;
  Future<void> getModel() async {
    cl3themeModel = await getFonts().then((value) => CL3ThemeModel(
          imageBorder: PdfColor.fromHex("#DEBFA5"),
          normalTextColor: PdfColor.fromHex("#46535F"),
          nameColor: PdfColor.fromHex("#151B4B"),
          background: PdfAssets.back31,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.gravitasOneRegular();
    normalFont = await PdfGoogleFonts.arimoRegular();
  }
}

class CL3Theme2 {
  static late Font nameFont;
  static late Font normalFont;

  late CL3ThemeModel cl3themeModel;
  Future<void> getModel() async {
    cl3themeModel = await getFonts().then((value) => CL3ThemeModel(
          imageBorder: PdfColor.fromHex("#A6C480"),
          normalTextColor: PdfColor.fromHex("#64754F"),
          nameColor: PdfColor.fromHex("#656100"),
          background: PdfAssets.back32,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.gravitasOneRegular();
    normalFont = await PdfGoogleFonts.arimoRegular();
  }
}

class CL3Theme3 {
  static late Font nameFont;
  static late Font normalFont;

  late CL3ThemeModel cl3themeModel;
  Future<void> getModel() async {
    cl3themeModel = await getFonts().then((value) => CL3ThemeModel(
          imageBorder: PdfColor.fromHex("#77AEB5"),
          normalTextColor: PdfColor.fromHex("#134349"),
          nameColor: PdfColor.fromHex("#595959"),
          background: PdfAssets.back33,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.gravitasOneRegular();
    normalFont = await PdfGoogleFonts.arimoRegular();
  }
}

class CL4Theme1 {
  static late Font nameFont;
  static late Font normalFont;

  late CL4ThemeModel cl4themeModel;
  Future<void> getModel() async {
    cl4themeModel = await getFonts().then((value) => CL4ThemeModel(
          imageBorder: PdfColor.fromHex("#F9FCFF"),
          normalTextColor: PdfColor.fromHex("#46535F"),
          nameColor: PdfColor.fromHex("#151B4B"),
          borderImage: PdfAssets.clborder41,
          background: PdfAssets.back41,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class CL4Theme2 {
  static late Font nameFont;
  static late Font normalFont;

  late CL4ThemeModel cl4themeModel;
  Future<void> getModel() async {
    cl4themeModel = await getFonts().then((value) => CL4ThemeModel(
          imageBorder: PdfColor.fromHex("#F9FCFF"),
          normalTextColor: PdfColor.fromHex("#082C41"),
          nameColor: PdfColor.fromHex("#082C41"),
          borderImage: PdfAssets.clborder42,
          background: PdfAssets.back42,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class CL4Theme3 {
  static late Font nameFont;
  static late Font normalFont;

  late CL4ThemeModel cl4themeModel;
  Future<void> getModel() async {
    cl4themeModel = await getFonts().then((value) => CL4ThemeModel(
          imageBorder: PdfColor.fromHex("#F9FCFF"),
          normalTextColor: PdfColor.fromHex("#1D331B"),
          nameColor: PdfColor.fromHex("#194B15"),
          borderImage: PdfAssets.clborder43,
          background: PdfAssets.back43,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class CL5Theme1 {
  static late Font nameFont;
  static late Font normalFont;

  late CL5ThemeModel cl5themeModel;
  Future<void> getModel() async {
    cl5themeModel = await getFonts().then((value) => CL5ThemeModel(
          imageBorder: PdfColor.fromHex("#4895E0"),
          normalTextColor: PdfColor.fromHex("#46535F"),
          nameColor: PdfColor.fromHex("#B87397"),
          background: PdfAssets.back51,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class CL5Theme2 {
  static late Font nameFont;
  static late Font normalFont;

  late CL5ThemeModel cl5themeModel;
  Future<void> getModel() async {
    cl5themeModel = await getFonts().then((value) => CL5ThemeModel(
          imageBorder: PdfColor.fromHex("#B87397"),
          normalTextColor: PdfColor.fromHex("#46535F"),
          nameColor: PdfColor.fromHex("#46535F"),
          background: PdfAssets.back52,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class CL5Theme3 {
  static late Font nameFont;
  static late Font normalFont;

  late CL5ThemeModel cl5themeModel;
  Future<void> getModel() async {
    cl5themeModel = await getFonts().then((value) => CL5ThemeModel(
          imageBorder: PdfColor.fromHex("#99C364"),
          normalTextColor: PdfColor.fromHex("#5F5D51"),
          nameColor: PdfColor.fromHex("#796601"),
          background: PdfAssets.back53,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class CL5Theme4 {
  static late Font nameFont;
  static late Font normalFont;

  late CL5ThemeModel cl5themeModel;
  Future<void> getModel() async {
    cl5themeModel = await getFonts().then((value) => CL5ThemeModel(
          imageBorder: PdfColor.fromHex("#796601"),
          normalTextColor: PdfColor.fromHex("#676C60"),
          nameColor: PdfColor.fromHex("#476324"),
          background: PdfAssets.back54,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.goldmanRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class CL6Theme1 {
  static late Font nameFont;
  static late Font normalFont;

  late CL6ThemeModel cl6themeModel;
  Future<void> getModel() async {
    cl6themeModel = await getFonts().then((value) => CL6ThemeModel(
          imageBorder: PdfColor.fromHex("#D698A9"),
          normalTextColor: PdfColor.fromHex("#6E4651"),
          nameColor: PdfColor.fromHex("#6E4651"),
          objBackImg: PdfAssets.cl_rect61,
          locationImg: PdfAssets.cl_loc61,
          emailImg: PdfAssets.clemail61,
          phoneImg: PdfAssets.cl_phone61,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.rozhaOneRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class CL6Theme2 {
  static late Font nameFont;
  static late Font normalFont;

  late CL6ThemeModel cl6themeModel;
  Future<void> getModel() async {
    cl6themeModel = await getFonts().then((value) => CL6ThemeModel(
          imageBorder: PdfColor.fromHex("#8D8572"),
          normalTextColor: PdfColor.fromHex("#8D8572"),
          nameColor: PdfColor.fromHex("#413822"),
          objBackImg: PdfAssets.cl_rect62,
          locationImg: PdfAssets.cl_loc62,
          emailImg: PdfAssets.clemail62,
          phoneImg: PdfAssets.cl_phone62,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.rozhaOneRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class CL6Theme3 {
  static late Font nameFont;
  static late Font normalFont;

  late CL6ThemeModel cl6themeModel;
  Future<void> getModel() async {
    cl6themeModel = await getFonts().then((value) => CL6ThemeModel(
          imageBorder: PdfColor.fromHex("#5F725F"),
          normalTextColor: PdfColor.fromHex("#0D490E"),
          nameColor: PdfColor.fromHex("#0D490E"),
          objBackImg: PdfAssets.cl_rect63,
          locationImg: PdfAssets.cl_loc63,
          emailImg: PdfAssets.clemail63,
          phoneImg: PdfAssets.cl_phone63,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.rozhaOneRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}

class CL6Theme4 {
  static late Font nameFont;
  static late Font normalFont;

  late CL6ThemeModel cl6themeModel;
  Future<void> getModel() async {
    cl6themeModel = await getFonts().then((value) => CL6ThemeModel(
          imageBorder: PdfColor.fromHex("#54616A"),
          normalTextColor: PdfColor.fromHex("#0D3049"),
          nameColor: PdfColor.fromHex("#0D3049"),
          objBackImg: PdfAssets.cl_rect64,
          locationImg: PdfAssets.cl_loc64,
          emailImg: PdfAssets.clemail64,
          phoneImg: PdfAssets.cl_phone64,
          normalFont: normalFont,
          nameFont: nameFont,
        ));
  }

  Future<void> getFonts() async {
    // headerFont = await PdfGoogleFonts.dMSansRegular();
    nameFont = await PdfGoogleFonts.rozhaOneRegular();
    normalFont = await PdfGoogleFonts.averageSansRegular();
  }
}
