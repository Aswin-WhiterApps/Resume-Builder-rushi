import 'onnx_model_manager.dart';
import 'package:resume_builder/constants/openai_service.dart';

class AITextService {
  static AITextService? _instance;
  static AITextService get instance => _instance ??= AITextService._();
  
  AITextService._();
  
  final ONNXModelManager _modelManager = ONNXModelManager.instance;
  final OpenAIService _openAI = OpenAIService.instance;
  
  Future<void> initialize() async {
    if (!_modelManager.isInitialized) {
      await _modelManager.initialize();
    }
  }
  
  /// Generate resume summary based on user input
  Future<String> generateResumeSummary({
    required String name,
    required String position,
    required List<String> skills,
    required List<String> experiences,
  }) async {
    try {
      final prompt = _buildSummaryPrompt(name, position, skills, experiences);
      if (_openAI.isConfigured) {
        return await _openAI.generateText(
          systemPrompt: 'You are an expert resume writer. Write concise, ATS-friendly summaries.',
          userPrompt: prompt,
          maxTokens: 220,
          temperature: 0.6,
        );
      }
      return await _generateText(prompt, maxLength: 150);
    } catch (e) {
      throw Exception('Failed to generate resume summary: $e');
    }
  }
  
  /// Generate cover letter content
  Future<String> generateCoverLetter({
    required String name,
    required String position,
    required String companyName,
    required List<String> skills,
    required List<String> experiences,
  }) async {
    try {
      final prompt = _buildCoverLetterPrompt(name, position, companyName, skills, experiences);
      if (_openAI.isConfigured) {
        return await _openAI.generateText(
          systemPrompt: 'You are an expert resume and cover letter writer. Keep it concise and professional.',
          userPrompt: prompt,
          maxTokens: 450,
          temperature: 0.65,
        );
      }
      return await _generateText(prompt, maxLength: 300);
    } catch (e) {
      throw Exception('Failed to generate cover letter: $e');
    }
  }
  
  /// Generate professional objective statement
  Future<String> generateObjective({
    required String name,
    required String position,
    required List<String> skills,
    required int yearsOfExperience,
  }) async {
    try {
      final prompt = _buildObjectivePrompt(name, position, skills, yearsOfExperience);
      if (_openAI.isConfigured) {
        return await _openAI.generateText(
          systemPrompt: 'You write crisp, strong resume objective statements in 1-2 sentences.',
          userPrompt: prompt,
          maxTokens: 180,
          temperature: 0.6,
        );
      }
      return await _generateText(prompt, maxLength: 100);
    } catch (e) {
      throw Exception('Failed to generate objective: $e');
    }
  }
  
  /// Improve existing text content with comprehensive professional enhancement
  Future<String> improveText(String originalText, {String? context}) async {
    try {
      final prompt = _buildProfessionalImprovementPrompt(originalText, context);
      if (_openAI.isConfigured) {
        return await _openAI.generateText(
          systemPrompt: 'You are an expert resume writer and career coach. Transform resume content to be more professional, impactful, and ATS-friendly. Use strong action verbs, add quantifiable achievements, and ensure clarity while maintaining the original meaning.',
          userPrompt: prompt,
          maxTokens: ((originalText.length * 1.5).clamp(150, 800)).toInt(),
          temperature: 0.4, // Lower temperature for more consistent professional output
        );
      }
      return await _generateText(prompt, maxLength: originalText.length + 100);
    } catch (e) {
      throw Exception('Failed to improve text: $e');
    }
  }
  
  /// Generate skills suggestions based on job description
  Future<List<String>> suggestSkills({
    required String jobDescription,
    required List<String> currentSkills,
  }) async {
    try {
      final prompt = _buildSkillsSuggestionPrompt(jobDescription, currentSkills);
      final response = await _generateText(prompt, maxLength: 200);
      return _parseSkillsFromResponse(response);
    } catch (e) {
      throw Exception('Failed to suggest skills: $e');
    }
  }
  
  Future<String> _generateText(String prompt, {int maxLength = 200}) async {
    // For now, use template-based generation until ONNX models are properly set up
    // This provides immediate functionality while models are being configured
    
    if (prompt.toLowerCase().contains('summary')) {
      return _generateTemplateSummary(prompt);
    } else if (prompt.toLowerCase().contains('cover letter')) {
      return _generateTemplateCoverLetter(prompt);
    } else if (prompt.toLowerCase().contains('objective')) {
      return _generateTemplateObjective(prompt);
    } else {
      return _generateTemplateImprovement(prompt);
    }
  }
  
  String _generateTemplateSummary(String prompt) {
    // Extract information from prompt
    final nameMatch = RegExp(r'Name: ([^\n]+)').firstMatch(prompt);
    final positionMatch = RegExp(r'Position: ([^\n]+)').firstMatch(prompt);
    final skillsMatch = RegExp(r'Skills: ([^\n]+)').firstMatch(prompt);
    
    final name = nameMatch?.group(1)?.trim() ?? 'Professional';
    final position = positionMatch?.group(1)?.trim() ?? 'candidate';
    final skills = skillsMatch?.group(1)?.trim() ?? 'relevant skills';
    
    return 'Experienced $position with a strong background in $skills. $name brings proven expertise and a track record of delivering results in dynamic environments. Passionate about leveraging technical skills to drive innovation and contribute to team success.';
  }
  
  String _generateTemplateCoverLetter(String prompt) {
    final nameMatch = RegExp(r'Name: ([^\n]+)').firstMatch(prompt);
    final positionMatch = RegExp(r'Position: ([^\n]+)').firstMatch(prompt);
    final companyMatch = RegExp(r'Company: ([^\n]+)').firstMatch(prompt);
    
    final name = nameMatch?.group(1)?.trim() ?? 'I';
    final position = positionMatch?.group(1)?.trim() ?? 'this position';
    final company = companyMatch?.group(1)?.trim() ?? 'your organization';
    
    return 'Dear Hiring Manager, I am writing to express my strong interest in the $position at $company. With my background and skills, I am confident that I would be a valuable addition to your team. I look forward to the opportunity to discuss how my experience can contribute to your organization\'s success. Sincerely, $name';
  }
  
  String _generateTemplateObjective(String prompt) {
    final positionMatch = RegExp(r'Position: ([^\n]+)').firstMatch(prompt);
    
    final position = positionMatch?.group(1)?.trim() ?? 'target role';
    
    return 'To secure a $position where I can utilize my skills and experience to contribute to organizational success while advancing my career in a challenging and rewarding environment.';
  }
  
  String _generateTemplateImprovement(String prompt) {
    final originalMatch = RegExp(r'Original: ([^\n]+)').firstMatch(prompt);
    final original = originalMatch?.group(1)?.trim() ?? '';
    
    if (original.isEmpty) {
      return 'Consider using stronger action verbs, adding quantifiable achievements, and tailoring content to highlight relevant skills and experience.';
    }
    
    // Simple improvement suggestions
    return 'Enhanced version: $original. Consider adding specific metrics, using stronger action verbs, and highlighting quantifiable achievements to make your content more impactful.';
  }
  
  String _buildSummaryPrompt(String name, String position, List<String> skills, List<String> experiences) {
    return '''
Generate a professional summary for a resume:
Name: $name
Position: $position
Skills: ${skills.join(', ')}
Experience: ${experiences.join('; ')}

Write a concise, professional summary (2-3 sentences) highlighting key qualifications and career objectives.
''';
  }
  
  String _buildCoverLetterPrompt(String name, String position, String companyName, List<String> skills, List<String> experiences) {
    return '''
Generate a professional cover letter:
Name: $name
Position: $position
Company: $companyName
Skills: ${skills.join(', ')}
Experience: ${experiences.join('; ')}

Write an engaging cover letter paragraph expressing interest in the position and highlighting relevant qualifications.
''';
  }
  
  String _buildObjectivePrompt(String name, String position, List<String> skills, int yearsOfExperience) {
    return '''
Generate a professional objective statement:
Name: $name
Position: $position
Skills: ${skills.join(', ')}
Years of Experience: $yearsOfExperience

Write a clear, focused objective statement (1-2 sentences) that aligns with the target position.
''';
  }
  
  String _buildProfessionalImprovementPrompt(String originalText, String? context) {
    String contextSpecific = '';
    
    switch (context?.toLowerCase()) {
      case 'resume summary':
        contextSpecific = '''
Focus on creating a compelling 2-3 sentence summary that:
- Highlights key qualifications and career achievements
- Uses strong professional language
- Incorporates industry-relevant keywords
- Shows career progression and value proposition
''';
        break;
      case 'professional objective':
        contextSpecific = '''
Focus on creating a clear, impactful objective statement that:
- States career goals and aspirations
- Highlights key strengths and skills
- Aligns with target positions
- Shows enthusiasm and direction
''';
        break;
      case 'work experience description':
        contextSpecific = '''
Focus on enhancing work experience by:
- Using strong action verbs (Managed, Led, Developed, Implemented, etc.)
- Adding quantifiable achievements and metrics
- Highlighting impact and results
- Using bullet-point friendly format
- Incorporating industry-specific terminology
''';
        break;
      case 'education':
        contextSpecific = '''
Focus on presenting education information by:
- Highlighting relevant coursework and achievements
- Including academic honors or distinctions
- Emphasizing relevant projects or research
- Using formal academic language
''';
        break;
      case 'skills':
        contextSpecific = '''
Focus on skills presentation by:
- Categorizing skills appropriately
- Using industry-standard terminology
- Highlighting proficiency levels where relevant
- Including both technical and soft skills
''';
        break;
      default:
        contextSpecific = '''
Focus on making the content more professional by:
- Using clear, concise language
- Incorporating industry-relevant terminology
- Ensuring ATS-friendly formatting
- Maintaining professional tone throughout
- Adding quantifiable achievements where possible
''';
    }
    
    return '''
Transform the following resume content to be more professional and impactful:

Original Text: $originalText
Context: $context

$contextSpecific

Requirements:
1. Maintain the original meaning and core information
2. Use stronger, more professional language
3. Add quantifiable achievements where appropriate (use realistic metrics if none provided)
4. Ensure ATS-friendly keywords and formatting
5. Use active voice and strong action verbs
6. Keep the content concise but comprehensive
7. Follow professional resume writing standards

Enhanced Version:
''';
  }
  
  String _buildImprovementPrompt(String originalText, String? context) {
    return '''
Improve the following text to make it more professional and impactful:
Original: $originalText
Context: ${context ?? 'Resume content'}

Provide an improved version that is more concise, uses action verbs, and follows professional writing standards.
''';
  }
  
  String _buildSkillsSuggestionPrompt(String jobDescription, List<String> currentSkills) {
    return '''
Based on the job description, suggest additional relevant skills:
Job Description: $jobDescription
Current Skills: ${currentSkills.join(', ')}

Suggest 3-5 additional skills that would be relevant for this position. Format as a comma-separated list.
''';
  }
  
  List<String> _parseSkillsFromResponse(String response) {
    final skills = response
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .take(5)
        .toList();
    return skills;
  }
  
}
