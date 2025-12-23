
import 'package:flutter/material.dart';
import 'package:resume_builder/Presentation/resources/color_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:resume_builder/services/ats_checking_service.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AtsResultsScreen extends StatelessWidget {
  final ATSResult atsResult;

  const AtsResultsScreen({Key? key, required this.atsResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ATS Analysis Result'),
        backgroundColor: ColorManager.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score Section
            Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 12.0,
                percent: atsResult.score / 100,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${atsResult.score.toInt()}%",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.primary),
                    ),
                    Text(
                      "Match Score",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                  ],
                ),
                progressColor: _getScoreColor(atsResult.score),
                backgroundColor: Colors.grey[200]!,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
              ),
            ),
            SizedBox(height: 30),

            // Suggestions Section
            Text(
              "Suggestions for Improvement",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.black),
            ),
            SizedBox(height: 10),
            if (atsResult.suggestions.isEmpty)
              Text("No specific suggestions found. Great job!",
                  style: TextStyle(color: Colors.grey))
            else
              ...atsResult.suggestions.map((suggestion) => _buildSuggestionItem(suggestion)),

            SizedBox(height: 30),

            // Keyword Analysis (if available) - checking details map
            if (atsResult.details.containsKey('missing_keywords')) ...[
              Text(
                "Missing Keywords",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.black),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: (atsResult.details['missing_keywords'] as List)
                    .map((keyword) => Chip(
                          label: Text(keyword.toString()),
                          backgroundColor: Colors.red[50],
                          labelStyle: TextStyle(color: Colors.red),
                        ))
                    .toList(),
              ),
              SizedBox(height: 30),
            ],
            
             if (atsResult.details.containsKey('job_match_score')) ...[
               _buildInfoRow("Job Description Match", "${(atsResult.details['job_match_score'] as num).toStringAsFixed(1)}%"),
             ],
             
             _buildInfoRow("Word Count", atsResult.details['word_count']?.toString() ?? "N/A"),
             _buildInfoRow("Professional Tone", atsResult.details['professional_tone']?.toString() ?? "N/A"),


          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSuggestionItem(String suggestion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              suggestion,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
     return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: ColorManager.black)),
        ],
      ),
     );
  }
}