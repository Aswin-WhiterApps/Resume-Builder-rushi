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
      // Check if model files exist before trying to load them
      final phi3ModelPath = await _getModelPath(
          'Phi-3-mini-4k-instruct-onnx/phi3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx',
          'Phi-3-mini-4k-instruct.onnx');
      final embeddingModelPath = await _getModelPath(
          'all-MiniLM-L6-v2-onnx/model.onnx', 'all-MiniLM-L6-v2.onnx');

      // Check if files exist and have content
      final phi3File = File(phi3ModelPath);
      final embeddingFile = File(embeddingModelPath);

      if (await phi3File.exists() && await phi3File.length() > 0) {
        final phi3ModelBytes = await phi3File.readAsBytes();
        _phi3Session = OrtSession.fromBuffer(
          phi3ModelBytes,
          OrtSessionOptions(),
        );
        print('✅ Phi-3 model loaded successfully');
      } else {
        print('⚠️ Phi-3 model file not found, using template-based generation');
      }

      if (await embeddingFile.exists() && await embeddingFile.length() > 0) {
        final embeddingModelBytes = await embeddingFile.readAsBytes();
        _embeddingSession = OrtSession.fromBuffer(
          embeddingModelBytes,
          OrtSessionOptions(),
        );
        print('✅ Embedding model loaded successfully');
      } else {
        print(
            '⚠️ Embedding model file not found, using simple similarity calculation');
      }
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
