import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:resume_builder/Presentation/resources/color_manager.dart';
import 'package:resume_builder/Presentation/resources/font_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:resume_builder/services/ats_checking_service.dart';
import 'package:resume_builder/screens/AtsCheckingScreen.dart';

class DownloadScreen extends StatelessWidget {
  final File resumePdf;

  const DownloadScreen({Key? key, required this.resumePdf}) : super(key: key);

  // Function to save the PDF to the device's Downloads folder
  Future<void> _saveToDownloads(BuildContext context) async {
    try {
      // getExternalStorageDirectory is only supported on Android.
      // For iOS, we use getApplicationDocumentsDirectory.
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (directory == null) {
        throw Exception("Could not find storage directory");
      }

      final newPath =
          '${directory.path}/Resume_${DateTime.now().toIso8601String().replaceAll(':', '-')}.pdf';
      final newFile = await resumePdf.copy(newPath);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to $newPath')),
      );
      // Optionally open the saved file
      await OpenFile.open(newFile.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }

  // Function to perform ATS checking using the centralized service
  Future<Map<String, dynamic>> _performAtsCheck() async {
    try {
      print('🔍 Starting ATS check...');

      // Use the centralized ATSCheckingService which is connected to OpenAI
      // Note: In a real app, we would extract text from the PDF file here.
      // Since we don't have a PDF extractor handy, we pass a placeholder.
      // Ideally, this screen should be passed the resume data object if possible.
      final atsResult = await ATSCheckingService.instance.analyzeResume(
        resumeContent: 'Resume content placeholder for analysis',
        jobDescription: null,
        pdfFile: resumePdf,
        comprehensiveData: null,
      );

      return {
        'status': 'success',
        'source': 'ats_checking_service',
        'score': atsResult.score,
        'grade': atsResult.grade,
        'details': atsResult.details,
        'suggestions': atsResult.suggestions,
      };
    } catch (e) {
      print('❌ ATS check error: $e');
      throw Exception('Error during ATS check: $e');
    }
  }

  // Function to show ATS results in a dialog with FutureBuilder
  void _showAtsResults(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppPadding.p16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _performAtsCheck(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        fontSize: FontSize.s14,
                        color: ColorManager.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final result = snapshot.data ?? <String, dynamic>{};
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'ATS Results',
                            style: TextStyle(
                              fontSize: FontSize.s18,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.primary,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Show score prominently if available
                      if (result.containsKey('score'))
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'ATS Score: ',
                                style: TextStyle(
                                  fontSize: FontSize.s16,
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.primary,
                                ),
                              ),
                              Text(
                                '${result['score']}',
                                style: TextStyle(
                                  fontSize: FontSize.s20,
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Show analysis details
                      if (result.containsKey('analysis'))
                        ..._buildAnalysisDetails(
                            result['analysis'] as Map<String, dynamic>),
                      // Show suggestions
                      if (result.containsKey('suggestions') &&
                          (result['suggestions'] as List).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Suggestions:',
                          style: TextStyle(
                            fontSize: FontSize.s16,
                            fontWeight: FontWeight.bold,
                            color: ColorManager.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(result['suggestions'] as List)
                            .map((suggestion) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.lightbulb_outline,
                                          size: 16, color: Colors.amber),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          suggestion.toString(),
                                          style: TextStyle(
                                            fontSize: FontSize.s14,
                                            color: ColorManager.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                      ],
                      // Show other result entries
                      ...result.entries
                          .where((e) => ![
                                'score',
                                'analysis',
                                'suggestions',
                                'source',
                                'status'
                              ].contains(e.key))
                          .map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                '${e.key}: ${e.value}',
                                style: TextStyle(
                                  fontSize: FontSize.s14,
                                  color: ColorManager.grey,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Helper method to build analysis details
  List<Widget> _buildAnalysisDetails(Map<String, dynamic> analysis) {
    final widgets = <Widget>[];

    if (analysis.containsKey('score')) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'Score: ${analysis['score']}',
            style: TextStyle(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.bold,
              color: ColorManager.grey,
            ),
          ),
        ),
      );
    }

    if (analysis.containsKey('keywords')) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'Keywords: ${analysis['keywords']}',
            style: TextStyle(
              fontSize: FontSize.s14,
              color: ColorManager.grey,
            ),
          ),
        ),
      );
    }

    if (analysis.containsKey('match')) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'Match: ${analysis['match']}',
            style: TextStyle(
              fontSize: FontSize.s14,
              color: ColorManager.grey,
            ),
          ),
        ),
      );
    }

    if (analysis.containsKey('analysis')) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'Analysis: ${analysis['analysis']}',
            style: TextStyle(
              fontSize: FontSize.s14,
              color: ColorManager.grey,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Resume'),
        backgroundColor: ColorManager.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your resume is ready!',
              style: TextStyle(
                fontSize: FontSize.s20,
                fontWeight: FontWeight.bold,
                color: ColorManager.primary,
              ),
            ),
            const SizedBox(height: AppSize.s20),
            Text(
              'File: ${resumePdf.path.split('/').last}',
              style: TextStyle(
                fontSize: FontSize.s14,
                color: ColorManager.grey,
              ),
            ),
            const SizedBox(height: AppSize.s40),
            ElevatedButton(
              onPressed: () => _saveToDownloads(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p20,
                  vertical: AppPadding.p12,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(
                'Download as Free',
                style: TextStyle(
                  fontSize: FontSize.s16,
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSize.s20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AtsCheckingScreen(initialResumeFile: resumePdf),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.promo1BgColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p20,
                  vertical: AppPadding.p12,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(
                'ATS Checking',
                style: TextStyle(
                  fontSize: FontSize.s16,
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
