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

class Template4 {
  // --- Theme Properties ---
  late final Font? normalFont;
  late final Font? headerFont;
  late final PdfColor normalTextColor;
  late final PdfColor headerDarkColor;
  late final PdfColor nameColor;
  late final PdfColor imageBorder;

  late final String? borderImg;
  late final String? objVertical;
  late final String? emailIc;
  late final String? phoneIc;
  late final String? linkIc;
  late final String? bullet;
  late final String? bulletDark;
  late final String? bulletLight;

  // --- Asset and Data Models ---
  MemoryImage? t4_verticle;
  MemoryImage? imgBack;
  MemoryImage? t4_email;
  MemoryImage? t4_phone;
  MemoryImage? t4_link;
  MemoryImage? t4_bullet;
  MemoryImage? t4_bulletDark;
  MemoryImage? t4_bulletLight;
  MemoryImage? profileImage;

  IntroModel? introData;
  ContactModel? contactData;
  SummeryModel? summeryData;
  List<EducationModel> educationData = [];
  List<WorkModel> workData = [];
  List<SectionModel> sectionData = [];

  Template4(
      {required Resume4ThemeModel? resume4themeModel,
      required CL4ThemeModel? cl4themeModel}) {
    normalTextColor = resume4themeModel?.normalTextColor ?? PdfColors.black;
    headerDarkColor = resume4themeModel?.headerDarkColor ?? PdfColors.grey800;
    nameColor = resume4themeModel?.nameColor ?? PdfColors.blueGrey900;
    imageBorder = resume4themeModel?.imageBorder ?? PdfColors.white;

    borderImg = resume4themeModel?.imgBorder;
    objVertical = resume4themeModel?.objVertical;
    emailIc = resume4themeModel?.emailIc;
    phoneIc = resume4themeModel?.phoneIc;
    linkIc = resume4themeModel?.linkIc;
    bullet = resume4themeModel?.bullet;
    bulletDark = resume4themeModel?.bulletDark;
    bulletLight = resume4themeModel?.bulletLight;

    normalFont = resume4themeModel?.normalFont ?? Font.helvetica();
    headerFont = resume4themeModel?.headerFont ?? Font.helveticaBold();
  }

  Future<bool> initializeDataAndAssets() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      print("Error in Template4: User or Resume ID is null.");
      return false;
    }

    final fireUser = FireUser();

    try {
      print("Template4: Fetching all data for PDF generation...");
      print("Template4: userId=$userId, resumeId=$resumeId");

      final results = await Future.wait([
        fireUser.getResume(userId: userId, resumeId: resumeId),
        fireUser.getWorkExperiences(userId: userId, resumeId: resumeId),
        fireUser.getEducations(userId: userId, resumeId: resumeId),
        fireUser.getAllSections(userId: userId, resumeId: resumeId),
      ]);

      print("Template4: All data fetch operations completed");

      final resume = results[0] as ResumeModel?;
      if (resume == null) {
        print("Template4: Main resume document not found.");
      } else {
        introData = resume.intro;
        contactData = resume.contact;
        summeryData = resume.summary;
        print(
            "Template4: Resume data loaded - Name: ${introData?.firstName ?? ''} ${introData?.lastName ?? ''}");
        print(
            "Template4: Contact - Email: ${contactData?.email ?? 'N/A'}, Phone: ${contactData?.phone ?? 'N/A'}");
        print(
            "Template4: Summary: ${summeryData?.summery?.substring(0, summeryData!.summery!.length > 50 ? 50 : summeryData!.summery!.length) ?? 'N/A'}...");
      }

      workData = results[1] as List<WorkModel>;
      educationData = results[2] as List<EducationModel>;
      sectionData = (results[3] as List<SectionModel>)
          .where((s) => s.value != null && s.value!.isNotEmpty)
          .toList();

      print(" Template4: Work experiences: ${workData.length}");
      print(" Template4: Education entries: ${educationData.length}");
      print(" Template4: Sections: ${sectionData.length}");

      // Debug: Print work data details
      for (int i = 0; i < workData.length; i++) {
        print(
            "  Work $i: ${workData[i].compName ?? 'N/A'} - ${workData[i].compPosition ?? 'N/A'}");
      }

      // Debug: Print education data details
      for (int i = 0; i < educationData.length; i++) {
        print("  Education $i: ${educationData[i].schoolName ?? 'N/A'}");
      }

      // Debug: Print section data details
      for (int i = 0; i < sectionData.length; i++) {
        print(
            "  Section $i: ${sectionData[i].id} - Items: ${sectionData[i].value?.split('@').length ?? 0}");
      }

      print(" Template4: Data fetched successfully.");

      final imageFutures = <Future>[];

      if (borderImg != null && borderImg!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(borderImg!)
            .then((data) => imgBack = MemoryImage(data.buffer.asUint8List())));
      }
      if (bullet != null && bullet!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bullet!).then(
            (data) => t4_bullet = MemoryImage(data.buffer.asUint8List())));
      }
      if (bulletDark != null && bulletDark!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bulletDark!).then(
            (data) => t4_bulletDark = MemoryImage(data.buffer.asUint8List())));
      }
      if (bulletLight != null && bulletLight!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bulletLight!).then(
            (data) => t4_bulletLight = MemoryImage(data.buffer.asUint8List())));
      }
      if (objVertical != null && objVertical!.isNotEmpty) {
        imageFutures.add(rootBundle.load(objVertical!).then(
            (data) => t4_verticle = MemoryImage(data.buffer.asUint8List())));
      }
      if (emailIc != null && emailIc!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(emailIc!)
            .then((data) => t4_email = MemoryImage(data.buffer.asUint8List())));
      }
      if (phoneIc != null && phoneIc!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(phoneIc!)
            .then((data) => t4_phone = MemoryImage(data.buffer.asUint8List())));
      }
      if (linkIc != null && linkIc!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(linkIc!)
            .then((data) => t4_link = MemoryImage(data.buffer.asUint8List())));
      }

      // User Profile Image (from local path)
      if (introData?.imagePath != null && introData!.imagePath!.isNotEmpty) {
        final imageFile = File(introData!.imagePath!);
        if (await imageFile.exists()) {
          imageFutures.add(imageFile
              .readAsBytes()
              .then((bytes) => profileImage = MemoryImage(bytes)));
        }
      }

      await Future.wait(imageFutures);
      print("All assets loaded for Template4.");
      return true;
    } catch (e) {
      print("Error initializing data/assets in Template4: $e");
      return false;
    }
  }

  Future<File?> createPage() async {
    print(" Template4: Starting PDF generation...");
    final bool isInitialized = await initializeDataAndAssets();
    if (!isInitialized) {
      print(" Template4: PDF generation failed due to initialization errors.");
      return null;
    }

    print(" Template4: Building PDF widgets...");
    print(
        " Template4: introData=${introData != null ? '${introData?.firstName ?? ''} ${introData?.lastName ?? ''}' : 'null'}");
    print(" Template4: contactData=${contactData != null ? 'exists' : 'null'}");
    print(" Template4: summeryData=${summeryData != null ? 'exists' : 'null'}");
    print(" Template4: workData.length=${workData.length}");
    print(" Template4: educationData.length=${educationData.length}");
    print(" Template4: sectionData.length=${sectionData.length}");

    final pdf = Document();

    print(" Template4: All widgets built successfully");

    pdf.addPage(MultiPage(
        pageTheme: PageTheme(
            margin: EdgeInsets.zero,
            pageFormat: PdfPageFormat.a4,
            buildBackground: (context) {
              return t4_verticle != null
                  ? Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover, image: t4_verticle!)))
                  : Container(color: PdfColors.grey100);
            }),
        build: (Context context) {
          return _buildLayout();
        }));

    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final String timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File("${outputDir.path}/Resume_T4_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());
      print("Pdf Saved To ${file.path}");
      return file;
    } catch (e) {
      print('Failed to save PDF for Template4: $e');
      return null;
    }
  }

  List<Widget> _buildLayout() {
    final name =
        "${introData?.firstName ?? ""} ${introData?.lastName ?? ""}".trim();
    final List<Widget> leftColumnItems = [];
    final List<Widget> rightColumnItems = [];

    // Identify and extract the Projects section
    SectionModel? projectsSection;
    final List<SectionModel> otherSections = [];

    for (final section in sectionData) {
      if (section.id.toLowerCase() == 'projects' ||
          section.id == AppStrings.projects) {
        projectsSection = section;
      } else {
        otherSections.add(section);
      }
    }

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
                padding: imgBack != null ? EdgeInsets.all(8) : EdgeInsets.zero,
                decoration: imgBack != null
                    ? BoxDecoration(
                        image:
                            DecorationImage(image: imgBack!, fit: BoxFit.cover),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: imageBorder),
                    shape: BoxShape.circle,
                  ),
                  child:
                      ClipOval(child: Image(profileImage!, fit: BoxFit.cover)),
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
          title: AppStrings.t2, // CONTACT
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (t4_email != null)
                _buildContactRow(t4_email!, contactData?.email),
              if (t4_phone != null)
                _buildContactRow(t4_phone!, contactData?.phone),
              if (t4_link != null)
                _buildContactRow(t4_link!, contactData?.socialMediaUrl1),
              if (t4_link != null)
                _buildContactRow(t4_link!, contactData?.socialMediaUrl2),
              if (contactData?.addr1?.isNotEmpty ?? false)
                Text(
                  contactData!.addr1!,
                  style: TextStyle(fontSize: 7, color: normalTextColor),
                ),
              if (contactData?.addr2?.isNotEmpty ?? false)
                Text(
                  contactData!.addr2!,
                  style: TextStyle(fontSize: 7, color: normalTextColor),
                ),
            ],
          ),
        ),
      ),
    );

    for (int i = 0; i < otherSections.length; i++) {
      if (i % 2 == 0) {
        // left-side only
        leftColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(50, 5, 20, 5),
            child: _buildRotatedSectionFromModel(otherSections[i]),
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
          child: _buildWorkSection(),
        ),
      );
    }

    if (projectsSection != null) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(20, 3, 20, 5),
          child: _buildProjectSection(projectsSection),
        ),
      );
    }

    // Add right column sections (odd indices)
    for (int i = 0; i < otherSections.length; i++) {
      if (i % 2 == 1) {
        rightColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(20, 3, 20, 5),
            child: _buildRightColumnSectionFromModel(otherSections[i],
                headerSpacing: 3.0),
          ),
        );
      }
    }

    return [
      Partitions(
        children: [
          // Left Column
          Partition(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: leftColumnItems,
            ),
          ),
          Partition(width: 15, child: SizedBox()),
          // Right Column
          Partition(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rightColumnItems,
            ),
          ),
        ],
      )
    ];
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
    var out = s.replaceAll(RegExp(r'[\u0000-\u001F\uFFFD]'), ' ');
    // Collapse multiple whitespace into single space and trim
    out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
    return out;
  }

  Widget _getHeaderText4Dark({required String text}) {
    return Text(text.toUpperCase(),
        style: TextStyle(
            color: headerDarkColor,
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
    final MemoryImage? bulletToUse = t4_bulletLight ?? t4_bullet;
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

  // For sections in the left column with rotated titles
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

  Widget _buildRightColumnSectionFromModel(SectionModel sectionModel,
      {double headerSpacing = 3.0}) {
    final List<String> items = sectionModel.value
            ?.split('@@@')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    final List<String> descriptions =
        sectionModel.description?.split('@@@').map((s) => s.trim()).toList() ??
            [];

    final MemoryImage? bulletToUse = t4_bulletLight ?? t4_bullet;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _getHeaderText4Dark(text: sectionModel.id),
        SizedBox(height: headerSpacing),
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(left: AppPadding.p12, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (bulletToUse != null)
                    Image(bulletToUse, width: 4, height: 4),
                  SizedBox(width: 8),
                  Expanded(child: _getNormalText4(text: items[i])),
                ]),
                if (i < descriptions.length && descriptions[i].isNotEmpty) ...[
                  SizedBox(height: 2),
                  for (final d in descriptions[i]
                      .split(RegExp(r'[\n@]+'))
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _buildBulletedText(text: d),
                    ),
                ]
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
    final List<String> descriptions =
        sectionModel.description?.split('@@@').map((s) => s.trim()).toList() ??
            [];

    final MemoryImage? bulletToUse = t4_bulletDark ?? t4_bullet;
    return _buildRotatedSection(
      title: sectionModel.id,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (bulletToUse != null)
                      Image(bulletToUse, width: 4, height: 4),
                    SizedBox(width: 5),
                    Expanded(child: _getNormalText4(text: items[i])),
                  ]),
                  if (i < descriptions.length &&
                      descriptions[i].isNotEmpty) ...[
                    SizedBox(height: 2),
                    for (final d in descriptions[i]
                        .split(RegExp(r'[\n@]+'))
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty))
                      Padding(
                        padding: const EdgeInsets.only(left: 9),
                        child: _buildBulletedText(text: d),
                      ),
                  ]
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _getHeaderText1(text: AppStrings.t4),
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
                  _buildBulletedText(text: d),
              ]
            ],
          ),
        ),
      SizedBox(height: 8),
    ]);
  }

  Widget _getHeaderText1({required String text}) {
    return Text(text.toUpperCase(),
        style: TextStyle(
          font: headerFont,
          color: headerDarkColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ));
  }

  Widget _buildBulletedText({required String text}) {
    final MemoryImage? bulletToUse = t4_bulletDark ?? t4_bullet;
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bulletToUse != null)
            Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Image(bulletToUse, width: 4, height: 4))
          else
            Text("• ", style: TextStyle(fontSize: 8, color: normalTextColor)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: normalTextColor,
                fontSize: 9,
                font: normalFont,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSection(SectionModel projectSection) {
    final List<String> projectNames = projectSection.value
            ?.split('@@@')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    final List<String> projectDescriptions = projectSection.description
            ?.split('@@@')
            .map((s) => s.trim())
            .toList() ??
        [];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _getHeaderText1(text: projectSection.id),
      SizedBox(height: 4),
      for (int i = 0; i < projectNames.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projectNames[i],
                style: TextStyle(
                  color: normalTextColor,
                  fontSize: 10,
                  font: headerFont,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              if (i < projectDescriptions.length &&
                  projectDescriptions[i].isNotEmpty) ...[
                SizedBox(height: 4),
                for (final d in projectDescriptions[i]
                    .split(RegExp(r'[\n@]+'))
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty))
                  _buildBulletedText(text: d),
              ]
            ],
          ),
        ),
      SizedBox(height: 8),
    ]);
  }
}
