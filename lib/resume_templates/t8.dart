import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/model/resume_theme_model.dart';
import 'package:resume_builder/my_singleton.dart';

import 'package:resume_builder/Presentation/resources/strings_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:resume_builder/Presentation/resources/pdf_assets.dart';

class Template8 {
  MemoryImage? backgroundImage;
  Font? headerFont;
  Font? nameFont;
  Font? normalFont;
  late final PdfColor normalTextColor;
  late final PdfColor headerLightColor;
  late final PdfColor headerDarkColor;
  late final PdfColor nameColor;
  late final PdfColor positionColor;
  late final PdfColor imageBorderColor;
  late final PdfColor dateColor;
  late final PdfColor linkColor;

  late final String? linkAsset;
  late final String? bulletAsset;

  late final String? objHorizontalAsset;
  late final String? objVerticalAsset;
  late final String? emailAsset;
  late final String? phoneAsset;

  Resume8ThemeModel resume8themeModel;

  MemoryImage? bulletDarkImage;
  MemoryImage? bulletLightImage;
  MemoryImage? profileImage;
  MemoryImage? objH32;
  MemoryImage? objV32;

  // Icon images
  MemoryImage? emailImage;
  MemoryImage? phoneImage;
  MemoryImage? linkImage;

  IntroModel? introData;
  ContactModel? contactData;
  SummeryModel? summaryData;
  List<EducationModel> educationData = [];
  List<WorkModel> workData = [];
  List<SectionModel> sectionData = [];

  Template8({required this.resume8themeModel}) {
    normalTextColor = PdfColors.black;
    headerDarkColor = resume8themeModel.headerDarkColor ?? PdfColors.black;
    nameColor = PdfColors.black;
    positionColor = resume8themeModel.positionColor ?? PdfColors.black;
    imageBorderColor = resume8themeModel.imageBorder ?? PdfColors.black;
    dateColor = resume8themeModel.dateColor ?? PdfColors.black;
    linkColor = resume8themeModel.linkColor ?? PdfColors.black;

    linkAsset = resume8themeModel.link ?? resume8themeModel.link;
    bulletAsset = PdfAssets.bullet81; // Use Template8 bullet asset

    objHorizontalAsset = PdfAssets.objH32;
    objVerticalAsset = PdfAssets.objV32;
    emailAsset = resume8themeModel.emailIc;
    phoneAsset = resume8themeModel.phoneIc;

    normalFont = resume8themeModel.normalFont ?? Font.times();
    headerFont = resume8themeModel.headerFont ?? Font.helvetica();
    nameFont = resume8themeModel.nameFont ?? Font.helveticaBold();
  }

  Future<bool> initializeDataAndAssets() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      print("User or Resume ID is null in Template8.");
      return false;
    }

    final fireUser = FireUser();

    try {
      print("Template8: Fetching all data for PDF generation...");
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
        summaryData = resume.summary;
      } else {
        print("Main resume document not found for Template8.");
      }

      workData = results[1] as List<WorkModel>;
      educationData = results[2] as List<EducationModel>;
      sectionData = (results[3] as List<SectionModel>)
          .where((s) => s.value != null && s.value!.isNotEmpty)
          .toList();

      final imageFutures = <Future>[];

      if (bulletAsset != null && bulletAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bulletAsset!).then((data) {
          bulletDarkImage = MemoryImage(data.buffer.asUint8List());
          bulletLightImage = MemoryImage(
              data.buffer.asUint8List()); // Assigning same to light for now
        }));
      }

      // Load icons from theme assets
      if (emailAsset != null && emailAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(emailAsset!).then(
            (data) => emailImage = MemoryImage(data.buffer.asUint8List())));
      }

      if (phoneAsset != null && phoneAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(phoneAsset!).then(
            (data) => phoneImage = MemoryImage(data.buffer.asUint8List())));
      }

      if (linkAsset != null && linkAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(linkAsset!).then(
            (data) => linkImage = MemoryImage(data.buffer.asUint8List())));
      }

      if (objHorizontalAsset != null && objHorizontalAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(objHorizontalAsset!).then(
            (data) => objH32 = MemoryImage(data.buffer.asUint8List())));
      }

      if (objVerticalAsset != null && objVerticalAsset!.isNotEmpty) {
        imageFutures.add(rootBundle.load(objVerticalAsset!).then(
            (data) => objV32 = MemoryImage(data.buffer.asUint8List())));
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
      
      // Debug logging for contact details
      print("Template8: Contact Data Debug:");
      print("  - contactData: ${contactData != null ? 'exists' : 'null'}");
      if (contactData != null) {
        print("  - email: '${contactData!.email ?? 'null'}'");
        print("  - phone: '${contactData!.phone ?? 'null'}'");
        print("  - personnelWeb: '${contactData!.personnelWeb ?? 'null'}'");
      }
      print("  - emailImage: ${emailImage != null ? 'loaded' : 'null'}");
      print("  - phoneImage: ${phoneImage != null ? 'loaded' : 'null'}");
      print("  - linkImage: ${linkImage != null ? 'loaded' : 'null'}");
      print("  - emailAsset: '${emailAsset ?? 'null'}'");
      print("  - phoneAsset: '${phoneAsset ?? 'null'}'");
      print("  - linkAsset: '${linkAsset ?? 'null'}'");
      
      print("Template8: All assets loaded successfully.");
      return true;
    } catch (e) {
      print("Failed to initialize data/assets in Template8: $e");
      return false;
    }
  }

  Future<File?> createPage() async {
    print("Template8: Starting PDF generation...");

    try {
      final success = await initializeDataAndAssets();
      if (!success) {
        throw Exception("Failed to initialize assets");
      }
    } catch (e) {
      print("Template8 initialization exception: $e");
      // throw Exception("Template8 initialization failed: $e");
      return null;
    }

   final pdf = Document();

    pdf.addPage(MultiPage(
        pageTheme: PageTheme(
            margin: EdgeInsets.zero,
            pageFormat: PdfPageFormat.a4,
            orientation: PageOrientation.portrait,
            buildBackground: (context) {
              return Stack(
                children: [
                  // Base light beige background
                  Container(color: PdfColor(0.995, 0.96, 0.98, 1)),
                  // Horizontal background image as base layer
                  if (objH32 != null)
                    Positioned.fill(
                      child: Image(objH32!, fit: BoxFit.cover),
                    ),
                  // Vertical background image as overlay
                  if (objV32 != null)
                    Positioned.fill(
                      child: Image(objV32!, fit: BoxFit.cover),
                    ),
                ],
              );
            }),
        build: (Context context) {
          final name =
              "${introData?.firstName ?? ""} ${introData?.lastName ?? ""}"
                  .trim();
          final SectionModel? projectsSection = sectionData.firstWhere(
            (s) =>
                s.id.toLowerCase() == 'projects' || s.id == AppStrings.projects,
            orElse: () => SectionModel(id: ''),
          );

          final List<SectionModel> otherSections = sectionData
              .where((s) =>
                  s.id.toLowerCase() != 'projects' &&
                  s.id != AppStrings.projects &&
                  s.id.isNotEmpty)
              .toList();

          final List<Widget> leftColumnItems = [];
          final List<Widget> rightColumnItems = [];

          // Left Column Profile Image
          leftColumnItems.add(
            Container(
              padding:
                  EdgeInsets.only(top: 60, bottom: 20, right: 40, left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profileImage != null)
                    Container(
                      width: 120,
                      height: 120,
                      padding: imageBorderColor != null
                          ? EdgeInsets.all(5)
                          : EdgeInsets.zero,
                      decoration: imageBorderColor != null
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              color: imageBorderColor,
                            )
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 15,
                              color: PdfColors.white), // Inner border
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                            child: Image(profileImage!, fit: BoxFit.cover)),
                      ),
                    ),
                ],
              ),
            ),
          );

          // Left Column Custom Sections (Even indices)
          for (int i = 0; i < otherSections.length; i++) {
            if (i % 2 == 0) {
              leftColumnItems.add(
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 2, 20, 2),
                  child: _buildRotatedSectionFromModel(otherSections[i]),
                ),
              );
            }
          }

          // Right Column Header (Name)
          rightColumnItems.add(
            Container(
              padding: EdgeInsets.only(top: 60, bottom: 5, right: 40, left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? "Your Name" : name,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: nameColor,
                      font: nameFont,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );

          // Right Column Summary
          if ((summaryData?.summery?.isNotEmpty ?? false)) {
            rightColumnItems.add(
              Padding(
                padding: EdgeInsets.fromLTRB(5, 2, 20, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getParagraph(text: summaryData!.summery!),
                  ],
                ),
              ),
            );
          }

          // Right Column Education
          if (educationData.isNotEmpty) {
            rightColumnItems.add(
              Padding(
                padding: EdgeInsets.fromLTRB(5, 2, 20, 2),
                child: _buildRightColumnSection(
                  title: AppStrings.t3,
                  items: educationData
                      .map(
                        (edu) =>
                            "${edu.schoolName ?? ''}\n[${edu.dateFrom ?? ''} - ${edu.present == true ? 'Present' : edu.dateTo ?? ''}]",
                      )
                      .toList(),
                  bottomPadding: 2.0,
                  headerSpacing: 3.0,
                ),
              ),
            );
          }

          // Right Column Work Experience
          if (workData.isNotEmpty) {
            rightColumnItems.add(
              Padding(
                padding: EdgeInsets.fromLTRB(5, 2, 20, 2),
                child: _buildWorkSection(),
              ),
            );
          }

          // Projects Section (Explicitly handled)
          if (projectsSection?.id.isNotEmpty ?? false) {
            rightColumnItems.add(
              Padding(
                padding: EdgeInsets.fromLTRB(5, 2, 20, 2),
                child: _buildProjectSection(projectsSection!),
              ),
            );
          }

          // Right Column Custom Sections (Odd indices)
          for (int i = 0; i < otherSections.length; i++) {
            if (i % 2 == 1) {
              leftColumnItems.add(
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 2, 20, 2),
                  child: _buildRotatedSectionFromModel(otherSections[i]),
                ),
              );
            }
          }

          // Left Column Contact Info (At bottom)
          leftColumnItems.add(
            Padding(
              padding: EdgeInsets.fromLTRB(10, 2, 20, 2),
              child: _buildRotatedSection(
                title: AppStrings.t2, // CONTACT
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (emailAsset != null)
                      _buildContactRow(emailImage!, contactData?.email),
                    if (phoneAsset != null)
                      _buildContactRow(phoneImage!, contactData?.phone),
                    if (linkAsset != null)
                      _buildContactRow(
                        linkImage!,
                        contactData?.socialMediaUrl1,
                      ),
                    if (linkAsset != null)
                      _buildContactRow(
                          linkImage!, contactData?.socialMediaUrl2),
                    if (contactData?.addr1?.isNotEmpty ?? false)
                      Text(
                        contactData!.addr1!,
                        style: TextStyle(fontSize: 7, color: PdfColors.black),
                      ),
                    if (contactData?.addr2?.isNotEmpty ?? false)
                      Text(
                        contactData!.addr2!,
                        style: TextStyle(fontSize: 7, color: PdfColors.black),
                      ),
                  ],
                ),
              ),
            ),
          );

          return [
            Partitions(
              children: [
                Partition(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: leftColumnItems,
                  ),
                ),
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
        }));

    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final String timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File("${outputDir.path}/Resume_T7_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());
      print("Pdf Saved To ${file.path}");
      return file;
    } catch (e) {
      print('Failed to save PDF for Template7: $e');
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: null,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
            color: headerDarkColor,
            fontSize: 12,
            font: headerFont,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  // For sections in the right column
  Widget _buildRightColumnSection(
      {required String title,
      required List<String> items,
      double bottomPadding = 3.0,
      double headerSpacing = 3.0}) {
    final MemoryImage? bulletToUse = bulletDarkImage;
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

    final List<String> combined = [];
    for (int i = 0; i < items.length; i++) {
      String item = items[i];
      if (i < descriptions.length && descriptions[i].isNotEmpty) {
        item += "\n" + descriptions[i];
      }
      combined.add(item);
    }

    return _buildRightColumnSection(
        title: sectionModel.id, items: combined, headerSpacing: headerSpacing);
  }

  Widget _buildProjectSection(SectionModel sectionModel) {
    final List<String> titles = sectionModel.value
            ?.split('@@@')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    final List<String> descriptions =
        sectionModel.description?.split('@@@').map((s) => s.trim()).toList() ??
            [];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _getHeaderText1(text: sectionModel.id),
      SizedBox(height: 2),
      for (int i = 0; i < titles.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titles[i],
                style: TextStyle(
                  color: normalTextColor,
                  fontSize: 10,
                  font: headerFont,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              if (i < descriptions.length && descriptions[i].isNotEmpty) ...[
                SizedBox(height: 2),
                for (final d in descriptions[i]
                    .split(RegExp(r'[\n@]+'))
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty))
                  _buildBulletedText(text: d),
              ]
            ],
          ),
        ),
    ]);
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

    final MemoryImage? bulletToUse = bulletDarkImage;
    return _buildRotatedSection(
      title: sectionModel.id,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (bulletToUse != null)
                  Image(bulletToUse, width: 4, height: 4),
                SizedBox(width: 5),
                Expanded(
                    child: _getNormalText4(
                  text: (i < descriptions.length && descriptions[i].isNotEmpty)
                      ? "${items[i]}\n${descriptions[i]}"
                      : items[i],
                )),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _getHeaderText1({required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
            color: headerDarkColor,
            fontSize: 14,
            font: headerFont,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBulletedText({required String text}) {
    final MemoryImage? bulletToUse = bulletDarkImage;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (bulletToUse != null) Image(bulletToUse, width: 4, height: 4),
        SizedBox(width: 8),
        Expanded(child: _getNormalText4(text: text)),
      ]),
    );
  }

  Widget _buildWorkSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _getHeaderText1(text: AppStrings.t4),
      SizedBox(height: 2),
      for (final work in workData)
        Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
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
    ]);
  }
}