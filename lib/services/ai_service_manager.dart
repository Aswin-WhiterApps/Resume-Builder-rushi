import 'onnx_model_manager.dart';
import 'ai_text_service.dart';
import 'ai_embedding_service.dart';
import 'ai_resume_enhancer.dart';

class AIServiceManager {
  static AIServiceManager? _instance;
  static AIServiceManager get instance => _instance ??= AIServiceManager._();
  
  AIServiceManager._();
  
  final ONNXModelManager _modelManager = ONNXModelManager.instance;
  final AITextService _textService = AITextService.instance;
  final AIEmbeddingService _embeddingService = AIEmbeddingService.instance;
  final AIResumeEnhancer _resumeEnhancer = AIResumeEnhancer.instance;
  
  bool _isInitialized = false;
  String? _initializationError;
  
  /// Initialize all AI services
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize model manager first
      await _modelManager.initialize();
      
      // Initialize text service
      await _textService.initialize();
      
      // Initialize embedding service
      await _embeddingService.initialize();
      
      _isInitialized = true;
      _initializationError = null;
      print('AI services initialized successfully (template-based mode)');
    } catch (e) {
      _initializationError = e.toString();
      print('AI services initialization failed, using template-based features: $e');
      // Don't throw exception, just mark as initialized with template-based features
      _isInitialized = true;
    }
  }
  
  /// Check if AI services are available
  bool get isAvailable => _isInitialized; // Always available with template-based features
  
  /// Get initialization error if any
  String? get initializationError => _initializationError;
  
  /// Get text service
  AITextService get textService => _textService;
  
  /// Get embedding service
  AIEmbeddingService get embeddingService => _embeddingService;
  
  /// Get resume enhancer
  AIResumeEnhancer get resumeEnhancer => _resumeEnhancer;
  
  /// Check if models are loaded
  bool get areModelsLoaded => _modelManager.isInitialized;
  
  /// Dispose all services
  Future<void> dispose() async {
    await _modelManager.dispose();
    _isInitialized = false;
  }
}
