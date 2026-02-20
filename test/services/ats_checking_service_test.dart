import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:resume_builder/services/ats_checking_service.dart';
import 'package:resume_builder/constants/openai_service.dart';
import 'package:resume_builder/services/ai_service_manager.dart';
import 'package:resume_builder/services/ai_embedding_service.dart';

// Generate mocks for OpenAIService, AIServiceManager, and AIEmbeddingService
@GenerateMocks([OpenAIService, AIServiceManager, AIEmbeddingService])
import 'ats_checking_service_test.mocks.dart';

void main() {
  late MockOpenAIService mockOpenAIService;
  late MockAIServiceManager mockAIServiceManager;
  late MockAIEmbeddingService mockAIEmbeddingService;
  late ATSCheckingService atsCheckingService;

  // A dummy file for testing
  final dummyFile = File('test.pdf');

  setUp(() {
    mockOpenAIService = MockOpenAIService();
    mockAIServiceManager = MockAIServiceManager();
    mockAIEmbeddingService = MockAIEmbeddingService();

    // Setup AIServiceManager to return our mock embedding service
    when(mockAIServiceManager.embeddingService)
        .thenReturn(mockAIEmbeddingService);

    // Default mocks behavior
    when(mockOpenAIService.isConfigured).thenReturn(true);

    atsCheckingService = ATSCheckingService(
      openAIService: mockOpenAIService,
      aiServiceManager: mockAIServiceManager,
      fileSizeProvider: (_) async => 1024 * 500, // 500 KB
    );
  });

  group('ATSCheckingService Tests', () {
    const resumeContent =
        'Software Engineer with 5 years of experience in Flutter.';
    const jobDescription = 'Looking for a Flutter expert.';

    test('analyzeResume uses OpenAI service when configured', () async {
      // ARRANGEMENT
      // Mock OpenAI success response
      when(mockOpenAIService.generateText(
        systemPrompt: anyNamed('systemPrompt'),
        userPrompt: anyNamed('userPrompt'),
        model: anyNamed('model'),
        maxTokens: anyNamed('maxTokens'),
        temperature: anyNamed('temperature'),
      )).thenAnswer(
          (_) async => '{ "score": 85, "suggestions": ["Improve summary"] }');

      // ACT
      final result = await atsCheckingService.analyzeResume(
        resumeContent: resumeContent,
        jobDescription: jobDescription,
        resumeFile: dummyFile,
      );

      // ASSERT
      expect(result.score, 85);
      expect(result.suggestions, contains('Improve summary'));
      expect(result.details['analysis_source'], 'AI');

      // Verify generateText was called
      verify(mockOpenAIService.generateText(
        systemPrompt: anyNamed('systemPrompt'),
        userPrompt: anyNamed('userPrompt'),
        model: anyNamed('model'),
        maxTokens: anyNamed('maxTokens'),
        temperature: anyNamed('temperature'),
      )).called(1);
    });

    test('analyzeResume falls back when OpenAI fails', () async {
      // ARRANGEMENT
      // Mock OpenAI failure
      when(mockOpenAIService.generateText(
        systemPrompt: anyNamed('systemPrompt'),
        userPrompt: anyNamed('userPrompt'),
        model: anyNamed('model'),
        maxTokens: anyNamed('maxTokens'),
        temperature: anyNamed('temperature'),
      )).thenThrow(Exception('API Error'));

      // Mock local AI service avaiability
      when(mockAIServiceManager.isAvailable).thenReturn(false);

      // ACT
      final result = await atsCheckingService.analyzeResume(
        resumeContent: resumeContent,
        jobDescription: jobDescription,
        resumeFile: dummyFile,
      );

      // ASSERT
      // Should fallback to basic analysis which calculates score based on keywords/content
      // We expect the score to be calculated by _calculateBasicATSScore
      expect(result.details['analysis_source'], 'Basic (AI Failed)');
      expect(result.details['openai_status'], 'failed');
    });

    test('analyzeResume uses local AI if OpenAI is not configured', () async {
      // ARRANGEMENT
      when(mockOpenAIService.isConfigured).thenReturn(false);
      when(mockAIServiceManager.isAvailable).thenReturn(true);

      // Mock local AI services
      when(mockAIEmbeddingService.extractKeywords(any))
          .thenAnswer((_) async => ['Flutter', 'Expert']);
      when(mockAIEmbeddingService.calculateKeywordMatch(
              resumeContent: anyNamed('resumeContent'),
              keywords: anyNamed('keywords')))
          .thenAnswer((_) async => 0.8);

      when(mockAIEmbeddingService.calculateSimilarity(any, any))
          .thenAnswer((_) async => 0.7);
      when(mockAIEmbeddingService.getATSOptimizationSuggestions(
              resumeContent: anyNamed('resumeContent'),
              jobDescription: anyNamed('jobDescription')))
          .thenAnswer((_) async => ['Add more keywords']);

      // ACT
      final result = await atsCheckingService.analyzeResume(
        resumeContent: resumeContent,
        jobDescription: jobDescription,
        resumeFile: dummyFile,
      );

      // ASSERT
      expect(result.details['openai_status'], 'not_configured');
      expect(result.details.containsKey('keyword_match'), isTrue);
      // It should calculate score based on enhanced algorithm
      expect(result.score, isNotNull);
    });
  });
}
