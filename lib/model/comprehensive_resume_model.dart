import 'package:equatable/equatable.dart';

/// Comprehensive resume data model that consolidates all resume sections
class ComprehensiveResumeData extends Equatable {
  // Personal Information (Intro)
  final String? firstName;
  final String? lastName;
  final String? profileImagePath;
  final String? position;
  
  // Contact Information
  final String? email;
  final String? phone;
  final String? address1;
  final String? address2;
  final String? socialMediaUrl1;
  final String? socialMediaUrl2;
  final String? personalWebsite;
  
  // Professional Summary
  final String? summary;
  
  // Work Experience
  final List<WorkExperience> workExperience;
  
  // Education
  final List<Education> education;
  
  // Skills
  final List<String> skills;
  
  // Additional Sections (Languages, Certifications, etc.)
  final List<AdditionalSection> additionalSections;
  
  // Cover Letter
  final String? coverLetter;
  
  // Signature
  final String? signaturePath;
  
  // Template Information
  final String? selectedTemplateId;
  final String? resumeTitle;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ComprehensiveResumeData({
    this.firstName,
    this.lastName,
    this.profileImagePath,
    this.position,
    this.email,
    this.phone,
    this.address1,
    this.address2,
    this.socialMediaUrl1,
    this.socialMediaUrl2,
    this.personalWebsite,
    this.summary,
    this.workExperience = const [],
    this.education = const [],
    this.skills = const [],
    this.additionalSections = const [],
    this.coverLetter,
    this.signaturePath,
    this.selectedTemplateId,
    this.resumeTitle,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    profileImagePath,
    position,
    email,
    phone,
    address1,
    address2,
    socialMediaUrl1,
    socialMediaUrl2,
    personalWebsite,
    summary,
    workExperience,
    education,
    skills,
    additionalSections,
    coverLetter,
    signaturePath,
    selectedTemplateId,
    resumeTitle,
    createdAt,
    updatedAt,
  ];

  ComprehensiveResumeData copyWith({
    String? firstName,
    String? lastName,
    String? profileImagePath,
    String? position,
    String? email,
    String? phone,
    String? address1,
    String? address2,
    String? socialMediaUrl1,
    String? socialMediaUrl2,
    String? personalWebsite,
    String? summary,
    List<WorkExperience>? workExperience,
    List<Education>? education,
    List<String>? skills,
    List<AdditionalSection>? additionalSections,
    String? coverLetter,
    String? signaturePath,
    String? selectedTemplateId,
    String? resumeTitle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComprehensiveResumeData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      position: position ?? this.position,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      socialMediaUrl1: socialMediaUrl1 ?? this.socialMediaUrl1,
      socialMediaUrl2: socialMediaUrl2 ?? this.socialMediaUrl2,
      personalWebsite: personalWebsite ?? this.personalWebsite,
      summary: summary ?? this.summary,
      workExperience: workExperience ?? this.workExperience,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      additionalSections: additionalSections ?? this.additionalSections,
      coverLetter: coverLetter ?? this.coverLetter,
      signaturePath: signaturePath ?? this.signaturePath,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      resumeTitle: resumeTitle ?? this.resumeTitle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to Map for storage/transmission
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'profileImagePath': profileImagePath,
      'position': position,
      'email': email,
      'phone': phone,
      'address1': address1,
      'address2': address2,
      'socialMediaUrl1': socialMediaUrl1,
      'socialMediaUrl2': socialMediaUrl2,
      'personalWebsite': personalWebsite,
      'summary': summary,
      'workExperience': workExperience.map((e) => e.toMap()).toList(),
      'education': education.map((e) => e.toMap()).toList(),
      'skills': skills,
      'additionalSections': additionalSections.map((e) => e.toMap()).toList(),
      'coverLetter': coverLetter,
      'signaturePath': signaturePath,
      'selectedTemplateId': selectedTemplateId,
      'resumeTitle': resumeTitle,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from Map
  factory ComprehensiveResumeData.fromMap(Map<String, dynamic> map) {
    return ComprehensiveResumeData(
      firstName: map['firstName'],
      lastName: map['lastName'],
      profileImagePath: map['profileImagePath'],
      position: map['position'],
      email: map['email'],
      phone: map['phone'],
      address1: map['address1'],
      address2: map['address2'],
      socialMediaUrl1: map['socialMediaUrl1'],
      socialMediaUrl2: map['socialMediaUrl2'],
      personalWebsite: map['personalWebsite'],
      summary: map['summary'],
      workExperience: (map['workExperience'] as List<dynamic>?)
          ?.map((e) => WorkExperience.fromMap(e))
          .toList() ?? [],
      education: (map['education'] as List<dynamic>?)
          ?.map((e) => Education.fromMap(e))
          .toList() ?? [],
      skills: (map['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      additionalSections: (map['additionalSections'] as List<dynamic>?)
          ?.map((e) => AdditionalSection.fromMap(e))
          .toList() ?? [],
      coverLetter: map['coverLetter'],
      signaturePath: map['signaturePath'],
      selectedTemplateId: map['selectedTemplateId'],
      resumeTitle: map['resumeTitle'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  /// Get full name
  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  /// Check if resume has minimum required data
  bool get hasMinimumData {
    return fullName.isNotEmpty && 
           (email?.isNotEmpty == true || phone?.isNotEmpty == true);
  }

  /// Get all contact information as a list
  List<String> get contactInfo {
    final contacts = <String>[];
    if (email?.isNotEmpty == true) contacts.add(email!);
    if (phone?.isNotEmpty == true) contacts.add(phone!);
    if (address1?.isNotEmpty == true) contacts.add(address1!);
    if (address2?.isNotEmpty == true) contacts.add(address2!);
    if (socialMediaUrl1?.isNotEmpty == true) contacts.add(socialMediaUrl1!);
    if (socialMediaUrl2?.isNotEmpty == true) contacts.add(socialMediaUrl2!);
    if (personalWebsite?.isNotEmpty == true) contacts.add(personalWebsite!);
    return contacts;
  }
}

/// Work Experience model
class WorkExperience extends Equatable {
  final String id;
  final String? companyName;
  final String? position;
  final String? location;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;
  final List<String> achievements;
  final int sortOrder;

  const WorkExperience({
    required this.id,
    this.companyName,
    this.position,
    this.location,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
    this.achievements = const [],
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [
    id,
    companyName,
    position,
    location,
    startDate,
    endDate,
    isCurrent,
    description,
    achievements,
    sortOrder,
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'position': position,
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'isCurrent': isCurrent,
      'description': description,
      'achievements': achievements,
      'sortOrder': sortOrder,
    };
  }

  factory WorkExperience.fromMap(Map<String, dynamic> map) {
    return WorkExperience(
      id: map['id'] ?? '',
      companyName: map['companyName'],
      position: map['position'],
      location: map['location'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      isCurrent: map['isCurrent'] ?? false,
      description: map['description'],
      achievements: (map['achievements'] as List<dynamic>?)?.cast<String>() ?? [],
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  WorkExperience copyWith({
    String? id,
    String? companyName,
    String? position,
    String? location,
    String? startDate,
    String? endDate,
    bool? isCurrent,
    String? description,
    List<String>? achievements,
    int? sortOrder,
  }) {
    return WorkExperience(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      position: position ?? this.position,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
      achievements: achievements ?? this.achievements,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Education model
class Education extends Equatable {
  final String id;
  final String? institution;
  final String? degree;
  final String? fieldOfStudy;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final double? gpa;
  final String? description;
  final List<String> achievements;
  final int sortOrder;

  const Education({
    required this.id,
    this.institution,
    this.degree,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.gpa,
    this.description,
    this.achievements = const [],
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [
    id,
    institution,
    degree,
    fieldOfStudy,
    startDate,
    endDate,
    isCurrent,
    gpa,
    description,
    achievements,
    sortOrder,
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'institution': institution,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'startDate': startDate,
      'endDate': endDate,
      'isCurrent': isCurrent,
      'gpa': gpa,
      'description': description,
      'achievements': achievements,
      'sortOrder': sortOrder,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      id: map['id'] ?? '',
      institution: map['institution'],
      degree: map['degree'],
      fieldOfStudy: map['fieldOfStudy'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      isCurrent: map['isCurrent'] ?? false,
      gpa: map['gpa']?.toDouble(),
      description: map['description'],
      achievements: (map['achievements'] as List<dynamic>?)?.cast<String>() ?? [],
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  Education copyWith({
    String? id,
    String? institution,
    String? degree,
    String? fieldOfStudy,
    String? startDate,
    String? endDate,
    bool? isCurrent,
    double? gpa,
    String? description,
    List<String>? achievements,
    int? sortOrder,
  }) {
    return Education(
      id: id ?? this.id,
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      gpa: gpa ?? this.gpa,
      description: description ?? this.description,
      achievements: achievements ?? this.achievements,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Additional Section model (Languages, Certifications, etc.)
class AdditionalSection extends Equatable {
  final String id;
  final String title;
  final List<AdditionalItem> items;
  final bool isSelected;
  final int sortOrder;

  const AdditionalSection({
    required this.id,
    required this.title,
    this.items = const [],
    this.isSelected = true,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, title, items, isSelected, sortOrder];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'items': items.map((e) => e.toMap()).toList(),
      'isSelected': isSelected,
      'sortOrder': sortOrder,
    };
  }

  factory AdditionalSection.fromMap(Map<String, dynamic> map) {
    return AdditionalSection(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((e) => AdditionalItem.fromMap(e))
          .toList() ?? [],
      isSelected: map['isSelected'] ?? true,
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  AdditionalSection copyWith({
    String? id,
    String? title,
    List<AdditionalItem>? items,
    bool? isSelected,
    int? sortOrder,
  }) {
    return AdditionalSection(
      id: id ?? this.id,
      title: title ?? this.title,
      items: items ?? this.items,
      isSelected: isSelected ?? this.isSelected,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Additional Item model
class AdditionalItem extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? date;
  final String? issuer;
  final String? level;

  const AdditionalItem({
    required this.id,
    required this.title,
    this.description,
    this.date,
    this.issuer,
    this.level,
  });

  @override
  List<Object?> get props => [id, title, description, date, issuer, level];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'issuer': issuer,
      'level': level,
    };
  }

  factory AdditionalItem.fromMap(Map<String, dynamic> map) {
    return AdditionalItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      date: map['date'],
      issuer: map['issuer'],
      level: map['level'],
    );
  }

  AdditionalItem copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? issuer,
    String? level,
  }) {
    return AdditionalItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      issuer: issuer ?? this.issuer,
      level: level ?? this.level,
    );
  }
}
