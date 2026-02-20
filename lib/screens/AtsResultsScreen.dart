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
              ...atsResult.suggestions
                  .map((suggestion) => _buildSuggestionItem(suggestion)),

            SizedBox(height: 30),

            // Score Breakdown
            Text(
              "Score Breakdown",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.black),
            ),
            SizedBox(height: 10),
            _buildBreakdownItem("Formatting", atsResult.atsParsingScore ?? 0),
            _buildBreakdownItem(
                "Experience Quality", atsResult.contentQualityScore ?? 0),
            _buildBreakdownItem(
                "Keyword Match", atsResult.keywordAlignmentScore ?? 0),
            _buildBreakdownItem(
                "Skills Relevance", atsResult.impactMetricsScore ?? 0),

            SizedBox(height: 30),

            // Strengths & Weaknesses Section
            if (atsResult.details.containsKey('strengths') &&
                (atsResult.details['strengths'] as List).isNotEmpty) ...[
              const SizedBox(height: 30),
              Text(
                "Key Strengths",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700]),
              ),
              const SizedBox(height: 10),
              ...(atsResult.details['strengths'] as List)
                  .map((s) => _buildBulletItem(s, Colors.green)),
            ],

            if (atsResult.details.containsKey('weaknesses') &&
                (atsResult.details['weaknesses'] as List).isNotEmpty) ...[
              const SizedBox(height: 30),
              Text(
                "Areas for Improvement",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700]),
              ),
              const SizedBox(height: 10),
              ...(atsResult.details['weaknesses'] as List)
                  .map((w) => _buildBulletItem(w, Colors.red)),
            ],

            // Section Analysis
            if (atsResult.details.containsKey('section_analysis')) ...[
              const SizedBox(height: 30),
              Text(
                "Section Analysis",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.black),
              ),
              const SizedBox(height: 10),
              _buildSectionAnalysisTable(atsResult.details['section_analysis']
                  as Map<String, dynamic>),
            ],

            const SizedBox(height: 30),

            // Keyword Analysis
            if (atsResult.details.containsKey('missing_keywords')) ...[
              Text(
                "Missing Keywords",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.black),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: (atsResult.details['missing_keywords'] as List)
                    .map((keyword) => Chip(
                          label: Text(keyword.toString()),
                          backgroundColor: Colors.red[50],
                          labelStyle: const TextStyle(color: Colors.red),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 30),
            ],

            if (atsResult.details.containsKey('job_match_score')) ...[
              _buildInfoRow("Job Description Match",
                  "${(atsResult.details['job_match_score'] as num).toStringAsFixed(1)}%"),
            ],

            _buildInfoRow("Word Count",
                atsResult.details['word_count']?.toString() ?? "N/A"),
            _buildInfoRow("Professional Tone",
                atsResult.details['professional_tone']?.toString() ?? "N/A"),
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

  Widget _buildBulletItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionAnalysisTable(Map<String, dynamic> analysis) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: analysis.entries.map((entry) {
          final isLast = entry.key == analysis.keys.last;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key
                      .split('_')
                      .map((s) => s[0].toUpperCase() + s.substring(1))
                      .join(' '),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                _buildStatusChip(entry.value.toString()),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'strong':
        color = Colors.green[700]!;
        bgColor = Colors.green[50]!;
        break;
      case 'weak':
        color = Colors.orange[700]!;
        bgColor = Colors.orange[50]!;
        break;
      case 'missing':
        color = Colors.red[700]!;
        bgColor = Colors.red[50]!;
        break;
      default:
        color = Colors.grey[700]!;
        bgColor = Colors.grey[50]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text("${score.toInt()}%",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: (score / 100).clamp(0, 1),
            progressColor: _getScoreColor(score),
            backgroundColor: Colors.grey[200]!,
            barRadius: const Radius.circular(4),
            animation: true,
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
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey[700])),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: ColorManager.black)),
        ],
      ),
    );
  }
}
