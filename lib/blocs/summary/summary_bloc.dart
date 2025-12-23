// lib/blocs/summary/summary_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/model/model.dart';
import 'summary_event.dart';
import 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final FireUser fireUser;

  SummaryBloc({required this.fireUser}) : super(SummaryInitial()) {
    on<LoadSummary>(_onLoadSummary);
    on<UpdateSummary>(_onUpdateSummary);
  }

  Future<void> _onLoadSummary(
      LoadSummary event, Emitter<SummaryState> emit) async {
    emit(SummaryLoading());
    try {
      final resume = await fireUser.getResume(userId: event.userId, resumeId: event.resumeId);
      // Use the new model's field name
      final summaryText = resume?.summary?.summery ?? '';
      emit(SummaryLoaded(summaryText));
    } catch (e) {
      emit(SummaryError('Failed to load summary: ${e.toString()}'));
    }
  }


  Future<void> _onUpdateSummary(
      UpdateSummary event, Emitter<SummaryState> emit) async {
    try {
      final model = SummeryModel(summery: event.summary);

      await fireUser.saveSummaryForResume(
        userId: event.userId,
        resumeId: event.resumeId,
        summary: model, // The parameter name is 'summary'
      );
      emit(SummaryLoaded(event.summary));
    } catch (e) {
      emit(SummaryError('Failed to update summary: ${e.toString()}'));
    }
  }
}