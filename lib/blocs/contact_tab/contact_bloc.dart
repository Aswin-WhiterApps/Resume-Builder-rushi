// lib/blocs/contact_tab/contact_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/model/model.dart';

import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final FireUser fireUser;

  ContactBloc({required this.fireUser}) : super(ContactInitial()) {
    on<LoadContactEvent>(_onLoadContact);
    on<SaveContactEvent>(_onSaveContact);
  }

  Future<void> _onLoadContact(
      LoadContactEvent event, Emitter<ContactState> emit) async {
    emit(ContactLoading());
    try {
      // REFACTORED: Get the full resume from Firestore
      final resume = await fireUser.getResume(userId: event.userId, resumeId: event.resumeId);
      if (resume?.contact != null) {
        emit(ContactLoaded(resume!.contact!));
      } else {
        // If there's no contact data yet, emit a new empty model
        emit(ContactLoaded(ContactModel()));
      }
    } catch (e) {
      emit(ContactError('Failed to load contact data: $e'));
    }
  }

  Future<void> _onSaveContact(
      SaveContactEvent event, Emitter<ContactState> emit) async {
    try {
      // REFACTORED: Save the contact data to the resume document in Firestore
      await fireUser.saveContactForResume(
        userId: event.userId,
        resumeId: event.resumeId,
        contact: event.contactModel,
      );
      // After saving, emit the new state to the UI
      emit(ContactLoaded(event.contactModel));
    } catch (e) {
      emit(ContactError('Failed to save contact data: $e'));
    }
  }
}