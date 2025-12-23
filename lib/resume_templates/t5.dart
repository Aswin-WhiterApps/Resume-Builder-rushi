import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../firestore/user_firestore.dart';
import '../Presentation/resources/strings_manager.dart';
import '../Presentation/resources/values_manager.dart';
import '../Presentation/resources/pdf_assets.dart';
import '../model/model.dart';
import '../model/resume_theme_model.dart';
import '../my_singleton.dart';

class Template5 {
  late final Font? normalFont;
  late final Font? headerFont;
  late final PdfColor normalTextColor;
  late final PdfColor headerDarkColor;
  late final PdfColor nameColor;
  late final PdfColor imageBorder;

  late final String? backgroundAsset;
  late final String? emailAsset;
  late final String? phoneAsset;
  late final String? linkAsset;
  late final String? bulletAsset;
  late final String? bulletDarkAsset;
  late final String? bulletLightAsset;
  late final String? bulletDark;
  late final String? bulletLight;

  MemoryImage? backgroundImage;
  MemoryImage? emailIcon;
  MemoryImage? phoneIcon;
  MemoryImage? linkIcon;
  MemoryImage? bulletIcon;
  MemoryImage? bulletDarkIcon;
  MemoryImage? bulletLightIcon;
  MemoryImage? profileImage;
  MemoryImage? t5_bulletDark;
  MemoryImage? t5_bulletLight;

  IntroModel? introData;
  ContactModel? contactData;
  SummeryModel? summeryData;
  List<EducationModel> educationData = [];
  List<WorkModel> workData = [];
  List<SectionModel> sectionData = [];

  Template5(
      {required Resume5ThemeModel? resume5themeModel,
      required CL5ThemeModel? cl5themeModel}) {
    normalTextColor = resume5themeModel?.normalTextColor ?? PdfColors.blue;
    headerDarkColor = resume5themeModel?.headerDarkColor ?? PdfColors.blue;
    nameColor = resume5themeModel?.nameColor ?? PdfColors.blue;
    imageBorder = resume5themeModel?.imageBorder ?? PdfColors.white;

    backgroundAsset = resume5themeModel?.background ?? PdfAssets.back22;
    emailAsset = resume5themeModel?.email;
    phoneAsset = resume5themeModel?.phone;
    linkAsset = resume5themeModel?.link;
    bulletAsset = resume5themeModel?.bullet;
    bulletDarkAsset = resume5themeModel?.bulletDark ?? PdfAssets.bullet22dark;
    bulletLightAsset = resume5themeModel?.bulletLight ?? PdfAssets.bullet22light;
    bulletDark = resume5themeModel?.bulletDark ?? PdfAssets.bullet22dark;
    bulletLight = resume5themeModel?.bulletLight ?? PdfAssets.bullet22light;

    normalFont = resume5themeModel?.normalFont ?? Font.helvetica();
    headerFont = resume5themeModel?.headerFont ?? Font.helvetica();
  }

  Future<bool> initializeDataAndAssets() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      print("Error in Template5: User or Resume ID is null.");
      return false;
    }

    final fireUser = FireUser();

    try {
      print("Template5: Fetching all data for PDF generation...");
      final results = await Future.wait([
        fireUser.getResume(userId: userId, resumeId: resumeId),
        fireUser.getWorkExperiences(userId: userId, resumeId: resumeId),
        fireUser.getEducations(userId: userId, resumeId: resumeId),
        fireUser.getAllSections(userId: userId, resumeId: resumeId),
      ]);

      final resume = results[0] as ResumeModel?;
      if (resume != null) {
        introData = resume.intro;
        contactData = resume.contact;
        summeryData = resume.summary;
      } else {
        print("Template5: Main resume document not found.");
      }

      workData = results[1] as List<WorkModel>;
      educationData = results[2] as List<EducationModel>;
      sectionData = (results[3] as List<SectionModel>)
          .where((s) => s.value != null && s.value!.isNotEmpty)
          .toList();

      final imageFutures = <Future>[];

      if (backgroundAsset != null && backgroundAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(backgroundAsset!).then((data) =>
            backgroundImage = MemoryImage(data.buffer.asUint8List())));
      }
      if (emailAsset != null && emailAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(emailAsset!).then(
            (data) => emailIcon = MemoryImage(data.buffer.asUint8List())));
      }
      if (phoneAsset != null && phoneAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(phoneAsset!).then(
            (data) => phoneIcon = MemoryImage(data.buffer.asUint8List())));
      }
      if (linkAsset != null && linkAsset!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(linkAsset!)
            .then((data) => linkIcon = MemoryImage(data.buffer.asUint8List())));
      }
      if (bulletAsset != null && bulletAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bulletAsset!).then(
            (data) => bulletIcon = MemoryImage(data.buffer.asUint8List())));
      }
      if (bulletDarkAsset != null && bulletDarkAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bulletDarkAsset!).then(
            (data) => bulletDarkIcon = MemoryImage(data.buffer.asUint8List())));
      }
      if (bulletLightAsset != null && bulletLightAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bulletLightAsset!).then((data) =>
            bulletLightIcon = MemoryImage(data.buffer.asUint8List())));
      }

      if (bulletDark != null && bulletDark!.isNotEmpty)
        t5_bulletDark = MemoryImage(
            (await rootBundle.load(bulletDark!)).buffer.asUint8List());

      if (bulletLight != null && bulletLight!.isNotEmpty)
        t5_bulletLight = MemoryImage(
            (await rootBundle.load(bulletLight!)).buffer.asUint8List());

      if (introData?.imagePath != null && introData!.imagePath!.isNotEmpty) {
        final imageFile = File(introData!.imagePath!);
        if (await imageFile.exists()) {
          imageFutures.add(imageFile
              .readAsBytes()
              .then((bytes) => profileImage = MemoryImage(bytes)));
        }
      }

      await Future.wait(imageFutures);
      print("Template5: All assets loaded successfully.");
      return true;
    } catch (e) {
      print("Error initializing data/assets in Template5: $e");
      return false;
    }
  }

  Future<File?> createPage() async {
    print("Template5: Starting PDF generation...");
    final bool isInitialized = await initializeDataAndAssets();
    if (!isInitialized) {
      print("Template5: PDF generation failed due to initialization errors.");
      return null;
    }

    final pdf = Document();

    pdf.addPage(MultiPage(
        pageTheme: PageTheme(
            margin: EdgeInsets.zero,
            pageFormat: PdfPageFormat.a4,
            buildBackground: (context) {
              return backgroundImage != null
                  ? Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover, image: backgroundImage!)))
                  : Container(color: PdfColors.grey100);
            }),
        build: (Context context) {
          return [_buildSinglePageLayout()];
        }));

    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final String timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File("${outputDir.path}/Resume_T5_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());
      print("Template5: PDF saved to ${file.path}");
      return file;
    } catch (e) {
      print('Failed to save PDF for Template5: $e');
      return null;
    }
  }

  Widget _buildSinglePageLayout() {
    final name =
        "${introData?.firstName ?? ""} ${introData?.lastName ?? ""}".trim();
    final List<Widget> leftColumnItems = [];
    final List<Widget> rightColumnItems = [];

    leftColumnItems.add(
      Container(
        padding: EdgeInsets.only(top: 60, bottom: 10, right: 20, left: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (profileImage != null)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: imageBorder),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(child: Image(profileImage!, fit: BoxFit.cover)),
              )
            else
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: PdfColors.grey300,
                  border: Border.all(width: 2, color: imageBorder),
                  shape: BoxShape.circle,
                ),
              ),
            SizedBox(height: 10),
            Text(
              name.isEmpty ? "Your Name" : name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: nameColor,
                font: headerFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    leftColumnItems.add(
      Padding(
        padding: EdgeInsets.fromLTRB(50, 5, 20, 5),
        child: _buildRotatedSection(
          title: AppStrings.t2,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (emailIcon != null)
                _buildContactRow(emailIcon!, contactData?.email),
              if (phoneIcon != null)
                _buildContactRow(phoneIcon!, contactData?.phone),
              if (linkIcon != null)
                _buildContactRow(linkIcon!, contactData?.personnelWeb),
            ],
          ),
        ),
      ),
    );

    for (int i = 0; i < sectionData.length; i++) {
      if (i % 2 == 0) {
        leftColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(50, 5, 20, 5),
            child: _buildRotatedSectionFromModel(sectionData[i]),
          ),
        );
      }
    }

    if (summeryData?.summery?.isNotEmpty ?? false) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(20, 60, 20, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getHeaderText(text: AppStrings.t5),
              SizedBox(height: 5),
              _getParagraph(text: summeryData!.summery!),
            ],
          ),
        ),
      );
    }

    if (educationData.isNotEmpty) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          child: _buildRightColumnSection(
            title: AppStrings.t3,
            items: educationData
                .map(
                  (edu) =>
                      "${edu.schoolName ?? ''}\n[${edu.dateFrom ?? ''} - ${edu.present == true ? 'Present' : edu.dateTo ?? ''}]",
                )
                .toList(),
            bottomPadding: 3.0,
          ),
        ),
      );
    }

    if (workData.isNotEmpty) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(20, 3, 20, 5),
          child: _buildRightColumnSection(
            title: AppStrings.t4,
            items: workData
                .map(
                  (work) =>
                      "${work.compName ?? ''}, ${work.compLocation ?? ''}\nPosition: ${work.compPosition ?? ''}\nDuration: ${work.present == true ? '[${work.dateFrom ?? ''}] - Present' : '[${work.dateFrom ?? ''} - ${work.dateTo ?? ''}]'}",
                )
                .toList(),
            bottomPadding: 3.0,
          ),
        ),
      );
    }

    for (int i = 0; i < sectionData.length; i++) {
      if (i % 2 == 1) {
        rightColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(20, 3, 20, 5),
            child: _buildRightColumnSectionFromModel(sectionData[i]),
          ),
        );
      }
    }

    return Container(
      padding: EdgeInsets.all(0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: leftColumnItems,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rightColumnItems,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(MemoryImage icon, String? text) {
    if (text == null || text.isEmpty) return Container();
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(children: [
        SizedBox(width: 12, height: 12, child: Image(icon)),
        SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: normalTextColor, font: normalFont, fontSize: 9))),
      ]),
    );
  }

  Widget _getParagraph({required String text}) {
    return Text(text,
        textAlign: TextAlign.justify,
        style:
            TextStyle(color: normalTextColor, fontSize: 7, font: normalFont));
  }

  Widget _getNormalText({required String text}) {
    return Padding(
      padding: EdgeInsets.only(left: AppPadding.p12, bottom: 2),
      child: Text(_sanitizeText(text),
          textAlign: TextAlign.left,
          softWrap: true,
          style: TextStyle(
            color: normalTextColor,
            fontSize: 9,
            font: normalFont,
          )),
    );
  }

  String _sanitizeText(String s) {
    var out = s.replaceAll(RegExp(r'[\u0000-\u001F\uFFFD]'), ' ');
    out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
    return out;
  }

  Widget _getHeaderText({required String text}) {
    return Text(text.toUpperCase(),
        style: TextStyle(
            color: headerDarkColor,
            fontSize: 12,
            font: headerFont,
            fontWeight: FontWeight.bold));
  }

  Widget _buildRightColumnSection(
      {required String title,
      required List<String> items,
      double bottomPadding = 3.0,
      double headerSpacing = 3.0}) {
      final MemoryImage? bulletToUse = t5_bulletLight ?? bulletIcon;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _getHeaderText(text: title),
        SizedBox(height: headerSpacing),
        for (final item in items)
          Padding(
            padding: EdgeInsets.only(left: AppPadding.p12, bottom: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (bulletToUse != null) Image(bulletToUse, width: 5, height: 5),
              SizedBox(width: 8),
              Expanded(child: _getNormalText(text: item)),
            ]),
          ),
      ]),
    );
  }

  Widget _buildRotatedSection({
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _getHeaderText(text: title),
        SizedBox(height: 4),
        content,
      ],
    );
  }

  Widget _buildRightColumnSectionFromModel(SectionModel sectionModel) {
    final List<String> items = sectionModel.value
            ?.split('@@@')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    return _buildRightColumnSection(title: sectionModel.id, items: items);
  }

  Widget _buildRotatedSectionFromModel(SectionModel sectionModel) {
    final List<String> items = sectionModel.value
            ?.split('@@@')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];

    final MemoryImage? bulletToUse = bulletDarkIcon ?? bulletIcon;
    return _buildRotatedSection(
      title: sectionModel.id,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (bulletToUse != null)
                  Image(bulletToUse, width: 4, height: 4),
                SizedBox(width: 5),
                Expanded(child: _getNormalText(text: item)),
              ]),
            ),
        ],
      ),
    );
  }
}
