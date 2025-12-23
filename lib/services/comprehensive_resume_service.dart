import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/model/comprehensive_resume_model.dart';
import 'package:resume_builder/model/model.dart';

/// Service to collect and aggregate all resume data from different sections
class ComprehensiveResumeService {
  static ComprehensiveResumeService? _instance;
  static ComprehensiveResumeService get instance => _instance ??= ComprehensiveResumeService._();
  
  ComprehensiveResumeService._();
  
  final FireUser _fireUser = FireUser();
  
  /// Collect all resume data from different sections and create comprehensive model
  Future<ComprehensiveResumeData> collectAllResumeData({
    required String userId,
    required String resumeId,
  }) async {
    try {
      print('Collecting comprehensive resume data...');
      
      // Get the main resume document
      final resume = await _fireUser.getResume(userId: userId, resumeId: resumeId);
      if (resume == null) {
        throw Exception('Resume not found');
      }
      
      // Collect personal information (Intro)
      final personalInfo = _extractPersonalInfo(resume);
      
      // Collect contact information
      final contactInfo = _extractContactInfo(resume);
      
      // Collect summary
      final summary = resume.summary?.summery;
      
      // Collect work experience
      final workExperience = await _collectWorkExperience(userId, resumeId);
      
      // Collect education
      final education = await _collectEducation(userId, resumeId);
      
      // Collect skills and additional sections from generic sections store
      final skills = await _collectSkills(userId, resumeId);
      final additionalSections = await _collectAdditionalSections(userId, resumeId);
      
      // Collect cover letter
      final coverLetter = resume.coverLetter?.text;
      
      // Collect signature
      final signaturePath = resume.signatureUrl;
      
      // Create comprehensive resume data
      final comprehensiveData = ComprehensiveResumeData(
        // Personal Information
        firstName: personalInfo['firstName'],
        lastName: personalInfo['lastName'],
        profileImagePath: personalInfo['profileImagePath'],
        position: personalInfo['position'],
        
        // Contact Information
        email: contactInfo['email'],
        phone: contactInfo['phone'],
        address1: contactInfo['address1'],
        address2: contactInfo['address2'],
        socialMediaUrl1: contactInfo['socialMediaUrl1'],
        socialMediaUrl2: contactInfo['socialMediaUrl2'],
        personalWebsite: contactInfo['personalWebsite'],
        
        // Professional Information
        summary: summary,
        workExperience: workExperience,
        education: education,
        additionalSections: additionalSections,
        skills: skills,
        coverLetter: coverLetter,
        signaturePath: signaturePath,
        
        // Metadata
        selectedTemplateId: resumeId, // Using resumeId as template identifier
        resumeTitle: resume.title,
        createdAt: resume.createdAt,
        updatedAt: DateTime.now(),
      );
      
      print('Comprehensive resume data collected successfully');
      print('Data summary:');
      print('   - Personal: ${comprehensiveData.fullName}');
      print('   - Work Experience: ${comprehensiveData.workExperience.length} entries');
      print('   - Education: ${comprehensiveData.education.length} entries');
      print('   - Additional Sections: ${comprehensiveData.additionalSections.length} entries');
      print('   - Skills: ${comprehensiveData.skills.length} skills');
      
      return comprehensiveData;
    } catch (e) {
      print('Failed to collect comprehensive resume data: $e');
      rethrow;
    }
  }
  
  /// Extract personal information from resume
  Map<String, String?> _extractPersonalInfo(ResumeModel resume) {
    return {
      'firstName': resume.intro?.firstName,
      'lastName': resume.intro?.lastName,
      'profileImagePath': resume.intro?.imagePath,
      'position': null, // Position is not stored in intro, might be in contact or summary
    };
  }
  
  /// Extract contact information from resume
  Map<String, String?> _extractContactInfo(ResumeModel resume) {
    return {
      'email': resume.contact?.email,
      'phone': resume.contact?.phone,
      'address1': resume.contact?.addr1,
      'address2': resume.contact?.addr2,
      'socialMediaUrl1': resume.contact?.socialMediaUrl1,
      'socialMediaUrl2': resume.contact?.socialMediaUrl2,
      'personalWebsite': resume.contact?.personnelWeb,
    };
  }
  
  /// Collect work experience data
  Future<List<WorkExperience>> _collectWorkExperience(String userId, String resumeId) async {
    try {
      final workList = await _fireUser.getWorkExperiences(userId: userId, resumeId: resumeId);
      return workList.map((work) => WorkExperience(
        id: work.id ?? '',
        companyName: work.compName,
        position: work.compPosition,
        location: work.compLocation,
        startDate: work.dateFrom,
        endDate: work.dateTo,
        isCurrent: work.present ?? false,
        description: work.details,
        achievements: [], // Achievements not stored separately in current model
        sortOrder: work.sortOrder ?? 0,
      )).toList();
    } catch (e) {
      print('Failed to collect work experience: $e');
      return [];
    }
  }
  
  /// Collect education data
  Future<List<Education>> _collectEducation(String userId, String resumeId) async {
    try {
      final educationList = await _fireUser.getEducations(userId: userId, resumeId: resumeId);
      return educationList.map((edu) => Education(
        id: edu.id,
        institution: edu.schoolName,
        degree: null, // Degree not stored in current model
        fieldOfStudy: null, // Field of study not stored in current model
        startDate: edu.dateFrom,
        endDate: edu.dateTo,
        isCurrent: edu.present ?? false,
        gpa: null, // GPA not stored in current model
        description: null, // Description not stored in current model
        achievements: [], // Achievements not stored separately in current model
        sortOrder: edu.sortOrder ?? 0,
      )).toList();
    } catch (e) {
      print('Failed to collect education: $e');
      return [];
    }
  }
  
  /// Collect skills from sections 'Skills' and 'Technical Skills'
  Future<List<String>> _collectSkills(String userId, String resumeId) async {
    const delimiter = '@@@';
    try {
      final sections = await _fireUser.getAllSections(userId: userId, resumeId: resumeId);
      final skillSectionIds = {'Skills', 'Technical Skills'};
      final allSkills = <String>{};

      for (final section in sections) {
        if (skillSectionIds.contains(section.id)) {
          final value = section.value ?? '';
          if (value.isEmpty) continue;
          final parts = value.split(delimiter).map((s) => s.trim()).where((s) => s.isNotEmpty);
          allSkills.addAll(parts);
        }
      }

      return allSkills.toList();
    } catch (e) {
      print('Failed to collect skills: $e');
      return [];
    }
  }

  /// Collect additional sections data
  Future<List<AdditionalSection>> _collectAdditionalSections(String userId, String resumeId) async {
    // Any section other than 'Skills' and 'Technical Skills' becomes an AdditionalSection.
    const delimiter = '@@@';
    const excluded = {'Skills', 'Technical Skills'};
    try {
      final sections = await _fireUser.getAllSections(userId: userId, resumeId: resumeId);
      final additional = <AdditionalSection>[];
      for (final section in sections) {
        if (excluded.contains(section.id)) continue;

        final values = (section.value ?? '')
            .split(delimiter)
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        final descriptions = (section.description ?? '')
            .split(delimiter)
            .map((s) => s.trim())
            .toList();

        if (values.isEmpty && (section.description == null || section.description!.isEmpty)) {
          // Skip empty sections
          continue;
        }

        final items = <AdditionalItem>[];
        for (var i = 0; i < values.length; i++) {
          final title = values[i];
          final desc = i < descriptions.length ? descriptions[i] : null;
          items.add(AdditionalItem(
            id: '${section.id}-$i',
            title: title,
            description: (desc != null && desc.isNotEmpty) ? desc : null,
          ));
        }

        additional.add(AdditionalSection(
          id: section.id,
          title: section.id,
          items: items,
        ));
      }

      return additional;
    } catch (e) {
      print('Failed to collect additional sections: $e');
      return [];
    }
  }
  
  /// Convert comprehensive data to the format expected by PDF generation service
  Map<String, dynamic> convertToPDFFormat(ComprehensiveResumeData data) {
    return {
      // Personal Information
      'firstName': data.firstName,
      'lastName': data.lastName,
      'position': data.position,
      'profileImagePath': data.profileImagePath,
      
      // Contact Information
      'email': data.email,
      'phone': data.phone,
      'address1': data.address1,
      'address2': data.address2,
      'socialMediaUrl1': data.socialMediaUrl1,
      'socialMediaUrl2': data.socialMediaUrl2,
      'personalWebsite': data.personalWebsite,
      
      // Professional Information
      'summary': data.summary,
      'coverLetter': data.coverLetter,
      'signaturePath': data.signaturePath,
      
      // Work Experience (convert to expected format)
      'workExperience': data.workExperience.map((work) => {
        'title': work.position,
        'company': work.companyName,
        'location': work.location,
        'duration': _formatDuration(work.startDate, work.endDate, work.isCurrent),
        'description': work.description,
        'achievements': work.achievements,
      }).toList(),
      
      // Education (convert to expected format)
      'education': data.education.map((edu) => {
        'degree': edu.degree,
        'institution': edu.institution,
        'fieldOfStudy': edu.fieldOfStudy,
        'year': _formatEducationYear(edu.startDate, edu.endDate, edu.isCurrent),
        'gpa': edu.gpa,
        'description': edu.description,
        'achievements': edu.achievements,
      }).toList(),
      
      // Skills
      'skills': data.skills,
      
      // Additional Sections
      'additionalSections': data.additionalSections.map((section) => {
        'title': section.title,
        'items': section.items.map((item) => {
          'title': item.title,
          'description': item.description,
          'date': item.date,
          'issuer': item.issuer,
          'level': item.level,
        }).toList(),
      }).toList(),
      
      // Template Information
      'templateId': data.selectedTemplateId,
      'resumeTitle': data.resumeTitle,
      'createdAt': data.createdAt?.toIso8601String(),
      'updatedAt': data.updatedAt?.toIso8601String(),
    };
  }
  
  /// Format work duration
  String _formatDuration(String? startDate, String? endDate, bool isCurrent) {
    if (startDate == null) return '';
    
    final start = startDate;
    final end = isCurrent ? 'Present' : (endDate ?? '');
    
    return '$start - $end';
  }
  
  /// Format education year
  String _formatEducationYear(String? startDate, String? endDate, bool isCurrent) {
    if (startDate == null) return '';
    
    final start = startDate;
    final end = isCurrent ? 'Present' : (endDate ?? '');
    
    return '$start - $end';
  }
  
  /// Validate resume data completeness
  Map<String, dynamic> validateResumeData(ComprehensiveResumeData data) {
    final issues = <String>[];
    final warnings = <String>[];
    
    // Check required fields
    if (data.firstName?.isEmpty ?? true) {
      issues.add('First name is required');
    }
    
    if (data.lastName?.isEmpty ?? true) {
      issues.add('Last name is required');
    }
    
    if (data.email?.isEmpty ?? true) {
      issues.add('Email is required');
    }
    
    // Check for warnings
    if (data.workExperience.isEmpty) {
      warnings.add('No work experience added');
    }
    
    if (data.education.isEmpty) {
      warnings.add('No education added');
    }
    
    if (data.summary?.isEmpty ?? true) {
      warnings.add('No professional summary added');
    }
    
    if (data.skills.isEmpty) {
      warnings.add('No skills added');
    }
    
    return {
      'isValid': issues.isEmpty,
      'issues': issues,
      'warnings': warnings,
      'completenessScore': _calculateCompletenessScore(data),
    };
  }
  
  /// Calculate resume completeness score
  double _calculateCompletenessScore(ComprehensiveResumeData data) {
    int totalFields = 0;
    int completedFields = 0;
    
    // Personal Information (4 fields)
    totalFields += 4;
    if (data.firstName?.isNotEmpty == true) completedFields++;
    if (data.lastName?.isNotEmpty == true) completedFields++;
    if (data.email?.isNotEmpty == true) completedFields++;
    if (data.phone?.isNotEmpty == true) completedFields++;
    
    // Professional Information (3 fields)
    totalFields += 3;
    if (data.summary?.isNotEmpty == true) completedFields++;
    if (data.workExperience.isNotEmpty) completedFields++;
    if (data.education.isNotEmpty) completedFields++;
    
    // Additional Information (2 fields)
    totalFields += 2;
    if (data.skills.isNotEmpty) completedFields++;
    if (data.additionalSections.isNotEmpty) completedFields++;
    
    return (completedFields / totalFields) * 100;
  }
}
