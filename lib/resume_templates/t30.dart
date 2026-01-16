import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:resume_builder/Presentation/resources/strings_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/model/resume_theme_model.dart';
import 'package:resume_builder/my_singleton.dart';
import 'package:resume_builder/Presentation/resources/pdf_assets.dart';

class Template30 {
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

  late final String? backgroundPath;
  late final String? linkAsset;

  // T7 uses bulletDark/Light logic, we will adapt or simplify
  late final String? bulletDarkPath;
  late final String? bulletLightPath;

  Resume30ThemeModel resume30themeModel;

  MemoryImage? bulletDarkImage;
  MemoryImage? bulletLightImage;
  MemoryImage? profileImage;
  MemoryImage? imageBorder64;

  // New single background asset
  MemoryImage? back72Image;

  IntroModel? introData;
  ContactModel? contactData;
  SummeryModel? summaryData;
  List<EducationModel> educationData = [];
  List<WorkModel> workData = [];
  List<SectionModel> sectionData = [];

  Template30({required this.resume30themeModel}) {
    normalTextColor = resume30themeModel.normalTextColor ?? PdfColors.black;
    headerDarkColor = resume30themeModel.headerColor ?? PdfColors.grey800;
    // headerLightColor is not in Resume21ThemeModel, using default or derived
    headerLightColor = PdfColors.white;

    nameColor = resume30themeModel.nameColor ?? PdfColors.blueGrey900;
    positionColor = resume30themeModel.positionColor ?? PdfColors.blueGrey900;

    // No background asset - using solid white background
    linkAsset = resume30themeModel.linkIc ?? PdfAssets.link7;

    normalFont = resume30themeModel.normalFont ?? Font.times();
    headerFont = resume30themeModel.headerFont ?? Font.helvetica();
    nameFont = resume30themeModel.headerFont ?? Font.helveticaBold();
  }

  Future<bool> _initializeDataAndAssets() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      print("Error in Template29: User or Resume ID is null.");
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
        summaryData = resume.summary;
      } else {
        print("Template30: Main resume document not found.");
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
      // Removed background asset loading for solid white background

      if (introData?.imagePath != null && introData!.imagePath!.isNotEmpty) {
        final imageFile = File(introData!.imagePath!);
        if (await imageFile.exists()) {
          imageFutures.add(imageFile
              .readAsBytes()
              .then((bytes) => profileImage = MemoryImage(bytes)));
        }
      }

      await Future.wait(imageFutures);
      print("Template30: All assets loaded successfully.");
      return true;
    } catch (e) {
      print("Error initializing data/assets in Template30: $e");
      return false;
    }
  }

  Future<File?> createPage() async {
    print(" Template30: Starting PDF generation...");
    final bool isInitialized = await _initializeDataAndAssets();
    if (!isInitialized) {
      print(" Template30: PDF generation failed due to initialization errors.");
      return null;
    }

    print(" Template30: Building PDF widgets...");
    print(
        " Template30: introData=${introData != null ? '${introData?.firstName ?? ''} ${introData?.lastName ?? ''}' : 'null'}");
    print(
        " Template30: contactData=${contactData != null ? 'exists' : 'null'}");
    print(
        " Template30: summaryData=${summaryData != null ? 'exists' : 'null'}");
    print(" Template30: workData.length=${workData.length}");
    print(" Template30: educationData.length=${educationData.length}");
    print(" Template30: sectionData.length=${sectionData.length}");

    final pdf = Document();

    print(" Template27: All widgets built successfully");

    pdf.addPage(MultiPage(
        pageTheme: PageTheme(
            margin: EdgeInsets.all(20), // Add proper margins
            pageFormat: PdfPageFormat.a4,
            buildBackground: (context) {
              if (back72Image != null) {
                return Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover, image: back72Image!)));
              } else if (profileImage != null) {
                return Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover, image: profileImage!)));
              } else {
                return Container(color: PdfColors.grey100);
              }
            }),
        build: (Context context) {
          return [_buildSinglePageLayout()];
        }));

    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final String timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File("${outputDir.path}/Resume_T27_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());
      print("Pdf Saved To ${file.path}");
      return file;
    } catch (e) {
      print('Failed to save PDF for Template27: $e');
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

    // Add name to LEFT column at the top (swapped from right)
    leftColumnItems.add(
      Container(
        padding: EdgeInsets.only(top: 20, bottom: 10, right: 20, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _sanitizeText(name.isEmpty ? "Your Name" : name),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: PdfColor.fromHex("#000000"), // Changed to black
                font: headerFont,
                fontSize: 24, // Reduced font size
                fontWeight: FontWeight.bold,
              ),
            ),
            // Add contact data below name
            if (contactData?.email != null &&
                contactData!.email!.isNotEmpty) ...[
              SizedBox(height: 5),
              Text(
                _sanitizeText(contactData!.email!),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: PdfColor.fromHex("#000000"),
                  font: normalFont,
                  fontSize: 8,
                ),
              ),
            ],
            if (contactData?.phone != null &&
                contactData!.phone!.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(
                _sanitizeText(contactData!.phone!),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: PdfColor.fromHex("#000000"),
                  font: normalFont,
                  fontSize: 8,
                ),
              ),
            ],
            if (contactData?.personnelWeb != null &&
                contactData!.personnelWeb!.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(
                _sanitizeText(contactData!.personnelWeb!),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: PdfColor.fromHex("#000000"),
                  font: normalFont,
                  fontSize: 8,
                ),
              ),
            ],
            if (contactData?.socialMediaUrl1 != null &&
                contactData!.socialMediaUrl1!.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(
                _sanitizeText(contactData!.socialMediaUrl1!),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: PdfColor.fromHex("#000000"),
                  font: normalFont,
                  fontSize: 8,
                ),
              ),
            ],
            if (contactData?.socialMediaUrl2 != null &&
                contactData!.socialMediaUrl2!.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(
                _sanitizeText(contactData!.socialMediaUrl2!),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: PdfColor.fromHex("#000000"),
                  font: normalFont,
                  fontSize: 8,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    leftColumnItems.add(
      Container(
        padding: EdgeInsets.only(top: 5, bottom: 10, right: 20, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imageBorder64 != null)
              Container(
                width: 80, // Reduced size
                height: 80, // Reduced size
                padding: EdgeInsets.all(2), // Reduced padding
                decoration: imageBorder64 != null
                    ? BoxDecoration(
                        image: DecorationImage(
                            image: imageBorder64!, fit: BoxFit.cover),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 3,
                        color: PdfColor.fromHex(
                            "#000000")), // Reduced border width
                    shape: BoxShape.circle,
                  ),
                  child:
                      ClipOval(child: Image(imageBorder64!, fit: BoxFit.cover)),
                ),
              ),
          ],
        ),
      ),
    );

    for (int i = 0; i < sectionData.length; i++) {
      if (i % 2 == 0) {
        // right-side only (swapped from left)
        rightColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 5), // Reduced padding
            child: _buildRotatedSectionFromModel(sectionData[i]),
          ),
        );
      }
    }

    // Add summary to LEFT column (swapped from right)
    if ((summaryData?.summery?.isNotEmpty ?? false)) {
      leftColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 1, 5), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getHeaderText4Dark(text: AppStrings.t5),
              SizedBox(height: 4), // Reduced spacing
              _getParagraph(text: summaryData!.summery!),
            ],
          ),
        ),
      );
    }

    // Add education to LEFT column (swapped from right)
    if (educationData.isNotEmpty) {
      leftColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5), // Reduced padding
          child: _buildRightColumnSection(
            title: AppStrings.t3,
            items: educationData
                .map(
                  (edu) =>
                      "${edu.schoolName ?? ''}\n[${edu.dateFrom ?? ''} - ${edu.present == true ? 'Present' : edu.dateTo ?? ''}]",
                )
                .toList(),
            bottomPadding: 2.0, // Reduced padding
          ),
        ),
      );
    }

    // Add work experience to LEFT column (swapped from right)
    if (workData.isNotEmpty) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 5), // Reduced padding
          child: _buildWorkSection(),
        ),
      );
    }

    // Add odd-indexed sections to LEFT column (swapped from right)
    for (int i = 0; i < sectionData.length; i++) {
      if (i % 2 == 1) {
        leftColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(10, 3, 10, 5), // Reduced padding
            child: _buildRightColumnSectionFromModel(sectionData[i],
                headerSpacing: 2.0), // Reduced spacing
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
          SizedBox(width: 5),
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
                    color: PdfColor.fromHex("#000000"),
                    font: normalFont,
                    fontSize: 8))), // Reduced font size
      ]),
    );
  }

  Widget _getNormalText4({required String text}) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppPadding.p12, bottom: 1), // Reduced bottom padding
      child: Text(_sanitizeText(text),
          textAlign: TextAlign.left,
          softWrap: true,
          style: TextStyle(
            color: PdfColor.fromHex("#000000"), // Changed to black
            fontSize: 8, // Reduced font size
            font: normalFont,
          )),
    );
  }

  Widget _getParagraph({required String text}) {
    return Text(text,
        textAlign: TextAlign.justify,
        style: TextStyle(
            color: PdfColor.fromHex("#000000"),
            fontSize: 6,
            font: normalFont)); // Reduced font size
  }

  // Clean up any control / replacement characters and normalize whitespace
  String _sanitizeText(String s) {
    if (s.isEmpty) return s;
    // Replace common non-renderable characters with space
    var out = s.replaceAll(
        RegExp(r'[\u00A0\u200B\u200C\u200D\u200E\u200F\uFEFF\uFFFD]'), ' ');
    // Remove control characters (0-31, 127-159)
    out = out.replaceAll(RegExp(r'[\x00-\x1f\x7f-\x9f]'), ' ');
    // Collapse multiple whitespace into single space and trim
    out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
    return out;
  }

  Widget _getHeaderText4Dark({required String text}) {
    return Text(_sanitizeText(text).toUpperCase(),
        style: TextStyle(
            color: PdfColor.fromHex("#000000"), // Changed to black
            fontSize: 10, // Reduced font size
            font: headerFont,
            fontWeight: FontWeight.bold));
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

  Widget _buildWorkSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _getHeaderText4Dark(text: AppStrings.t4),
      SizedBox(height: 4),
      if (workData.isEmpty) ...[
        Text(
          "No work experience added",
          style: TextStyle(
            color: PdfColor.fromHex("#000000"),
            fontSize: 9,
            font: normalFont,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
      for (final work in workData)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Always show position (even if empty, show placeholder)
              Text(
                _sanitizeText((work.compPosition?.trim().isNotEmpty == true)
                    ? work.compPosition!.trim()
                    : "Position"),
                style: TextStyle(
                  color: PdfColor.fromHex("#000000"),
                  fontSize: 10,
                  font: headerFont,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              // Company and Location (show if either exists, otherwise show placeholder)
              Text(
                [
                  _sanitizeText((work.compName?.trim().isNotEmpty == true)
                      ? work.compName!.trim()
                      : "Company Name"),
                  _sanitizeText((work.compLocation?.trim().isNotEmpty == true)
                      ? work.compLocation!.trim()
                      : "Location"),
                ].join(' | '),
                style: TextStyle(
                  color: PdfColor.fromHex("#000000"),
                  fontSize: 9,
                  font: normalFont,
                  letterSpacing: -0.2,
                ),
              ),
              // Always show dates (even if empty, show placeholder)
              Text(
                (work.present ?? false)
                    ? "${work.dateFrom?.trim().isNotEmpty == true ? _sanitizeText(work.dateFrom!.trim()) : "Start Date"} - Present"
                    : "${work.dateFrom?.trim().isNotEmpty == true ? _sanitizeText(work.dateFrom!.trim()) : "Start Date"} - ${work.dateTo?.trim().isNotEmpty == true ? _sanitizeText(work.dateTo!.trim()) : "End Date"}",
                style: TextStyle(
                  color: PdfColor.fromHex("#000000"),
                  fontSize: 8,
                  font: normalFont,
                  letterSpacing: -0.2,
                ),
              ),
              // Work details
              if (work.details?.trim().isNotEmpty == true) ...[
                SizedBox(height: 4),
                for (final d in (work.details!)
                    .split(RegExp(r'[\n@]+'))
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty))
                  Padding(
                    padding: EdgeInsets.only(left: AppPadding.p12, bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 3,
                          height: 3,
                          margin: EdgeInsets.only(top: 3, right: 5),
                          decoration: BoxDecoration(
                            color: PdfColor.fromHex("#000000"),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _sanitizeText(d),
                            textAlign: TextAlign.left,
                            softWrap: true,
                            style: TextStyle(
                              color: PdfColor.fromHex("#000000"),
                              fontSize: 8,
                              font: normalFont,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ]
            ],
          ),
        ),
      SizedBox(height: 8),
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

    final MemoryImage? bulletToUse = bulletDarkImage;
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
                  if (bulletToUse != null)
                    Container(
                      width: 4,
                      height: 4,
                      child: Image(bulletToUse),
                    )
                  else
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: PdfColor.fromHex("#000000"),
                        shape: BoxShape.circle,
                      ),
                    ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _sanitizeText(items[i]),
                      style: TextStyle(
                        color: PdfColor.fromHex("#000000"),
                        fontSize: 8,
                        font: headerFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
                // Description below if exists
                if (i < descriptions.length && descriptions[i].isNotEmpty) ...[
                  SizedBox(height: 1),
                  Padding(
                    padding: EdgeInsets.only(left: AppPadding.p12 + 12),
                    child: Text(
                      _sanitizeText(descriptions[i]),
                      style: TextStyle(
                        color: PdfColor.fromHex("#000000"),
                        fontSize: 7,
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

    final MemoryImage? bulletToUse = bulletDarkImage;
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
                  // Bold subheading
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (bulletToUse != null)
                      Image(bulletToUse, width: 4, height: 4),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _sanitizeText(items[i]),
                        style: TextStyle(
                          color: PdfColor.fromHex("#000000"),
                          fontSize: 8,
                          font: headerFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                  // Description below if exists
                  if (i < descriptions.length &&
                      descriptions[i].isNotEmpty) ...[
                    SizedBox(height: 1),
                    Padding(
                      padding: EdgeInsets.only(left: 9),
                      child: Text(
                        _sanitizeText(descriptions[i]),
                        style: TextStyle(
                          color: PdfColor.fromHex("#000000"),
                          fontSize: 7,
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
