import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:resume_builder/Presentation/resources/color_manager.dart';
import 'package:resume_builder/Presentation/resources/font_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';

class AtsResultsScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const AtsResultsScreen({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int atsScore = result['score'] ?? 0;
    final List<String> keywordsMatched = List<String>.from(result['keywords_matched'] ?? []);
    final List<String> keywordsMissing = List<String>.from(result['missing_keywords'] ?? []);
    final String summary = result['summary'] ?? 'No summary provided';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ATS Results'),
        backgroundColor: ColorManager.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ATS Score with CircularPercentIndicator
            Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 10.0,
                percent: atsScore / 100.0,
                center: Text(
                  '$atsScore%',
                  style: TextStyle(
                    fontSize: FontSize.s24,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.primary,
                  ),
                ),
                progressColor: ColorManager.secondary,
                backgroundColor: ColorManager.grey,
                animation: true,
                animationDuration: 1000,
              ),
            ),
            const SizedBox(height: AppSize.s20),
            Text(
              'ATS Analysis Result',
              style: TextStyle(
                fontSize: FontSize.s20,
                fontWeight: FontWeight.bold,
                color: ColorManager.primary,
              ),
            ),
            SizedBox(height: AppSize.s10),
            Text(
              summary,
              style: TextStyle(
                fontSize: FontSize.s14,
                color: ColorManager.grey,
              ),
            ),
            const SizedBox(height: AppSize.s20),
            Text(
              'Keywords Matched',
              style: TextStyle(
                fontSize: FontSize.s16,
                fontWeight: FontWeight.bold,
                color: ColorManager.primary,
              ),
            ),
            SizedBox(height: AppSize.s10),
            Expanded(
              child: ListView.builder(
                itemCount: keywordsMatched.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: AppMargin.m8),
                    child: ListTile(
                      leading: Icon(
                        Icons.check_circle,
                        color: ColorManager.secondary,
                        size: AppSize.s20,
                      ),
                      title: Text(
                        keywordsMatched[index],
                        style: TextStyle(
                          fontSize: FontSize.s14,
                          color: ColorManager.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSize.s20),
            Text(
              'Keywords Missing',
              style: TextStyle(
                fontSize: FontSize.s16,
                fontWeight: FontWeight.bold,
                color: ColorManager.primary,
              ),
            ),
            SizedBox(height: AppSize.s10),
            Expanded(
              child: ListView.builder(
                itemCount: keywordsMissing.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: AppMargin.m8),
                    child: ListTile(
                      leading: Icon(
                        Icons.cancel,
                        color: ColorManager.error,
                        size: AppSize.s20,
                      ),
                      title: Text(
                        keywordsMissing[index],
                        style: TextStyle(
                          fontSize: FontSize.s14,
                          color: ColorManager.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}