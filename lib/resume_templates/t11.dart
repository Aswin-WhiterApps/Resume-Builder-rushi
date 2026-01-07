import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:resume_builder/Presentation/resources/pdf_assets.dart';
import 'package:resume_builder/Presentation/resources/strings_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import '../model/model.dart';
import '../model/resume_theme_model.dart';
import '../my_singleton.dart';

class Template11 {
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

  late final String? bullet42;
  late final String? background;
  late final String? imageBorder;
  late final String? emailIc;
  late final String? phoneIc;
  late final String? linkIc;

  MemoryImage? backgroundImage;
  MemoryImage? bulletImage;
  MemoryImage? profileImage;
  MemoryImage? imageBorder2;
  MemoryImage? email_42;
  MemoryImage? phone_42;
  MemoryImage? link_42;

  Resume11ThemeModel? resume11theme;

  IntroModel? introData;
  ContactModel? contactData;
  SummeryModel? summeryData;
  List<EducationModel?>? educationData;
  List<WorkModel?>? workData;
  List<SectionModel?> sectionData = [];

  Template11({required this.resume11theme}) {
    normalFont = resume11theme?.normalFont ?? Font.helvetica();
    headerFont = resume11theme?.headerFont ?? Font.helveticaBold();    
    subHeaderColor = resume11theme?.subHeaderColor ?? PdfColor.fromHex("#1E2A5A");
    headerColor = resume11theme?.headerColor ?? PdfColor.fromHex("#1E2A5A");
    nameColor = resume11theme?.nameColor ?? PdfColor.fromHex("#1E2A5A");
    background = resume11theme?.background ?? PdfAssets.rect42;
    normalTextColor = resume11theme!.normalTextColor ?? PdfColor.fromHex("#FFFFFF");
    positionColor = resume11theme!.positionColor ?? PdfColor.fromHex("#F0F0F0");
    boxBottomBorderColor = resume11theme!.boxBottomBorderColor ?? PdfColor.fromHex("#1E2A5A");
    boxHorizontalColor = resume11theme!.boxHorizontalColor ?? PdfColor.fromHex("#FCD1F2");
    boxVerticalColor = resume11theme!.boxVerticalColor ?? PdfColor.fromHex("#F8A0E4");
    backgroundBoxColor = resume11theme!.boxHorizontalColor ?? PdfColor.fromHex("#FCD1F2");
    bullet42 = resume11theme?.bullet42;
    imageBorder = resume11theme?.imageBorder2;
    emailIc = resume11theme?.emailIc;
    phoneIc = resume11theme?.phoneIc;
    linkIc = resume11theme?.linkIc;
  }

   Future<bool> _initializeDataAndAssets() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      print("Error in Template11: User or Resume ID is null.");
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
        print("Template11: Main resume document not found.");
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
            (data) => imageBorder2 = MemoryImage(data.buffer.asUint8List())));
      }

      if (bullet42 != null && bullet42!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bullet42!).then((byteData) {
          bulletImage = MemoryImage(byteData.buffer.asUint8List());
        }));
      }
      if (emailIc != null && emailIc!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(emailIc!)
            .then((data) => email_42 = MemoryImage(data.buffer.asUint8List())));
      }
      if (phoneIc != null && phoneIc!.isNotEmpty) {
        imageFutures.add(rootBundle
            .load(phoneIc!)
            .then((data) => phone_42 = MemoryImage(data.buffer.asUint8List())));
      }
      if (linkIc != null && linkIc!.isNotEmpty) {
        // previously this incorrectly assigned the link image into phone_42.
        // Store the loaded link image into link_42 instead.
        imageFutures.add(rootBundle
            .load(linkIc!)
            .then((data) => link_42 = MemoryImage(data.buffer.asUint8List())));
      }

      if (backgroundBoxColor != null && background!.isNotEmpty) {
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
      print("Template11: All assets loaded successfully.");
      return true;
    } catch (e) {
      print("Error initializing data/assets in Template11: $e");
      return false;
    }
  }

  Future<File?> createPage() async {
    print(" Template11: Starting PDF generation...");
    final bool isInitialized = await _initializeDataAndAssets();
    if (!isInitialized) {
      print(" Template11: PDF generation failed due to initialization errors.");
      return null;
    }

    print(" Template11: Building PDF widgets...");
    print(
        " Template11: introData=${introData != null ? '${introData?.firstName ?? ''} ${introData?.lastName ?? ''}' : 'null'}");
    print(
        " Template11: contactData=${contactData != null ? 'exists' : 'null'}");
    print(
        " Template11: summeryData=${summeryData != null ? 'exists' : 'null'}");
    print(" Template11: workData.length=${workData?.length}");
    print(" Template11: educationData.length=${educationData?.length}");
    print(" Template11: sectionData.length=${sectionData.length}");

   final pdf = Document();

    print(" Template10: All widgets built successfully");

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
          final name =
              "${introData?.firstName ?? ""} ${introData?.lastName ?? ""}"
                  .trim();

          final projectsMatches = sectionData.where(
            (s) =>
                s?.id.toLowerCase() == 'projects' ||
                s?.id == AppStrings.projects,
          );
          final SectionModel? projectsSection =
              projectsMatches.isEmpty ? null : projectsMatches.first;

          final List<SectionModel?> otherSections = sectionData
              .where((s) =>
                  s?.id.toLowerCase() != 'projects' &&
                  s?.id != AppStrings.projects)
              .toList();

          final List<Widget> leftColumnItems = [];
          final List<Widget> rightColumnItems = [];

          // Left Column Content
          leftColumnItems.add(
            Container(
              padding:
                  EdgeInsets.only(top: 60, bottom: 20, right: 40, left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (profileImage != null)
                    Container(
                      width: 120,
                      height: 120,
                      padding: imageBorder2 != null
                          ? EdgeInsets.all(8)
                          : EdgeInsets.zero,
                      decoration: imageBorder2 != null
                          ? BoxDecoration(
                              image: DecorationImage(
                                  image: imageBorder2!, fit: BoxFit.cover),
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 2, color: PdfColor.fromHex("#5B0202")),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                            child: Image(profileImage!, fit: BoxFit.cover)),
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

          leftColumnItems.add(
            Padding(
              padding: EdgeInsets.fromLTRB(60, 5, 20, 5),
              child: _buildRotatedSection(
                title: AppStrings.t2, // CONTACT
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (emailIc != null && email_42 != null)
                      _buildContactRow(email_42!, contactData?.email),
                    if (phoneIc != null && phone_42 != null)
                      _buildContactRow(phone_42!, contactData?.phone),
                    if (linkIc != null && link_42 != null)
                      _buildContactRow(link_42!, contactData?.socialMediaUrl1),
                    if (linkIc != null && link_42 != null)
                      _buildContactRow(link_42!, contactData?.socialMediaUrl2),
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
              leftColumnItems.add(
                Padding(
                  padding: EdgeInsets.fromLTRB(60, 20, 20, 5),
                  child: _buildRotatedSectionFromModel(otherSections[i]!),
                ),
              );
            }
          }

          // Right Column Content
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

          if (educationData != null && educationData!.isNotEmpty) {
            leftColumnItems.add(
              Padding(
                padding: EdgeInsets.fromLTRB(60, 5, 20, 5),
                child: _buildRotatedSection(
                  title: AppStrings.t3,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final edu in educationData!)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (bulletImage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Image(bulletImage!, width: 4, height: 4),
                                ),
                              if (bulletImage != null) SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if ((edu?.schoolName?.isNotEmpty ?? false))
                                      Text(
                                        edu!.schoolName!,
                                        style: TextStyle(
                                          color: normalTextColor,
                                          fontSize: 9,
                                          font: normalFont,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    Text(
                                      "[${edu?.dateFrom ?? ''} - ${edu?.present == true ? 'Present' : edu?.dateTo ?? ''}]",
                                      style: TextStyle(
                                        color: normalTextColor,
                                        fontSize: 7,
                                        font: normalFont,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (workData != null && workData!.isNotEmpty) {
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
                child: _buildProjectSection(projectsSection, ),
              ),
            );
          }

          for (int i = 0; i < otherSections.length; i++) {
            if (i % 2 == 1) {
              rightColumnItems.add(
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 3, 20, 5),
                  child: _buildRightColumnSectionFromModel(otherSections[i]!,
                      headerSpacing: 3.0),
                ),
              );
            }
          }

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
      final file = File("${outputDir.path}/Resume_T10_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());
      print("Pdf Saved To ${file.path}");
      return file;
    } catch (e) {
      print('Failed to save PDF for Template4: $e');
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
                      color: headerColor,
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

  Widget _buildBulletedText({required String text}) {
    final MemoryImage? bulletToUse = bulletImage;
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
      _getHeaderText4Dark(text: AppStrings.t4),
      SizedBox(height: 2),
      for (final work in workData!)
        Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (((work?.compPosition ?? '').trim()).isNotEmpty)
                Text(
                  (work?.compPosition ?? '').trim(),
                  style: TextStyle(
                    color: normalTextColor,
                    fontSize: 10,
                    font: headerFont,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
              if (((work?.compName ?? '').trim()).isNotEmpty ||
                  ((work?.compLocation ?? '').trim()).isNotEmpty)
                Text(
                  [
                    (work?.compName ?? '').trim(),
                    (work?.compLocation ?? '').trim(),
                  ].where((s) => s.isNotEmpty).join(' | '),
                  style: TextStyle(
                    color: normalTextColor,
                    fontSize: 9,
                    font: normalFont,
                    letterSpacing: -0.2,
                  ),
                ),
              Text(
                (work?.present ?? false)
                    ? "${(work?.dateFrom ?? '').trim()} - Present"
                    : "${(work?.dateFrom ?? '').trim()} - ${(work?.dateTo ?? '').trim()}",
                style: TextStyle(
                  color: normalTextColor,
                  fontSize: 8,
                  font: normalFont,
                  letterSpacing: -0.2,
                ),
              ),
              if (((work?.details ?? '').trim()).isNotEmpty) ...[
                SizedBox(height: 2),
                for (final d in (work?.details ?? '')
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
      _getHeaderText4Dark(text: projectSection.id),
      SizedBox(height: 2),
      for (int i = 0; i < projectNames.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (projectNames[i].isNotEmpty)
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
                SizedBox(height: 2),
                for (final d in projectDescriptions[i]
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
