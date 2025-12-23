import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/my_singleton.dart';

import 'additional_event.dart';
import 'additional_state.dart';


class AdditionalBloc extends Bloc<AdditionalEvent, AdditionalState> {
  final FireUser _fireUser = FireUser();

  AdditionalBloc() : super(AdditionalInitial()) {
    on<LoadAdditionalSections>(_onLoadAdditionalSections);
    on<AddCustomSection>(_onAddCustomSection);
    on<UpdateSectionDetails>(_onUpdateSectionDetails);
    on<DeleteCustomSection>(_onDeleteCustomSection);
  }

  Future<void> _onLoadAdditionalSections(
      LoadAdditionalSections event, Emitter<AdditionalState> emit) async {
    emit(AdditionalLoading());
    try {
      // The logic to initialize default sections is still necessary and correct.
      var sections = await _fireUser.getAllSections(userId: event.userId, resumeId: event.resumeId);
      if (sections.isEmpty) {
        await _fireUser.initializeDefaultSections(userId: event.userId, resumeId: event.resumeId);
        sections = await _fireUser.getAllSections(userId: event.userId, resumeId: event.resumeId);
      }
      emit(AdditionalLoaded(sections));
    } catch (e) {
      emit(AdditionalError("Failed to load sections: ${e.toString()}"));
    }
  }

  Future<void> _onAddCustomSection(
      AddCustomSection event, Emitter<AdditionalState> emit) async {
    if (state is! AdditionalLoaded) return;
    final currentState = state as AdditionalLoaded;
    final userId = MySingleton.userId!;
    final resumeId = MySingleton.resumeId!;

    try {
      final newSection = SectionModel(id: event.sectionName, value: '', description: '');
      await _fireUser.saveSection(userId: userId, resumeId: resumeId, section: newSection);
      final updatedList = List<SectionModel>.from(currentState.sections)..add(newSection);
      emit(AdditionalLoaded(updatedList));
    } catch (e) {
      emit(AdditionalError("Failed to add section: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateSectionDetails(
      UpdateSectionDetails event, Emitter<AdditionalState> emit) async {
    if (state is! AdditionalLoaded) return;
    final currentState = state as AdditionalLoaded;
    final userId = MySingleton.userId!;
    final resumeId = MySingleton.resumeId!;

    try {
      final sectionToUpdate = currentState.sections.firstWhere((s) => s.id == event.sectionId);
      final updatedSection = sectionToUpdate.copyWith(
        value: event.values,
        description: event.descriptions,
      );

      await _fireUser.saveSection(userId: userId, resumeId: resumeId, section: updatedSection);
      final updatedList = currentState.sections.map((s) => s.id == event.sectionId ? updatedSection : s).toList();
      emit(AdditionalLoaded(updatedList));
    } catch (e) {
      emit(AdditionalError("Failed to update section: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteCustomSection(
      DeleteCustomSection event, Emitter<AdditionalState> emit) async {
    if (state is! AdditionalLoaded) return;
    final currentState = state as AdditionalLoaded;
    final userId = MySingleton.userId!;
    final resumeId = MySingleton.resumeId!;
    try {
      await _fireUser.deleteSection(userId: userId, resumeId: resumeId, sectionId: event.sectionId);
      final updatedList = currentState.sections.where((s) => s.id != event.sectionId).toList();
      emit(AdditionalLoaded(updatedList));
    } catch (e) {
      emit(AdditionalError("Failed to delete section: ${e.toString()}"));
    }
  }
}