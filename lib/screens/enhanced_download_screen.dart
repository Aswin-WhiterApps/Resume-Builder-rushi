import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resume_builder/Presentation/resources/color_manager.dart';
import 'package:resume_builder/services/pdf_generation_service.dart';
import 'package:resume_builder/services/ats_checking_service.dart';
import 'package:resume_builder/services/ai_service_manager.dart';
import 'package:resume_builder/services/comprehensive_resume_service.dart';
import 'package:resume_builder/model/comprehensive_resume_model.dart';
import 'package:resume_builder/my_singleton.dart';
import 'package:resume_builder/screens/comprehensive_resume_data_screen.dart';
import 'package:resume_builder/screens/AtsCheckingScreen.dart';
import 'package:resume_builder/google_ads/admob_service.dart';
import 'package:resume_builder/google_ads/adunits.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:resume_builder/Presentation/resources/strings_manager.dart';

class EnhancedDownloadScreen extends StatefulWidget {
  final String templateId;
  final Map<String, dynamic> resumeData;
  final File? existingPdfFile;

  const EnhancedDownloadScreen({
    Key? key,
    required this.templateId,
    required this.resumeData,
    this.existingPdfFile,
  }) : super(key: key);

  @override
  State<EnhancedDownloadScreen> createState() => _EnhancedDownloadScreenState();
}

class _EnhancedDownloadScreenState extends State<EnhancedDownloadScreen> {
  File? _generatedPdfFile;
  bool _isGeneratingAIPdf = false;
  bool _isGeneratingPdf = false;
  ATSResult? _atsResult;
  String? _errorMessage;
  ComprehensiveResumeData? _comprehensiveData;
  bool _isLoadingData = false;
  Map<String, dynamic>? _validationResults;

  @override
  void initState() {
    super.initState();
    _generatedPdfFile = widget.existingPdfFile;
    _loadComprehensiveData();
  }

  /// Load comprehensive resume data from all sections
  Future<void> _loadComprehensiveData() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    try {
      final userId = MySingleton.userId;
      final resumeId = MySingleton.resumeId;

      if (userId == null || resumeId == null) {
        throw Exception('User ID or Resume ID not found');
      }

      print('Loading comprehensive resume data...');
      final comprehensiveData =
          await ComprehensiveResumeService.instance.collectAllResumeData(
        userId: userId,
        resumeId: resumeId,
      );

      // Validate the data
      final validationResults = ComprehensiveResumeService.instance
          .validateResumeData(comprehensiveData);

      if (!mounted) return;
      setState(() {
        _comprehensiveData = comprehensiveData;
        _validationResults = validationResults;
        _isLoadingData = false;
      });

      print('Comprehensive data loaded successfully');
      print('Validation results: ${validationResults['isValid']}');
      print('Completeness score: ${validationResults['completenessScore']}%');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load resume data: $e';
        _isLoadingData = false;
      });
      print('Failed to load comprehensive data: $e');
    }
  }

  Future<void> _generatePDF({bool useAIEnhancement = true}) async {
    if (_comprehensiveData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait for resume data to load'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      if (useAIEnhancement) {
        _isGeneratingAIPdf = true;
      } else {
        _isGeneratingPdf = true;
      }
      _errorMessage = null;
    });

    try {
      final pdfData = ComprehensiveResumeService.instance
          .convertToPDFFormat(_comprehensiveData!);

      print('Generating PDF with comprehensive data...');
      print('Data sections: ${pdfData.keys.toList()}');

      final pdfFile = await PDFGenerationService.instance.generateResumePDF(
        templateId: widget.templateId,
        resumeData: pdfData,
        useAIEnhancement: useAIEnhancement,
      );

      if (!mounted) return;
      setState(() {
        _generatedPdfFile = pdfFile;
        if (useAIEnhancement) {
          _isGeneratingAIPdf = false;
        } else {
          _isGeneratingPdf = false;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to generate PDF: $e';
        if (useAIEnhancement) {
          _isGeneratingAIPdf = false;
        } else {
          _isGeneratingPdf = false;
        }
      });
    }
  }

  Future<void> _viewPDF() async {
    if (_generatedPdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please generate PDF first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show PDF in a dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resume Preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // PDF Content (simplified preview)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PDF Generated Successfully!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'File: ${_generatedPdfFile!.path.split('/').last}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resume Content Preview:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _buildResumeContentText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPDF() async {
    if (_generatedPdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please generate PDF first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      print('Download PDF clicked - Saving PDF...');

      // getExternalStorageDirectory is only supported on Android.
      // For iOS, we use getApplicationDocumentsDirectory.
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (directory == null) {
        throw Exception("Could not find storage directory");
      }

      // On Android, we might want to put it in a Downloads subfolder.
      // On iOS, we save it directly to the app's documents directory.
      String targetPath;
      if (Platform.isAndroid) {
        final downloadsDir = Directory('${directory.path}/Downloads');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        targetPath = downloadsDir.path;
      } else {
        targetPath = directory.path;
      }

      final fileName = 'Resume_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final newPath = '$targetPath/$fileName';
      final newFile = await _generatedPdfFile!.copy(newPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Open the file
      await OpenFile.open(newFile.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _performATSCheck() async {
    if (_generatedPdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please generate PDF first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      print('ATS Check clicked - Triggering Hugging Face API analysis...');

      // Convert resume data to text for analysis (includes Overview section - summary)
      final resumeContent = _buildResumeContentText();
      print('Resume content length: ${resumeContent.length} characters');
      print(
          'Overview section (summary): ${_comprehensiveData?.summary?.length ?? 0} characters');

      // Perform ATS analysis with Hugging Face API integration
      final atsResult = await ATSCheckingService.instance.analyzeResume(
        resumeContent: resumeContent,
        jobDescription: widget.resumeData['jobDescription'],
        resumeFile: _generatedPdfFile!,
        comprehensiveData:
            _comprehensiveData, // Pass comprehensive data for enhanced analysis
      );

      if (!mounted) return;
      setState(() {
        _atsResult = atsResult;
      });

      // Show success message with Hugging Face status
      final hfStatus = atsResult.details['hugging_face_status'] ?? 'unknown';
      final statusMessage = hfStatus == 'success'
          ? 'ATS analysis completed with Hugging Face API! Score: ${atsResult.score.toStringAsFixed(1)}%'
          : 'ATS analysis completed! Score: ${atsResult.score.toStringAsFixed(1)}%';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusMessage),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'ATS check failed: $e';
      });

      print('ATS check error: $e');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ATS analysis failed: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  String _buildResumeContentText() {
    if (_comprehensiveData == null) {
      return 'Loading resume data...';
    }

    final buffer = StringBuffer();

    // Add personal information
    buffer.writeln(_comprehensiveData!.fullName);
    if (_comprehensiveData!.position?.isNotEmpty == true) {
      buffer.writeln(_comprehensiveData!.position!);
    }
    if (_comprehensiveData!.email?.isNotEmpty == true) {
      buffer.writeln(_comprehensiveData!.email!);
    }
    if (_comprehensiveData!.phone?.isNotEmpty == true) {
      buffer.writeln(_comprehensiveData!.phone!);
    }

    buffer.writeln();

    // Add Overview section (Professional Summary) - This is the primary content for analysis
    if (_comprehensiveData!.summary?.isNotEmpty == true) {
      buffer.writeln('PROFESSIONAL SUMMARY');
      buffer.writeln(_comprehensiveData!.summary!);
      buffer.writeln();
    }

    // Add work experience
    if (_comprehensiveData!.workExperience.isNotEmpty) {
      buffer.writeln('WORK EXPERIENCE');
      for (final work in _comprehensiveData!.workExperience) {
        if (work.position?.isNotEmpty == true) buffer.writeln(work.position!);
        if (work.companyName?.isNotEmpty == true)
          buffer.writeln(work.companyName!);
        if (work.startDate?.isNotEmpty == true) {
          final duration = work.isCurrent
              ? '${work.startDate} - Present'
              : '${work.startDate} - ${work.endDate ?? ''}';
          buffer.writeln(duration);
        }
        if (work.description?.isNotEmpty == true)
          buffer.writeln(work.description!);
        if (work.achievements.isNotEmpty) {
          for (final achievement in work.achievements) {
            buffer.writeln('• $achievement');
          }
        }
        buffer.writeln();
      }
    }

    // Add education
    if (_comprehensiveData!.education.isNotEmpty) {
      buffer.writeln('EDUCATION');
      for (final edu in _comprehensiveData!.education) {
        if (edu.degree?.isNotEmpty == true) buffer.writeln(edu.degree!);
        if (edu.institution?.isNotEmpty == true)
          buffer.writeln(edu.institution!);
        if (edu.fieldOfStudy?.isNotEmpty == true)
          buffer.writeln(edu.fieldOfStudy!);
        if (edu.startDate?.isNotEmpty == true) {
          final duration = edu.isCurrent
              ? '${edu.startDate} - Present'
              : '${edu.startDate} - ${edu.endDate ?? ''}';
          buffer.writeln(duration);
        }
        if (edu.gpa != null) buffer.writeln('GPA: ${edu.gpa}');
        if (edu.description?.isNotEmpty == true)
          buffer.writeln(edu.description!);
        buffer.writeln();
      }
    }

    // Add skills
    if (_comprehensiveData!.skills.isNotEmpty) {
      buffer.writeln('SKILLS');
      buffer.writeln(_comprehensiveData!.skills.join(', '));
      buffer.writeln();
    }

    // Add additional sections
    if (_comprehensiveData!.additionalSections.isNotEmpty) {
      for (final section in _comprehensiveData!.additionalSections) {
        if (section.isSelected && section.items.isNotEmpty) {
          buffer.writeln(section.title.toUpperCase());
          for (final item in section.items) {
            if (item.title.isNotEmpty) buffer.writeln(item.title);
            if (item.description?.isNotEmpty == true)
              buffer.writeln(item.description!);
            if (item.date?.isNotEmpty == true) buffer.writeln(item.date!);
            buffer.writeln();
          }
        }
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Download'),
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Resume is Ready!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Template: ${AppStrings.templateNames[widget.templateId] ?? widget.templateId}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (_generatedPdfFile != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'File: ${_generatedPdfFile!.path.split('/').last}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Data Overview Section
            if (_isLoadingData) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      Text('Loading resume data...'),
                    ],
                  ),
                ),
              ),
            ] else if (_comprehensiveData != null) ...[
              _buildDataOverviewCard(),
              const SizedBox(height: 12),
              // View Detailed Data Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComprehensiveResumeDataScreen(
                          resumeData: _comprehensiveData!,
                          validationResults: _validationResults!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Detailed Resume Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // PDF Generation Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate PDF',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // AI Enhancement Toggle
                    if (AIServiceManager.instance.isAvailable)
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.blue[600]),
                          const SizedBox(width: 8),
                          Text(
                            'AI Enhancement Available',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Generate PDF Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isGeneratingAIPdf
                                ? null
                                : () => _generatePDF(useAIEnhancement: true),
                            icon: _isGeneratingAIPdf
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: Text(_isGeneratingAIPdf
                                ? 'Generating...'
                                : 'Generate with AI'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isGeneratingPdf
                                ? null
                                : () => _generatePDF(useAIEnhancement: false),
                            icon: _isGeneratingPdf
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.description),
                            label: Text(_isGeneratingPdf
                                ? 'Generating...'
                                : 'Generate Standard'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Download Section
            if (_generatedPdfFile != null) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // PDF Preview and Actions
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _downloadPDF,
                              icon: const Icon(Icons.download),
                              label: const Text('View PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ATS Checking Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ATS Optimization',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ATS Check Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_generatedPdfFile == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please generate PDF first'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Show loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Loading Ad...'),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            // Load Interstitial Ad
                            AdMobService.loadInterstitialAd(
                              adUnitId: AdUnitId.resumeBuilderInterstitialAd,
                              onAdLoaded: (InterstitialAd ad) {
                                // Ad loaded successfully
                                ad.fullScreenContentCallback =
                                    FullScreenContentCallback(
                                  onAdDismissedFullScreenContent: (ad) {
                                    ad.dispose();
                                    // Navigate after ad is closed
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AtsCheckingScreen(
                                            initialResumeFile:
                                                _generatedPdfFile),
                                      ),
                                    );
                                  },
                                  onAdFailedToShowFullScreenContent:
                                      (ad, error) {
                                    ad.dispose();
                                    // Fallback navigation
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AtsCheckingScreen(
                                            initialResumeFile:
                                                _generatedPdfFile),
                                      ),
                                    );
                                  },
                                );
                                ad.show();
                              },
                              onAdFailedToLoad: (LoadAdError error) {
                                print('Interstitial ad failed to load: $error');
                                // Fallback navigation if ad fails to load
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AtsCheckingScreen(
                                        initialResumeFile: _generatedPdfFile),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.analytics),
                          label: const Text('ATS Checking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ATS Results
            if (_atsResult != null) ...[
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ATS Analysis Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          // Hugging Face API Status Badge
                          if (_atsResult!.details
                              .containsKey('hugging_face_status'))
                            _buildHuggingFaceStatusBadge(
                              _atsResult!.details['hugging_face_status']
                                  as String,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ATS Score
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getScoreColor(_atsResult!.score)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _getScoreColor(_atsResult!.score)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ATS Score',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    '${_atsResult!.score.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: _getScoreColor(_atsResult!.score),
                                    ),
                                  ),
                                  Text(
                                    'Grade: ${_atsResult!.grade}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  // Show Hugging Face analysis source if available
                                  if (_atsResult!
                                          .details['hugging_face_status'] ==
                                      'success') ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.api,
                                            size: 14, color: Colors.blue[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Analyzed with Hugging Face API',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[700],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            CircularProgressIndicator(
                              value: _atsResult!.score / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getScoreColor(_atsResult!.score),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Hugging Face Analysis Details
                      if (_atsResult!.details
                          .containsKey('hugging_face_analysis')) ...[
                        const SizedBox(height: 16),
                        _buildHuggingFaceAnalysisCard(
                          _atsResult!.details['hugging_face_analysis']
                              as Map<String, dynamic>,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Suggestions
                      if (_atsResult!.suggestions.isNotEmpty) ...[
                        Text(
                          'Improvement Suggestions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._atsResult!.suggestions
                            .map((suggestion) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        size: 16,
                                        color: Colors.amber[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          suggestion,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Error Message
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  /// Build Hugging Face status badge
  Widget _buildHuggingFaceStatusBadge(String status) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (status) {
      case 'success':
        badgeColor = Colors.green;
        badgeText = 'HF API';
        badgeIcon = Icons.check_circle;
        break;
      case 'text_fallback_success':
        badgeColor = Colors.blue;
        badgeText = 'HF Text';
        badgeIcon = Icons.text_fields;
        break;
      case 'failed':
        badgeColor = Colors.orange;
        badgeText = 'Fallback';
        badgeIcon = Icons.warning;
        break;
      default:
        badgeColor = Colors.grey;
        badgeText = 'Unknown';
        badgeIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Hugging Face analysis details card
  Widget _buildHuggingFaceAnalysisCard(Map<String, dynamic> hfAnalysis) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, size: 18, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Hugging Face API Analysis',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Display analysis fields
          if (hfAnalysis.containsKey('score'))
            _buildAnalysisRow('Score', hfAnalysis['score'].toString()),
          if (hfAnalysis.containsKey('analysis'))
            _buildAnalysisRow('Analysis', hfAnalysis['analysis'].toString()),
          if (hfAnalysis.containsKey('keywords'))
            _buildAnalysisRow('Keywords', hfAnalysis['keywords'].toString()),
          if (hfAnalysis.containsKey('match'))
            _buildAnalysisRow('Match', hfAnalysis['match'].toString()),
          // Show full response if no specific fields
          if (hfAnalysis.containsKey('full_response'))
            _buildAnalysisRow(
                'Full Response', hfAnalysis['full_response'].toString()),
        ],
      ),
    );
  }

  /// Build analysis row for Hugging Face details
  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.length > 100 ? '${value.substring(0, 100)}...' : value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build data overview card showing resume completeness
  Widget _buildDataOverviewCard() {
    final data = _comprehensiveData!;
    final validation = _validationResults!;
    final completenessScore = validation['completenessScore'] as double;
    final issues = validation['issues'] as List<String>;
    final warnings = validation['warnings'] as List<String>;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: ColorManager.primary),
                const SizedBox(width: 8),
                Text(
                  'Resume Data Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Completeness Score
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getScoreColor(completenessScore).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getScoreColor(completenessScore)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completeness Score',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          '${completenessScore.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(completenessScore),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircularProgressIndicator(
                    value: completenessScore / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(completenessScore),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Data Summary
            _buildDataSummary(data),

            const SizedBox(height: 16),

            // Issues and Warnings
            if (issues.isNotEmpty || warnings.isNotEmpty) ...[
              if (issues.isNotEmpty) ...[
                Text(
                  'Required Information Missing:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                ...issues.map((issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error, size: 16, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              issue,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
              ],
              if (warnings.isNotEmpty) ...[
                Text(
                  'Recommendations:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 8),
                ...warnings.map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning,
                              size: 16, color: Colors.orange[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              warning,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// Build data summary showing what information is available
  Widget _buildDataSummary(ComprehensiveResumeData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Summary:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        _buildSummaryItem('Personal Info', data.fullName.isNotEmpty),
        _buildSummaryItem('Contact Info', data.contactInfo.isNotEmpty),
        _buildSummaryItem(
            'Professional Summary', data.summary?.isNotEmpty == true),
        _buildSummaryItem('Work Experience', data.workExperience.isNotEmpty),
        _buildSummaryItem('Education', data.education.isNotEmpty),
        _buildSummaryItem('Skills', data.skills.isNotEmpty),
        _buildSummaryItem(
            'Additional Sections', data.additionalSections.isNotEmpty),
        _buildSummaryItem('Cover Letter', data.coverLetter?.isNotEmpty == true),
        _buildSummaryItem('Signature', data.signaturePath?.isNotEmpty == true),
      ],
    );
  }

  /// Build individual summary item
  Widget _buildSummaryItem(String label, bool hasData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            hasData ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: hasData ? Colors.green[600] : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: hasData ? Colors.grey[800] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
