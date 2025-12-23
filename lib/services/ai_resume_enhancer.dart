import '../services/ai_text_service.dart';
import '../services/ai_embedding_service.dart';

class AIResumeEnhancer {
  static AIResumeEnhancer? _instance;
  static AIResumeEnhancer get instance => _instance ??= AIResumeEnhancer._();
  
  AIResumeEnhancer._();
  
  final AITextService _textService = AITextService.instance;
  final AIEmbeddingService _embeddingService = AIEmbeddingService.instance;
  
  /// Enhance a resume section with AI suggestions
  Future<ResumeEnhancementResult> enhanceResumeSection({
    required String sectionType,
    required String currentContent,
    required Map<String, dynamic> userData,
    String? jobDescription,
  }) async {
    try {
      final suggestions = <String>[];
      final improvements = <String>[];
      
      // Generate AI-powered suggestions based on section type
      switch (sectionType.toLowerCase()) {
        case 'summary':
          final aiSummary = await _textService.generateResumeSummary(
            name: userData['name'] ?? '',
            position: userData['position'] ?? '',
            skills: List<String>.from(userData['skills'] ?? []),
            experiences: List<String>.from(userData['experiences'] ?? []),
          );
          suggestions.add(aiSummary);
          break;
          
        case 'objective':
          final aiObjective = await _textService.generateObjective(
            name: userData['name'] ?? '',
            position: userData['position'] ?? '',
            skills: List<String>.from(userData['skills'] ?? []),
            yearsOfExperience: userData['yearsOfExperience'] ?? 0,
          );
          suggestions.add(aiObjective);
          break;
          
        case 'experience':
          final improvedExperience = await _textService.improveText(
            currentContent,
            context: 'Work experience description',
          );
          suggestions.add(improvedExperience);
          break;
          
        case 'skills':
          if (jobDescription != null && jobDescription.isNotEmpty) {
            final skillSuggestions = await _textService.suggestSkills(
              jobDescription: jobDescription,
              currentSkills: List<String>.from(userData['skills'] ?? []),
            );
            suggestions.addAll(skillSuggestions);
          }
          break;
      }
      
      // Get ATS optimization suggestions if job description is provided
      if (jobDescription != null && jobDescription.isNotEmpty) {
        final atsSuggestions = await _embeddingService.getATSOptimizationSuggestions(
          resumeContent: currentContent,
          jobDescription: jobDescription,
        );
        improvements.addAll(atsSuggestions);
      }
      
      // Generate general improvements
      final generalImprovement = await _textService.improveText(
        currentContent,
        context: sectionType,
      );
      improvements.add(generalImprovement);
      
      return ResumeEnhancementResult(
        suggestions: suggestions,
        improvements: improvements,
        score: await _calculateSectionScore(currentContent, jobDescription),
      );
    } catch (e) {
      throw Exception('Failed to enhance resume section: $e');
    }
  }
  
  /// Generate a complete cover letter
  Future<String> generateCoverLetter({
    required Map<String, dynamic> userData,
    required String companyName,
    required String jobDescription,
  }) async {
    try {
      return await _textService.generateCoverLetter(
        name: userData['name'] ?? '',
        position: userData['position'] ?? '',
        companyName: companyName,
        skills: List<String>.from(userData['skills'] ?? []),
        experiences: List<String>.from(userData['experiences'] ?? []),
      );
    } catch (e) {
      throw Exception('Failed to generate cover letter: $e');
    }
  }
  
  /// Analyze resume completeness
  Future<ResumeAnalysisResult> analyzeResumeCompleteness({
    required Map<String, dynamic> resumeData,
    required String jobDescription,
  }) async {
    try {
      final analysis = ResumeAnalysisResult();
      
      // Check required sections
      final requiredSections = ['name', 'contact', 'summary', 'experience', 'skills'];
      final missingSections = <String>[];
      
      for (final section in requiredSections) {
        if (!resumeData.containsKey(section) || 
            resumeData[section] == null || 
            resumeData[section].toString().isEmpty) {
          missingSections.add(section);
        }
      }
      
      analysis.missingSections = missingSections;
      
      // Calculate ATS score
      final resumeContent = _buildResumeContentString(resumeData);
      analysis.atsScore = await _calculateOverallATSScore(resumeContent, jobDescription);
      
      // Get improvement suggestions
      analysis.suggestions = await _embeddingService.getATSOptimizationSuggestions(
        resumeContent: resumeContent,
        jobDescription: jobDescription,
      );
      
      // Calculate completeness percentage
      final totalSections = requiredSections.length;
      final completedSections = totalSections - missingSections.length;
      analysis.completenessPercentage = (completedSections / totalSections) * 100;
      
      return analysis;
    } catch (e) {
      throw Exception('Failed to analyze resume completeness: $e');
    }
  }
  
  /// Get personalized resume tips
  Future<List<String>> getPersonalizedTips({
    required String sectionType,
    required String currentContent,
    required Map<String, dynamic> userData,
    String? jobDescription,
  }) async {
    try {
      final tips = <String>[];
      
      switch (sectionType.toLowerCase()) {
        case 'summary':
          tips.addAll([
            'Keep your summary concise (2-3 sentences)',
            'Highlight your most relevant skills and achievements',
            'Use quantifiable metrics when possible',
            'Tailor the summary to the specific job you\'re applying for',
          ]);
          break;
          
        case 'experience':
          tips.addAll([
            'Start each bullet point with a strong action verb',
            'Use the STAR method (Situation, Task, Action, Result)',
            'Include quantifiable achievements and metrics',
            'Focus on results and impact, not just responsibilities',
          ]);
          break;
          
        case 'skills':
          tips.addAll([
            'Include both technical and soft skills',
            'List skills in order of relevance to the job',
            'Be specific about your proficiency level',
            'Include skills mentioned in the job description',
          ]);
          break;
          
        case 'education':
          tips.addAll([
            'Include relevant coursework if you\'re a recent graduate',
            'Highlight academic achievements and honors',
            'Include relevant certifications and licenses',
            'List education in reverse chronological order',
          ]);
          break;
      }
      
      // Add job-specific tips if job description is provided
      if (jobDescription != null && jobDescription.isNotEmpty) {
        final keywords = await _embeddingService.extractKeywords(jobDescription);
        if (keywords.isNotEmpty) {
          tips.add('Consider incorporating these keywords: ${keywords.take(3).join(', ')}');
        }
      }
      
      return tips;
    } catch (e) {
      throw Exception('Failed to get personalized tips: $e');
    }
  }
  
  Future<double> _calculateSectionScore(String content, String? jobDescription) async {
    if (jobDescription == null || jobDescription.isEmpty) return 0.0;
    
    try {
      final similarity = await _embeddingService.calculateSimilarity(content, jobDescription);
      return similarity * 100;
    } catch (e) {
      return 0.0;
    }
  }
  
  Future<double> _calculateOverallATSScore(String resumeContent, String jobDescription) async {
    try {
      final keywords = await _embeddingService.extractKeywords(jobDescription);
      final keywordMatch = await _embeddingService.calculateKeywordMatch(
        resumeContent: resumeContent,
        keywords: keywords,
      );
      
      final similarity = await _embeddingService.calculateSimilarity(
        resumeContent,
        jobDescription,
      );
      
      return (keywordMatch * 0.6 + similarity * 0.4) * 100;
    } catch (e) {
      return 0.0;
    }
  }
  
  String _buildResumeContentString(Map<String, dynamic> resumeData) {
    final content = StringBuffer();
    
    for (final entry in resumeData.entries) {
      if (entry.value != null && entry.value.toString().isNotEmpty) {
        content.writeln('${entry.key}: ${entry.value}');
      }
    }
    
    return content.toString();
  }
}

class ResumeEnhancementResult {
  final List<String> suggestions;
  final List<String> improvements;
  final double score;
  
  ResumeEnhancementResult({
    required this.suggestions,
    required this.improvements,
    required this.score,
  });
}

class ResumeAnalysisResult {
  late List<String> missingSections;
  late double atsScore;
  late List<String> suggestions;
  late double completenessPercentage;
  
  ResumeAnalysisResult();
}
