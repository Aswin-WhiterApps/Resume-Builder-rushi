import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/model/resume_theme_model.dart';
import 'package:resume_builder/my_singleton.dart';
import '../Presentation/resources/pdf_assets.dart';

class Template9 {
 
  Font? font ;
  Font? headerFont;
  Font? normalFont;

  late final PdfColor normalTextColor;
  late final PdfColor headerColor;
  late final PdfColor nameColor;
  late final PdfColor positionColor;
  late final PdfColor boxBottomBorderColor;
  late final PdfColor subHeaderColor;

  late final String? backgroundPath;
  late final String? linkAsset;
  late final String? bulletAsset;
  late final String? bulletDarkAsset;
  late final String? bulletLightAsset;
  late final String? bulletDarkPath;
  late final String? bulletLightPath;

  Resume9ThemeModel resume9themeModel;
  MemoryImage? backgroundBoxColor;
  MemoryImage? bulletDarkImage;
  MemoryImage? bulletLightImage;
  MemoryImage? profileImage;
  MemoryImage? t33Horizontal;
  MemoryImage? t33Vertical;

  IntroModel? introData;
  ContactModel? contactData;
  SummeryModel? summaryData;
  List<EducationModel> educationData = [];
  List<WorkModel> workData = [];
  List<SectionModel> sectionData = [];

  Template9({required this.resume9themeModel}) {
    normalTextColor = PdfColors.black;
    headerColor = resume9themeModel.headerColor ?? PdfColors.grey800;
    nameColor = resume9themeModel.nameColor ?? PdfColors.blueGrey900;
    positionColor = resume9themeModel.positionColor ?? PdfColors.blueGrey900;

    backgroundPath = PdfAssets.back91;
    linkAsset = PdfAssets.link91;
    bulletAsset = resume9themeModel.bullet ?? PdfAssets.bullet91;
    bulletDarkPath = bulletAsset;
    bulletLightPath = bulletAsset;

    normalFont = resume9themeModel.font ?? Font.times();
    headerFont = resume9themeModel.font ?? Font.helvetica();
  }

  Future<bool> initializeDataAndAssets() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      throw ArgumentError(
          "User or Resume ID is null in Template9. Ensure MySingleton.userId and MySingleton.resumeId are set.");
    }

    final fireUser = FireUser();

    try {
      print("Template9: Fetching all data for PDF generation...");
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
        throw StateError("Main resume document not found for Template9.");
      }

      workData = results[1] as List<WorkModel>;
      educationData = results[2] as List<EducationModel>;
      sectionData = (results[3] as List<SectionModel>)
          .where((s) => s.value != null && s.value!.isNotEmpty)
          .toList();

      final imageFutures = <Future>[];

      try {
        imageFutures.add(rootBundle.load(PdfAssets.t33Horizontal).then(
            (data) => t33Horizontal = MemoryImage(data.buffer.asUint8List())));
        imageFutures.add(rootBundle.load(PdfAssets.t33Vertical).then(
            (data) => t33Vertical = MemoryImage(data.buffer.asUint8List())));
      } catch (e) {
        print(
            "Template9: Warning - Failed to load background assets: $e (using fallback color)");
      }

      if (introData?.imagePath != null && introData!.imagePath!.isNotEmpty) {
        final imageFile = File(introData!.imagePath!);
        if (await imageFile.exists()) {
          imageFutures.add(imageFile
              .readAsBytes()
              .then((bytes) => profileImage = MemoryImage(bytes)));
        } else {
          print(
              "Template9: Profile image file not found at ${introData!.imagePath}");
        }
      }

      await Future.wait(imageFutures);
      print("Template9: All assets loaded successfully.");
      return true;
    } catch (e) {
      if (e is ArgumentError || e is StateError) {
        rethrow;
      }
      throw Exception("Failed to initialize data/assets in Template9: $e");
    }
  }

  Future<File> createPage() async {
    print("Template9: Starting PDF generation...");

    try {
      await initializeDataAndAssets();
    } catch (e) {
      throw Exception("Template9 initialization failed: $e");
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
                  if (t33Horizontal != null)
                    Positioned.fill(
                      child: Image(t33Horizontal!, fit: BoxFit.cover),
                    ),
                  // Vertical background image as overlay
                  if (t33Vertical != null)
                    Positioned.fill(
                      child: Image(t33Vertical!, fit: BoxFit.cover),
                    ),
                ],
              );
            }),
        build: (Context context) {
          return _buildPageContent();
        }));

    try {
      final outputDir = await getApplicationDocumentsDirectory();

      // 2. Create a unique filename.
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filePath = "${outputDir.path}/Resume_T9_$timestamp.pdf";
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());
      print("Template9: PDF saved to $filePath");
      return file;
    } catch (e) {
      throw Exception("Failed to save Template9 PDF: $e");
    }
  }

  List<Widget> _buildPageContent() {
    final double leftWidth = 210.0;
    final double rightWidth = 320.0;
    final double sectionSpacing = 8.0;
    final double topPadding = 35.0;
    final double betweenColumns = 20.0;
    List<SectionModel> leftSections = [];
    List<SectionModel> rightSections = [];

    // Prioritize hobbies, interests, languages, accomplishments, awards, certificates for left column
    for (final section in sectionData) {
      final sectionId = section.id.toLowerCase();
      if (sectionId.contains('hobbies') ||
          sectionId.contains('interest') ||
          sectionId.contains('language') ||
          sectionId.contains('accomplishment') ||
          sectionId.contains('award') ||
          sectionId.contains('certificate')) {
        leftSections.add(section);
      } else {
        rightSections.add(section);
      }
    }

    if (leftSections.isEmpty && sectionData.isNotEmpty) {
      leftSections =
          sectionData.length >= 2 ? sectionData.sublist(0, 2) : sectionData;
      rightSections = sectionData.length > 2 ? sectionData.sublist(2) : [];
    }

    final Widget profileWidget = Container(
        padding: EdgeInsets.only(top: 10, bottom: 10, right: 80, left: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: PdfColors.white,
              border: Border.all(width: 4, color: PdfColors.grey800),
              image: profileImage != null
                  ? DecorationImage(
                      image: profileImage!,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          )
        ]));

    final Widget leftColumn = Container(
      width: leftWidth,
      padding: EdgeInsets.only(top: 25, bottom: 15, right: 15, left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          profileWidget,
          SizedBox(height: 20),
          if (contactData != null) ...[
            if (contactData!.email != null && contactData!.email!.isNotEmpty)
              _getContactText(text: contactData!.email!),
            if (contactData!.phone != null &&
                contactData!.phone!.isNotEmpty) ...[
              SizedBox(height: 4),
              _getContactText(text: contactData!.phone!),
            ],
            SizedBox(height: 15),
          ],
          for (int i = 0; i < leftSections.length; i++) ...[
            _getSectionWidget(
              title: leftSections[i].id,
              items: leftSections[i]
                      .value
                      ?.split('@@@')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList() ??
                  [],
              isLeft: true,
              description: leftSections[i].description ?? "",
            ),
            if (i < leftSections.length - 1) SizedBox(height: sectionSpacing),
          ],
        ],
      ),
    );

    final Widget rightColumn = Container(
      width: rightWidth,
      child: Padding(
        padding: EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (introData!.firstName != null &&
                introData!.lastName != null) ...[
              Text(
                "${introData!.firstName} ${introData!.lastName}",
                style: TextStyle(
                  font: headerFont,
                  color: PdfColors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
            ],

            // Summary
            if (summaryData != null) ...[
              _getHeaderTextDark(text: "SUMMARY", size: 11),
              SizedBox(height: 4),
              _getParagraph(text: summaryData!.summery ?? ""),
              SizedBox(height: sectionSpacing),
            ],

            // Education
            if (educationData.isNotEmpty) ...[
              _getHeaderTextDark(text: "EDUCATION", size: 11), // Reduced
              SizedBox(height: 4), // Reduced
              for (final edu in educationData) ...[
                _buildEducationEntry(edu),
                SizedBox(height: 3),
              ],
              SizedBox(height: sectionSpacing),
            ],

            // Work Experience
            if (workData.isNotEmpty) ...[
              _getHeaderTextDark(text: "WORK", size: 11), // Reduced
              SizedBox(height: 4), // Reduced
              for (int i = 0; i < workData.length; i++) ...[
                _getWorkEntry(i + 1, workData[i]),
                SizedBox(height: 6), // Reduced from 8
              ],
              SizedBox(height: sectionSpacing),
            ],

            // Right Sections (Interests, Achievements)
            for (int i = 0; i < rightSections.length; i++) ...[
              _getSectionWidget(
                title: rightSections[i].id,
                items: rightSections[i]
                        .value
                        ?.split('@@@@@@@')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList() ??
                    [],
                isLeft: false,
                description: rightSections[i].description ?? "",
              ),
              if (i < rightSections.length - 1)
                SizedBox(height: sectionSpacing),
            ],
          ],
        ),
      ),
    );

    return [
      Padding(
        padding: EdgeInsets.only(top: topPadding, left: 20, right: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leftColumn,
            SizedBox(width: betweenColumns),
            rightColumn,
          ],
        ),
      ),
    ];
  }

  // --- PDF WIDGET HELPER METHODS ---
  Widget _getParagraph({required String text, PdfColor? color}) => Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          color: color ?? normalTextColor,
          fontSize: 7.5, // Reduced from 8 to help fit
          font: normalFont,
          height: 1.2,
        ),
      );

  Widget _getSectionWidget({
    required String title,
    required List<String> items,
    required bool isLeft,
    required String description,
  }) {
    final PdfColor textColor = normalTextColor;
    final MemoryImage? bullet = bulletDarkImage;
    final double fontSize = 6.5;
    final double headerSize = isLeft ? 9.0 : 10.0;
    final double sectionWidth = isLeft ? 170.0 : double.infinity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _getHeaderTextDark(text: title, size: headerSize),
        SizedBox(height: 3),
        if (description.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              description,
              style: TextStyle(
                  font: normalFont, color: textColor, fontSize: fontSize - 0.5),
            ),
          ),
          SizedBox(height: 2),
        ],
        // Special handling for Projects section
        if (title.toLowerCase().contains('project')) ...[
          for (final item in items) ...[
            _buildProjectItem(item, textColor, fontSize, sectionWidth),
            SizedBox(height: 2),
          ],
        ] else ...[
          for (final item in items) ...[
            _buildBulletedText(
              bullet: bullet,
              text: item.trim().replaceAll('@@@@@@', '  '),
              color: textColor,
              font: normalFont,
              size: fontSize,
              maxWidth: sectionWidth,
            ),
            SizedBox(height: 2),
          ],
        ],
      ],
    );
  }

  Widget _buildProjectItem(
      String item, PdfColor textColor, double fontSize, double maxWidth) {
    // Split project name and description
    final parts = item.split('|');
    final projectName = parts.isNotEmpty ? parts[0].trim() : '';
    final description = parts.length > 1 ? parts[1].trim() : '';

    return Padding(
      padding: EdgeInsets.only(left: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            projectName,
            style: TextStyle(
              font: headerFont,
              color: textColor,
              fontSize: fontSize + 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (description.isNotEmpty) ...[
            SizedBox(height: 1),
            Text(
              description,
              style: TextStyle(
                font: normalFont,
                color: textColor,
                fontSize: fontSize,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBulletedText({
    required MemoryImage? bullet,
    required String text,
    required PdfColor color,
    required Font? font,
    required double size,
    double? maxWidth,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bullet != null)
            Padding(
              padding: EdgeInsets.only(top: 3, right: 4),
              child: Image(bullet, width: 3, height: 3),
            )
          else
            SizedBox(width: 7),
          Expanded(
            // This inner Expanded is fine as parent Row width is bounded
            child: maxWidth != null
                ? SizedBox(
                    width: maxWidth,
                    child: Text(
                      text,
                      style:
                          TextStyle(font: font, color: color, fontSize: size),
                      softWrap: true,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(font: font, color: color, fontSize: size),
                    softWrap: true,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _getContactText({required String text}) => Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          font: normalFont,
          color: PdfColors.black,
          fontSize: 7,
          fontWeight: FontWeight.normal,
        ),
      );

  Widget _getHeaderTextDark({required String text, double size = 11}) => Text(
        // Default reduced to 11
        text,
        style: TextStyle(
          font: headerFont,
          color: PdfColor.fromHex("#FF8C00"), // Orange color from image
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _buildEducationEntry(EducationModel edu) {
    final String eduText =
        "${edu.schoolName ?? ''} [${edu.dateFrom ?? ''}${edu.dateTo != null ? ' - ${edu.dateTo}' : ''}${edu.present == true ? ' - Present' : ''}]";
    return Padding(
      padding: EdgeInsets.only(left: 5),
      child: Text(
        eduText,
        style:
            TextStyle(font: normalFont, color: normalTextColor, fontSize: 6.5),
      ),
    );
  }

  Widget _getWorkEntry(int index, WorkModel work) {
    final String duration = work.present == true
        ? '[${work.dateFrom ?? ''} - Present]'
        : '[${work.dateFrom ?? ''} - ${work.dateTo ?? ''}]';
    return Padding(
      padding: EdgeInsets.only(left: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${index}. ${work.compName ?? ''}",
            style: TextStyle(
              font: headerFont,
              color: normalTextColor,
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (work.compLocation?.isNotEmpty ?? false)
            Text(
              work.compLocation!,
              style: TextStyle(
                  font: normalFont, color: normalTextColor, fontSize: 6.5),
            ),
          Text(
            "Position: ${work.compPosition ?? ''}",
            style: TextStyle(
                font: normalFont, color: normalTextColor, fontSize: 6.5),
          ),
          Text(
            "Duration: $duration",
            style: TextStyle(
                font: normalFont, color: normalTextColor, fontSize: 6.5),
          ),
        ],
      ),
    );
  }
}
