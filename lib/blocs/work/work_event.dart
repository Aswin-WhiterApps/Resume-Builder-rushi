// lib/blocs/work/work_event.dart

import 'package:equatable/equatable.dart';
import 'package:resume_builder/model/model.dart';

abstract class WorkEvent extends Equatable {
  const WorkEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkList extends WorkEvent {
  final String? userId;
  final String? id; // This is the resumeId

  const LoadWorkList({required this.userId, required this.id});

  @override
  List<Object?> get props => [userId, id];
}

class AddWork extends WorkEvent {
  // REFACTORED: The model itself no longer needs userId or resumeId
  final WorkModel work;

  const AddWork(this.work);

  @override
  List<Object?> get props => [work];
}

class UpdateWork extends WorkEvent {
  final WorkModel work;

  const UpdateWork(this.work);

  @override
  List<Object?> get props => [work];
}

class DeleteWorkplace extends WorkEvent {
  final String userId;
  final String id; // resumeId
  final String wid; // work document ID

  const DeleteWorkplace(
      {required this.userId, required this.id, required this.wid});

  @override
  List<Object?> get props => [userId, id, wid];
}

class MoveWorkUp extends WorkEvent {
  final int currentIndex; // Pass the index of the item to move
  const MoveWorkUp(this.currentIndex);

  @override
  List<Object?> get props => [currentIndex];
}

class MoveWorkDown extends WorkEvent {
  final int currentIndex; // Pass the index of the item to move
  const MoveWorkDown(this.currentIndex);

  @override
  List<Object?> get props => [currentIndex];
}