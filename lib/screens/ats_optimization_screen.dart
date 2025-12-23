import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/ai_embedding_service.dart';
import 'package:resume_builder/google_ads/ads.dart';
import 'package:resume_builder/my_singleton.dart';

class ATSOptimizationScreen extends StatefulWidget {
  final String resumeContent;
  final String? jobDescription;

  const ATSOptimizationScreen({
    Key? key,
    required this.resumeContent,
    this.jobDescription,
  }) : super(key: key);

  @override
  State<ATSOptimizationScreen> createState() => _ATSOptimizationScreenState();
}

class _ATSOptimizationScreenState extends State<ATSOptimizationScreen> {
  final AIEmbeddingService _embeddingService = AIEmbeddingService.instance;
  
  final TextEditingController _jobDescriptionController = TextEditingController();
  final TextEditingController _resumeContentController = TextEditingController();
  
  bool _isLoading = false;
  List<String> _optimizationSuggestions = [];
  Map<String, double> _sectionScores = {};
  double _overallScore = 0.0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _resumeContentController.text = widget.resumeContent;
    if (widget.jobDescription != null) {
      _jobDescriptionController.text = widget.jobDescription!;
    }
  }

  @override
  void dispose() {
    _jobDescriptionController.dispose();
    _resumeContentController.dispose();
    super.dispose();
  }

  Future<void> _analyzeResume() async {
    if (_jobDescriptionController.text.isEmpty) {
      _showSnackBar('Please enter a job description to analyze');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _optimizationSuggestions = [];
      _sectionScores = {};
      _overallScore = 0.0;
    });

    //Show an interstitial ad while performing ATS analysis for non-subscribed users
    try {
      if (!(MySingleton.loggedInUser?.subscribed ?? false)) {
        CreateAd().loadResumeBuilderAd();
      }
    } catch (e) {
      // Fail silently - analysis should continue even if ad fails
      print('Ad load failed or skipped: $e');
    }

    try {
      // Get optimization suggestions
      final suggestions = await _embeddingService.getATSOptimizationSuggestions(
        resumeContent: _resumeContentController.text,
        jobDescription: _jobDescriptionController.text,
      );

      // Calculate keyword match score
      final keywords = await _embeddingService.extractKeywords(_jobDescriptionController.text);
      final keywordMatch = await _embeddingService.calculateKeywordMatch(
        resumeContent: _resumeContentController.text,
        keywords: keywords,
      );

      // Calculate overall similarity
      final similarity = await _embeddingService.calculateSimilarity(
        _resumeContentController.text,
        _jobDescriptionController.text,
      );

      setState(() {
        _optimizationSuggestions = suggestions;
        _overallScore = (keywordMatch * 0.6 + similarity * 0.4) * 100;
        _sectionScores = {
          'Keyword Match': keywordMatch * 100,
          'Content Similarity': similarity * 100,
          'ATS Compatibility': (keywordMatch * 0.7 + similarity * 0.3) * 100,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to analyze resume: $e';
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ATS Optimization'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Description Input
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _jobDescriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Paste the job description here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Analyze Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _analyzeResume,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics),
                label: Text(_isLoading ? 'Analyzing...' : 'Analyze Resume'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Results Section
            if (_isLoading)
              const Center(
                child: SpinKitThreeBounce(
                  color: Colors.blue,
                  size: 40,
                ),
              )
            else if (_errorMessage.isNotEmpty)
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
                        _errorMessage,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              )
            else if (_optimizationSuggestions.isNotEmpty) ...[
              // Overall Score
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall ATS Score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  value: _overallScore / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _overallScore >= 70
                                        ? Colors.green
                                        : _overallScore >= 50
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_overallScore.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _overallScore >= 70
                                        ? Colors.green
                                        : _overallScore >= 50
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getScoreMessage(_overallScore),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getScoreDescription(_overallScore),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Section Scores
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detailed Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._sectionScores.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: LinearProgressIndicator(
                                  value: entry.value / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    entry.value >= 70
                                        ? Colors.green
                                        : entry.value >= 50
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${entry.value.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: entry.value >= 70
                                      ? Colors.green
                                      : entry.value >= 50
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Optimization Suggestions
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.amber[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Optimization Suggestions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._optimizationSuggestions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final suggestion = entry.value;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.amber[600],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getScoreMessage(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs Improvement';
  }

  String _getScoreDescription(double score) {
    if (score >= 80) return 'Your resume is well-optimized for ATS systems.';
    if (score >= 70) return 'Your resume is generally ATS-friendly with minor improvements needed.';
    if (score >= 50) return 'Your resume needs several improvements for better ATS compatibility.';
    return 'Your resume requires significant optimization for ATS systems.';
  }
}
