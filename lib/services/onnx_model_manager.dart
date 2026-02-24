import 'dart:io';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class ONNXModelManager {
  static ONNXModelManager? _instance;
  static ONNXModelManager get instance => _instance ??= ONNXModelManager._();

  ONNXModelManager._();

  OrtSession? _phi3Session;
  OrtSession? _embeddingSession;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize ONNX Runtime
      OrtEnv.instance.init();

      // Load models
      await _loadModels();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize ONNX models: $e');
    }
  }

  Future<void> _loadModels() async {
    try {
      // Load only embedding model (Phi-3 is too large for mobile)
      final embeddingModelPath = await _getModelPath(
          'all-MiniLM-L6-v2-onnx/model.onnx', 'all-MiniLM-L6-v2.onnx');

      // Check if embedding model exists and has content
      final embeddingFile = File(embeddingModelPath);

      print('🔍 Checking embedding model at: $embeddingModelPath');

      if (await embeddingFile.exists()) {
        final fileSize = await embeddingFile.length();
        print('📁 Embedding file exists, size: ${fileSize} bytes');
        
        if (fileSize > 0) {
          try {
            final embeddingModelBytes = await embeddingFile.readAsBytes();
            _embeddingSession = OrtSession.fromBuffer(
              embeddingModelBytes,
              OrtSessionOptions(),
            );
            print('✅ Embedding model loaded successfully');
          } catch (e) {
            print('❌ Failed to load embedding session: $e');
            print('⚠️ Embedding model file found but session creation failed, using simple similarity calculation');
          }
        } else {
          print('⚠️ Embedding model file is empty, using simple similarity calculation');
        }
      } else {
        print('⚠️ Embedding model file not found at $embeddingModelPath, using simple similarity calculation');
        print('💡 Attempting to copy from assets...');
        
        // Try to force copy from assets
        try {
          final modelData = await rootBundle.load('assets/models/all-MiniLM-L6-v2-onnx/model.onnx');
          await embeddingFile.writeAsBytes(modelData.buffer.asUint8List());
          print('✅ Embedding model copied from assets successfully');
          
          // Retry loading
          if (await embeddingFile.exists() && await embeddingFile.length() > 0) {
            final embeddingModelBytes = await embeddingFile.readAsBytes();
            _embeddingSession = OrtSession.fromBuffer(
              embeddingModelBytes,
              OrtSessionOptions(),
            );
            print('✅ Embedding model loaded successfully after copy');
          }
        } catch (copyError) {
          print('❌ Failed to copy embedding model from assets: $copyError');
        }
      }

      // Note: Phi-3 model is too large for mobile apps (2.7GB)
      // Using OpenAI API for text generation instead
      print('ℹ️ Phi-3 model skipped (too large for mobile). Using OpenAI API for text generation.');

    } catch (e) {
      print('⚠️ Model loading failed, using template-based features: $e');
      // Don't throw exception, just log and continue with template-based features
    }
  }

  Future<String> _getModelPath(String assetPath, String localName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${appDir.path}/models');

    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }

    final modelFile = File('${modelsDir.path}/$localName');

    if (!await modelFile.exists()) {
      // Copy model from assets to documents directory
      final modelData = await rootBundle.load('assets/models/$assetPath');
      await modelFile.writeAsBytes(modelData.buffer.asUint8List());
    }

    return modelFile.path;
  }

  OrtSession? get phi3Session => _phi3Session;
  OrtSession? get embeddingSession => _embeddingSession;

  bool get isInitialized => _isInitialized;

  Future<void> dispose() async {
    _phi3Session?.release();
    _embeddingSession?.release();
    _isInitialized = false;
  }
}
