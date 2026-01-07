import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import '../firestore/user_firestore.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/model/resume_theme_model.dart';
import 'package:resume_builder/my_singleton.dart';
import '../Presentation/resources/strings_manager.dart';
import 'package:http/http.dart' as http;

class Template2 {
  late final Font nameFont;
  late final Font normalFont;
  late final Font headerFont;
  late final PdfColor nameColor;
  late final PdfColor headerColor;
  late final PdfColor normalColor;
  late final String? bulletPathFromTheme;

  MemoryImage? t2_bullet;
  MemoryImage? profileImage;
  MemoryImage? signatureImage;

  IntroModel? introData;
  ContactModel? contactData;
  SummeryModel? summeryData;
  List<EducationModel> educationData = [];
  List<WorkModel> workData = [];
  List<SectionModel> sectionData = [];

  Template2(
      {required Resume2ThemeModel? resume2theme,
      required CL2ThemeModel? cl2themeModel}) {
    nameFont = Font.timesBold();
    normalFont = Font.times();
    headerFont = Font.timesBold();
    nameColor = PdfColor.fromHex('#2E7D32');
    headerColor = PdfColor.fromHex('#2E7D32');
    normalColor = PdfColor.fromHex('#2E7D32');
    bulletPathFromTheme = resume2theme?.bulletDark;
  }

  Future<bool> _initializeDataAndAssets() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      print("Error in Template1: User or Resume ID is null.");
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
      sectionData = (results[3] as List<SectionModel>)
          .where((s) =>
              (s.value != null && s.value!.isNotEmpty) ||
              (s.description != null && s.description!.isNotEmpty))
          .toList();

      if (resume != null) {
        introData = resume.intro;
        contactData = resume.contact;
        summeryData = resume.summary;
      }

      final imageFutures = <Future>[];

      if (bulletPathFromTheme != null && bulletPathFromTheme!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bulletPathFromTheme!).then((byteData) {
          t2_bullet = MemoryImage(byteData.buffer.asUint8List());
        }));
      }

      if (introData?.imagePath != null && introData!.imagePath!.isNotEmpty) {
        final imageFile = File(introData!.imagePath!);
        if (await imageFile.exists()) {
          imageFutures.add(imageFile.readAsBytes().then((bytes) {
            profileImage = MemoryImage(bytes);
          }));
        }
      }

      if (resume?.signatureUrl != null && resume!.signatureUrl!.isNotEmpty) {
        imageFutures
            .add(http.get(Uri.parse(resume.signatureUrl!)).then((response) {
          if (response.statusCode == 200) {
            signatureImage = MemoryImage(response.bodyBytes);
          }
        }).catchError((e) {
          print(
              "Failed to load signature from URL: ${resume.signatureUrl}. Error: $e");
        }));
      }

      await Future.wait(imageFutures);

      profileImage ??= MemoryImage(
          (await rootBundle.load('assets/images/samp_prof_img.png'))
              .buffer
              .asUint8List());
    } catch (e) {
      print("Error loading assets/data for Template1: $e");
      return false;
    }
    return true;
  }

  Future<File?> createPage() async {
    final bool isInitialized = await _initializeDataAndAssets();
    if (!isInitialized) {
      print("PDF generation failed due to initialization errors.");
      return null;
    }

    final pdf = Document();
    final List<Widget> leftColumnWidgets = [];
    final List<Widget> rightColumnWidgets = [];

    if (summeryData?.summery?.isNotEmpty ?? false) {
      rightColumnWidgets.add(_buildSummarySection(summeryData!.summery!));
    }
    if (educationData.isNotEmpty) {
      rightColumnWidgets.add(_buildEducationSection());
    }
    if (workData.isNotEmpty) {
      rightColumnWidgets.add(_buildWorkSection());
    }

    for (int i = 0; i < sectionData.length; i++) {
      Widget sectionWidget = _getMultiSection(
        title: sectionData[i].id,
        itemText: sectionData[i].value ?? "",
        descriptionText: sectionData[i].description ?? "",
      );
      if (i % 2 == 0) {
        leftColumnWidgets.add(sectionWidget);
      } else {
        rightColumnWidgets.add(sectionWidget);
      }
    }

    if (signatureImage != null) {
      rightColumnWidgets.add(
        Container(
          alignment: Alignment.centerRight,
          margin: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 120,
                height: 40,
                child: Image(signatureImage!, fit: BoxFit.contain),
              ),
              Container(width: 100, height: 1, color: normalColor),
              Text(
                "Signature",
                style: TextStyle(
                  font: normalFont,
                  fontSize: 7,
                  color: normalColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    pdf.addPage(
      MultiPage(
        pageTheme: PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.all(15),
        ),
        build: (Context context) {
          return [
            if (profileImage != null)
              Center(
                child: ClipOval(
                  child: SizedBox.fromSize(
                    size: const PdfPoint(60, 60),
                    child: Image(profileImage!, fit: BoxFit.cover),
                  ),
                ),
              ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "${introData?.firstName ?? ""} ${introData?.lastName ?? ""}"
                    .toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  font: nameFont,
                  color: nameColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                if (contactData?.email?.isNotEmpty ?? false)
                  Text(
                    contactData!.email!,
                    style: TextStyle(fontSize: 7, color: normalColor),
                  ),
                if (contactData?.phone?.isNotEmpty ?? false)
                  Text(
                    contactData!.phone!,
                    style: TextStyle(fontSize: 7, color: normalColor),
                  ),
                if (contactData?.addr1?.isNotEmpty ?? false)
                  Text(
                    contactData!.addr1!,
                    style: TextStyle(fontSize: 7, color: normalColor),
                  ),
                if (contactData?.addr2?.isNotEmpty ?? false)
                  Text(
                    contactData!.addr2!,
                    style: TextStyle(fontSize: 7, color: normalColor),
                  ),
                if (contactData?.socialMediaUrl1?.isNotEmpty ?? false)
                  Text(
                    contactData!.socialMediaUrl1!,
                    style: TextStyle(
                      fontSize: 7,
                      color: PdfColors.blue,
                    ),
                  ),
                if (contactData?.socialMediaUrl2?.isNotEmpty ?? false)
                  Text(
                    contactData!.socialMediaUrl2!,
                    style: TextStyle(
                      fontSize: 7,
                      color: PdfColors.blue,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Partitions(
              children: [
                Partition(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: leftColumnWidgets,
                  ),
                ),
                Partition(
                  width: 20,
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 1,
                      color: PdfColors.black,
                      height: double.infinity,
                    ),
                  ),
                ),
                Partition(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rightColumnWidgets,
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filePath = "${outputDir.path}/Resume_T1_$timestamp.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      print("PDF Saved To: $filePath");
      return file;
    } catch (e) {
      print('Failed to save PDF for Template1: $e');
      return null;
    }
  }

  Widget _buildSummarySection(String summary) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _getHeaderText1(text: AppStrings.t5),
      SizedBox(height: 5),
      _getParagraph(text: summary),
      SizedBox(height: 10),
    ]);
  }

  Widget _buildEducationSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _getHeaderText1(text: AppStrings.t3),
      SizedBox(height: 4),
      for (final edu in educationData)
        _buildBulletedText(
            text:
                "${edu.schoolName ?? ""} [${edu.dateFrom ?? ""}${(edu.present ?? false) ? " - Present" : (edu.dateTo != null && edu.dateTo!.isNotEmpty ? " - ${edu.dateTo}" : "")}]"),
      SizedBox(height: 8),
    ]);
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
                    color: normalColor,
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
                    color: normalColor,
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
                  color: normalColor,
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

  Widget _getMultiSection(
      {required String title,
      required String itemText,
      required String descriptionText}) {
    final List<String> itemTitles =
        itemText.split('@').where((s) => s.trim().isNotEmpty).toList();
    final List<String> itemDescriptions =
        descriptionText.split(RegExp(r'@{1,3}'));

    if (itemTitles.isEmpty && descriptionText.trim().isEmpty)
      return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _getHeaderText1(text: title),
        SizedBox(height: 4),
        for (int i = 0; i < itemTitles.length; i++)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBulletedText(text: itemTitles[i], isBold: true),
              if (i < itemDescriptions.length &&
                  itemDescriptions[i].trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 4),
                  child: _getNormalText1(text: itemDescriptions[i].trim()),
                ),
            ],
          )
      ]),
    );
  }

  Widget _buildBulletedText({required String text, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (t2_bullet != null)
            Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Image(t2_bullet!, width: 4, height: 4))
          else
            Text("• ", style: TextStyle(fontSize: 8)),
          SizedBox(width: 10),
          Expanded(child: _getNormalText1(text: text, isBold: isBold)),
        ],
      ),
    );
  }

  Widget _getNormalText1({required String text, bool isBold = false}) {
    return Text(text,
        style: TextStyle(
          color: normalColor,
          fontSize: 9,
          font: isBold ? headerFont : normalFont,
          fontWeight: isBold ? FontWeight.bold : null,
          letterSpacing: -0.2,
        ));
  }

  Widget _getParagraph({required String text}) {
    return Text(text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          color: normalColor,
          fontSize: 9,
          font: normalFont,
          lineSpacing: 1.2,
          letterSpacing: -0.2,
        ));
  }

  Widget _getHeaderText1({required String text}) {
    return Text(text.toUpperCase(),
        style: TextStyle(
          font: headerFont,
          color: headerColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ));
  }
}
