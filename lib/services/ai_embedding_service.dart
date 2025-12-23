import 'dart:math';
import 'onnx_model_manager.dart';

class AIEmbeddingService {
  static AIEmbeddingService? _instance;
  static AIEmbeddingService get instance => _instance ??= AIEmbeddingService._();
  
  AIEmbeddingService._();
  
  final ONNXModelManager _modelManager = ONNXModelManager.instance;
  
  Future<void> initialize() async {
    if (!_modelManager.isInitialized) {
      await _modelManager.initialize();
    }
  }
  
  /// Generate embeddings for text (simplified implementation)
  Future<List<double>> generateEmbedding(String text) async {
    // For now, return a simple hash-based embedding until ONNX models are properly set up
    // This provides immediate functionality while models are being configured
    return _generateSimpleEmbedding(text);
  }
  
  List<double> _generateSimpleEmbedding(String text) {
    // Create a simple embedding based on text characteristics
    final words = text.toLowerCase().split(' ');
    final embedding = List<double>.filled(384, 0.0); // Standard embedding dimension
    
    for (int i = 0; i < words.length && i < embedding.length; i++) {
      final word = words[i];
      final hash = word.hashCode;
      embedding[i] = (hash % 1000) / 1000.0; // Normalize to 0-1
    }
    
    // Add some text length and complexity features
    embedding[380] = (text.length / 1000.0).clamp(0.0, 1.0);
    embedding[381] = (words.length / 100.0).clamp(0.0, 1.0);
    embedding[382] = text.contains(RegExp(r'\d+')) ? 1.0 : 0.0; // Contains numbers
    embedding[383] = text.contains(RegExp(r'[A-Z]')) ? 1.0 : 0.0; // Contains capitals
    
    return embedding;
  }
  
  /// Calculate similarity between two texts
  Future<double> calculateSimilarity(String text1, String text2) async {
    try {
      final embedding1 = await generateEmbedding(text1);
      final embedding2 = await generateEmbedding(text2);
      
      return _cosineSimilarity(embedding1, embedding2);
    } catch (e) {
      throw Exception('Failed to calculate similarity: $e');
    }
  }
  
  /// Find best matching resume sections for a job description
  Future<Map<String, double>> matchResumeWithJob({
    required Map<String, String> resumeSections,
    required String jobDescription,
  }) async {
    try {
      final jobEmbedding = await generateEmbedding(jobDescription);
      final results = <String, double>{};
      
      for (final entry in resumeSections.entries) {
        final sectionEmbedding = await generateEmbedding(entry.value);
        final similarity = _cosineSimilarity(jobEmbedding, sectionEmbedding);
        results[entry.key] = similarity;
      }
      
      // Sort by similarity score
      final sortedResults = Map.fromEntries(
        results.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value))
      );
      
      return sortedResults;
    } catch (e) {
      throw Exception('Failed to match resume with job: $e');
    }
  }
  
  /// Optimize resume content for ATS
  Future<List<String>> getATSOptimizationSuggestions({
    required String resumeContent,
    required String jobDescription,
  }) async {
    try {
      final suggestions = <String>[];
      
      // Analyze keyword coverage
      final keywordSuggestions = await _analyzeKeywords(resumeContent, jobDescription);
      suggestions.addAll(keywordSuggestions);
      
      // Analyze skill relevance
      final skillSuggestions = await _analyzeSkills(resumeContent, jobDescription);
      suggestions.addAll(skillSuggestions);
      
      // Analyze experience relevance
      final experienceSuggestions = await _analyzeExperience(resumeContent, jobDescription);
      suggestions.addAll(experienceSuggestions);
      
      return suggestions;
    } catch (e) {
      throw Exception('Failed to get ATS optimization suggestions: $e');
    }
  }
  
  /// Extract keywords from job description
  Future<List<String>> extractKeywords(String jobDescription) async {
    try {
      // Simple keyword extraction - in a real implementation, you might use NLP techniques
      final words = jobDescription
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), ' ')
          .split(' ')
          .where((word) => word.length > 3)
          .toSet()
          .toList();
      
    // Filter common words
    final commonWords = {'the', 'and', 'for', 'are', 'with', 'this', 'that', 'will', 'have', 'been', 'from', 'they', 'know', 'want', 'good', 'much', 'some', 'time', 'very', 'when', 'come', 'here', 'just', 'like', 'long', 'make', 'many', 'over', 'such', 'take', 'than', 'them', 'well', 'were'};
      
      return words.where((word) => !commonWords.contains(word)).toList();
    } catch (e) {
      throw Exception('Failed to extract keywords: $e');
    }
  }
  
  /// Check if resume contains specific keywords
  Future<double> calculateKeywordMatch({
    required String resumeContent,
    required List<String> keywords,
  }) async {
    try {
      final resumeLower = resumeContent.toLowerCase();
      final matchedKeywords = keywords.where((keyword) => 
          resumeLower.contains(keyword.toLowerCase())).length;
      
      return matchedKeywords / keywords.length;
    } catch (e) {
      throw Exception('Failed to calculate keyword match: $e');
    }
  }
  
  Future<List<String>> _analyzeKeywords(String resumeContent, String jobDescription) async {
    final suggestions = <String>[];
    final keywords = await extractKeywords(jobDescription);
    final keywordMatch = await calculateKeywordMatch(
      resumeContent: resumeContent,
      keywords: keywords,
    );
    
    if (keywordMatch < 0.7) {
      final missingKeywords = keywords.where((keyword) => 
          !resumeContent.toLowerCase().contains(keyword.toLowerCase())).toList();
      
      if (missingKeywords.isNotEmpty) {
        suggestions.add('Consider adding these keywords: ${missingKeywords.take(5).join(', ')}');
      }
    }
    
    return suggestions;
  }
  
  Future<List<String>> _analyzeSkills(String resumeContent, String jobDescription) async {
    final suggestions = <String>[];
    
    // Extract skills from job description (simplified)
    final skillKeywords = ['python', 'java', 'javascript', 'react', 'angular', 'sql', 'aws', 'azure', 'docker', 'kubernetes'];
    final jobSkills = skillKeywords.where((skill) => 
        jobDescription.toLowerCase().contains(skill)).toList();
    
    final resumeSkills = skillKeywords.where((skill) => 
        resumeContent.toLowerCase().contains(skill)).toList();
    
    final missingSkills = jobSkills.where((skill) => !resumeSkills.contains(skill)).toList();
    
    if (missingSkills.isNotEmpty) {
      suggestions.add('Consider highlighting these skills: ${missingSkills.join(', ')}');
    }
    
    return suggestions;
  }
  
  Future<List<String>> _analyzeExperience(String resumeContent, String jobDescription) async {
    final suggestions = <String>[];
    
    // Check for quantifiable achievements
    if (!RegExp(r'\d+%|\$\d+|\d+\+').hasMatch(resumeContent)) {
      suggestions.add('Add quantifiable achievements (percentages, dollar amounts, numbers)');
    }
    
    // Check for action verbs
    final actionVerbs = ['achieved', 'implemented', 'developed', 'managed', 'led', 'created', 'improved', 'increased', 'reduced', 'optimized'];
    final hasActionVerbs = actionVerbs.any((verb) => resumeContent.toLowerCase().contains(verb));
    
    if (!hasActionVerbs) {
      suggestions.add('Use strong action verbs to describe your accomplishments');
    }
    
    return suggestions;
  }
  
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw Exception('Vectors must have the same length');
    }
    
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    if (normA == 0.0 || normB == 0.0) {
      return 0.0;
    }
    
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}
