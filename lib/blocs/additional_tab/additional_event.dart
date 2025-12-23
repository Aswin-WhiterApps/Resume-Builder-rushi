
import 'package:equatable/equatable.dart';

abstract class AdditionalEvent extends Equatable {
  const AdditionalEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdditionalSections extends AdditionalEvent {
  final String userId;
  final String resumeId;
  const LoadAdditionalSections({required this.userId, required this.resumeId});
}

class AddCustomSection extends AdditionalEvent {
  final String sectionName;
  const AddCustomSection(this.sectionName);
}

// This event now carries the delimited strings.
class UpdateSectionDetails extends AdditionalEvent {
  final String sectionId;
  final String values;
  final String descriptions;

  const UpdateSectionDetails(this.sectionId, this.values, this.descriptions);

  @override
  List<Object?> get props => [sectionId, values, descriptions];
}

class DeleteCustomSection extends AdditionalEvent {
  final String sectionId;
  const DeleteCustomSection(this.sectionId);
}


