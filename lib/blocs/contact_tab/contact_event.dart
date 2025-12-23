// lib/blocs/contact_tab/contact_event.dart

import 'package:equatable/equatable.dart';
import '../../model/model.dart';

abstract class ContactEvent extends Equatable {
  const ContactEvent();

  @override
  List<Object?> get props => [];
}

class LoadContactEvent extends ContactEvent {
  final String userId;
  final String resumeId;

  const LoadContactEvent({required this.userId, required this.resumeId});

  @override
  List<Object?> get props => [userId, resumeId];
}

class SaveContactEvent extends ContactEvent {
  final String userId;
  final String resumeId;
  final ContactModel contactModel;

  const SaveContactEvent({
    required this.userId,
    required this.resumeId,
    required this.contactModel,
  });

  @override
  List<Object?> get props => [userId, resumeId, contactModel];
}