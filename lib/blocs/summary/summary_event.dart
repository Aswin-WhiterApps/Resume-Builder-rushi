// lib/blocs/summary/summary_event.dart

import 'package:equatable/equatable.dart';

abstract class SummaryEvent extends Equatable {
  const SummaryEvent();

  @override
  List<Object?> get props => [];
}

class LoadSummary extends SummaryEvent {
  final String userId;
  final String resumeId;

  const LoadSummary({required this.userId, required this.resumeId});

  @override
  List<Object?> get props => [userId, resumeId];
}

class UpdateSummary extends SummaryEvent {
  final String userId;
  final String resumeId;
  final String summary;

  const UpdateSummary({
    required this.userId,
    required this.resumeId,
    required this.summary,
  });

  @override
  List<Object?> get props => [userId, resumeId, summary];
}