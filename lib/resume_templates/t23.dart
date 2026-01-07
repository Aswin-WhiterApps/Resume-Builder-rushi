import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
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

class Template23 {
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
  late final String? linkIcPath;
  late final String? bulletDarkPath;
  late final String? bulletLightPath;
  late final String? imageBorderPath;

  Resume23ThemeModel resume23themeModel;

  MemoryImage? bulletDarkImage;
  MemoryImage? bulletLightImage;
  MemoryImage? profileImage;
  MemoryImage? imageBorder64;
  MemoryImage? link9Image;

  // New single background asset
  MemoryImage? back72Image;

  IntroModel? introData;
  ContactModel? contactData;
  SummeryModel? summaryData;
  List<EducationModel> educationData = [];
  List<WorkModel> workData = [];
  List<SectionModel> sectionData = [];

  Template23({required this.resume23themeModel}) {
    normalTextColor = resume23themeModel.normalTextColor ?? PdfColors.black;
    headerDarkColor = resume23themeModel.headerColor ?? PdfColors.grey800;
    // headerLightColor is not in Resume21ThemeModel, using default or derived
    headerLightColor = PdfColors.white;

    nameColor = resume23themeModel.nameColor ?? PdfColors.blueGrey900;
    positionColor = resume23themeModel.positionColor ?? PdfColors.blueGrey900;

    backgroundPath = resume23themeModel.background ?? PdfAssets.back73;
    linkIcPath = resume23themeModel.linkIc ?? PdfAssets.link83;
    bulletDarkPath = resume23themeModel.bullet73 ?? PdfAssets.bullet83;
    bulletLightPath = resume23themeModel.bullet73 ?? PdfAssets.bullet83;
    imageBorderPath =
        resume23themeModel.imageBorder73 ?? PdfAssets.imageBorder71;

    normalFont = resume23themeModel.normalFont ?? Font.times();
    headerFont = resume23themeModel.headerFont ?? Font.helvetica();
    nameFont = resume23themeModel.headerFont ?? Font.helveticaBold();
  }

  Future<bool> _initializeDataAndAssets() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      print("Error in Template23: User or Resume ID is null.");
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
        print("Template23: Main resume document not found.");
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
      if (backgroundPath != null && backgroundPath!.isNotEmpty) {
        imageFutures.add(rootBundle.load(backgroundPath!).then((byteData) {
          back72Image = MemoryImage(byteData.buffer.asUint8List());
        }).catchError((e) {
          print("Template23: Failed to load asset $backgroundPath: $e");
        }));
      }

      if (imageBorderPath != null && imageBorderPath!.isNotEmpty) {
        imageFutures.add(rootBundle.load(imageBorderPath!).then((data) {
          imageBorder64 = MemoryImage(data.buffer.asUint8List());
        }).catchError((e) {
          print("Template23: Failed to load asset $imageBorderPath: $e");
        }));
      }

      if (linkIcPath != null && linkIcPath!.isNotEmpty) {
        imageFutures.add(rootBundle.load(linkIcPath!).then((data) {
          link9Image = MemoryImage(data.buffer.asUint8List());
        }).catchError((e) {
          print("Template23: Failed to load asset $linkIcPath: $e");
        }));
      }

      if (bulletDarkPath != null && bulletDarkPath!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bulletDarkPath!).then((data) {
          bulletDarkImage = MemoryImage(data.buffer.asUint8List());
        }).catchError((e) {
          print("Template23: Failed to load asset $bulletDarkPath: $e");
        }));
      }
      if (bulletLightPath != null && bulletLightPath!.isNotEmpty) {
        imageFutures.add(rootBundle.load(bulletLightPath!).then((data) {
          bulletLightImage = MemoryImage(data.buffer.asUint8List());
        }).catchError((e) {
          print("Template23: Failed to load asset $bulletLightPath: $e");
        }));
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
      print("Template23: All assets loaded successfully.");
      return true;
    } catch (e) {
      print("Error initializing data/assets in Template23: $e");
      return false;
    }
  }

  Future<File?> createPage() async {
    print(" Template23: Starting PDF generation...");
    final bool isInitialized = await _initializeDataAndAssets();
    if (!isInitialized) {
      print(" Template23: PDF generation failed due to initialization errors.");
      return null;
    }

    print(" Template23: Building PDF widgets...");
    print(
        " Template23: introData=${introData != null ? '${introData?.firstName ?? ''} ${introData?.lastName ?? ''}' : 'null'}");
    print(
        " Template23: contactData=${contactData != null ? 'exists' : 'null'}");
    print(
        " Template23: summaryData=${summaryData != null ? 'exists' : 'null'}");
    print(" Template23: workData.length=${workData.length}");
    print(" Template23: educationData.length=${educationData.length}");
    print(" Template23: sectionData.length=${sectionData.length}");

    final pdf = Document();

    print(" Template23: All widgets built successfully");

    pdf.addPage(MultiPage(
        pageTheme: PageTheme(
            margin: EdgeInsets.zero,
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
      final file = File("${outputDir.path}/Resume_T23_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());
      print("Pdf Saved To ${file.path}");
      return file;
    } catch (e) {
      print('Failed to save PDF for Template23: $e');
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

    // Add name section
    leftColumnItems.add(
      Container(
        margin: EdgeInsets.only(top: 60, bottom: 5, right: 5, left: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              PdfColor.fromHex('#6B4E3D'),
              PdfColor.fromHex('#8D6E63'),
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
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name.isEmpty ? "Your Name" : name,
                style: TextStyle(
                  color: PdfColors.white,
                  font: nameFont,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
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
            padding: EdgeInsets.fromLTRB(60, 20, 5, 5),
            child: _buildRotatedSectionFromModel(otherSections[i]),
          ),
        );
      }
    }

    // Left Column Contact Info (At bottom)
    leftColumnItems.add(
      Padding(
        padding: EdgeInsets.fromLTRB(60, 20, 20, 5),
        child: _buildRotatedSection(
          title: AppStrings.t2, // CONTACT
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (link9Image != null)
                _buildContactRow(
                  link9Image!,
                  contactData?.socialMediaUrl1,
                ),
              if (link9Image != null)
                _buildContactRow(link9Image!, contactData?.socialMediaUrl2),
            ],
          ),
        ),
      ),
    );

    if ((summaryData?.summery?.isNotEmpty ?? false)) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(5, 60, 10, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getHeaderText4Dark(text: AppStrings.t5),
              SizedBox(height: 5),
              _getParagraph(text: summaryData!.summery!),
            ],
          ),
        ),
      );
    }

    if (educationData.isNotEmpty) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 20, 5),
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
          padding: EdgeInsets.fromLTRB(5, 3, 20, 5),
          child: _buildWorkSection(),
        ),
      );
    }

    if (projectsSection != null) {
      rightColumnItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(5, 3, 20, 5),
          child: _buildProjectSection(projectsSection),
        ),
      );
    }

    for (int i = 0; i < otherSections.length; i++) {
      if (i % 2 == 1) {
        leftColumnItems.add(
          Padding(
            padding: EdgeInsets.fromLTRB(60, 20, 5, 5),
            child: _buildRightColumnSectionFromModel(otherSections[i],
                headerSpacing: 3.0),
          ),
        );
      }
    }

    return Partitions(
      children: [
        // Left Column
        Partition(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: leftColumnItems,
          ),
        ),
        Partition(child: SizedBox(width: 1)),
        // Right Column
        Partition(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rightColumnItems,
          ),
        ),
      ],
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
                    text:
                        (i < descriptions.length && descriptions[i].isNotEmpty)
                            ? "${items[i]}\n${descriptions[i]}"
                            : items[i],
                  ),
                ),
              ]),
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

    final MemoryImage? bulletToUse = bulletDarkImage;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _getHeaderText4Dark(text: projectSection.id),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (bulletToUse != null)
                            Image(bulletToUse, width: 4, height: 4),
                          SizedBox(width: 8),
                          Expanded(child: _getNormalText4(text: d)),
                        ]),
                  ),
              ]
            ],
          ),
        ),
      SizedBox(height: 8),
    ]);
  }
}
