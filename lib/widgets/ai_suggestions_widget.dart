import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:resume_builder/services/ai_service_manager.dart';
import '../services/ai_text_service.dart';
import '../services/ai_embedding_service.dart';

class AISuggestionsWidget extends StatefulWidget {
  final String currentText;
  final String context;
  final Function(String) onSuggestionSelected;
  final String? jobDescription;

  const AISuggestionsWidget({
    Key? key,
    required this.currentText,
    required this.context,
    required this.onSuggestionSelected,
    this.jobDescription,
  }) : super(key: key);

  @override
  State<AISuggestionsWidget> createState() => _AISuggestionsWidgetState();
}

class _AISuggestionsWidgetState extends State<AISuggestionsWidget> {
  final AITextService _aiTextService = AITextService.instance;
  final AIEmbeddingService _embeddingService = AIEmbeddingService.instance;
  
  bool _isLoading = false;
  bool _isRefreshingAI = false;
  List<String> _suggestions = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _generateSuggestions();
  }
  
  @override
  void dispose() {
    // No timers to cancel here, but ensure no further setState after dispose
    super.dispose();
  }
  Future<void> _generateSuggestions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final suggestions = await _getAISuggestions();
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to generate suggestions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshSummaryWithAI() async {
    if (_isRefreshingAI) return;

    if (!mounted) return;
    setState(() {
      _isRefreshingAI = true;
      _errorMessage = '';
    });

    try {
      final suggestions = await _getAISuggestions();
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Please try again after one minute.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isRefreshingAI = false;
      });
    }
  }

  Future<List<String>> _getAISuggestions() async {
    final suggestions = <String>[];

    if (widget.context.toLowerCase().contains('summary')) {
      // Generate improved summary
      final improvedSummary = await _aiTextService.improveText(
        widget.currentText,
        context: 'Resume summary',
      );
      suggestions.add(improvedSummary);
    } else if (widget.context.toLowerCase().contains('objective')) {
      // Generate improved objective
      final improvedObjective = await _aiTextService.improveText(
        widget.currentText,
        context: 'Professional objective',
      );
      suggestions.add(improvedObjective);
    } else if (widget.context.toLowerCase().contains('experience')) {
      // Generate improved experience description
      final improvedExperience = await _aiTextService.improveText(
        widget.currentText,
        context: 'Work experience description',
      );
      suggestions.add(improvedExperience);
    }

    // Add ATS optimization suggestions if job description is provided
    if (widget.jobDescription != null && widget.jobDescription!.isNotEmpty) {
      try {
        final atsSuggestions = await _embeddingService.getATSOptimizationSuggestions(
          resumeContent: widget.currentText,
          jobDescription: widget.jobDescription!,
        );
        suggestions.addAll(atsSuggestions);
      } catch (e) {
        // Continue without ATS suggestions if they fail
      }
    }

    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'AI Suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              if (AIServiceManager.instance.isAvailable)
            ElevatedButton.icon(
              onPressed: _isRefreshingAI ? null : _refreshSummaryWithAI,
              icon: _isRefreshingAI
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh),
              label: Text(_isRefreshingAI ? 'Refreshing...' : 'Generate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Center(
              child: SpinKitThreeBounce(
                color: Colors.blue,
                size: 30,
              ),
            )
          else if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            )
          else if (_suggestions.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'No suggestions available at the moment.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Suggestion ${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => widget.onSuggestionSelected(suggestion),
                          icon: Icon(Icons.check_circle_outline, color: Colors.green[600]),
                          tooltip: 'Use this suggestion',
                          iconSize: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
