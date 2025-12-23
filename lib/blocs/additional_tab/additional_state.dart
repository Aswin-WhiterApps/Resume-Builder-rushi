
import 'package:equatable/equatable.dart';

import '../../model/model.dart';

abstract class AdditionalState extends Equatable {
  const AdditionalState();
  @override
  List<Object> get props => [];
}

class AdditionalInitial extends AdditionalState {}
class AdditionalLoading extends AdditionalState {}

class AdditionalLoaded extends AdditionalState {
  final List<SectionModel> sections;
  const AdditionalLoaded(this.sections);
  @override
  List<Object> get props => [sections];
}

class AdditionalError extends AdditionalState {
  final String message;
  const AdditionalError(this.message);
  @override
  List<Object> get props => [message];
}