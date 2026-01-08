import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resume_builder/auth/auth.dart';
import 'package:resume_builder/model/model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireUser {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  Future<void> addUser({required UserModel userModel}) {
    return _firestore
        .collection('users')
        .doc(userModel.uid)
        .set(userModel.toMap())
        .then((value) => print("✅ User Added/Updated in Firestore"))
        .catchError((error) => print("❌ Failed to add user: $error"));
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    final userData = snapshot.docs
        .map((e) =>
            UserModel.fromSnapshot(e as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
    return userData;
  }

  Future<UserModel?> getCurrentUser(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data() as Map<String, dynamic>);
      } else {
        print("⚠️ User with UID $uid not found in Firestore.");
        return null;
      }
    } catch (e) {
      print("❌ Error getting current user: $e");
      return null;
    }
  }

  Future<bool> addSubscriptionDetails(
      SubscriptionDetail subscriptionDetail) async {
    final String? userId = Auth().currentUser?.uid;
    if (userId == null) {
      print("❌ Cannot add subscription: User not logged in.");
      return false;
    }
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(subscriptionDetail.toMap());
      print("✅ Subscription details updated for user: $userId");
      return true;
    } catch (e) {
      print("❌ Update Subscription Failed with error: $e");
      return false;
    }
  }

  Future<bool> removeSubscriptionDetails() async {
    final String? userId = Auth().currentUser?.uid;
    if (userId == null) {
      print("❌ Cannot remove subscription: User not logged in.");
      return false;
    }

    final Map<String, dynamic> removalMap = {
      'subscribed': false,
      'subEndDate': null,
      'subStartDate': null,
      'packageName': null,
      'orderId': null,
      'signature': null,
      'paymentId': null,
      'duration': null,
    };

    try {
      await _firestore.collection('users').doc(userId).update(removalMap);
      print("✅ Subscription details removed for user: $userId");
      return true;
    } catch (e) {
      print("❌ Remove Subscription Failed with error: $e");
      return false;
    }
  }

  Future<String?> createNewResume(
      {required String userId, required String title}) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('resumes')
          .add({
        'uid': userId,
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("✅ Resume created in Firestore with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("❌ Error creating new resume: $e");
      return null;
    }
  }

  Future<List<ResumeModel>> getResumesForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('resumes')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ResumeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("❌ Error fetching resumes for user: $e");
      return [];
    }
  }

  Future<void> deleteResume({
    required String userId,
    required String resumeId,
  }) async {
    print("Attempting to delete resume: $resumeId for user: $userId");
    final resumeRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId);

    try {
      final subcollections = ['work_experiences', 'educations', 'sections'];

      for (final collectionName in subcollections) {
        await _deleteSubcollection(resumeRef, collectionName);
      }

      await resumeRef.delete();
      print("✅ Successfully deleted resume ID: $resumeId");
    } catch (e) {
      print("❌ Error deleting resume ID $resumeId: $e");
    }
  }

  Future<void> _deleteSubcollection(
      DocumentReference parentDoc, String collectionName) async {
    final snapshot = await parentDoc.collection(collectionName).get();

    if (snapshot.docs.isEmpty) {
      print("No documents in '$collectionName'. Skipping delete.");
      return;
    }

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    print(
        "✅ Deleted ${snapshot.docs.length} documents from '$collectionName'.");
  }

  Future<void> saveIntroForResume(
      {required String userId,
      required String resumeId,
      required IntroModel intro}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .set({'intro': intro.toMap()}, SetOptions(merge: true))
        .then((_) => print("✅ Intro section saved successfully."))
        .catchError((error) => print("❌ Error saving intro section: $error"));
  }

  Future<void> saveIntroImageForResume({
    required String userId,
    required String resumeId,
    required String? imagePath,
  }) {
    print("Updating intro image for resume: $resumeId");
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .update({'intro.imagePath': imagePath})
        .then((_) => print("✅ Intro image updated successfully."))
        .catchError((error) => print("❌ Failed to update intro image: $error"));
  }

  Future<void> saveContactForResume(
      {required String userId,
      required String resumeId,
      required ContactModel contact}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .set({'contact': contact.toMap()}, SetOptions(merge: true));
  }

  Future<DocumentReference> addWorkExperience(
      {required String userId,
      required String? resumeId,
      required WorkModel work}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('work_experiences')
        .add(work.toMap());
  }

  Future<List<WorkModel>> getWorkExperiences(
      {required String? userId, required String? resumeId}) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('work_experiences')
        .get();
    return snapshot.docs.map((doc) => WorkModel.fromFirestore(doc)).toList();
  }

  Future<void> updateWorkExperience({
    required String userId,
    required String resumeId,
    required WorkModel work,
  }) {
    final String? workId = work.id;

    if (workId == null || workId.isEmpty) {
      throw ArgumentError('WorkModel must have a non-null ID to be updated.');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('work_experiences')
        .doc(workId)
        .update(work.toMap());
  }

  Future<void> deleteWorkExperience(
      {required String userId,
      required String resumeId,
      required String workId}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('work_experiences')
        .doc(workId)
        .delete();
  }

  Future<DocumentReference> addEducation(
      {required String userId,
      required String resumeId,
      required EducationModel education}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('educations')
        .add(education.toMap());
  }

  Future<List<EducationModel>> getEducations(
      {required String userId, required String resumeId}) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('educations')
        .get();
    return snapshot.docs
        .map((doc) => EducationModel.fromFirestore(doc))
        .toList();
  }

  Future<void> updateEducation(
      {required String userId,
      required String resumeId,
      required EducationModel education}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('educations')
        .doc(education.id)
        .update(education.toMap());
  }

  Future<void> deleteEducation(
      {required String userId,
      required String resumeId,
      required String educationId}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('educations')
        .doc(educationId)
        .delete();
  }

  Future<void> updateEducationSortOrder({
    required String userId,
    required String resumeId,
    required String educationId,
    required int newSortOrder,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('educations')
        .doc(educationId)
        .update({'sortOrder': newSortOrder});
  }

  Future<ResumeModel?> getResume({
    required String userId,
    required String resumeId,
  }) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('resumes')
          .doc(resumeId)
          .get();

      if (docSnapshot.exists) {
        return ResumeModel.fromFirestore(docSnapshot);
      } else {
        print("⚠️ Resume with ID $resumeId not found.");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching resume: $e");
      return null;
    }
  }

  Future<void> updateWorkSortOrder({
    required String userId,
    required String resumeId,
    required String workId,
    required int? newSortOrder,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('work_experiences')
        .doc(workId)
        .update({'sortOrder': newSortOrder});
  }

  Future<void> saveSummaryForResume({
    required String userId,
    required String resumeId,
    required SummeryModel summary,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .set({'summary': summary.toMap()}, SetOptions(merge: true));
  }

  Future<List<SectionModel>> getSections({
    required String userId,
    required String resumeId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('resumes')
          .doc(resumeId)
          .collection('sections')
          .get();
      return snapshot.docs
          .map((doc) => SectionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("❌ Error fetching sections: $e");
      return [];
    }
  }

  Future<void> saveSection(
      {required String userId,
      required String resumeId,
      required SectionModel section}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('sections')
        .doc(section.id)
        .set(section.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteSection(
      {required String userId,
      required String resumeId,
      required String sectionId}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('sections')
        .doc(sectionId)
        .delete();
  }

  Future<List<SectionModel>> getAllSections(
      {required String userId, required String resumeId}) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .collection('sections')
        .get();
    return snapshot.docs.map((doc) => SectionModel.fromFirestore(doc)).toList();
  }

//   Future<void> initializeDefaultSections({required String userId, required String resumeId}) async {
//     try {
//       final batch = _firestore.batch();
//       final sectionsCollection = _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('resumes')
//           .doc(resumeId)
//           .collection('sections');
//
//       for (final sectionName in defaultSectionNames) {
//         final section = SectionModel(id: sectionName, value: '', description: '');
//         final docRef = sectionsCollection.doc(section.id);
//         batch.set(docRef, section.toMap());
//       }
//
//       // Commit the batch to execute all operations at once.
//       await batch.commit();
//       print("✅ Default sections have been initialized in Firestore.");
//     } catch (e) {
//       print("❌ Error initializing default sections: $e");
//     }
//   }

  Future<void> saveCoverLetterForResume({
    required String userId,
    required String resumeId,
    required CoverLetterModel coverLetter,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .set({'coverLetter': coverLetter.toMap()}, SetOptions(merge: true));
  }

  Future<String?> uploadFile({
    required String userId,
    required String resumeId,
    required String filePath,
    required String storagePath,
  }) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref('$storagePath/$userId/$resumeId/signature.jpg');

      final uploadTask = await ref.putFile(file);

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print("✅ File uploaded successfully: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("❌ Error uploading file: $e");
      return null;
    }
  }

  Future<void> saveSignatureForResume({
    required String userId,
    required String resumeId,
    required String? signatureUrl,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .set({'signatureUrl': signatureUrl}, SetOptions(merge: true))
        .then((_) => print("✅ Signature URL saved successfully."))
        .catchError((error) => print("❌ Error saving signature URL: $error"));
  }

  Future<void> deleteFileFromStorage({
    required String userId,
    required String resumeId,
    required String storagePath,
  }) async {
    try {
      final ref = _storage.ref('$storagePath/$userId/$resumeId/signature.jpg');
      await ref.delete();
      print("✅ File deleted from Storage.");
    } catch (e) {
      if (e is FirebaseException && e.code != 'object-not-found') {
        print("❌ Error deleting file from Storage: $e");
      }
    }
  }

  Future<void> initializeDefaultSections(
      {required String userId, required String resumeId}) async {
    try {
      final batch = _firestore.batch();
      final sectionsCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('resumes')
          .doc(resumeId)
          .collection('sections');

      for (final sectionName in defaultSectionNames) {
        final section =
            SectionModel(id: sectionName, value: '', description: '');
        final docRef = sectionsCollection.doc(section.id);
        batch.set(docRef, section.toMap());
      }
      await batch.commit();
      print("✅ Default sections have been initialized in Firestore.");
    } catch (e) {
      print("❌ Error initializing default sections: $e");
    }
  }
}

const List<String> defaultSectionNames = [
  'Accomplishments',
  'Awards',
  'Films',
  'Hobbies',
  'Interests',
  'Languages',
  'Organizations',
  'Publications',
  'Professional Certifications',
  'Projects',
  'Radio',
  'References',
  'Skills',
  'Technical Skills',
  'Training',
  'Other',
];
