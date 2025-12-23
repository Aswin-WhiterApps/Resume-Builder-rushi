import 'dart:io';
import 'dart:convert';
import 'package:resume_builder/services/ai_service_manager.dart';
import 'package:resume_builder/constants/openai_service.dart';
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
    String? jobDescription,
    required File pdfFile,
    ComprehensiveResumeData? comprehensiveData,
  }) async {
    try {
      print('Starting comprehensive ATS analysis with OpenAI...');
      final results = <String, dynamic>{};

      // Basic ATS checks
      results['file_format'] = 'PDF';
      try {
        results['file_size'] =
            '${(await _fileSizeProvider(pdfFile)) / 1024} KB';
      } catch (e) {
        results['file_size'] = 'Unknown';
      }
      results['page_count'] = '1'; // Assuming single page for now

      // OpenAI API Analysis - Primary Analysis Method
      print('Starting OpenAI API analysis...');
      Map<String, dynamic>? openAIResults;

      if (_openAIService.isConfigured) {
        try {
          // Analyze using OpenAI API
          final openaiResponse = await _performOpenAIAnalysis(
            resumeContent: resumeContent,
            jobDescription: jobDescription,
            comprehensiveData: comprehensiveData,
          );

          openAIResults = openaiResponse;
          results['openai_analysis'] = openAIResults;
          results['openai_status'] = 'success';
          results['analysis_source'] = 'AI';
          print('OpenAI analysis completed');
        } catch (openaiError) {
          print('OpenAI API analysis failed: $openaiError');
          results['openai_status'] = 'failed';
          results['openai_error'] = openaiError.toString();
          // Do NOT fallback silently if the user expects AI.
          // We will still allow basic analysis to fill in gaps, but we mark source as mixed/failed
          results['analysis_source'] = 'Basic (AI Failed)';
        }
      } else {
        print('OpenAI API not configured');
        results['openai_status'] = 'not_configured';
        results['analysis_source'] = 'Basic';
      }

      // Enhanced analysis with comprehensive data if available
      if (comprehensiveData != null) {
        print('Using comprehensive resume data for analysis');
        final comprehensiveResults = await _performComprehensiveAnalysis(
            comprehensiveData, jobDescription);
        results.addAll(comprehensiveResults); // Merge basic/comp results
      } else {
        print('Using text-based analysis (fallback/supplementary)');
        // Only run local AI if OpenAI didn't run
        if (openAIResults == null && _aiServiceManager.isAvailable) {
          final aiResults =
              await _performAIAnalysis(resumeContent, jobDescription);
          results.addAll(aiResults);
        } else {
          final basicResults = await _performBasicAnalysis(resumeContent);
          results.addAll(basicResults);
        }
      }

      // Extract ATS score from OpenAI results if available, otherwise calculate
      double atsScore;
      if (openAIResults != null && openAIResults.containsKey('score')) {
        // Use OpenAI score if available
        final aiScore = openAIResults['score'];
        if (aiScore is num) {
          atsScore = aiScore.toDouble();
          print('Using OpenAI ATS score: ${atsScore.toStringAsFixed(1)}%');
        } else {
          // Calculate score from our algorithm
          atsScore = _calculateEnhancedATSScore(results, comprehensiveData);
        }
      } else {
        // Calculate overall ATS score with enhanced algorithm
        atsScore = _calculateEnhancedATSScore(results, comprehensiveData);
      }

      results['ats_score'] = atsScore;
      results['ats_grade'] = _getATSGrade(atsScore);

      // Merge OpenAI suggestions with our suggestions
      // Generate suggestions
      List<String> allSuggestions = [];

      if (openAIResults != null && openAIResults.containsKey('suggestions')) {
        // Use OpenAI suggestions exclusively if available
        print('Using OpenAI generated suggestions exclusively');
        final aiSuggestions = openAIResults['suggestions'];
        if (aiSuggestions is List) {
          allSuggestions
              .addAll(aiSuggestions.map((s) => s.toString()).toList());
        } else if (aiSuggestions is String) {
          allSuggestions.add(aiSuggestions);
        }
      } else {
        // Fallback to our internal algorithm if OpenAI failed or didn't return suggestions
        print('Using internal algorithm suggestions as fallback');
        allSuggestions =
            _generateEnhancedSuggestions(results, comprehensiveData);
      }

      print('ATS analysis completed. Score: ${atsScore.toStringAsFixed(1)}%');

      return ATSResult(
        score: atsScore,
        grade: _getATSGrade(atsScore),
        details: results,
        suggestions: allSuggestions,
      );
    } catch (e) {
      print('ATS analysis failed: $e');
      throw Exception('ATS analysis failed: $e');
    }
  }

  /// Perform comprehensive analysis using structured resume data
  Future<Map<String, dynamic>> _performComprehensiveAnalysis(
      ComprehensiveResumeData data, String? jobDescription) async {
    final results = <String, dynamic>{};

    print('Analyzing comprehensive resume data...');

    // Personal Information Analysis
    results['has_full_name'] = data.fullName.isNotEmpty;
    results['has_email'] = data.email?.isNotEmpty == true;
    results['has_phone'] = data.phone?.isNotEmpty == true;
    results['has_address'] =
        data.address1?.isNotEmpty == true || data.address2?.isNotEmpty == true;
    results['has_position'] = data.position?.isNotEmpty == true;

    // Contact Information Quality
    final contactScore = _calculateContactScore(data);
    results['contact_score'] = contactScore;

    // Professional Summary Analysis
    results['has_summary'] = data.summary?.isNotEmpty == true;
    if (data.summary?.isNotEmpty == true) {
      results['summary_length'] = data.summary!.length;
      results['summary_word_count'] = data.summary!.split(' ').length;
      results['summary_quality'] = _analyzeSummaryQuality(data.summary!);
    }

    // Work Experience Analysis
    results['work_experience_count'] = data.workExperience.length;
    results['has_work_experience'] = data.workExperience.isNotEmpty;
    if (data.workExperience.isNotEmpty) {
      results['work_experience_quality'] =
          _analyzeWorkExperienceQuality(data.workExperience);
      results['work_experience_score'] =
          _calculateWorkExperienceScore(data.workExperience);
    }

    // Education Analysis
    results['education_count'] = data.education.length;
    results['has_education'] = data.education.isNotEmpty;
    if (data.education.isNotEmpty) {
      results['education_quality'] = _analyzeEducationQuality(data.education);
      results['education_score'] = _calculateEducationScore(data.education);
    }

    // Skills Analysis
    results['skills_count'] = data.skills.length;
    results['has_skills'] = data.skills.isNotEmpty;
    if (data.skills.isNotEmpty) {
      results['skills_quality'] = _analyzeSkillsQuality(data.skills);
      results['skills_score'] = _calculateSkillsScore(data.skills);
    }

    // Additional Sections Analysis
    results['additional_sections_count'] = data.additionalSections.length;
    results['has_additional_sections'] = data.additionalSections.isNotEmpty;

    // Cover Letter Analysis
    results['has_cover_letter'] = data.coverLetter?.isNotEmpty == true;
    if (data.coverLetter?.isNotEmpty == true) {
      results['cover_letter_length'] = data.coverLetter!.length;
      results['cover_letter_quality'] =
          _analyzeCoverLetterQuality(data.coverLetter!);
    }

    // Signature Analysis
    results['has_signature'] = data.signaturePath?.isNotEmpty == true;

    // Overall Completeness
    results['completeness_score'] = _calculateCompletenessScore(data);

    // Job Description Matching (if provided)
    if (jobDescription != null && jobDescription.isNotEmpty) {
      final jobMatchResults =
          await _analyzeJobDescriptionMatch(data, jobDescription);
      results.addAll(jobMatchResults);
    }

    print('Comprehensive analysis completed');
    return results;
  }

  /// Perform AI-powered analysis
  Future<Map<String, dynamic>> _performAIAnalysis(
      String resumeContent, String? jobDescription) async {
    final results = <String, dynamic>{};

    try {
      // Keyword analysis
      if (jobDescription != null && jobDescription.isNotEmpty) {
        final keywords = await _aiServiceManager.embeddingService
            .extractKeywords(jobDescription);
        final keywordMatch =
            await _aiServiceManager.embeddingService.calculateKeywordMatch(
          resumeContent: resumeContent,
          keywords: keywords,
        );
        results['keyword_match'] =
            '${(keywordMatch * 100).toStringAsFixed(1)}%';
        results['missing_keywords'] =
            _findMissingKeywords(resumeContent, keywords);
      }

      // Content similarity
      if (jobDescription != null && jobDescription.isNotEmpty) {
        final similarity =
            await _aiServiceManager.embeddingService.calculateSimilarity(
          resumeContent,
          jobDescription,
        );
        results['content_similarity'] =
            '${(similarity * 100).toStringAsFixed(1)}%';
      }

      // Get AI optimization suggestions
      if (jobDescription != null && jobDescription.isNotEmpty) {
        final suggestions = await _aiServiceManager.embeddingService
            .getATSOptimizationSuggestions(
          resumeContent: resumeContent,
          jobDescription: jobDescription,
        );
        results['ai_suggestions'] = suggestions;
      }

      // Content quality analysis
      final qualityAnalysis = await _analyzeContentQuality(resumeContent);
      results.addAll(qualityAnalysis);
    } catch (e) {
      print('AI analysis failed, using basic analysis: $e');
      return await _performBasicAnalysis(resumeContent);
    }

    return results;
  }

  /// Perform basic analysis without AI
  Future<Map<String, dynamic>> _performBasicAnalysis(
      String resumeContent) async {
    final results = <String, dynamic>{};

    // Basic content analysis
    results['word_count'] = resumeContent.split(' ').length.toString();
    results['character_count'] = resumeContent.length.toString();

    // Check for common ATS issues
    results['has_contact_info'] = _hasContactInfo(resumeContent);
    results['has_skills_section'] = _hasSkillsSection(resumeContent);
    results['has_experience_section'] = _hasExperienceSection(resumeContent);
    results['has_education_section'] = _hasEducationSection(resumeContent);

    // Format analysis
    results['uses_standard_fonts'] = 'Yes'; // Assuming PDF uses standard fonts
    results['has_proper_spacing'] = 'Yes';
    results['avoided_graphics'] = 'Yes';

    // Content quality
    results['action_verbs_count'] = _countActionVerbs(resumeContent);
    results['quantifiable_achievements'] =
        _countQuantifiableAchievements(resumeContent);

    return results;
  }

  /// Analyze content quality
  Future<Map<String, dynamic>> _analyzeContentQuality(
      String resumeContent) async {
    final results = <String, dynamic>{};

    // Word count and readability
    final words = resumeContent.split(' ');
    results['word_count'] = words.length.toString();
    results['average_word_length'] =
        (words.fold(0, (sum, word) => sum + word.length) / words.length)
            .toStringAsFixed(1);

    // Action verbs analysis
    final actionVerbs = _countActionVerbs(resumeContent);
    results['action_verbs_count'] = actionVerbs;
    results['action_verbs_score'] =
        actionVerbs > 5 ? 'Good' : 'Needs Improvement';

    // Quantifiable achievements
    final quantifiableCount = _countQuantifiableAchievements(resumeContent);
    results['quantifiable_achievements'] = quantifiableCount;
    results['achievements_score'] =
        quantifiableCount > 2 ? 'Good' : 'Needs Improvement';

    // Professional language
    results['professional_tone'] = _analyzeProfessionalTone(resumeContent);

    return results;
  }

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

  /// Analyze professional tone
  String _analyzeProfessionalTone(String content) {
    final unprofessionalWords = [
      'awesome',
      'cool',
      'amazing',
      'fantastic',
      'great'
    ];
    final hasUnprofessionalWords =
        unprofessionalWords.any((word) => content.toLowerCase().contains(word));

    if (hasUnprofessionalWords) {
      return 'Needs Improvement';
    }
    return 'Professional';
  }

  /// Calculate enhanced ATS score using comprehensive data
  double _calculateEnhancedATSScore(
      Map<String, dynamic> results, ComprehensiveResumeData? data) {
    if (data != null) {
      return _calculateComprehensiveATSScore(results, data);
    } else {
      return _calculateBasicATSScore(results);
    }
  }

  /// Calculate ATS score using comprehensive resume data
  double _calculateComprehensiveATSScore(
      Map<String, dynamic> results, ComprehensiveResumeData data) {
    double score = 0;
    double maxScore = 100;

    print('📊 Calculating comprehensive ATS score...');

    // Personal Information (15 points)
    if (results['has_full_name'] == true) score += 5;
    if (results['has_email'] == true) score += 5;
    if (results['has_phone'] == true) score += 3;
    if (results['has_position'] == true) score += 2;

    // Contact Information Quality (10 points)
    final contactScore = results['contact_score'] as double? ?? 0;
    score += (contactScore / 100) * 10;

    // Professional Summary (15 points)
    if (results['has_summary'] == true) {
      score += 10; // Base points for having summary
      final summaryQuality = results['summary_quality'] as String? ?? 'Poor';
      switch (summaryQuality) {
        case 'Excellent':
          score += 5;
          break;
        case 'Good':
          score += 3;
          break;
        case 'Fair':
          score += 1;
          break;
      }
    }

    // Work Experience (25 points)
    if (results['has_work_experience'] == true) {
      score += 10; // Base points for having experience
      final workScore = results['work_experience_score'] as double? ?? 0;
      score += (workScore / 100) * 15;
    }

    // Education (10 points)
    if (results['has_education'] == true) {
      score += 5; // Base points for having education
      final educationScore = results['education_score'] as double? ?? 0;
      score += (educationScore / 100) * 5;
    }

    // Skills (10 points)
    if (results['has_skills'] == true) {
      score += 5; // Base points for having skills
      final skillsScore = results['skills_score'] as double? ?? 0;
      score += (skillsScore / 100) * 5;
    }

    // Additional Sections (5 points)
    if (results['has_additional_sections'] == true) {
      score += 3;
    }

    // Cover Letter (5 points)
    if (results['has_cover_letter'] == true) {
      score += 3;
      final coverLetterQuality =
          results['cover_letter_quality'] as String? ?? 'Poor';
      if (coverLetterQuality == 'Good' || coverLetterQuality == 'Excellent') {
        score += 2;
      }
    }

    // Signature (2 points)
    if (results['has_signature'] == true) {
      score += 2;
    }

    // Job Description Matching (3 points)
    if (results.containsKey('job_match_score')) {
      final jobMatchScore = results['job_match_score'] as double? ?? 0;
      score += (jobMatchScore / 100) * 3;
    }

    // Ensure score doesn't exceed 100
    final finalScore = score > maxScore ? maxScore : score;

    print('📈 ATS Score breakdown:');
    print(
        '   - Personal Info: ${results['has_full_name'] == true ? '✓' : '✗'}');
    print('   - Contact: ${contactScore.toStringAsFixed(1)}%');
    print('   - Summary: ${results['has_summary'] == true ? '✓' : '✗'}');
    print(
        '   - Work Experience: ${results['work_experience_score']?.toStringAsFixed(1) ?? '0'}%');
    print(
        '   - Education: ${results['education_score']?.toStringAsFixed(1) ?? '0'}%');
    print(
        '   - Skills: ${results['skills_score']?.toStringAsFixed(1) ?? '0'}%');
    print('   - Final Score: ${finalScore.toStringAsFixed(1)}%');

    return finalScore;
  }

  /// Calculate basic ATS score for text-based analysis
  double _calculateBasicATSScore(Map<String, dynamic> results) {
    double score = 0;
    int factors = 0;

    // File format (20 points)
    if (results['file_format'] == 'PDF') {
      score += 20;
    }
    factors++;

    // Contact info (15 points)
    if (results['has_contact_info'] == true) {
      score += 15;
    }
    factors++;

    // Skills section (15 points)
    if (results['has_skills_section'] == true) {
      score += 15;
    }
    factors++;

    // Experience section (15 points)
    if (results['has_experience_section'] == true) {
      score += 15;
    }
    factors++;

    // Education section (10 points)
    if (results['has_education_section'] == true) {
      score += 10;
    }
    factors++;

    // Action verbs (10 points)
    final actionVerbsCount =
        int.tryParse(results['action_verbs_count']?.toString() ?? '0') ?? 0;
    if (actionVerbsCount >= 5) {
      score += 10;
    } else if (actionVerbsCount >= 3) {
      score += 5;
    }
    factors++;

    // Quantifiable achievements (10 points)
    final achievementsCount =
        int.tryParse(results['quantifiable_achievements']?.toString() ?? '0') ??
            0;
    if (achievementsCount >= 3) {
      score += 10;
    } else if (achievementsCount >= 1) {
      score += 5;
    }
    factors++;

    // Professional tone (5 points)
    if (results['professional_tone'] == 'Professional') {
      score += 5;
    }
    factors++;

    return (score / (factors * 20)) * 100; // Normalize to 0-100
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
      } else {
        final summaryQuality = results['summary_quality'] as String? ?? 'Poor';
        if (summaryQuality == 'Poor' || summaryQuality == 'Fair') {
          suggestions.add(
              'Improve your professional summary with more specific achievements and keywords');
        }
      }

      if (results['has_work_experience'] != true) {
        suggestions.add(
            'Add your work experience to showcase your professional background');
      } else {
        final workScore = results['work_experience_score'] as double? ?? 0;
        if (workScore < 70) {
          suggestions.add(
              'Enhance your work experience descriptions with more quantifiable achievements');
        }
      }

      if (results['has_education'] != true) {
        suggestions.add('Include your educational background');
      }

      if (results['has_skills'] != true) {
        suggestions.add(
            'Add a skills section to highlight your technical and soft skills');
      } else {
        final skillsScore = results['skills_score'] as double? ?? 0;
        if (skillsScore < 70) {
          suggestions.add(
              'Expand your skills section with more relevant technical skills');
        }
      }

      if (results['has_cover_letter'] != true) {
        suggestions.add(
            'Consider adding a cover letter to personalize your application');
      }

      if (results['has_signature'] != true) {
        suggestions.add('Add a digital signature for a professional touch');
      }

      // Job description matching suggestions
      if (results.containsKey('missing_keywords') &&
          (results['missing_keywords'] as List).isNotEmpty) {
        final missingKeywords = results['missing_keywords'] as List<String>;
        suggestions.add(
            'Include these relevant keywords: ${missingKeywords.take(5).join(', ')}');
      }
    } else {
      // Fallback to basic suggestions
      if (results['has_contact_info'] != true) {
        suggestions.add('Add your contact information (email, phone number)');
      }

      if (results['has_skills_section'] != true) {
        suggestions.add('Include a dedicated skills section');
      }

      if (results['has_experience_section'] != true) {
        suggestions.add('Add a work experience section');
      }

      if (results['has_education_section'] != true) {
        suggestions.add('Include your education background');
      }

      final actionVerbsCount =
          int.tryParse(results['action_verbs_count']?.toString() ?? '0') ?? 0;
      if (actionVerbsCount < 5) {
        suggestions.add('Use more action verbs to describe your achievements');
      }

      final achievementsCount = int.tryParse(
              results['quantifiable_achievements']?.toString() ?? '0') ??
          0;
      if (achievementsCount < 2) {
        suggestions
            .add('Add quantifiable achievements with numbers and percentages');
      }

      if (results['professional_tone'] != 'Professional') {
        suggestions
            .add('Use more professional language throughout your resume');
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

  Future<Map<String, dynamic>> _analyzeJobDescriptionMatch(
      ComprehensiveResumeData data, String jobDescription) async {
    final results = <String, dynamic>{};

    try {
      if (AIServiceManager.instance.isAvailable) {
        // Use AI for keyword matching
        final keywords = await AIServiceManager.instance.embeddingService
            .extractKeywords(jobDescription);
        final resumeText = _buildResumeText(data);
        final keywordMatch = await AIServiceManager.instance.embeddingService
            .calculateKeywordMatch(
          resumeContent: resumeText,
          keywords: keywords,
        );
        results['job_match_score'] = keywordMatch * 100;
        results['missing_keywords'] =
            _findMissingKeywords(resumeText, keywords);
      } else {
        // Basic keyword matching
        final jobKeywords = _extractBasicKeywords(jobDescription);
        final resumeText = _buildResumeText(data);
        final matchedKeywords = jobKeywords
            .where((keyword) =>
                resumeText.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
        results['job_match_score'] =
            (matchedKeywords.length / jobKeywords.length) * 100;
        results['missing_keywords'] = jobKeywords
            .where((keyword) =>
                !resumeText.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
      }
    } catch (e) {
      print('Job description matching failed: $e');
      results['job_match_score'] = 0;
      results['missing_keywords'] = <String>[];
    }

    return results;
  }

  String _buildResumeText(ComprehensiveResumeData data) {
    final buffer = StringBuffer();
    buffer.writeln(data.fullName);
    if (data.position?.isNotEmpty == true) buffer.writeln(data.position!);
    if (data.summary?.isNotEmpty == true) buffer.writeln(data.summary!);

    for (final work in data.workExperience) {
      if (work.position?.isNotEmpty == true) buffer.writeln(work.position!);
      if (work.companyName?.isNotEmpty == true)
        buffer.writeln(work.companyName!);
      if (work.description?.isNotEmpty == true)
        buffer.writeln(work.description!);
    }

    for (final edu in data.education) {
      if (edu.degree?.isNotEmpty == true) buffer.writeln(edu.degree!);
      if (edu.institution?.isNotEmpty == true) buffer.writeln(edu.institution!);
    }

    buffer.writeln(data.skills.join(' '));

    return buffer.toString();
  }

  List<String> _extractBasicKeywords(String text) {
    final words = text.toLowerCase().split(' ');
    final commonWords = {
      'the',
      'a',
      'an',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by'
    };
    return words
        .where((word) => word.length > 3 && !commonWords.contains(word))
        .toSet()
        .toList();
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
            'You are an expert ATS (Applicant Tracking System) analyst and resume coach. Analyze resumes for ATS compatibility, keyword matching, content quality, and provide actionable improvement suggestions. Return results in a structured format.',
        userPrompt: analysisPrompt,
        maxTokens: 1000,
        temperature: 0.3,
      );

      return _parseOpenAIResponse(response);
    } catch (e) {
      print('OpenAI analysis error: $e');
      throw Exception('OpenAI analysis failed: $e');
    }
  }

  /// Build comprehensive analysis prompt for OpenAI
  String _buildOpenAIAnalysisPrompt({
    required String resumeContent,
    String? jobDescription,
    ComprehensiveResumeData? comprehensiveData,
  }) {
    String prompt = '''
You are an expert ATS (Applicant Tracking System) analyst and resume coach. Your task is to analyze the provided resume against a target job description (if provided) or for general best practices.

IMPORTANT: You must return the result as a VALID JSON object. Do not include any markdown formatting (like ```json ... ```) outside the JSON object.

RESUME CONTENT:
$resumeContent

''';

    if (jobDescription != null && jobDescription.isNotEmpty) {
      prompt += '''
TARGET JOB DESCRIPTION:
$jobDescription

INSTRUCTION: Compare the resume STRICTLY against this job description.
''';
    } else {
      prompt += '''
INSTRUCTION: Validate the resume against general industry standards for a high-quality professional resume.
''';
    }

    if (comprehensiveData != null) {
      prompt += '''
STRUCTURED DATA EXTRACTION:
- Name: ${comprehensiveData.fullName}
- Position: ${comprehensiveData.position ?? 'Not specified'}
- Email: ${comprehensiveData.email ?? 'Not provided'}
- Work Experience Count: ${comprehensiveData.workExperience.length}
- Education Count: ${comprehensiveData.education.length}

''';
    }

    prompt += '''
REQUIRED OUTPUT FORMAT (JSON):
{
  "score": <number_0_to_100>,
  "keyword_match": "<percentage_string>",
  "missing_keywords": ["<keyword1>", "<keyword2>", ...],
  "suggested_keywords": ["<keyword1>", "<keyword2>", ...],
  "action_verbs_count": <number>,
  "quantifiable_achievements": <number>,
  "professional_tone": "<rating_string>",
  "suggestions": [
     "<specific_actionable_suggestion_1>",
     "<specific_actionable_suggestion_2>",
     ...
  ],
  "summary_feedback": "<brief_summary_of_analysis>"
}

SCORING CRITERIA (Out of 100):
- 90-100: Excellent match/quality. Perfect formatting, strong keywords, quantifiable results.
- 75-89: Good. Minor issues, creates a good impression but could be tighter.
- 60-74: Average. Needs work on formatting, keywords, or impact.
- 0-59: Poor. Significant issues, missing sections, or poor relevance.

Ensure the "suggestions" are specific to the content provided (e.g., "Add 'Project Management' skill", "Quantify your sales achievement in 2022").
''';

    return prompt;
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

      // Normalize specific fields if necessary
      if (parsedData['score'] is String) {
        parsedData['score'] = double.tryParse(parsedData['score']) ?? 0.0;
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
}

class ATSResult {
  final double score;
  final String grade;
  final Map<String, dynamic> details;
  final List<String> suggestions;

  ATSResult({
    required this.score,
    required this.grade,
    required this.details,
    required this.suggestions,
  });
}
