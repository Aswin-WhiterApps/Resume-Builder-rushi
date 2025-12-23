import 'package:equatable/equatable.dart';
import 'package:resume_builder/model/model.dart';

abstract class WorkState extends Equatable {
  const WorkState();

  @override
  List<Object?> get props => [];
}

class WorkInitial extends WorkState {
  const WorkInitial();
}

class WorkLoading extends WorkState {
  const WorkLoading();
}

class WorkLoaded extends WorkState {
  final List<WorkModel> works;

  const WorkLoaded(this.works);

  @override
  List<Object?> get props => [works];
}

class WorkError extends WorkState {
  final String message;

  const WorkError(this.message);

  @override
  List<Object?> get props => [message];
}
