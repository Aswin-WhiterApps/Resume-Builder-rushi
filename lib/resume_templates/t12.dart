import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:resume_builder/Presentation/resources/strings_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:resume_builder/Presentation/resources/pdf_assets.dart';
import 'package:resume_builder/firestore/user_firestore.dart';

import '../model/model.dart';
import '../model/resume_theme_model.dart';
import '../my_singleton.dart';

class Template12 {
  late final Font? normalFont;
  late final Font? headerFont;
  late final PdfColor? subHeaderColor;
  late final PdfColor? headerColor;
  late final PdfColor? nameColor;
  late final PdfColor? positionColor;
  late final PdfColor? boxBottomBorderColor;
  late final PdfColor? boxHorizontalColor;
  late final PdfColor? boxVerticalColor;
  late final PdfColor? normalTextColor;
  late final PdfColor? backgroundBoxColor;
  

  late final String? bullet43;
  late final String? background;
  late final String? imageBorder;
  late final String? emailIc;
  late final String? phoneIc;
  late final String? linkIc;

  MemoryImage? backgroundImage;
  MemoryImage? bulletImage;
  MemoryImage? profileImage;
  MemoryImage? imageBorder3;
  MemoryImage? email_43;
  MemoryImage? phone_43;
  MemoryImage? link_43;

  Resume12ThemeModel? resume12theme;

  IntroModel? introData;
  ContactModel? contactData;
  SummeryModel? summeryData;
  List<EducationModel?>? educationData;
  List<WorkModel?>? workData;
  List<SectionModel?> sectionData = [];

  Template12({required this.resume12theme}) {

    normalFont = resume12theme?.normalFont ?? Font.helvetica();
    headerFont = resume12theme?.headerFont ?? Font.helveticaBold(); 
    
    subHeaderColor = resume12theme?.subHeaderColor ?? PdfColor.fromHex("#0D490E");
    headerColor = resume12theme?.headerColor ?? PdfColor.fromHex("#0D490E");
    nameColor = resume12theme?.nameColor ?? PdfColor.fromHex("#0D490E");
    normalTextColor = resume12theme!.normalTextColor ?? PdfColor.fromHex("#0D490E");
    positionColor = resume12theme!.positionColor ?? PdfColor.fromHex("#3B82F6");
    boxHorizontalColor = resume12theme!.boxHorizontalColor ?? PdfColor.fromHex("#DBEAFE");
    boxVerticalColor = resume12theme!.boxVerticalColor ?? PdfColor.fromHex('#93C5FD');    
    backgroundBoxColor = resume12theme!.boxHorizontalColor ?? PdfColor.fromHex("#0D490E");
    boxBottomBorderColor = resume12theme!.boxBottomBorderColor ?? PdfColor.fromHex("#0D490E");
    bullet43 = resume12theme!.bullet43 ?? PdfAssets.bullet43;
    background = resume12theme?.background ?? PdfAssets.rect43;
    imageBorder = resume12theme?.imageBorder3 ?? PdfAssets.imageBorder3;
    emailIc = resume12theme?.emailIc ?? PdfAssets.emailIc43;
    phoneIc = resume12theme?.phoneIc ?? PdfAssets.phoneIc43;
    linkIc = resume12theme?.linkIc ?? PdfAssets.linkIc43;
  }

    Future<bool> _initializeDataAndAssets() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      print("Error in Template12: User or Resume ID is null.");
      return false;
    }

    final fireUser = FireUser();

    try {
      final results = await Future.wait([
        fireUser.getResume(userId: userId, resumeId: resumeId),
        fireUser.getWorkExperiences(userId: userId, resumeId: resumeId),
        fireUser.getEducations(userId: userId, resumeId: resumeId),
        fireUser.getAllSections(userId: userId, resumeId: resumeId),
      ]);

      final resume = results[0] as ResumeModel?;
      workData = results[1] as List<WorkModel>;
      educationData = results[2] as List<EducationModel>;
      // sections will be parsed after resume checks to allow filtering

      if (resume != null) {
        introData = resume.intro;
        contactData = resume.contact;
        summeryData = resume.summary;
      } else {
        print("Template12: Main resume document not found.");
      }

      workData = results[1] as List<WorkModel>;
      educationData = results[2] as List<EducationModel>;

      final rawSections = results[3] as List<SectionModel>;
      sectionData = rawSections.where((s) {
        final idLower = (s.id).toLowerCase();
        if (idLower.contains('cover')) return false;
        return (s.value != null && s.value!.isNotEmpty) ||
            (s.description != null && s.description!.isNotEmpty);
      }).toList();

      final imageFutures = <Future>[];

     if (imageBorder != null && imageBorder!.isNotEmpty) {
        imageFutures.add(rootBundle.load(imageBorder!).then(
            (data) => imageBorder3 = MemoryImage(data.buffer.asUint8List())));
      }

      if (bullet43 != null && bullet43!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bullet43!).then((byteData) {
          bulletImage = MemoryImage(byteData.buffer.asUint8List());
        }));
      }
      if (emailIc != null && emailIc!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(emailIc!)
            .then((data) => email_43 = MemoryImage(data.buffer.asUint8List())));
      }
      if (phoneIc != null && phoneIc!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(phoneIc!)
            .then((data) => phone_43 = MemoryImage(data.buffer.asUint8List())));
      }
      if (linkIc != null && linkIc!.isNotEmpty) {
        // previously this incorrectly assigned the link image into phone_41.
        // Store the loaded link image into link_41 instead.
        imageFutures.add(rootBundle
            .load(linkIc!)
            .then((data) => link_43 = MemoryImage(data.buffer.asUint8List())));
      }

      if (background != null && background!.isNotEmpty) {
        imageFutures.add(rootBundle.load(background!).then((data) =>
            backgroundImage = MemoryImage(data.buffer.asUint8List())));
      }


      if (introData?.imagePath != null && introData!.imagePath!.isNotEmpty) {
        final imageFile = File(introData!.imagePath!);
        if (await imageFile.exists()) {
          imageFutures.add(imageFile
              .readAsBytes()
              .then((bytes) => profileImage = MemoryImage(bytes)));
        }
      }

      await Future.wait(imageFutures);
      print("Template12: All assets loaded successfully.");
      return true;
    } catch (e) {
      print("Error initializing data/assets in Template11: $e");
      return false;
    }
  }

  Future<File?> createPage() async {
    print(" Template12: Starting PDF generation...");
    final bool isInitialized = await _initializeDataAndAssets();
    if (!isInitialized) {
      print(" Template12: PDF generation failed due to initialization errors.");
      return null;
    }

    print(" Template12: Building PDF widgets...");
    print(
        " Template12: introData=${introData != null ? '${introData?.firstName ?? ''} ${introData?.lastName ?? ''}' : 'null'}");
    print(
        " Template12: contactData=${contactData != null ? 'exists' : 'null'}");
    print(
        " Template12: summeryData=${summeryData != null ? 'exists' : 'null'}");
    print(" Template12: workData.length=${workData?.length}");
    print(" Template12: educationData.length=${educationData?.length}");
    print(" Template12: sectionData.length=${sectionData.length}");

    final pdf = Document();

    print(" Template12: All widgets built successfully");

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
      final file = File("${outputDir.path}/Resume_T12_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());
      print("Pdf Saved To ${file.path}");
      return file;
    } catch (e) {
      print('Failed to save PDF for Template12: $e');
      return null;
    }
  }

  String _truncateTitle(String title) {
    const int maxChars = 12; 
    if (title.length <= maxChars) {
      return title;
    }
    return title.substring(0, maxChars - 3) + '...';
  }

  Widget _buildRotatedSection({
    required String title,
    required Widget content,
    TextStyle? titleStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 0,
            child: Transform.rotate(
              angle: math.pi / -2,
              alignment: Alignment.topCenter,
              child: Text(
                _truncateTitle(title),
                style: titleStyle ??
                    TextStyle(
                      font: headerFont,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: boxHorizontalColor,
                    ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildSinglePageLayout() {
    final name =
        "${introData?.firstName ?? ""} ${introData?.lastName ?? ""}".trim();
    final List<Widget> leftColumnItems = [];
    final List<Widget> rightColumnItems = [];

    leftColumnItems.add(
      Container(
        padding: EdgeInsets.only(top: 60, bottom: 20, right: 40, left: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (profileImage != null)
              Container(
                width: 120,
                height: 120,
                padding:
                    imageBorder3 != null ? EdgeInsets.all(8) : EdgeInsets.zero,
                decoration: imageBorder3 != null
                    ? BoxDecoration(
                        image: DecorationImage(
                            image: imageBorder3!, fit: BoxFit.cover),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2,
                        color: PdfColor.fromHex("#0D490E")),
                    shape: BoxShape.circle,
                  ),
                  child:
                      ClipOval(child: Image(profileImage!, fit: BoxFit.cover)),
                ),
              ),
            SizedBox(height: 20),
            Text(
              name.isEmpty ? "Your Name" : name,
              textAlign: TextAlign.center,
              style: TextStyle(    
                color: nameColor,
                font: headerFont,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    // Only render contact section if at least one icon loaded successfully
    if (email_43 != null || phone_43 != null || link_43 != null) {
      leftColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(60, 5, 5, 5),
          child: _buildRotatedSection(
            title: AppStrings.t2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (email_43 != null && contactData?.email?.isNotEmpty == true)
                  _buildContactRow(email_43!, contactData!.email!),
                if (phone_43 != null && contactData?.phone?.isNotEmpty == true)
                  _buildContactRow(phone_43!, contactData!.phone!),
                if (link_43 != null && contactData?.personnelWeb?.isNotEmpty == true)
                  _buildContactRow(link_43!, contactData!.personnelWeb!),
              ],
            ),
          ),
        ),
      );
    }

    for (int i = 0; i < sectionData.length; i++) {
      if (i % 2 == 0) {
        // left-side only
        leftColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(60, 20, 20, 5),
            child: _buildRotatedSectionFromModel(sectionData[i]!),
          ),
        );
      }
    }

    if ((summeryData?.summery?.isNotEmpty ?? false)) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(20, 60, 20, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getHeaderText4Dark(text: AppStrings.t5),
              SizedBox(height: 5),
              _getParagraph(text: summeryData!.summery!),
            ],
          ),
        ),
      );
    }

    if (educationData!.isNotEmpty) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          child: _buildRightColumnSection(
            title: AppStrings.t3,
            items: educationData!
                .map(
                  (edu) =>  "${edu?.schoolName ?? ''}\n[${edu?.dateFrom ?? ''} - ${edu?.present == true ? 'Present' : edu?.dateTo ?? ''}]",
                )
                .toList(),
            bottomPadding: 3.0,
          ),
        ),
      );
    }

    if (workData!.isNotEmpty) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(20, 3, 20, 5),
          child: _buildRightColumnSection(
            title: AppStrings.t4,
            items: workData!
                .map(
                  (work) => "${work?.compName ?? ''}, ${work?.compLocation ?? ''}\nPosition: ${work?.compPosition ?? ''}\nDuration: ${work?.present == true ? '[${work?.dateFrom ?? ''}] - Present' : '[${work?.dateFrom ?? ''} - ${work?.dateTo ?? ''}]'}",
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
            child: _buildRightColumnSectionFromModel(sectionData[i]!,
                headerSpacing: 3.0),
          ),
        );
      }
    }

    return Container(
      padding: EdgeInsets.all(0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: leftColumnItems,
            ),
          ),
          SizedBox(width: 15),
          // Right Column
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

  Widget _getNormalText4({required String text}) {
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

  Widget _getParagraph({required String text}) {
    return Text(text,
        textAlign: TextAlign.justify,
        style: TextStyle(color: normalTextColor, fontSize: 7, font: normalFont));
  }

  // Clean up any control / replacement characters and normalize whitespace
  String _sanitizeText(String s) {
    // Remove common replacement characters and control chars
    var out = s.replaceAll(RegExp(r'[-\u001F\uFFFD]'), ' ');
    // Collapse multiple whitespace into single space and trim
    out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
    return out;
  }

  Widget _getHeaderText4Dark({required String text}) {
    return Text(text.toUpperCase(),
        style: TextStyle(
            color: boxBottomBorderColor,
            fontSize: 12,
            font: headerFont,
            fontWeight: FontWeight.bold));
  }

  // For sections in the right column
  Widget _buildRightColumnSection(
      {required String title,
      required List<String> items,
      double bottomPadding = 3.0,
      double headerSpacing = 3.0}) {
    final MemoryImage? bulletToUse = bulletImage;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _getHeaderText4Dark(text: title),
        SizedBox(height: headerSpacing),
        for (final item in items)
          Padding(
            padding: EdgeInsets.only(left: AppPadding.p12, bottom: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (bulletToUse != null) Image(bulletToUse, width: 4, height: 4),
              SizedBox(width: 8),
              Expanded(child: _getNormalText4(text: item)),
            ]),
          ),
      ]),
    );
  }

  Widget _buildRightColumnSectionFromModel(SectionModel sectionModel,
      {double headerSpacing = 3.0}) {
    final List<String> items = sectionModel.value
            ?.split('@@@')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    return _buildRightColumnSection(
        title: sectionModel.id, items: items, headerSpacing: headerSpacing);
  }

  Widget _buildRotatedSectionFromModel(SectionModel sectionModel) {
    final List<String> items = sectionModel.value
            ?.split('@@@')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];

    final MemoryImage? bulletToUse = bulletImage;
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
                Expanded(child: _getNormalText4(text: item)),
              ]),
            ),
        ],
      ),
    );
  }
}