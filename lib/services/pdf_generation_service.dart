import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:resume_builder/resume_templates/t10.dart' as rt10;
import 'package:resume_builder/resume_templates/t11.dart' as rt11;
import 'package:resume_builder/resume_templates/t12.dart' as rt12;
import 'package:resume_builder/resume_templates/t13.dart' as rt13;
import 'package:resume_builder/resume_templates/t14.dart' as rt14;
import 'package:resume_builder/resume_templates/t15.dart' as rt15;
import 'package:resume_builder/resume_templates/t16.dart' as rt16;
import 'package:resume_builder/resume_templates/t17.dart' as rt17;
import 'package:resume_builder/resume_templates/t18.dart' as rt18;
import 'package:resume_builder/resume_templates/t19.dart' as rt19;
import 'package:resume_builder/resume_templates/t20.dart' as rt20;
import 'package:resume_builder/resume_templates/t21.dart' as rt21;
import 'package:resume_builder/resume_templates/t8.dart';
import 'package:resume_builder/services/ai_service_manager.dart';
import 'package:resume_builder/resume_templates/t1.dart' as rt1;
import 'package:resume_builder/resume_templates/t2.dart' as rt2;
import 'package:resume_builder/resume_templates/t3.dart' as rt3;
import 'package:resume_builder/resume_templates/t4.dart' as rt4;
import 'package:resume_builder/resume_templates/t5.dart' as rt5;
import 'package:resume_builder/resume_templates/t6.dart' as rt6;
import 'package:resume_builder/resume_templates/t7.dart' as rt7;
import 'package:resume_builder/Presentation/resources/pdf_theme_manager.dart';

class PDFGenerationService {
  static PDFGenerationService? _instance;
  static PDFGenerationService get instance =>
      _instance ??= PDFGenerationService._();

  PDFGenerationService._();

  /// Generate PDF with AI-enhanced content
  Future<File> generateResumePDF({
    required String templateId,
    required Map<String, dynamic> resumeData,
    bool useAIEnhancement = true,
  }) async {
    try {
      print(' Starting PDF generation...');
      print('Template ID: $templateId');
      print('Use AI Enhancement: $useAIEnhancement');
      print('Resume Data Keys: ${resumeData.keys.toList()}');

      // Get AI-enhanced content if enabled
      Map<String, dynamic> enhancedData = resumeData;
      if (useAIEnhancement && AIServiceManager.instance.isAvailable) {
        print(' Applying AI enhancement...');
        enhancedData = await _enhanceResumeWithAI(resumeData);
        print(' AI enhancement completed');
      } else {
        print(' Using standard template generation');
      }

      // Generate PDF based on template
      print(' Generating PDF template...');
      switch (templateId) {
        case '1':
          {
            final resumeTheme = Resume1Theme1();
            await resumeTheme.getModel();
            final clTheme = CL1Theme1();
            await clTheme.getModel();
            final tmpl = rt1.Template1(
              resume1theme: resumeTheme.resume1theme1dec,
              cl1themeModel: clTheme.cl1themeModel,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template1 generation failed');
            return file;
          }
        case '2':
          {
            final resumeTheme = Resume2Theme1();
            await resumeTheme.getModel();
            final clTheme = CL2Theme1();
            await clTheme.getModel();
            final tmpl = rt2.Template2(
              resume2theme: resumeTheme.resume2theme1,
              cl2themeModel: clTheme.cl2themeModel,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template2 generation failed');
            return file;
          }
        case '3':
          {
            final resumeTheme = Resume3Theme1();
            await resumeTheme.getModel();
            final clTheme = CL3Theme1();
            await clTheme.getModel();
            final tmpl = rt3.Template3(
              resume3themeModel: resumeTheme.resume3theme1,
              cl3themeModel: clTheme.cl3themeModel,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template3 generation failed');
            return file;
          }
        case '4':
          {
            final resumeTheme = Resume4Theme1();
            await resumeTheme.getModel();
            final clTheme = CL4Theme1();
            await clTheme.getModel();
            final tmpl = rt4.Template4(
              resume4themeModel: resumeTheme.resume4theme1,
              cl4themeModel: clTheme.cl4themeModel,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template4 generation failed');
            return file;
          }
        case '5':
          {
            final resumeTheme = Resume5Theme1();
            await resumeTheme.getModel();
            final clTheme = CL5Theme1();
            await clTheme.getModel();
            final tmpl = rt5.Template5(
              resume5themeModel: resumeTheme.resume5theme1,
              cl5themeModel: clTheme.cl5themeModel,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template5 generation failed');
            return file;
          }
        case '6':
          {
            final resumeTheme = Resume6Theme1();
            await resumeTheme.getModel();
            final clTheme = CL6Theme1();
            await clTheme.getModel();
            final tmpl = rt6.Template6(
              resume6themeModel: resumeTheme.resume6theme1,
              cl6themeModel: clTheme.cl6themeModel,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template6 generation failed');
            return file;
          }
        case '7':
          {
            try {
              final resumeTheme = Resume7Theme1();
              await resumeTheme.getModel();
              final tmpl = rt7.Template7(
                resume7themeModel: resumeTheme.resume7theme1,
              );
              final file = await tmpl.createPage();
              return file;
            } on ArgumentError catch (e) {
              throw Exception('Template7 validation failed: ${e.message}');
            } on StateError catch (e) {
              throw Exception('Template7 data error: ${e.message}');
            } catch (e) {
              throw Exception('Template7 generation failed: $e');
            }
          }
        case '8':
          {
            print('PDF Service: Starting Template8 (Theme2) generation...');
            final resumeTheme = Resume8Theme2();
            await resumeTheme.getModel();
            print('PDF Service: Theme model loaded');

            final tmpl = Template8(
              resume8themeModel: resumeTheme.resume8theme2,
            );

            print('PDF Service: Calling Template8 createPage...');
            final file = await tmpl.createPage();
            print('PDF Service: Template8 generated successfully');
            return file;
          }
        case '9':
          {
            print('PDF Service: Starting Template9 (Theme2) generation...');
            final resumeTheme = Resume8Theme3();
            await resumeTheme.getModel();
            print('PDF Service: Theme model loaded');

            final tmpl = Template8(
              resume8themeModel: resumeTheme.resume8theme3,
            );

            print('PDF Service: Calling Template8 createPage...');
            final file = await tmpl.createPage();
            print('PDF Service: Template8 generated successfully');
            return file;
          }

        case '10':
          {
            final resumeTheme = Resume10Theme1();
            await resumeTheme.getModel();
            final tmpl = rt10.Template10(
              resume10theme: resumeTheme.resume10theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template10 generation failed');
            return file;
          }

        case '11':
          {
            final resumeTheme = Resume11Theme1();
            await resumeTheme.getModel();
            final tmpl = rt11.Template11(
              resume11theme: resumeTheme.resume11theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template11 generation failed');
            return file;
          }

        case '12':
          {
            final resumeTheme = Resume12Theme1();
            await resumeTheme.getModel();
            final tmpl = rt12.Template12(
              resume12theme: resumeTheme.resume12theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template12 generation failed');
            return file;
          }

        case '13':
          {
            final resumeTheme = Resume13Theme1();
            await resumeTheme.getModel();
            final tmpl = rt13.Template13(
              resume13theme: resumeTheme.resume13theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template13 generation failed');
            return file;
          }

        case '14':
          {
            final resumeTheme = Resume14Theme1();
            await resumeTheme.getModel();
            final tmpl = rt14.Template14(
              resume14theme: resumeTheme.resume14theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template14 generation failed');
            return file;
          }

        case '15':
          {
            final resumeTheme = Resume15Theme1();
            await resumeTheme.getModel();
            final tmpl = rt15.Template15(
              resume15theme: resumeTheme.resume15theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template15 generation failed');
            return file;
          }

        case '16':
          {
            final resumeTheme = Resume16Theme1();
            await resumeTheme.getModel();
            final tmpl = rt16.Template16(
              resume16theme: resumeTheme.resume16theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template16 generation failed');
            return file;
          }

        case '17':
          {
            final resumeTheme = Resume17Theme1();
            await resumeTheme.getModel();
            final tmpl = rt17.Template17(
              resume17theme: resumeTheme.resume17theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template17 generation failed');
            return file;
          }

        case '18':
          {
            final resumeTheme = Resume18Theme1();
            await resumeTheme.getModel();
            final tmpl = rt18.Template18(
              resume18theme: resumeTheme.resume18theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template18 generation failed');
            return file;
          }

        case '19':
          {
            final resumeTheme = Resume19Theme1();
            await resumeTheme.getModel();
            final tmpl = rt19.Template19(
              resume19theme: resumeTheme.resume19theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template19 generation failed');
            return file;
          }

        case '20':
          {
            final resumeTheme = Resume20Theme1();
            await resumeTheme.getModel();
            final tmpl = rt20.Template20(
              resume20theme: resumeTheme.resume20theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template20 generation failed');
            return file;
          }

        case '21':
          {
            final resumeTheme = Resume21Theme1();
            await resumeTheme.getModel();
            final tmpl = rt21.Template21(
              resume21themeModel: resumeTheme.resume21theme1,
            );
            final file = await tmpl.createPage();
            if (file == null) throw Exception('Template21 generation failed');
            return file;
          }

        default:
          break; // fall through to generic builders
      }

      final pdf = pw.Document();
      // Fallback: generic simple builders for unmapped templates
      pdf.addPage(await _generateDefaultTemplate(enhancedData));

      // Save PDF
      print('💾 Saving PDF file...');
      final output = await getApplicationDocumentsDirectory();
      final fileName = 'Resume_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      print('✅ PDF generated successfully: ${file.path}');
      print('📊 File size: ${await file.length()} bytes');

      return file;
    } catch (e) {
      print('❌ PDF generation failed: $e');
      throw Exception('Failed to generate PDF: $e');
    }
  }

  /// Enhance resume data with AI
  Future<Map<String, dynamic>> _enhanceResumeWithAI(
      Map<String, dynamic> resumeData) async {
    try {
      print('🤖 Starting AI enhancement...');
      final enhancedData = Map<String, dynamic>.from(resumeData);

      // Enhance summary if available
      if (resumeData.containsKey('summary') && resumeData['summary'] != null) {
        print('📝 Enhancing summary...');
        final enhancedSummary =
            await AIServiceManager.instance.textService.improveText(
          resumeData['summary'],
          context: 'Resume summary',
        );
        enhancedData['summary'] = enhancedSummary;
        print('✅ Summary enhanced');
      }

      // Enhance objective if available
      if (resumeData.containsKey('objective') &&
          resumeData['objective'] != null) {
        print('🎯 Enhancing objective...');
        final enhancedObjective =
            await AIServiceManager.instance.textService.improveText(
          resumeData['objective'],
          context: 'Professional objective',
        );
        enhancedData['objective'] = enhancedObjective;
        print('✅ Objective enhanced');
      }

      // Enhance work experience descriptions
      if (resumeData.containsKey('workExperience') &&
          resumeData['workExperience'] is List) {
        print('💼 Enhancing work experience...');
        final workList =
            List<Map<String, dynamic>>.from(resumeData['workExperience']);
        for (int i = 0; i < workList.length; i++) {
          if (workList[i].containsKey('description')) {
            final enhancedDescription =
                await AIServiceManager.instance.textService.improveText(
              workList[i]['description'],
              context: 'Work experience description',
            );
            workList[i]['description'] = enhancedDescription;
          }
        }
        enhancedData['workExperience'] = workList;
        print('✅ Work experience enhanced');
      }

      print('🎉 AI enhancement completed successfully');
      return enhancedData;
    } catch (e) {
      print('⚠️ AI enhancement failed, using original data: $e');
      return resumeData;
    }
  }

  /// Generate Template 1 (Professional)
  Future<pw.Page> _generateTemplate1(Map<String, dynamic> data) async {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(data),
            pw.SizedBox(height: 20),

            // Summary Section
            if (data['summary'] != null &&
                data['summary'].toString().isNotEmpty) ...[
              _buildSummary(data['summary']),
              pw.SizedBox(height: 15),
            ],

            // Work Experience
            if (data['workExperience'] != null &&
                (data['workExperience'] as List).isNotEmpty) ...[
              _buildWorkExperience(data['workExperience']),
              pw.SizedBox(height: 15),
            ],

            // Education
            if (data['education'] != null &&
                (data['education'] as List).isNotEmpty) ...[
              _buildEducation(data['education']),
              pw.SizedBox(height: 15),
            ],

            // Skills
            if (data['skills'] != null &&
                (data['skills'] as List).isNotEmpty) ...[
              _buildSkills(data['skills']),
              pw.SizedBox(height: 15),
            ],

            // Additional Sections
            if (data['additionalSections'] != null &&
                (data['additionalSections'] as List).isNotEmpty) ...[
              _buildAdditionalSections(data['additionalSections']),
              pw.SizedBox(height: 15),
            ],

            // Cover Letter
            if (data['coverLetter'] != null &&
                data['coverLetter'].toString().isNotEmpty) ...[
              _buildCoverLetter(data['coverLetter']),
              pw.SizedBox(height: 15),
            ],
          ],
        );
      },
    );
  }

  /// Generate Template 2 (Modern)
  // ignore: unused_element
  Future<pw.Page> _generateTemplate2(Map<String, dynamic> data) async {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        return pw.Row(
          children: [
            // Left sidebar
            pw.Container(
              width: 200,
              color: PdfColors.blueGrey800,
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildSidebarHeader(data),
                  pw.SizedBox(height: 20),
                  if (data['skills'] != null)
                    _buildSidebarSkills(data['skills']),
                  pw.SizedBox(height: 20),
                  if (data['contact'] != null)
                    _buildSidebarContact(data['contact']),
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            // Main content
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (data['summary'] != null) _buildSummary(data['summary']),
                  pw.SizedBox(height: 20),
                  if (data['workExperience'] != null)
                    _buildWorkExperience(data['workExperience']),
                  pw.SizedBox(height: 20),
                  if (data['education'] != null)
                    _buildEducation(data['education']),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Generate Template 3 (Creative)
  // ignore: unused_element
  Future<pw.Page> _generateTemplate3(Map<String, dynamic> data) async {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildCreativeHeader(data),
            pw.SizedBox(height: 30),
            if (data['summary'] != null) _buildSummary(data['summary']),
            pw.SizedBox(height: 20),
            if (data['workExperience'] != null)
              _buildWorkExperience(data['workExperience']),
            pw.SizedBox(height: 20),
            if (data['education'] != null) _buildEducation(data['education']),
            pw.SizedBox(height: 20),
            if (data['skills'] != null) _buildSkills(data['skills']),
          ],
        );
      },
    );
  }

  /// Generate Default Template
  Future<pw.Page> _generateDefaultTemplate(Map<String, dynamic> data) async {
    return _generateTemplate1(data);
  }

  // Helper methods for building PDF sections
  pw.Widget _buildHeader(Map<String, dynamic> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey800,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            data['position'] ?? '',
            style: pw.TextStyle(
              fontSize: 16,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          if (data['email'] != null)
            pw.Text(
              data['email'],
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.white,
              ),
            ),
          if (data['phone'] != null)
            pw.Text(
              data['phone'],
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.white,
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildSidebarHeader(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          data['position'] ?? '',
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.white,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummary(String summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PROFESSIONAL SUMMARY',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          summary,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey800,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildWorkExperience(List<dynamic> workExperience) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'WORK EXPERIENCE',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 8),
        ...workExperience
            .map((work) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        work['title'] ?? '',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.Text(
                        '${work['company'] ?? ''} | ${work['duration'] ?? ''}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        work['description'] ?? '',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  pw.Widget _buildEducation(List<dynamic> education) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'EDUCATION',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 8),
        ...education
            .map((edu) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        edu['degree'] ?? '',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.Text(
                        '${edu['institution'] ?? ''} | ${edu['year'] ?? ''}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  pw.Widget _buildSkills(List<dynamic> skills) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SKILLS',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Wrap(
          children: skills
              .map((skill) => pw.Container(
                    margin: const pw.EdgeInsets.only(right: 8, bottom: 4),
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blueGrey100,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      skill.toString(),
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  pw.Widget _buildSidebarSkills(List<dynamic> skills) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SKILLS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 8),
        ...skills
            .map((skill) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• ${skill.toString()}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  pw.Widget _buildSidebarContact(Map<String, dynamic> contact) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'CONTACT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 8),
        if (contact['email'] != null)
          pw.Text(
            contact['email'],
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.white,
            ),
          ),
        if (contact['phone'] != null)
          pw.Text(
            contact['phone'],
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.white,
            ),
          ),
      ],
    );
  }

  pw.Widget _buildCreativeHeader(Map<String, dynamic> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(30),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.blue600, PdfColors.purple600],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            data['position'] ?? '',
            style: pw.TextStyle(
              fontSize: 18,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              if (data['email'] != null)
                pw.Text(
                  data['email'],
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
              pw.SizedBox(width: 20),
              if (data['phone'] != null)
                pw.Text(
                  data['phone'],
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build additional sections (Languages, Certifications, etc.)
  pw.Widget _buildAdditionalSections(List<dynamic> additionalSections) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ADDITIONAL INFORMATION',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 8),
        ...additionalSections
            .map((section) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        section['title'] ?? '',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      ...(section['items'] as List<dynamic>)
                          .map((item) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 2),
                                child: pw.Text(
                                  '• ${item['title'] ?? ''}${item['description'] != null ? ' - ${item['description']}' : ''}',
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  /// Build cover letter section
  pw.Widget _buildCoverLetter(String coverLetter) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'COVER LETTER',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          coverLetter,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }
}
