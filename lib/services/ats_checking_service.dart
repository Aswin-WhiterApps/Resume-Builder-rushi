import 'dart:io';
import 'dart:convert';
import 'package:resume_builder/services/ai_service_manager.dart';
import 'package:resume_builder/constants/openai_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resume_builder/model/comprehensive_resume_model.dart';

typedef FileSizeProvider = Future<int> Function(File file);

class ATSCheckingService {
  static ATSCheckingService? _instance;

  // Dependencies
  final OpenAIService _openAIService;
  final AIServiceManager _aiServiceManager;
  final FileSizeProvider _fileSizeProvider;

  // Constructor with optional dependencies for testing
  ATSCheckingService({
    OpenAIService? openAIService,
    AIServiceManager? aiServiceManager,
    FileSizeProvider? fileSizeProvider,
  })  : _openAIService = openAIService ?? OpenAIService.instance,
        _aiServiceManager = aiServiceManager ?? AIServiceManager.instance,
        _fileSizeProvider = fileSizeProvider ?? ((f) => f.length());

  static ATSCheckingService get instance => _instance ??= ATSCheckingService();

  /// Perform comprehensive ATS analysis on resume content
  Future<ATSResult> analyzeResume({
    required String resumeContent,
    String? jobProfile,
    String? jobDescription,
    required File resumeFile,
    ComprehensiveResumeData? comprehensiveData,
  }) async {
    try {
      // 1. Check Cache first
      if (jobProfile != null &&
          jobProfile.isNotEmpty &&
          jobDescription != null &&
          jobDescription.isNotEmpty) {
        print('Checking Firebase cache for $jobProfile...');
        final cachedResult = await _fetchFromCache(jobProfile, jobDescription);
        if (cachedResult != null) {
          print('Matching AI suggestions found in Firebase. Reusing.');
          return cachedResult;
        }
        print('No matching Firebase data exists. Proceeding with AI call.');
      }

      print('Starting comprehensive ATS analysis with OpenAI...');
      final results = <String, dynamic>{};

      // Basic ATS checks
      final extension = resumeFile.path.split('.').last.toLowerCase();
      results['file_format'] = extension.toUpperCase();
      try {
        results['file_size'] =
            '${(await _fileSizeProvider(resumeFile)) / 1024} KB';
      } catch (e) {
        results['file_size'] = 'Unknown';
      }
      results['page_count'] = '1'; // Assuming single page for now

      // Analysis Phase: Attempt AI analysis (OpenAI primary, ONNX fallback)
      Map<String, dynamic>? aiResults;

      if (_openAIService.isConfigured) {
        try {
          print('Starting OpenAI API analysis...');
          aiResults = await _performOpenAIAnalysis(
            resumeContent: resumeContent,
            jobDescription: jobDescription,
            comprehensiveData: comprehensiveData,
          );
        } catch (openaiError) {
          print(
              'OpenAI API analysis failed, checking local ONNX: $openaiError');
        }
      }

      if (aiResults == null) {
        print('Using Local ONNX model for ATS analysis...');
        try {
          aiResults = await _performLocalONNXAnalysis(
            resumeContent: resumeContent,
            jobDescription: jobDescription,
            comprehensiveData: comprehensiveData,
          );
        } catch (onnxError) {
          print('Local ONNX analysis failed: $onnxError');
          // If both fail, we will use basic structural checks below
        }
      }

      // Merge AI Results and metadata
      if (aiResults != null) {
        results.addAll(aiResults);
        results['openai_analysis'] =
            aiResults; // Keep for backward compatibility
        results['analysis_source'] = aiResults['analysis_method'] ?? 'AI';
        results['openai_status'] = 'success';
        print('AI analysis (OpenAI/ONNX) completed and merged');
      } else {
        results['analysis_source'] = 'Basic (AI Unavailable)';
        results['openai_status'] = 'unavailable';
      }

      // Populate basic structural info from comprehensiveData if available
      if (comprehensiveData != null) {
        results['has_full_name'] = comprehensiveData.fullName.isNotEmpty;
        results['has_email'] = comprehensiveData.email?.isNotEmpty == true;
        results['has_phone'] = comprehensiveData.phone?.isNotEmpty == true;
        results['work_experience_count'] =
            comprehensiveData.workExperience.length;
        results['has_work_experience'] =
            comprehensiveData.workExperience.isNotEmpty;
        results['education_count'] = comprehensiveData.education.length;
        results['skills_count'] = comprehensiveData.skills.length;
        results['has_summary'] = comprehensiveData.summary?.isNotEmpty == true;
      }

      // Extract ATS score from AI results if available, otherwise calculate basic score
      double atsScore;
      if (aiResults != null && aiResults.containsKey('score')) {
        final aiScore = aiResults['score'];
        atsScore = (aiScore is num) ? aiScore.toDouble() : 0.0;
        print('Using AI-derived ATS score: ${atsScore.toStringAsFixed(1)}%');
      } else {
        // Fallback to basic score if AI failed
        atsScore = _calculateEnhancedATSScore(results, comprehensiveData);
      }

      results['ats_score'] = atsScore;
      results['ats_grade'] = _getATSGrade(atsScore);

      // Suggestions
      List<String> allSuggestions = [];
      if (aiResults != null && aiResults.containsKey('suggestions')) {
        final aiSuggestions = aiResults['suggestions'];
        if (aiSuggestions is List) {
          allSuggestions.addAll(aiSuggestions.map((s) => s.toString()));
        }
      } else {
        allSuggestions =
            _generateEnhancedSuggestions(results, comprehensiveData);
      }

      print('ATS analysis completed. Score: ${atsScore.toStringAsFixed(1)}%');

      final result = ATSResult(
        score: atsScore,
        grade: _getATSGrade(atsScore),
        details: results,
        suggestions: allSuggestions,
        atsParsingScore: aiResults?['ats_parsing_score']?.toDouble(),
        contentQualityScore: aiResults?['content_quality_score']?.toDouble(),
        keywordAlignmentScore:
            aiResults?['keyword_alignment_score']?.toDouble(),
        impactMetricsScore: aiResults?['impact_metrics_score']?.toDouble(),
        professionalStandardsScore:
            aiResults?['professional_standards_score']?.toDouble(),
        competitivePositioningScore:
            aiResults?['competitive_positioning_score']?.toDouble(),
        keywordMatchPercentage:
            aiResults?['keyword_match_percentage']?.toString(),
        semanticSimilarityScore:
            aiResults?['semantic_similarity_score']?.toDouble(),
      );

      // 4. Save to Cache if we had job profiling info
      if (jobProfile != null &&
          jobProfile.isNotEmpty &&
          jobDescription != null &&
          jobDescription.isNotEmpty &&
          aiResults != null) {
        await _saveToCache(jobProfile, jobDescription, result);
      }

      return result;
    } catch (e) {
      print('ATS analysis failed: $e');
      throw Exception('ATS analysis failed: $e');
    }
  }

  // Legacy heuristic analysis methods removed in favor of AI (OpenAI/ONNX)

  /// Find missing keywords
  List<String> _findMissingKeywords(
      String resumeContent, List<String> keywords) {
    final resumeLower = resumeContent.toLowerCase();
    return keywords
        .where((keyword) => !resumeLower.contains(keyword.toLowerCase()))
        .toList();
  }

  /// Check for contact information
  bool _hasContactInfo(String content) {
    final emailRegex =
        RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    final phoneRegex = RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b');
    return emailRegex.hasMatch(content) || phoneRegex.hasMatch(content);
  }

  /// Check for skills section
  bool _hasSkillsSection(String content) {
    final skillsKeywords = [
      'skills',
      'technical skills',
      'competencies',
      'abilities'
    ];
    return skillsKeywords
        .any((keyword) => content.toLowerCase().contains(keyword));
  }

  /// Check for experience section
  bool _hasExperienceSection(String content) {
    final experienceKeywords = [
      'experience',
      'work history',
      'employment',
      'career'
    ];
    return experienceKeywords
        .any((keyword) => content.toLowerCase().contains(keyword));
  }

  /// Check for education section
  bool _hasEducationSection(String content) {
    final educationKeywords = [
      'education',
      'degree',
      'university',
      'college',
      'bachelor',
      'master'
    ];
    return educationKeywords
        .any((keyword) => content.toLowerCase().contains(keyword));
  }

  /// Count action verbs
  int _countActionVerbs(String content) {
    final actionVerbs = [
      'achieved',
      'accomplished',
      'administered',
      'analyzed',
      'built',
      'created',
      'developed',
      'established',
      'generated',
      'implemented',
      'improved',
      'increased',
      'launched',
      'managed',
      'optimized',
      'produced',
      'reduced',
      'streamlined',
      'supervised',
      'transformed',
      'delivered',
      'executed',
      'facilitated',
      'initiated',
      'led',
      'organized',
      'planned',
      'resolved',
      'solved',
      'strengthened'
    ];

    final contentLower = content.toLowerCase();
    return actionVerbs.where((verb) => contentLower.contains(verb)).length;
  }

  /// Count quantifiable achievements
  int _countQuantifiableAchievements(String content) {
    final quantifiablePatterns = [
      RegExp(r'\d+%'), // Percentages
      RegExp(r'\$\d+'), // Dollar amounts
      RegExp(r'\d+\+'), // Numbers with plus
      RegExp(r'\d+\s*(years?|months?)'), // Time periods
      RegExp(r'\d+\s*(people|employees|clients)'), // People counts
    ];

    return quantifiablePatterns.fold(
        0, (count, pattern) => count + pattern.allMatches(content).length);
  }

  // Heuristic tone analysis removed

  /// Calculate enhanced ATS score using comprehensive data
  double _calculateEnhancedATSScore(
      Map<String, dynamic> results, ComprehensiveResumeData? data) {
    // If AI failed, we use a simple completeness-based score as the absolute last resort
    if (data != null) {
      return _calculateCompletenessScore(data);
    }

    // Default low score for text-only without AI
    return 30.0;
  }

  /// Get ATS grade based on score
  String _getATSGrade(double score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B+';
    if (score >= 60) return 'B';
    if (score >= 50) return 'C+';
    if (score >= 40) return 'C';
    return 'D';
  }

  /// Generate enhanced improvement suggestions
  List<String> _generateEnhancedSuggestions(
      Map<String, dynamic> results, ComprehensiveResumeData? data) {
    final suggestions = <String>[];

    if (data != null) {
      // Generate suggestions based on comprehensive data
      if (results['has_full_name'] != true) {
        suggestions.add('Add your full name to the resume');
      }

      if (results['has_email'] != true) {
        suggestions.add('Include your email address for contact');
      }

      if (results['has_phone'] != true) {
        suggestions.add('Add your phone number for better contact options');
      }

      if (results['has_position'] != true) {
        suggestions.add('Include your current position or job title');
      }

      if (results['has_summary'] != true) {
        suggestions.add(
            'Add a professional summary to highlight your key qualifications');
      }

      if (results.containsKey('missing_keywords') &&
          (results['missing_keywords'] as List).isNotEmpty) {
        final missingKeywords = results['missing_keywords'] as List<String>;
        suggestions.add(
            'Include these relevant keywords: ${missingKeywords.take(5).join(', ')}');
      }
    }

    // Add AI suggestions if available
    if (results.containsKey('ai_suggestions') &&
        results['ai_suggestions'] is List) {
      final aiSuggestions = List<String>.from(results['ai_suggestions']);
      suggestions.addAll(aiSuggestions);
    }

    return suggestions;
  }

  // Helper methods for comprehensive analysis

  double _calculateContactScore(ComprehensiveResumeData data) {
    double score = 0;
    if (data.email?.isNotEmpty == true) score += 40;
    if (data.phone?.isNotEmpty == true) score += 30;
    if (data.address1?.isNotEmpty == true || data.address2?.isNotEmpty == true)
      score += 20;
    if (data.personalWebsite?.isNotEmpty == true) score += 10;
    return score;
  }

  String _analyzeSummaryQuality(String summary) {
    final wordCount = summary.split(' ').length;
    if (wordCount < 20) return 'Poor';
    if (wordCount < 50) return 'Fair';
    if (wordCount < 100) return 'Good';
    return 'Excellent';
  }

  String _analyzeWorkExperienceQuality(List<WorkExperience> workExperience) {
    if (workExperience.isEmpty) return 'Poor';

    int qualityScore = 0;
    for (final work in workExperience) {
      if (work.description?.isNotEmpty == true) qualityScore += 1;
      if (work.achievements.isNotEmpty) qualityScore += 1;
      if (work.startDate?.isNotEmpty == true) qualityScore += 1;
    }

    final averageScore = qualityScore / workExperience.length;
    if (averageScore >= 2.5) return 'Excellent';
    if (averageScore >= 2.0) return 'Good';
    if (averageScore >= 1.5) return 'Fair';
    return 'Poor';
  }

  double _calculateWorkExperienceScore(List<WorkExperience> workExperience) {
    if (workExperience.isEmpty) return 0;

    double score = 0;
    for (final work in workExperience) {
      if (work.position?.isNotEmpty == true) score += 20;
      if (work.companyName?.isNotEmpty == true) score += 20;
      if (work.description?.isNotEmpty == true) score += 30;
      if (work.achievements.isNotEmpty) score += 20;
      if (work.startDate?.isNotEmpty == true) score += 10;
    }

    return (score / workExperience.length).clamp(0, 100);
  }

  String _analyzeEducationQuality(List<Education> education) {
    if (education.isEmpty) return 'Poor';

    int qualityScore = 0;
    for (final edu in education) {
      if (edu.institution?.isNotEmpty == true) qualityScore += 1;
      if (edu.degree?.isNotEmpty == true) qualityScore += 1;
      if (edu.startDate?.isNotEmpty == true) qualityScore += 1;
    }

    final averageScore = qualityScore / education.length;
    if (averageScore >= 2.5) return 'Excellent';
    if (averageScore >= 2.0) return 'Good';
    if (averageScore >= 1.5) return 'Fair';
    return 'Poor';
  }

  double _calculateEducationScore(List<Education> education) {
    if (education.isEmpty) return 0;

    double score = 0;
    for (final edu in education) {
      if (edu.institution?.isNotEmpty == true) score += 30;
      if (edu.degree?.isNotEmpty == true) score += 30;
      if (edu.startDate?.isNotEmpty == true) score += 20;
      if (edu.gpa != null) score += 20;
    }

    return (score / education.length).clamp(0, 100);
  }

  String _analyzeSkillsQuality(List<String> skills) {
    if (skills.isEmpty) return 'Poor';
    if (skills.length < 3) return 'Fair';
    if (skills.length < 8) return 'Good';
    return 'Excellent';
  }

  double _calculateSkillsScore(List<String> skills) {
    if (skills.isEmpty) return 0.0;
    return (skills.length * 10.0).clamp(0.0, 100.0);
  }

  String _analyzeCoverLetterQuality(String coverLetter) {
    final wordCount = coverLetter.split(' ').length;
    if (wordCount < 100) return 'Poor';
    if (wordCount < 200) return 'Fair';
    if (wordCount < 400) return 'Good';
    return 'Excellent';
  }

  double _calculateCompletenessScore(ComprehensiveResumeData data) {
    int totalFields = 0;
    int completedFields = 0;

    // Personal Information
    totalFields += 4;
    if (data.firstName?.isNotEmpty == true) completedFields++;
    if (data.lastName?.isNotEmpty == true) completedFields++;
    if (data.email?.isNotEmpty == true) completedFields++;
    if (data.phone?.isNotEmpty == true) completedFields++;

    // Professional Information
    totalFields += 3;
    if (data.summary?.isNotEmpty == true) completedFields++;
    if (data.workExperience.isNotEmpty) completedFields++;
    if (data.education.isNotEmpty) completedFields++;

    // Additional Information
    totalFields += 2;
    if (data.skills.isNotEmpty) completedFields++;
    if (data.additionalSections.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  /// Perform ATS analysis using local ONNX model
  Future<Map<String, dynamic>> _performLocalONNXAnalysis({
    required String resumeContent,
    String? jobDescription,
    ComprehensiveResumeData? comprehensiveData,
  }) async {
    try {
      final analysisPrompt = _buildOpenAIAnalysisPrompt(
        resumeContent: resumeContent,
        jobDescription: jobDescription,
        comprehensiveData: comprehensiveData,
      );

      final response = await _aiServiceManager.textService.generateText(
        systemPrompt:
            'You are a professional ATS resume evaluator. Provide accurate, strict, and highly personalized resume analysis strictly in JSON format. Avoid generic advice and focus on resume-specific weaknesses and measurable achievements.',
        prompt: analysisPrompt,
        maxTokens: 2000,
      );

      return _parseOpenAIResponse(response);
    } catch (e) {
      print('Local ONNX analysis error: $e');
      rethrow;
    }
  }

  /// Perform OpenAI-based ATS analysis
  Future<Map<String, dynamic>> _performOpenAIAnalysis({
    required String resumeContent,
    String? jobDescription,
    ComprehensiveResumeData? comprehensiveData,
  }) async {
    try {
      // Build comprehensive analysis prompt
      String analysisPrompt = _buildOpenAIAnalysisPrompt(
        resumeContent: resumeContent,
        jobDescription: jobDescription,
        comprehensiveData: comprehensiveData,
      );

      final response = await _openAIService.generateText(
        systemPrompt:
            'You are a professional ATS resume evaluator. Provide accurate, strict, and highly personalized resume analysis strictly in JSON format. Avoid generic advice and focus on resume-specific weaknesses and measurable achievements.',
        userPrompt: analysisPrompt,
        maxTokens: 2000,
        temperature: 0.1, // Low temperature for consistent JSON results
      );

      return _parseOpenAIResponse(response);
    } catch (e) {
      print('OpenAI analysis error: $e');
      rethrow;
    }
  }

  /// Build comprehensive analysis prompt for OpenAI
  String _buildOpenAIAnalysisPrompt({
    required String resumeContent,
    String? jobDescription,
    ComprehensiveResumeData? comprehensiveData,
  }) {
    return '''
You are a professional ATS resume evaluator. 

Carefully analyze the resume content provided below and generate personalized, resume-specific improvement suggestions based only on the actual content present in the resume. 

Rules for Analysis:
- Read the entire resume carefully
- Identify all sections
- Detect missing or weak sections
- Extract keywords
- Compare with job description (if provided)
- Provide a realistic ATS score (0–100)
- Give structured JSON output ONLY
- Do not give explanations outside JSON
- Do not hallucinate missing data
- If a section is missing, mark it as "missing"
- If a section is weak, mark it as "weak"
- If strong, mark it as "strong"
- Do not give generic advice. Do not repeat standard suggestions. 
- Identify real weaknesses, missing measurable achievements, unclear descriptions, weak bullet points, missing keywords from the job description, formatting problems, incomplete contact details, lack of impact metrics, skill gaps, or irrelevant content. 
- Every improvement suggestion must clearly reference a specific issue found in the resume and explain exactly what should be improved and how to improve it. 
- If a section is strong, do not suggest improving it unnecessarily. 
- Avoid generic phrases like “add more details” — instead, specify what details are missing (e.g., quantifiable results, technologies, certifications, leadership examples). 
- Generate unique suggestions tailored strictly to this resume only.

Be strict and realistic. Do not inflate scores.
Analyze the following resume for ATS compatibility.

RESUME:
"""
$resumeContent
"""

JOB DESCRIPTION:
"""
${jobDescription ?? "No job description provided."}
"""

Perform a complete ATS evaluation.

Return the result strictly in this JSON format:

{
  "ats_score": number,
  "score_breakdown": {
    "formatting": number,
    "keywords_match": number,
    "skills_relevance": number,
    "experience_quality": number,
    "education_clarity": number,
    "contact_information": number
  },
  "section_analysis": {
    "contact_information": "strong | weak | missing",
    "summary": "strong | weak | missing",
    "skills": "strong | weak | missing",
    "work_experience": "strong | weak | missing",
    "education": "strong | weak | missing",
    "projects": "strong | weak | missing",
    "certifications": "strong | weak | missing"
  },
  "keyword_analysis": {
    "matched_keywords": [],
    "missing_important_keywords": []
  },
  "strengths": [],
  "weaknesses": [],
  "improvement_suggestions": []
}

Rules for JSON:
- JSON MUST BE VALID.
- ATS score must be realistic.
- If resume lacks measurable achievements, reduce experience_quality score.
- If keywords from job description are missing, reduce keywords_match score.
- If contact info is incomplete, reduce score.
- Do NOT add extra text outside JSON.
''';
  }

  /// Parse OpenAI response and extract structured data
  Map<String, dynamic> _parseOpenAIResponse(String response) {
    try {
      String jsonStr = response.trim();

      // Remove potential markdown code block markers
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.replaceFirst('```json', '').trim();
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.replaceFirst('```', '').trim();
      }

      if (jsonStr.endsWith('```')) {
        jsonStr = jsonStr.substring(0, jsonStr.length - 3).trim();
      }

      // Try to find the first '{' and last '}' to isolate JSON
      final startIndex = jsonStr.indexOf('{');
      final endIndex = jsonStr.lastIndexOf('}');
      if (startIndex >= 0 && endIndex > startIndex) {
        jsonStr = jsonStr.substring(startIndex, endIndex + 1);
      }

      // Parse JSON
      final parsedData = Map<String, dynamic>.from(jsonDecode(jsonStr));

      // Handle the new structure's score (ats_score instead of overall_score)
      if (parsedData.containsKey('ats_score')) {
        final score = parsedData['ats_score'];
        parsedData['score'] = (score is num)
            ? score.toDouble()
            : double.tryParse(score.toString()) ?? 0.0;
      } else if (parsedData['score'] is String) {
        parsedData['score'] = double.tryParse(parsedData['score']) ?? 0.0;
      }

      // Map keywords for UI compatibility
      if (parsedData.containsKey('keyword_analysis')) {
        final keywordAnalysis = parsedData['keyword_analysis'];
        if (keywordAnalysis is Map) {
          parsedData['keywords_matched'] = keywordAnalysis['matched_keywords'];
          parsedData['missing_keywords'] =
              keywordAnalysis['missing_important_keywords'];
        }
      }

      // Ensure suggestions are extracted from the new format
      if (parsedData.containsKey('improvement_suggestions')) {
        final improvements = parsedData['improvement_suggestions'];
        if (improvements is List) {
          parsedData['suggestions'] =
              improvements.map((e) => e.toString()).toList();
        }
      }

      // Map breakdown scores for ATSResult compatibility
      if (parsedData.containsKey('score_breakdown')) {
        final breakdown = parsedData['score_breakdown'];
        if (breakdown is Map) {
          parsedData['ats_parsing_score'] =
              (breakdown['formatting'] as num?)?.toDouble();
          parsedData['content_quality_score'] =
              (breakdown['experience_quality'] as num?)?.toDouble();
          parsedData['keyword_alignment_score'] =
              (breakdown['keywords_match'] as num?)?.toDouble();
          parsedData['impact_metrics_score'] =
              (breakdown['skills_relevance'] as num?)
                  ?.toDouble(); // Approximation
        }
      }

      parsedData['raw_response'] = response;
      parsedData['analysis_method'] = 'OpenAI';

      return parsedData;
    } catch (e) {
      print('Error parsing OpenAI response: $e');
      print('Raw response was: $response');

      // Fallback: extract basic information from text response
      return {
        'score': _extractScoreFromText(response),
        'suggestions': _extractSuggestionsFromText(response),
        'raw_response': response,
        'analysis_method': 'OpenAI_parsing_error_fallback',
        'error': e.toString(),
      };
    }
  }

  /// Extract score from text response
  double _extractScoreFromText(String response) {
    final scorePattern = RegExp(r'(\d{1,3})\s*/\s*100|score[:\s]*(\d{1,3})',
        caseSensitive: false);
    final match = scorePattern.firstMatch(response);
    if (match != null) {
      final scoreStr = match.group(1) ?? match.group(2);
      return double.tryParse(scoreStr ?? '50') ?? 50.0;
    }
    return 50.0; // Default fallback score
  }

  /// Extract suggestions from text response
  List<String> _extractSuggestionsFromText(String response) {
    final suggestions = <String>[];
    final lines = response.split('\n');

    bool capturing = false;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.toLowerCase().contains('suggestions') ||
          trimmed.toLowerCase().contains('improvements')) {
        capturing = true;
        continue;
      }

      if (capturing) {
        if (trimmed.isEmpty) continue;
        if (trimmed.startsWith('-') ||
            trimmed.startsWith('*') ||
            RegExp(r'^\d+\.').hasMatch(trimmed)) {
          suggestions.add(trimmed.replaceAll(RegExp(r'^[-*•\d\.]+\s*'), ''));
        }
      }
    }

    if (suggestions.isEmpty) {
      // Just take distinct lines that look like bullet points anywhere
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
          suggestions.add(trimmed.substring(2));
        }
      }
    }

    return suggestions.take(5).toList();
  }

  // Caching methods

  Future<ATSResult?> _fetchFromCache(
      String jobProfile, String jobDescription) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('ai_suggestions_cache')
          .where('jobProfile', isEqualTo: jobProfile.trim().toLowerCase())
          .where('jobDescriptionHash', isEqualTo: _generateHash(jobDescription))
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return ATSResult(
          score: (data['score'] as num).toDouble(),
          grade: data['grade'] as String,
          details: data['details'] as Map<String, dynamic>,
          suggestions: List<String>.from(data['suggestions']),
        );
      }
    } catch (e) {
      print('Error fetching from cache: $e');
    }
    return null;
  }

  Future<void> _saveToCache(
      String jobProfile, String jobDescription, ATSResult result) async {
    try {
      await FirebaseFirestore.instance.collection('ai_suggestions_cache').add({
        'jobProfile': jobProfile.trim().toLowerCase(),
        'jobDescription': jobDescription, // Storing for reference
        'jobDescriptionHash': _generateHash(jobDescription),
        'score': result.score,
        'grade': result.grade,
        'details': result.details,
        'suggestions': result.suggestions,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Saved AI results to Firebase cache.');
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  String _generateHash(String text) {
    // Simple hash for job description normalization
    // In a real app, use crypto package, but here we can use hashCode for simplicity
    // or a more stable string normalization.
    return text.replaceAll(RegExp(r'\s+'), '').toLowerCase();
  }
}

class ATSResult {
  final double score;
  final String grade;
  final Map<String, dynamic> details;
  final List<String> suggestions;

  // New detailed scores
  final double? atsParsingScore;
  final double? contentQualityScore;
  final double? keywordAlignmentScore;
  final double? impactMetricsScore;
  final double? professionalStandardsScore;
  final double? competitivePositioningScore;
  final String? keywordMatchPercentage;
  final double? semanticSimilarityScore;

  ATSResult({
    required this.score,
    required this.grade,
    required this.details,
    required this.suggestions,
    this.atsParsingScore,
    this.contentQualityScore,
    this.keywordAlignmentScore,
    this.impactMetricsScore,
    this.professionalStandardsScore,
    this.competitivePositioningScore,
    this.keywordMatchPercentage,
    this.semanticSimilarityScore,
  });
}
