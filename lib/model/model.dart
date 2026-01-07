import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class IntroModel {
  //String id;
  String? firstName;
  String? lastName;
  String? imagePath;

  IntroModel({/*required this.id*/ this.firstName, this.lastName, this.imagePath});

  factory IntroModel.fromMap(Map<dynamic, dynamic> map) {
    return IntroModel(
      //id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
     // 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'imagePath': imagePath,
    };
  }

  Map<String, dynamic> onlyImage() {
    return {
     // 'id': id,
      'imagePath': imagePath,
    };
  }

  Map<String, dynamic> onlyText() {
    return {
     // 'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

class ContactModel {
 // String id;
  String? email;
  String? phone;
  String? socialMediaUrl1;
  String? socialMediaUrl2;
  String? personnelWeb;
  String? addr1;
  String? addr2;

  var socialMediaURL;

  ContactModel(
      {//required this.id,
      this.email,
      this.phone,
      this.socialMediaUrl1,
      this.socialMediaUrl2,
      this.personnelWeb,
      this.addr1,
      this.addr2});

  factory ContactModel.fromMap(Map<dynamic, dynamic> map) {
    return ContactModel(
      //id: map['id'],
      email: map['email'],
      phone: map['phone'],
      socialMediaUrl1: map['socialMediaUrl1'],
      socialMediaUrl2: map['socialMediaUrl2'],
      personnelWeb: map['personnelWeb'],
      addr1: map['addr1'],
      addr2: map['addr2'],
    );
  }

  get linkedin => null;

  Map<String, dynamic> toMap() {
    return {
      //'id': id,
      'email': email,
      'phone': phone,
      'socialMediaUrl1': socialMediaUrl1,
      'socialMediaUrl2': socialMediaUrl2,
      'personnelWeb': personnelWeb,
      'addr1': addr1,
      'addr2': addr2,
    };
  }
}

class UserModel {
  String? email;
  String? userName;
  String? uid;
  bool? subscribed;
  String? subStartDate;
  String? subEndDate;
  String? paymentId;
  String? orderId;
  String? signature;
  String? packageName;
  int? duration;
  // String? subStartDate;
  // String? subEndDate;

  UserModel(
      {this.userName,
      this.email,
      this.uid,
      this.subscribed,
      this.subStartDate,
      this.subEndDate,
      this.paymentId,
      this.orderId,
      this.signature,
      this.duration,
      this.packageName
      // this.subStartDate,
      // this.subEndDate
      });


  factory UserModel.fromJson(Map<dynamic, dynamic> map) {
    return UserModel(
      subscribed: map['subscribed'],
      // subStartDate: map['subStartDate'],
      // subEndDate: map['subEndDate'],
      userName: map['userName'],
      email: map['email'],
      uid: map['uid'],
      subStartDate: map['subStartDate'],
      subEndDate: map['subEndDate'],
      paymentId: map['paymentId'],
      orderId: map['orderId'],
      signature: map['signature'],
      packageName: map['packageName'],
      duration: map['duration'],
    );
  }

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return UserModel(
      subscribed: data!['subscribed'],
      // subStartDate: data!['subStartDate'],
      // subEndDate: data!['subEndDate'],
      userName: data['userName'],
      email: data['email'],
      uid: data['uid'],
      subStartDate: data['subStartDate'],
      subEndDate: data['subEndDate'],
      paymentId: data['paymentId'],
      orderId: data['orderId'],
      signature: data['signature'],
      duration: data['duration'],
      packageName: data['packageName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subscribed': subscribed,
      'userName': userName,
      'email': email,
      'uid': uid,
      'subEndDate': subEndDate,
      'subStartDate': subStartDate,
      'paymentId': paymentId,
      'orderId': orderId,
      'signature': signature,
      'duration': duration,
      'packageName': packageName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      subscribed: map['subscribed'],
      userName: map['userName'],
      email: map['email'],
      uid: map['uid'],
      subStartDate: map['subStartDate'],
      subEndDate: map['subEndDate'],
      paymentId: map['paymentId'],
      orderId: map['orderId'],
      signature: map['signature'],
      duration: map['duration'],
      packageName: map['packageName'],
    );
  }
}

class SubscriptionDetail {
  String? subStartDate;
  String? subEndDate;
  String? paymentId;
  // String? orderId;
  String? payerId;
  // String? signature;
  String? currency;
  String? packageName;
  int? duration;
  bool? subscribed;

  SubscriptionDetail(
      {this.subStartDate,
      this.subEndDate,
      this.paymentId,
      this.payerId,
      this.currency,
      this.duration,
      this.packageName,
      this.subscribed});

  factory SubscriptionDetail.fromJson(Map<dynamic, dynamic> map) {
    return SubscriptionDetail(
      subStartDate: map['subStartDate'],
      subEndDate: map['subEndDate'],
      paymentId: map['paymentId'],
      payerId: map['payerId'],
      currency: map['currency'],
      packageName: map['packageName'],
      duration: map['duration'],
      subscribed: map['subscribed'],
    );
  }

  factory SubscriptionDetail.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return SubscriptionDetail(
      subStartDate: data!['subStartDate'],
      subEndDate: data['subEndDate'],
      paymentId: data['paymentId'],
      payerId: data['payerId'],
      currency: data['currency'],
      duration: data['duration'],
      packageName: data['packageName'],
      subscribed: data['subscribed'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subEndDate': subEndDate,
      'subStartDate': subStartDate,
      'paymentId': paymentId,
      'payerId': payerId,
      'currency': currency,
      'duration': duration,
      'packageName': packageName,
      'subscribed': subscribed,
    };
  }
}

class SubscriptionDetailRemove {
  String? subStartDate;
  String? subEndDate;
  String? paymentId;
  String? orderId;
  String? signature;
  String? packageName;
  int? duration;
  bool? subscribed;

  SubscriptionDetailRemove(
      {this.subStartDate,
      this.subEndDate,
      this.paymentId,
      this.orderId,
      this.signature,
      this.duration,
      this.packageName,
      this.subscribed});

  Map<String, dynamic> toMap() {
    return {
      'subEndDate': subEndDate,
      'subStartDate': subStartDate,
      'paymentId': paymentId,
      'orderId': orderId,
      'signature': signature,
      'duration': duration,
      'packageName': packageName,
      'subscribed': subscribed,
    };
  }
}

class EducationModel {
  String id;
  String? eid;
  String? schoolName;
  String? dateFrom;
  String? dateTo;
  bool? present;
  int? sortOrder;

  EducationModel(
      { required this.id,
      this.eid,
      this.schoolName,
      this.present,
      this.dateFrom,
      this.dateTo,
      this.sortOrder});

  factory EducationModel.fromFirestore(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EducationModel(
      id: doc.id,
      schoolName: data['schoolName'],
      dateFrom: data['dateFrom'],
      dateTo: data['dateTo'],
      present: (data['present'] == 1 || data['present'] == true),
      sortOrder: data['sortOrder'],
    );
  }


  factory EducationModel.fromJson(Map<dynamic, dynamic> map) {
    return EducationModel(
      id: map['id'],
      eid: map['eid'],
      schoolName: map['schoolName'],
      dateFrom: map['dateFrom'],
      dateTo: map['dateTo'],
      present: map['present'] == 0 ? false : true,
      sortOrder: map['sortOrder'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
       'id': id,
       'eid': eid,
      'schoolName': schoolName,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'present': present,
      'sortOrder': sortOrder,
    };
  }
}

class WorkModel extends Equatable {
 //final String userId;
  final String? id;
  final String? wid;
  final String? compName;
  final String? compLocation;
  final String? compPosition;
  final String? dateFrom;
  final String? dateTo;
  final bool? present;
  final int? sortOrder;
  final String? details;

  const WorkModel({
    //required this.userId,
    required this.id,
    this.wid,
    this.compName,
    this.compLocation,
    this.compPosition,
    this.dateFrom,
    this.dateTo,
    this.present,
    this.sortOrder,
    this.details,
  });

  factory WorkModel.fromJson(Map<String, dynamic> map) {
    return WorkModel(
    //  userId: map['userId'], // ✅
      id: map['id'],
      wid: map['wid'],
      compName: map['compName'],
      compLocation: map['compLocation'],
      compPosition: map['compPosition'],
      dateFrom: map['dateFrom'],
      dateTo: map['dateTo'],
      present: map['present'] == 0 ? false : true,
      sortOrder: map['sortOrder'],
      details: map['details'],
    );
  }


  factory WorkModel.fromFirestore(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkModel(
     // userId: data['userId'],
      id: doc.id,
      compName: data['compName'],
      compLocation: data['compLocation'],
      compPosition: data['compPosition'],
      dateFrom: data['dateFrom'],
      dateTo: data['dateTo'],
      present: data['present'] == true || data['present'] == 1,
      sortOrder: data['sortOrder'],
      details: data['details'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
     // 'userId': userId, // ✅
      'id': id,
      'wid': wid,
      'compName': compName,
      'compLocation': compLocation,
      'compPosition': compPosition,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'present': present,
      'sortOrder': sortOrder,
      'details': details,
    };
  }

  WorkModel copyWith({
   String? userId,
   //  int? id,
    String? id,
    String? wid,
    String? compName,
    String? compLocation,
    String? compPosition,
    String? dateFrom,
    String? dateTo,
    bool? present,
    int? sortOrder,
    String? details,
  }) {
    return WorkModel(
     //userId: userId ?? this.userId,
      id: id ?? this.id,
      wid: wid ?? this.wid,
      compName: compName ?? this.compName,
      compLocation: compLocation ?? this.compLocation,
      compPosition: compPosition ?? this.compPosition,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      present: present ?? this.present,
      sortOrder: sortOrder ?? this.sortOrder,
      details: details ?? this.details,
    );
  }

  @override
  List<Object?> get props => [
        //userId,
        id,
        wid,
        compName,
        compLocation,
        compPosition,
        dateFrom,
        dateTo,
        present,
        sortOrder,
        details,
      ];
}

class SummeryModel {
  String? summery;

  SummeryModel({//required this.id,
    this.summery});

  factory SummeryModel.fromJson(Map<dynamic, dynamic> map) {
    return SummeryModel(
     // id: map['id'],
      summery: map['summery'],
    );
  }

  factory SummeryModel.fromMap(Map<dynamic, dynamic> map) {
    return SummeryModel(summery: map['summery']// id: map['id']
         );
  }


  Map<String, dynamic> toMap() {
    return {
     // 'id': id,
      'summery': summery,
    };
  }
}

class CoverLetterModel {
  String id;
  String? text;

  CoverLetterModel({required this.id, this.text});

  factory CoverLetterModel.fromJson(Map<dynamic, dynamic> map) {
    return CoverLetterModel(
      id: map['id'],
      text: map['text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
    };
  }
}

class SignModel {
  String id;
  String? signPath;

  SignModel({required this.id, this.signPath});

  factory SignModel.fromJson(Map<dynamic, dynamic> map) {
    return SignModel(
      id: map['id'],
      signPath: map['signPath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'signPath': signPath,
    };
  }
}
class ResumeModel {
  String id;
  String? uid;
  final String? signatureUrl;
  String? title;
  DateTime? createdAt;
  final CoverLetterModel? coverLetter;
  IntroModel? intro;
  ContactModel? contact;
  SummeryModel? summary;

  ResumeModel({
    required this.id,
    this.uid,
    this.title,
    this.createdAt,
    this.intro,
    this.contact,
    this.summary,
    this.signatureUrl,
    this.coverLetter
  });

  factory ResumeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResumeModel(
      id: doc.id,
      uid: data['uid'],
      title: data['title'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      intro: data['intro'] != null ? IntroModel.fromMap(data['intro']) : null,
      contact: data['contact'] != null ? ContactModel.fromMap(data['contact']) : null,
      summary: data['summary'] != null ? SummeryModel.fromMap(data['summary']) : null,
      coverLetter: data['coverLetter'] != null ? CoverLetterModel.fromJson(data['coverLetter']) : null,
      signatureUrl: data['signatureUrl'],
    );
  }

  factory ResumeModel.fromJson(Map<String , dynamic> map) {
    return ResumeModel(
      id: map['id'],
      uid: map['uid'],
      title: map['title'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
      'intro': intro?.toMap(),
      'contact': contact?.toMap(),
      'summary': summary?.toMap(),
      'signatureUrl': signatureUrl,
    };
  }

  factory ResumeModel.fromMap(Map<String, dynamic> map) {
    return ResumeModel(
      id: map['id'],
      uid: map['uid'],
      title: map['title'],
      createdAt: map['created_at'],
    );
  }
  ResumeModel copyWith({
    String? id,
    String? uid,
    String? title,
    DateTime? createdAt,
    IntroModel? intro,
    ContactModel? contact,
    SummeryModel? summary,
    CoverLetterModel? coverLetter,
    String? signatureUrl, required List<SectionModel> additionalSections,
  }) {
    return ResumeModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      intro: intro ?? this.intro,
      contact: contact ?? this.contact,
      summary: summary ?? this.summary,
      coverLetter: coverLetter ?? this.coverLetter,
      signatureUrl: signatureUrl ?? this.signatureUrl,
    );
  }
}


//
// class SectionItem {
//   final String value; // CHANGED: Renamed 'name' to 'value'
//   final String? description;
//
//   SectionItem({required this.value, this.description}); // CHANGED: Updated constructor
//
//   Map<String, dynamic> toMap() => {'value': value, 'description': description}; // CHANGED: Updated map key
//
//   factory SectionItem.fromMap(Map<String, dynamic> map) {
//     return SectionItem(
//       value: map['value'] as String, // CHANGED: Reads 'value' from the map
//       description: map['description'] as String?,
//     );
//   }
// }
//
// class SectionModel extends Equatable {
//   final String id; // The name of the section, e.g., "Languages"
//   final List<SectionItem> items; // The list of entries
//
//   const SectionModel({required this.id, this.items = const []});
//
//   @override
//   List<Object?> get props => [id, items];
//
//   factory SectionModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>?;
//     final itemsData = data?['items'] as List<dynamic>? ?? [];
//     return SectionModel(
//       id: doc.id,
//       items: itemsData.map((item) => SectionItem.fromMap(item as Map<String, dynamic>)).toList(),
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'items': items.map((item) => item.toMap()).toList(),
//     };
//   }
//
//   SectionModel copyWith({String? id, List<SectionItem>? items}) {
//     return SectionModel(
//       id: id ?? this.id,
//       items: items ?? this.items,
//     );
//   }
// }



// IMPORTANT: This model now represents a section where 'value' and 'description'
// can hold multiple entries separated by a special delimiter.
class SectionModel extends Equatable {
  final String id; // This is the unique name of the section, e.g., "Accomplishments"
  final String? resumeId;
  final String? value; // Will now store multiple names, e.g., "Name1@@@Name2@@@Name3"
  final String? description; // Will store multiple descriptions, e.g., "Desc1@@@Desc2@@@Desc3"
  final bool isSelected;

  const SectionModel({
    required this.id,
    this.value,
    this.description,
    this.isSelected = false,
    this.resumeId,
  });

  @override
  List<Object?> get props => [id, value, description, isSelected, resumeId];

  factory SectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return SectionModel(
      id: doc.id,
      value: data?['value'],
      description: data?['description'],
    );
  }

  SectionModel copyWith({
    String? id,
    String? resumeId,
    String? value,
    String? description,
    bool? isSelected,
  }) {
    return SectionModel(
      id: id ?? this.id,
      resumeId: resumeId ?? this.resumeId,
      value: value ?? this.value,
      description: description ?? this.description,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // fromJson is used by your legacy local DB if needed.
  factory SectionModel.fromJson(Map<String, dynamic> map) {
    return SectionModel(
      id: map['section'] ?? map['id'],
      resumeId: map['id']?.toString(),
      value: map['value'],
      description: map['description'],
      isSelected: false,
    );
  }

   Map<String, dynamic> toMap() {
    return {
      'value': value,
      'description': description,
    };
  }
}

// class SectionModel {
//   final String id;
//   final String? resumeId;
//   final String? value;
//   final String? description;
//   final bool isSelected;
//
//
//   SectionModel({
//     required this.id,
//     this.value,
//     this.description,
//     this.isSelected = false,
//     this.resumeId,
//   });
//
//   factory SectionModel.fromFirestore(DocumentSnapshot<Object?> doc) {
//     final data = doc.data() as Map<String, dynamic>?;
//     return SectionModel(
//       id: doc.id,
//       value: data?['value'],
//       description: data?['description'],
//     );
//   }
//
//   SectionModel copyWith({
//     String? id,
//     String? value,
//     String? description,
//     bool? isSelected,
//   }) {
//     return SectionModel(
//       id: id ?? this.id,
//       value: value ?? this.value,
//       description: description ?? this.description,
//       isSelected: isSelected ?? this.isSelected,
//     );
//   }
//
//   factory SectionModel.fromJson(Map<String, dynamic> map) {
//     return SectionModel(
//       id: map['section'] ?? map['id'],
//       resumeId: map['id']?.toString(),
//       value: map['value'],
//       description: map['description'],
//       isSelected: false,
//     );
//   }
//
//   @override
//   List<Object?> get props => [id, value, description, isSelected];
//
//   Map<String, dynamic> toMap() {
//     return {
//       'value': value,
//       'description': description,
//     };
//   }
// }
//


// class SectionModel {
//   final int? id; // Resume ID
//   final String? section; // Section name
//   String? value; // Item titles, concatenated
//   String? description; // Item descriptions, concatenated
//   bool includeInPdf;
//
//   SectionModel({
//     this.id,
//     this.section,
//     this.value,
//     this.description,
//     this.includeInPdf= false,
//   });
//
//   // For INSERT (and can be used for UPDATE if you update all fields)
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id, // Assuming AppConst.id is 'id'
//       'section': section, // Assuming AppConst.sectionName is 'section'
//       'value': value ?? "", // CHANGE: Ensure empty string if model's value is null
//       'description': description ?? "",
//       'include_in_pdf': includeInPdf ? 1 : 0, // CHANGE: Ensure empty string if model's description is null
//     };
//   }
//
//   Map<String, dynamic> toValueDescriptionMap() { // Example name
//     return {
//       'value': value ?? "", // CHANGE: Ensure empty string
//       'description': description ?? "", // CHANGE: Ensure empty string
//     };
//   }
//   Map<String, dynamic> toValueDescriptionMapForUpdate() {
//     return {
//       AppConst.sectionValue: value ?? "",
//       AppConst.sectionDescription: description ?? "",
//     };
//   }

//   factory SectionModel.fromJson(Map<String, dynamic> json) {
//     return SectionModel(
//       id: json[AppConst.id] ?,
//       section: json[AppConst.sectionName] as String?,
//       value: json[AppConst.sectionValue] as String?, // Reads null if DB has null, or string value
//       description: json[AppConst.sectionDescription] as String?, // Reads null if DB has null, or string value
//       includeInPdf: (json['include_in_pdf'] ? ?? 0) == 1,
//     );
//   }
// }

