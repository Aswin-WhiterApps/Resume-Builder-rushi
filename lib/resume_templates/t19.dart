import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:resume_builder/Presentation/resources/pdf_assets.dart';
import '../firestore/user_firestore.dart';
import '../Presentation/resources/strings_manager.dart';
import '../Presentation/resources/values_manager.dart';
import '../model/model.dart';
import '../model/resume_theme_model.dart';
import '../my_singleton.dart';

class Template19 {
  late final Font? normalFont;
  late final Font? headerFont;
  late final PdfColor? subHeaderColor;
  late final PdfColor? headerColor;
  late final PdfColor? nameColor;
  late final PdfColor? normalTextColor;

  late final String? bullet63;
  late final String? background;
  late final String? imageBorder;
  late final String? emailIc;
  late final String? phoneIc;
  late final String? linkIc;

  MemoryImage? bulletImage;
  MemoryImage? imageBorder63;
  MemoryImage? email_63;
  MemoryImage? phone_63;
  MemoryImage? link_63;

  IntroModel? introData;
  ContactModel? contactData;
  SummeryModel? summeryData;
  List<EducationModel> educationData = [];
  List<WorkModel> workData = [];
  List<SectionModel> sectionData = [];

  Template19(
      {required Resume19ThemeModel? resume19theme}) {
    subHeaderColor = resume19theme?.subHeaderColor ?? PdfColor.fromHex("#B87397");
    headerColor = resume19theme?.headerColor ?? PdfColor.fromHex("#B87397");
    nameColor = resume19theme?.nameColor ?? PdfColor.fromHex("#B87397");
    normalTextColor = resume19theme!.normalTextColor ?? PdfColor.fromHex("#0D490E");
    bullet63 = resume19theme.bullet63;
    background = resume19theme.rect63 ?? PdfAssets.rect63;
    imageBorder = resume19theme.imageBorder63;
    emailIc = resume19theme.emailIc;
    phoneIc = resume19theme.phoneIc;
    linkIc = resume19theme.linkIc;
    normalFont = resume19theme.normalFont ?? Font.helvetica();
    headerFont = resume19theme.headerFont ?? Font.helveticaBold(); 
  }

  Future<bool> _initializeDataAndAssets() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      print("Error in Template19: User or Resume ID is null.");
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
        print("Template19: Main resume document not found.");
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
            (data) => imageBorder63 = MemoryImage(data.buffer.asUint8List())));
      }

      if (bullet63 != null && bullet63!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bullet63!).then((byteData) {
          bulletImage = MemoryImage(byteData.buffer.asUint8List());
        }));
      }
      if (emailIc != null && emailIc!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(emailIc!)
            .then((data) => email_63 = MemoryImage(data.buffer.asUint8List())));
      }
      if (phoneIc != null && phoneIc!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(phoneIc!)
            .then((data) => phone_63 = MemoryImage(data.buffer.asUint8List())));
      }
      if (linkIc != null && linkIc!.isNotEmpty) {
        // previously this incorrectly assigned the link image into phone_41.
        // Store the loaded link image into link_41 instead.
        imageFutures.add(rootBundle
            .load(linkIc!)
            .then((data) => link_63 = MemoryImage(data.buffer.asUint8List())));
      }

      if (background != null && background!.isNotEmpty) {
        imageFutures.add(rootBundle.load(background!).then((data) =>
            imageBorder63 = MemoryImage(data.buffer.asUint8List())));
      }

      if (introData?.imagePath != null && introData!.imagePath!.isNotEmpty) {
        final imageFile = File(introData!.imagePath!);
        if (await imageFile.exists()) {
          imageFutures.add(imageFile
              .readAsBytes()
              .then((bytes) => imageBorder63 = MemoryImage(bytes)));
        }
      }

      await Future.wait(imageFutures);
      print("Template19: All assets loaded successfully.");
      return true;
    } catch (e) {
      print("Error initializing data/assets in Template19: $e");
      return false;
    }
  }

  Future<File?> createPage() async {
    print(" Template19: Starting PDF generation...");
    final bool isInitialized = await _initializeDataAndAssets();
    if (!isInitialized) {
      print(" Template19: PDF generation failed due to initialization errors.");
      return null;
    }

    print(" Template19: Building PDF widgets...");
    print(
        " Template19: introData=${introData != null ? '${introData?.firstName ?? ''} ${introData?.lastName ?? ''}' : 'null'}");
    print(
        " Template19: contactData=${contactData != null ? 'exists' : 'null'}");
    print(
        " Template19: summeryData=${summeryData != null ? 'exists' : 'null'}");
    print(" Template19: workData.length=${workData.length}");
    print(" Template19: educationData.length=${educationData.length}");
    print(" Template19: sectionData.length=${sectionData.length}");

    final pdf = Document();

    print(" Template19: All widgets built successfully");

    pdf.addPage(MultiPage(
        pageTheme: PageTheme(
            margin: EdgeInsets.zero,
            pageFormat: PdfPageFormat.a4,
            buildBackground: (context) {
              return imageBorder63 != null
                  ? Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover, image: imageBorder63!)))
                  : Container(color: PdfColors.grey100);
            }),
        build: (Context context) {
          return [_buildSinglePageLayout()];
        }));

    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final String timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File("${outputDir.path}/Resume_T19_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());
      print("Pdf Saved To ${file.path}");
      return file;
    } catch (e) {
      print('Failed to save PDF for Template19: $e');
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


  Widget _buildSinglePageLayout() {
    final name =
        "${introData?.firstName ?? ""} ${introData?.lastName ?? ""}".trim();
    final List<Widget> leftColumnItems = [];
    final List<Widget> rightColumnItems = [];

    // Add name to right column at the top
    rightColumnItems.add(
      Container(
        padding: EdgeInsets.only(top: 60, bottom: 20, right: 40, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              name.isEmpty ? "Your Name" : name,
              textAlign: TextAlign.right,
              style: TextStyle(    
                color: nameColor,
                font: headerFont,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

   leftColumnItems.add(
      Container(
        padding: EdgeInsets.only(top: 60, bottom: 20, right: 40, left: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imageBorder != null)
              Container(
                width: 120,
                height: 120,
                padding:
                    imageBorder63 != null ? EdgeInsets.all(5) : EdgeInsets.zero,
                decoration: imageBorder63 != null
                    ? BoxDecoration(
                        image: DecorationImage(
                            image: imageBorder63!, fit: BoxFit.cover),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 15, color: PdfColor.fromHex("#7FA3C8")),
                    shape: BoxShape.circle,
                  ),
                  child:
                      ClipOval(child: Image(imageBorder63!, fit: BoxFit.cover)),
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
              if (emailIc != null)
                _buildContactRow(email_63!, contactData?.email),
              if (phoneIc != null)
                _buildContactRow(phone_63!, contactData?.phone),
              if (linkIc != null)
                _buildContactRow(link_63!, contactData?.personnelWeb),
            ],
          ),
        ),
      ),
    );

    for (int i = 0; i < sectionData.length; i++) {
      if (i % 2 == 0) {
        // left-side only
        leftColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(60, 20, 20, 5),
            child: _buildRotatedSectionFromModel(sectionData[i]),
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

    if (educationData.isNotEmpty) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          child: _buildRightColumnSection(
            title: AppStrings.t3,
            items: educationData
                .map(
                  (edu) =>  "${edu.schoolName ?? ''}\n[${edu.dateFrom ?? ''} - ${edu.present == true ? 'Present' : edu.dateTo ?? ''}]",
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
          child: _buildWorkSection(),
        ),
      );
    }

    for (int i = 0; i < sectionData.length; i++) {
      if (i % 2 == 1) {
        rightColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(20, 3, 20, 5),
            child: _buildRightColumnSectionFromModel(sectionData[i],
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
            color: headerColor,
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
    Widget _buildRotatedSection({
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _getHeaderText4Dark(text: title),
        SizedBox(height: 4),
        content,
      ],
    );
  }

    Widget _buildWorkSection() {
    final MemoryImage? bulletToUse = bulletImage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _getHeaderText4Dark(text: AppStrings.t4),
        SizedBox(height: 3.0),
        for (final work in workData)
          Padding(
            padding: EdgeInsets.only(left: AppPadding.p12, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bulletToUse != null)
                  Image(bulletToUse, width: 4, height: 4),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Line 1: Company Name, Location
                      Text(
                        "${work.compName ?? ''}, ${work.compLocation ?? ''}",
                        style: TextStyle(
                            color: normalTextColor,
                            fontSize: 9,
                            font: normalFont),
                      ),
                      // Line 2: Position - Dates
                      Text(
                        "${work.compPosition ?? ''} - [${work.dateFrom ?? ''} - ${work.present == true ? 'Present' : work.dateTo ?? ''}]",
                        style: TextStyle(
                            color: normalTextColor,
                            fontSize: 9,
                            font: normalFont),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
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