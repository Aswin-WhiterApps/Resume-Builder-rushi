import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import '../firestore/user_firestore.dart';
import '../Presentation/resources/strings_manager.dart';
import '../Presentation/resources/values_manager.dart';
import '../model/model.dart';
import '../model/resume_theme_model.dart';
import '../my_singleton.dart';

class Template26 {
  late final Font? normalFont;
  late final Font? headerFont;
  late final PdfColor? subHeaderColor;
  late final PdfColor? headerColor;
  late final PdfColor? nameColor;
  late final PdfColor? normalTextColor;
  late final PdfColor? backgroundColor;

  late final String? bullet83;
  late final String? background;
  late final String? emailIc;
  late final String? phoneIc;
  late final String? linkIc;

  MemoryImage? bulletImage;
  MemoryImage? phone_81;
  MemoryImage? link_81;
  MemoryImage? imageBorder81;

  IntroModel? introData;
  ContactModel? contactData;
  SummeryModel? summeryData;
  List<EducationModel> educationData = [];
  List<WorkModel> workData = [];
  List<SectionModel> sectionData = [];

  Template26({required Resume26ThemeModel? resume26themeModel}) {
    subHeaderColor =
        resume26themeModel?.subHeaderColor ?? PdfColor.fromHex("#B87397");
    headerColor =
        resume26themeModel?.headerColor ?? PdfColor.fromHex("#B87397");
    nameColor = resume26themeModel?.nameColor ?? PdfColor.fromHex("#B87397");
    normalTextColor =
        resume26themeModel!.normalTextColor ?? PdfColor.fromHex("#0D490E");
    backgroundColor = resume26themeModel.backgroundColor;
    bullet83 = resume26themeModel.bullet83;
    background = resume26themeModel.background;
    phoneIc = resume26themeModel.phoneIc;
    linkIc = resume26themeModel.linkIc;
    normalFont = resume26themeModel.normalFont ?? Font.helvetica();
    headerFont = resume26themeModel.headerFont ?? Font.helveticaBold();
  }

  Future<bool> _initializeDataAndAssets() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      print("Error in Template26: User or Resume ID is null.");
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
        print("Template26: Main resume document not found.");
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

      if (bullet83 != null && bullet83!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bullet83!).then((byteData) {
          bulletImage = MemoryImage(byteData.buffer.asUint8List());
        }));
      }

      if (phoneIc != null && phoneIc!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(phoneIc!)
            .then((data) => phone_81 = MemoryImage(data.buffer.asUint8List())));
      }
      if (linkIc != null && linkIc!.isNotEmpty) {
        // previously this incorrectly assigned the link image into phone_41.
        // Store the loaded link image into link_41 instead.
        imageFutures.add(rootBundle
            .load(linkIc!)
            .then((data) => link_81 = MemoryImage(data.buffer.asUint8List())));
      }

      if (introData?.imagePath != null && introData!.imagePath!.isNotEmpty) {
        final imageFile = File(introData!.imagePath!);
        if (await imageFile.exists()) {
          imageFutures.add(imageFile
              .readAsBytes()
              .then((bytes) => imageBorder81 = MemoryImage(bytes)));
        }
      }

      await Future.wait(imageFutures);
      print("Template26: All assets loaded successfully.");
      return true;
    } catch (e) {
      print("Error initializing data/assets in Template26: $e");
      return false;
    }
  }

  Future<File?> createPage() async {
    print(" Template26: Starting PDF generation...");
    final bool isInitialized = await _initializeDataAndAssets();
    if (!isInitialized) {
      print(" Template26: PDF generation failed due to initialization errors.");
      return null;
    }

    print(" Template26: Building PDF widgets...");
    print(
        " Template26: introData=${introData != null ? '${introData?.firstName ?? ''} ${introData?.lastName ?? ''}' : 'null'}");
    print(
        " Template26: contactData=${contactData != null ? 'exists' : 'null'}");
    print(
        " Template26: summeryData=${summeryData != null ? 'exists' : 'null'}");
    print(" Template26: workData.length=${workData.length}");
    print(" Template26: educationData.length=${educationData.length}");
    print(" Template26: sectionData.length=${sectionData.length}");

   final pdf = Document();

    print(" Template24: All widgets built successfully");

    pdf.addPage(MultiPage(
        pageTheme: PageTheme(
            margin: EdgeInsets.zero,
            pageFormat: PdfPageFormat.a4,
            buildBackground: (context) {
              return Container(
                  color: backgroundColor ?? PdfColor.fromHex("#F4D34F"));
            }),
        build: (Context context) {
          return [_buildSinglePageLayout()];
        }));

    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final String timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File("${outputDir.path}/Resume_T24_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());
      print("Pdf Saved To ${file.path}");
      return file;
    } catch (e) {
      print('Failed to save PDF for Template24: $e');
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

    // Add Image and Name in a styled container
    leftColumnItems.add(
      Container(
        margin: EdgeInsets.only(top: 30, bottom: 10, right: 20, left: 40),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              PdfColor.fromHex('#F2F8D6'),
              PdfColor.fromHex('#E6F0BF'),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: PdfColor(0, 0, 0, 0.3),
              blurRadius: 10,
              offset: PdfPoint(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            if (imageBorder81 != null)
              Container(
                width: 140,
                height: 140,
                padding:
                    imageBorder81 != null ? EdgeInsets.all(1) : EdgeInsets.zero,
                decoration: imageBorder81 != null
                    ? BoxDecoration(
                        image: DecorationImage(
                            image: imageBorder81!, fit: BoxFit.cover),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 8, color: PdfColor.fromHex("#0D490E")),
                    shape: BoxShape.circle,
                  ),
                  child:
                      ClipOval(child: Image(imageBorder81!, fit: BoxFit.cover)),
                ),
              ),

            SizedBox(height: 10),

            // Name
            Text(
              name.isEmpty ? "Your Name" : name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: nameColor,
                font: headerFont,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (contactData?.email != null &&
                contactData!.email!.isNotEmpty) ...[
              SizedBox(height: 5),
              Text(
                contactData!.email!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: normalTextColor,
                  font: normalFont,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    for (int i = 0; i < sectionData.length; i++) {
      if (i % 2 == 0) {
        // left-side only
        leftColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(30, 10, 2, 3),
            child: _buildRotatedSectionFromModel(sectionData[i]),
          ),
        );
      }
    }

    leftColumnItems.add(
      Padding(
        padding: EdgeInsets.fromLTRB(50, 5, 20, 5),
        child: _buildRotatedSection(
          title: AppStrings.t2,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (phoneIc != null)
                _buildContactRow(phone_81!, contactData?.phone),
              if (linkIc != null) ...[
                _buildContactRow(link_81!, contactData?.personnelWeb),
                _buildContactRow(link_81!, contactData?.socialMediaUrl1),
                _buildContactRow(link_81!, contactData?.socialMediaUrl2),
              ],
            ],
          ),
        ),
      ),
    );

    if ((summeryData?.summery?.isNotEmpty ?? false)) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 3),
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
          padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
          child: _buildRightColumnSection(
            title: AppStrings.t3,
            items: educationData
                .map(
                  (edu) =>
                      "${edu.schoolName ?? ''}\n[${edu.dateFrom ?? ''} - ${edu.present == true ? 'Present' : edu.dateTo ?? ''}]",
                )
                .toList(),
            bottomPadding: 2.0,
          ),
        ),
      );
    }

    if (workData.isNotEmpty) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(20, 1, 20, 2),
          child: _buildWorkSection(),
        ),
      );
    }

    for (int i = 0; i < sectionData.length; i++) {
      if (i % 2 == 1) {
        rightColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(20, 1, 20, 2),
            child: _buildRightColumnSectionFromModel(sectionData[i],
                headerSpacing: 1.0),
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
        style:
            TextStyle(color: normalTextColor, fontSize: 7, font: normalFont));
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _getHeaderText4Dark(text: AppStrings.t4),
      SizedBox(height: 4),
      for (final work in workData)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (((work.compPosition ?? '').trim()).isNotEmpty)
                Text(
                  (work.compPosition ?? '').trim(),
                  style: TextStyle(
                    color: normalTextColor,
                    fontSize: 10,
                    font: headerFont,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
              if (((work.compName ?? '').trim()).isNotEmpty ||
                  ((work.compLocation ?? '').trim()).isNotEmpty)
                Text(
                  [
                    (work.compName ?? '').trim(),
                    (work.compLocation ?? '').trim(),
                  ].where((s) => s.isNotEmpty).join(' | '),
                  style: TextStyle(
                    color: normalTextColor,
                    fontSize: 9,
                    font: normalFont,
                    letterSpacing: -0.2,
                  ),
                ),
              Text(
                (work.present ?? false)
                    ? "${(work.dateFrom ?? '').trim()} - Present"
                    : "${(work.dateFrom ?? '').trim()} - ${(work.dateTo ?? '').trim()}",
                style: TextStyle(
                  color: normalTextColor,
                  fontSize: 8,
                  font: normalFont,
                  letterSpacing: -0.2,
                ),
              ),
              if (((work.details ?? '').trim()).isNotEmpty) ...[
                SizedBox(height: 4),
                for (final d in (work.details ?? '')
                    .split(RegExp(r'[\n@]+'))
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty))
                  _getNormalText4(text: d),
              ]
            ],
          ),
        ),
      SizedBox(height: 3),
    ]);
  }

  Widget _buildRightColumnSectionFromModel(SectionModel sectionModel,
      {double headerSpacing = 3.0}) {
    final List<String> items = sectionModel.value
            ?.split('@@@')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    final List<String> descriptions = sectionModel.description
            ?.split('@@@')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];

    final MemoryImage? bulletToUse = bulletImage;
    return Padding(
      padding: EdgeInsets.only(bottom: 3.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _getHeaderText4Dark(text: sectionModel.id),
        SizedBox(height: headerSpacing),
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(left: AppPadding.p12, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bold subheading
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (bulletToUse != null) Image(bulletToUse, width: 4, height: 4),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      items[i],
                      style: TextStyle(
                        color: normalTextColor,
                        fontSize: 9,
                        font: headerFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
                // Description below if exists
                if (i < descriptions.length && descriptions[i].isNotEmpty) ...[
                  SizedBox(height: 0.5),
                  Padding(
                    padding: EdgeInsets.only(left: AppPadding.p12 + 12),
                    child: Text(
                      descriptions[i],
                      style: TextStyle(
                        color: normalTextColor,
                        fontSize: 8,
                        font: normalFont,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ]),
    );
  }

  Widget _buildRotatedSectionFromModel(SectionModel sectionModel) {
    final List<String> items = sectionModel.value
            ?.split('@@@')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    final List<String> descriptions = sectionModel.description
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
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bold subheading
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (bulletToUse != null)
                      Image(bulletToUse, width: 4, height: 4),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        items[i],
                        style: TextStyle(
                          color: normalTextColor,
                          fontSize: 9,
                          font: headerFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                  // Description below if exists
                  if (i < descriptions.length && descriptions[i].isNotEmpty) ...[
                    SizedBox(height: 0.5),
                    Padding(
                      padding: EdgeInsets.only(left: 9),
                      child: Text(
                        descriptions[i],
                        style: TextStyle(
                          color: normalTextColor,
                          fontSize: 8,
                          font: normalFont,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
