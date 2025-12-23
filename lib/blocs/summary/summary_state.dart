// lib/blocs/summary/summary_state.dart

import 'package:equatable/equatable.dart';

abstract class SummaryState extends Equatable {
  const SummaryState();

  @override
  List<Object?> get props => [];
}

class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {}

class SummaryLoaded extends SummaryState {
  final String summary;
  const SummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class SummaryError extends SummaryState {
  final String message;
  const SummaryError(this.message);

  @override
  List<Object?> get props => [message];
}