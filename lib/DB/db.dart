  import 'package:resume_builder/model/model.dart';
  import 'package:resume_builder/shared_preference/shared_preferences.dart';
  import 'package:sqflite/sqflite.dart';
  import 'package:path/path.dart';
  
  class AppConst {
    static const String userTable = "user";
    static const String uidColumn = "uid";
    static const String emailColumn = "email";
  
    static const String resumeTable = "resumes";
    static const String titleColumn = "title";
    static const String createdAtColumn = "created_at";
  
    static const String introTable = "intro";
    static const String fNameColumn = "firstName";
    static const String lNameColumn = "lastName";
    static const String imgPathColumn = "imagePath";
  
    static const String contactTable = "contacts";
    static const String emlColumn = "email";
    static const String phoneColumn = "phone";
    static const String smu1Column = "socialMediaUrl1";
    static const String smu2Column = "socialMediaUrl2";
    static const String pwColumn = "personnelWeb";
    static const String addr1Column = "addr1";
    static const String addr2Column = "addr2";
  
    static const String educationTable = "education";
    static const String schNameColumn = "schoolName";
    static const String fromColumn = "dateFrom";
    static const String toColumn = "dateTo";
    static const String presentColumn = "present";
  
    static const String workTable = "work";
    static const String nameColumn = "compName";
    static const String locColumn = "compLocation";
    static const String posColumn = "compPosition";
  
    static const String additionalTable = "additional";
    static const String sectionName = "section";
    static const String sectionValue = "value";
    static const String sectionDescription = "description";
  
    static const String summeryTable = "summary";
    static const String summeryColumn = "summery";
  
    static const String coverLetterTable = "coverLetter";
    static const String coverTextColumn = "text";
  
    static const String signTable = "signature";
    static const String signPathColumn = "signPath";
  
    static const String id = "id";
    static const String databaseName = 'resume_builder.db';
    static const String wid = "wid";
  }
  
  class DbHelper {
    static final DbHelper instance = DbHelper._init();
  
    DbHelper._init();
  
    Database? _database;
  
    Future<Database> get database async {
      if (_database != null) return _database!;
  
      _database = await _initDB(AppConst.databaseName);
      return _database!;
    }
  
    Future<Database> _initDB(String filePath) async {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
  
      return await openDatabase(path,
          version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
    }
  
    Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        try {
          await db.execute(
              'ALTER TABLE ${AppConst.workTable} ADD COLUMN sortOrder INTEGER');
        } catch (e) {
          print("sortOrder column may already exist: $e");
        }
  
        try {
          await db.execute(
              'ALTER TABLE ${AppConst.workTable} ADD COLUMN details TEXT');
        } catch (e) {
          print("details column may already exist: $e");
        }
        try {
          await db.execute(
              'ALTER TABLE ${AppConst.educationTable} ADD COLUMN sortOrder INTEGER');
        } catch (e) {
          print("sortOrder column for educationTable may already exist: $e");
        }
  
        try {
          await db.execute(
              'ALTER TABLE ${AppConst.workTable} ADD COLUMN userId TEXT');
        } catch (e) {
          print("userId column may already exist: $e");
        }
      }
    }
  
    Future<void> _deleteDB(Database db, int i, int? j) async {
      await db.execute("DROP DATABASE ${AppConst.databaseName}");
    }

    Future _createDB(Database db, int version) async {
      await db.execute('''
    CREATE TABLE IF NOT EXISTS ${AppConst.resumeTable} (
      ${AppConst.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${AppConst.uidColumn} TEXT,
      ${AppConst.titleColumn} TEXT,
      ${AppConst.createdAtColumn} TEXT
    )
  ''');
  
      await db.execute(
          '''create table IF NOT EXISTS ${AppConst.summeryTable} (${AppConst.id} integer primary key,
          ${AppConst.summeryColumn} text)''');
  
      await db.execute('''create table IF NOT EXISTS ${AppConst.userTable} (
          ${AppConst.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${AppConst.uidColumn} text,
          ${AppConst.emailColumn} text)
          ''');
      await db.execute(
          '''create table IF NOT EXISTS ${AppConst.coverLetterTable} (${AppConst
              .id} integer primary key,
          ${AppConst.coverTextColumn} text)''');
  
      await db.execute(
          '''create table IF NOT EXISTS ${AppConst.signTable} (${AppConst.id} integer primary key,
          ${AppConst.signPathColumn} text)''');
  
      await db.execute('''create table IF NOT EXISTS ${AppConst.workTable} (
        userId TEXT,
          ${AppConst.id} integer,
          wid INTEGER PRIMARY KEY AUTOINCREMENT,
          ${AppConst.nameColumn} text,
          ${AppConst.locColumn} text,
          ${AppConst.posColumn} text,
          ${AppConst.fromColumn} text,
          ${AppConst.toColumn} text,
          ${AppConst.presentColumn} boolean,
           sortOrder INTEGER,
    details TEXT)''');
      await db.execute('''create table IF NOT EXISTS ${AppConst.additionalTable} (
          ${AppConst.id} integer,
          ${AppConst.sectionName} text,
          ${AppConst.sectionValue} text,
          ${AppConst.sectionDescription} text,
           PRIMARY KEY (${AppConst.id}, ${AppConst.sectionName})
          )''');
      await db.execute('''create table IF NOT EXISTS ${AppConst.educationTable} (
          ${AppConst.id} integer,
          eid INTEGER PRIMARY KEY AUTOINCREMENT,
          ${AppConst.schNameColumn} text,
          ${AppConst.fromColumn} text,
          ${AppConst.toColumn} text,
          ${AppConst.presentColumn} boolean,
      sortOrder INTEGER)''');
      await db.execute(
          '''create table IF NOT EXISTS ${AppConst.contactTable} (${AppConst.id} integer primary key,
          ${AppConst.emlColumn} text,
          ${AppConst.phoneColumn} text,
          ${AppConst.smu1Column} text,
          ${AppConst.smu2Column} text,
          ${AppConst.pwColumn} text,
          ${AppConst.addr1Column} text,
          ${AppConst.addr2Column} text) ''');
      await db.execute(
          '''create table IF NOT EXISTS ${AppConst.introTable} (${AppConst.id} integer primary key,
          ${AppConst.fNameColumn} text,
          ${AppConst.lNameColumn} text,
          ${AppConst.imgPathColumn} text)''');
    }
  
    Future<List<ResumeModel>> getAllResume() async {
      try {
        final db = await database;
        final uid = await SharedPrefHelper.getUserUid();
        if (uid == null) {
          print("❌ No UID found in SharedPreferences.");
          return [];
        }
  
        final result = await db.query(
          AppConst.resumeTable,
          where: 'uid = ?',
          whereArgs: [uid],
        );
  
        if (result.isNotEmpty) {
          final resumes = result.map((map) => ResumeModel.fromJson(map)).toList();
          print("✅ Retrieved ${resumes.length} resumes for UID: $uid");
          return resumes;
        } else {
          print("⚠️ No resumes found for UID: $uid");
          return [];
        }
      } catch (e) {
        print("❌ Error fetching resumes: $e");
        return [];
      }
    }
  
    Future<List<IntroModel?>> getAllIntro() async {
      List<Map> result = [];
      List<IntroModel?> result1 = [];
      try {
        final db = await database;
        result = await db.query(
          AppConst.introTable,
        );
        if (result.isNotEmpty) {
          result1 = result.map((map) => IntroModel.fromMap(map)).toList();
          print("Info Retrieval Successful");
        } else {
          print("Failed to Retrieve All Resumes");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<List<EducationModel?>?> getAllEducations(String id) async {
      List<Map> result = [];
      List<EducationModel>? result1;
      try {
        final db = await database;
        result = await db.query(
          AppConst.educationTable,
          where: "${AppConst.id} = ?",
          whereArgs: [id],
          orderBy: 'sortOrder ASC',
        );
  
        if (result.isNotEmpty) {
          result1 = result.map((map) => EducationModel.fromJson(map)).toList();
          print("All Education Retrieval Successful");
          print("${result1[1].id}");
          return result1;
        } else {
          print("Failed to Retrieve Education");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<List<EducationModel?>> getAllEducation(
        EducationModel educationModel) async {
      List<Map> result = [];
      List<EducationModel> result1 = [];
      try {
        final db = await database;
        result = await db.query(AppConst.educationTable,
            where: "${AppConst.id} = ? AND eid = ?",
            whereArgs: [educationModel.id, educationModel.eid]);
        if (result.isNotEmpty) {
          result1 = result.map((map) => EducationModel.fromJson(map)).toList();
          print("All Education Retrieval Successful");
          print("${result1[1].id}");
          return result1;
        } else {
          print("Failed to Retrieve Education");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<List<WorkModel?>?> getAllWork(String userId, String resumeId) async {
      List<Map> result = [];
      List<WorkModel>? result1;
      try {
        final db = await database;
        result = await db.query(
          AppConst.workTable,
          where: "userId = ? AND id = ?",
          whereArgs: [userId, resumeId],
          orderBy: 'sortOrder ASC',
        );
        print("Raw result: $result");
        if (result.isNotEmpty) {
          result1 = result
              .map((map) => WorkModel.fromJson(Map<String, dynamic>.from(map)))
              .toList();          print("✅ WorkList Retrieval Successful");
          if (result1.isNotEmpty) {
            print("First Work ID: ${result1.first.wid}");
          }
          return result1;
        } else {
          print(
              "⚠️ No Work Records Found for userId: $userId and resumeId: $resumeId");
        }
      } catch (e) {
        print("🔥 getAllWork error: ${e.toString()}");
      }
      return result1;
    }
  
    Future<List<WorkModel?>> getAllWorks(WorkModel workModel) async {
      List<Map> result = [];
      List<WorkModel> result1 = [];
      try {
        final db = await database;
        result = await db.query(AppConst.workTable,
            where: "${AppConst.id} = ? AND wid = ?",
            whereArgs: [workModel.id, workModel.wid]);
        if (result.isNotEmpty) {
          result1 = result
              .map((map) => WorkModel.fromJson(Map<String, dynamic>.from(map)))
              .toList();
          print("All Education Retrieval Successful");
          print("${result1[1].id}");
          return result1;
        } else {
          print("Failed to Retrieve Education");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    // Future<List<SectionModel>?> getAllSections({required String? id}) async {
    //   List<Map<String, dynamic>> result = [];
    //   List<SectionModel>? result1;
    //   try {
    //     final db = await database;
    //     result = await db.query(AppConst.additionalTable,
    //         where: "${AppConst.id} = ?", whereArgs: [id]);
    //     if (result.isNotEmpty) {
    //       result1 = result.map((map) => SectionModel.fromJson(map)).toList();
    //       print("Sections Retrieval Successful");
    //       // Avoid printing result1[1].id directly if result1 c5ould have < 2 elements
    //       if (result1.isNotEmpty && result1.length > 1) {
    //         print("Second Section ID: ${result1[1].id}, Section Name: ${result1[1]
    //             .section}");
    //       } else if (result1.isNotEmpty) {
    //         print("First Section ID: ${result1.first.id}, Section Name: ${result1
    //             .first.section}");
    //       }
    //       return result1;
    //     } else {
    //       print("Failed to Retrieve Sections or no sections found for id: $id");
    //     }
    //   } catch (e) {
    //     print("Error retrieving sections: $e");
    //   }
    //   return result1;
    // }

    Future<List<SectionModel>?> getAllSections({required String? id}) async {
      List<Map<String, dynamic>> result = [];
      List<SectionModel>? result1;
      try {
        final db = await database;
        result = await db.query(AppConst.additionalTable,
            where: "${AppConst.id} = ?", whereArgs: [id]);
        if (result.isNotEmpty) {
          result1 = result.map((map) => SectionModel.fromJson(map)).toList();
          print("Sections Retrieval Successful");

          if (result1.isNotEmpty && result1.length > 1) {
            print("Second Section ID: ${result1[1].id}");
          } else if (result1.isNotEmpty) {
            print("First Section ID: ${result1.first.id}");
          }
          return result1;
        } else {
          print("Failed to Retrieve Sections or no sections found for id: $id");
        }
      } catch (e) {
        print("Error retrieving sections: $e");
      }
      return result1;
    }


    Future<ResumeModel?> getResume(String id) async {
      List<Map> result = [];
      late ResumeModel? result1 = null;
      try {
        final db = await database;
        result = await db.query(AppConst.resumeTable,
            where: "${AppConst.resumeTable}.${AppConst.id} = ?", whereArgs: [id]);
        if (result.isNotEmpty) {
          result1 = ResumeModel.fromJson(Map<String, dynamic>.from(result.first));
          print("Intro Retrieval Successful");
          print("${result1.id}");
          return result1;
        } else {
          print("Failed to Retrieve intro");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<IntroModel?> getIntro(String id) async {
      List<Map> result = [];
      late IntroModel? result1 = null;
      try {
        final db = await database;
        result = await db.query(AppConst.introTable,
            where: "${AppConst.introTable}.${AppConst.id} = ?", whereArgs: [id]);
        if (result.isNotEmpty) {
          result1 = IntroModel.fromMap(result.first);
          print("Intro Retrieval Successful");
          //print("${result1.id}");
          return result1;
        } else {
          print("Failed to Retrieve intro");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<ContactModel?> getContacts(String id) async {
      List<Map> result = [];
      late ContactModel? result1 = null;
      try {
        final db = await database;
        result = await db.query(AppConst.contactTable,
            where: "${AppConst.contactTable}.${AppConst.id} = ?",
            whereArgs: [id]);
        if (result.isNotEmpty) {
          result1 = ContactModel.fromMap(result.first);
          print("Contact Retrieval Successful");
         // print("${result1.id}");
        } else {
          print("Failed to Retrieve Contact");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<EducationModel?> getSingleEducation(String id, int eid) async {
      List<Map> result = [];
      EducationModel? result1 = null;
      try {
        final db = await database;
        result = await db.query(AppConst.educationTable,
            where: "${AppConst.id} = ? AND eid = ?", whereArgs: [id, eid]);
        if (result.isNotEmpty) {
          result1 = EducationModel.fromJson(result.first);
          print("Education Retrieval Successful");
          print("Education Map ${result.toString()}");
          print("${result1.id}");
        } else {
          print("Failed to Retrieve Education");
          print("Education Map ${result.toString()}");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<WorkModel?> getSingleWork(String id, int wid) async {
      List<Map> result = [];
      WorkModel? result1 = null;
      try {
        final db = await database;
        result = await db.query(AppConst.workTable,
            where: "${AppConst.id} = ? AND wid = ?", whereArgs: [id, wid]);
        if (result.isNotEmpty) {
          result1 = WorkModel.fromJson(Map<String, dynamic>.from(result.first));
          print("Education Retrieval Successful");
          print("Education Map ${result.toString()}");
          print("${result1.id}");
        } else {
          print("Failed to Retrieve Education");
          print("Education Map ${result.toString()}");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<WorkModel?> getWork(String id) async {
      List<Map> result = [];
      late WorkModel? result1 = null;
      try {
        final db = await database;
        result = await db.query(AppConst.workTable,
            where: "${AppConst.workTable}.${AppConst.id} = ?", whereArgs: [id]);
        if (result.isNotEmpty) {
          result1 = WorkModel.fromJson(Map<String, dynamic>.from(result.first));
          print("Education Retrieval Successful");
          print("${result1.id}");
        } else {
          print("Failed to Retrieve Education");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<SummeryModel?> getSummery(String id) async {
      List<Map> result = [];
      SummeryModel? result1;
      try {
        final db = await database;
        result = await db.query(AppConst.summeryTable,
            where: "${AppConst.id} = ?", whereArgs: [id]);
        if (result.isNotEmpty) {
          result1 = SummeryModel.fromJson(result.first);
          print("Education Retrieval Successful");
        } else {
          print("Failed to Retrieve Education");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<CoverLetterModel?> getCoverLetter(String id) async {
      List<Map> result = [];
      CoverLetterModel? result1;
      try {
        final db = await database;
        result = await db.query(AppConst.coverLetterTable,
            where: "${AppConst.id} = ?", whereArgs: [id]);
        if (result.isNotEmpty) {
          result1 = CoverLetterModel.fromJson(result.first);
          print("CoverLetter Retrieval Successful");
          print("${result1.id}");
        } else {
          print("Failed to Retrieve CoverLetter");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<SignModel?> getSign(String id) async {
      List<Map> result = [];
      SignModel? result1;
      try {
        final db = await database;
        result = await db.query(AppConst.signTable,
            where: "${AppConst.signTable}.${AppConst.id} = ?", whereArgs: [id]);
        if (result.isNotEmpty) {
          result1 = SignModel.fromJson(result.first);
          print("Education Retrieval Successful");
          print("${result1.id}");
        } else {
          print("Failed to Retrieve Education");
        }
      } catch (e) {
        print(e.toString());
      }
      return result1;
    }
  
    Future<int?> insertResumeAndReturnId(ResumeModel model) async {
      try {
        final db = await database;
        final uid = await SharedPrefHelper.getUserUid();
        if (uid == null) {
          print("❌ UID is null. Cannot save resume.");
          return null;
        }
  
        final data = model.toMap();
        data['uid'] = uid;
        data.remove('id'); // Let SQLite auto-generate ID
  
        final id = await db.insert(AppConst.resumeTable, data);
        print("✅ Resume inserted with ID: $id");
        return id;
      } catch (e) {
        print("❌ insertResumeAndReturnId error: $e");
        return null;
      }
    }
  
    Future<void> insertIntroText({required IntroModel introModel}) async {
      try {
        final db = await database;
        int result = await db.insert(AppConst.introTable, introModel.onlyText(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        if (result >= 0) { // insert can return 0, update returns rows affected.
          print("Intro Text Saved/Updated To The Table");
        } else {
          print("Failed to save/update Intro Text");
        }
      } catch (e) {
        print(e.toString());
      }
    }
    //
    // Future<void> insertIntroImg({required IntroModel introModel}) async {
    //   try {
    //     final db = await database;
    //     int result = await db.update( // Should be update, assuming entry exists
    //         AppConst.introTable, introModel.onlyImage(),
    //         where: '${AppConst.id} = ?',
    //         whereArgs: [introModel.id]);
    //     if (result > 0) {
    //       print("Intro Image Updated In The Table");
    //     } else {
    //       print("Failed to Update Intro Image (or no change)");
    //     }
    //   } catch (e) {
    //     print(e.toString());
    //   }
    // }
  
    Future<void> insertSign({required SignModel signModel}) async {
      try {
        final db = await database;
        int result = await db.insert(AppConst.signTable, signModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        if (result >= 0) {
          print("Sign path Saved/Updated To The Table");
        } else {
          print("Failed to save Sign Path");
        }
      } catch (e) {
        print(e.toString());
      }
    }
  
    Future<void> insertContact({required ContactModel contactModel}) async {
      try {
        final db = await database;
        int result = await db.insert(AppConst.contactTable, contactModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        if (result >= 0) {
          print("Contact Information Saved/Updated To The Table");
        } else {
          print("Failed to save Contact Information");
        }
      } catch (e) {
        print(e.toString());
      }
    }
  
    Future<void> insertEducation({required EducationModel educationModel}) async {
      try {
        final db = await database;
        int result = await db.insert(
            AppConst.educationTable, educationModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        if (result >= 0) {
          print("Education Entry Saved/Updated To The Table");
        } else {
          print("Failed to save Education Entry");
        }
      } catch (e) {
        print(e.toString());
      }
    }
  
    Future<Object?> insertWork({required WorkModel workModel}) async {
      try {
        final db = await database;
        final data = workModel.toMap();
  
        if (workModel.wid == null) {
          // Insert new
          data.remove('wid'); // Let SQLite autoincrement
          int newWid = await db.insert(
            AppConst.workTable,
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          print("✅ Work inserted with wid: $newWid");
          return newWid;
        } else {
          // Update existing
          int result = await db.update(
            AppConst.workTable,
            data,
            where: 'wid = ?',
            whereArgs: [workModel.wid],
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          print(result > 0 ? "✅ Work updated" : "❌ Update failed or no change");
          return workModel.wid;
        }
      } catch (e) {
        print("🔥 insertWork error: ${e.toString()}");
        return null;
      }
    }
  
    Future<void> insertSummery({required SummeryModel summeryModel}) async {
      try {
        final db = await database;
        int result = await db.insert(AppConst.summeryTable, summeryModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        if (result >= 0) {
          print("Summary Saved/Updated To The Table");
        } else {
          print("Failed to save Summary");
        }
      } catch (e) {
        print(e.toString());
      }
    }
  
    Future<void> insertCoverLetter(
        {required CoverLetterModel coverLetterModel}) async {
      try {
        final db = await database;
        int result = await db.insert(
            AppConst.coverLetterTable, coverLetterModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        if (result >= 0) {
          print("Cover Letter Saved/Updated To The Table");
        } else {
          print("Failed to save Cover Letter");
        }
      } catch (e) {
        print(e.toString());
      }
    }

    // Future<bool> createNewSection({required SectionModel section, bool isUpsertAttempt = false}) async {
    //   bool success = false;
    //   try {
    //     final db = await database;
    //     if (section.id == null || section.section == null || section.section!.isEmpty) {
    //       print("❌ Cannot create section: resume_id or section name is missing.");
    //       return false;
    //     }
    //
    //     Map<String, dynamic> sectionData = {
    //       AppConst.id: section.id,
    //       AppConst.sectionName: section.section,
    //       AppConst.sectionValue: section.value?.trim() ?? "",
    //       AppConst.sectionDescription: section.description?.trim() ?? ""
    //     };
    //
    //     int result = await db.insert(AppConst.additionalTable, sectionData,
    //         conflictAlgorithm: ConflictAlgorithm.ignore);
    //
    //     if (result > 0) {
    //       success = true;
    //       print("New Section ${section.section} (Resume ID: ${section.id}) Created/Inserted.");
    //     } else {
    //       if (isUpsertAttempt) {
    //         print("Section ${section.section} (Resume ID: ${section.id}) already existed. This is okay for upsert.");
    //         success = true;
    //       } else {
    //         print("Failed to Create New Section or Section already exists: ${section.section} (Resume ID: ${section.id})");
    //       }
    //     }
    //   } catch (e) {
    //     print("Error creating/inserting new section: $e");
    //   }
    //   return success;
    // }


    Future<bool> createNewSection({required SectionModel section, bool isUpsertAttempt = false}) async {
      bool success = false;
      try {
        final db = await database;
        if (section.resumeId == null || section.id.isEmpty) {
          print("❌ Cannot create section: resumeId or section name (id) is missing.");
          return false;
        }
        Map<String, dynamic> sectionData = {
          AppConst.id: section.resumeId,
          AppConst.sectionName: section.id,
          AppConst.sectionValue: section.value?.trim() ?? "",
          AppConst.sectionDescription: section.description?.trim() ?? ""
        };

        int result = await db.insert(AppConst.additionalTable, sectionData,
            conflictAlgorithm: ConflictAlgorithm.ignore);

        if (result > 0) {
          success = true;
          print("New Section '${section.id}' (Resume ID: ${section.resumeId}) Created/Inserted.");
        } else {
          if (isUpsertAttempt) {
            print("Section '${section.id}' (Resume ID: ${section.resumeId}) already existed. This is okay for upsert.");
            success = true;
          } else {
            print("Failed to Create New Section or Section already exists: '${section.id}' (Resume ID: ${section.resumeId})");
          }
        }
      } catch (e) {
        print("Error creating/inserting new section: $e");
      }
      return success;
    }

    // Future<bool> updateSectionDetails(
    //     {required SectionModel sectionModel, required String resumeId}) async {
    //   try {
    //     final db = await database;
    //
    //     if (sectionModel.section == null || sectionModel.section!.isEmpty) {
    //       print("❌ Cannot update section details: section name is missing.");
    //       return false;
    //     }
    //
    //     Map<String, dynamic> dataToUpdate = {
    //       AppConst.sectionValue: sectionModel.value?.trim() ?? "",
    //       AppConst.sectionDescription: sectionModel.description?.trim() ?? ""
    //     };
    //
    //     int result = await db.update(
    //         AppConst.additionalTable,
    //         dataToUpdate,
    //         where: '${AppConst.id} = ? AND ${AppConst.sectionName} = ?',
    //         whereArgs: [resumeId, sectionModel.section]);
    //
    //     if (result == 1) {
    //       print("✅ Details for '${sectionModel.section}' (Resume ID: $resumeId) updated successfully.");
    //       return true;
    //     } else {
    //       print("⚠️ Failed to update '${sectionModel.section}' (Resume ID: $resumeId). Rows affected: $result. Attempting insert.");
    //       SectionModel forInsert = SectionModel(
    //           id: resumeId,
    //           section: sectionModel.section,
    //           value: sectionModel.value?.trim() ?? "",
    //           description: sectionModel.description?.trim() ?? ""
    //       );
    //       return await createNewSection(section: forInsert, isUpsertAttempt: true);
    //     }
    //   } catch (e) {
    //     print("❌ Error updating details for '${sectionModel.section}': $e");
    //     return false;
    //   }
    // }

    Future<bool> updateSectionDetails({required SectionModel sectionModel, required String resumeId}) async {
      try {
        final db = await database;
        if (sectionModel.id.isEmpty) {
          print("❌ Cannot update section details: section name (id) is missing.");
          return false;
        }

        Map<String, dynamic> dataToUpdate = {
          AppConst.sectionValue: sectionModel.value?.trim() ?? "",
          AppConst.sectionDescription: sectionModel.description?.trim() ?? ""
        };

        int result = await db.update(
            AppConst.additionalTable,
            dataToUpdate,
            where: '${AppConst.id} = ? AND ${AppConst.sectionName} = ?',
            whereArgs: [resumeId, sectionModel.id]);

        if (result == 1) {
          print("✅ Details for '${sectionModel.id}' (Resume ID: $resumeId) updated successfully.");
          return true;
        } else {
          print("⚠️ Failed to update '${sectionModel.id}' (Resume ID: $resumeId). Rows affected: $result. Attempting insert.");

          SectionModel forInsert = SectionModel(
              id: sectionModel.id, // The section name
              resumeId: resumeId,    // The resume's ID
              value: sectionModel.value?.trim() ?? "",
              description: sectionModel.description?.trim() ?? ""
          );
          return await createNewSection(section: forInsert, isUpsertAttempt: true);
        }
      } catch (e) {
        print("❌ Error updating details for '${sectionModel.id}': $e");
        return false;
      }
    }
  
    // Future<void> removeResume({required String id}) async {
    //   try {
    //     final db = await database;
    //     await db.delete(AppConst.summeryTable, where: '${AppConst.id} = ?', whereArgs: [id]);
    //     await db.delete(AppConst.signTable, where: '${AppConst.id} = ?', whereArgs: [id]);
    //     await db.delete(AppConst.introTable, where: '${AppConst.id} = ?', whereArgs: [id]);
    //     await db.delete(AppConst.contactTable, where: '${AppConst.id} = ?', whereArgs: [id]);
    //     await db.delete(AppConst.educationTable, where: '${AppConst.id} = ?', whereArgs: [id]);
    //     await db.delete(AppConst.workTable, where: '${AppConst.id} = ?', whereArgs: [id]);
    //     await db.delete(AppConst.additionalTable, where: '${AppConst.id} = ?', whereArgs: [id]);
    //     await db.delete(AppConst.coverLetterTable, where: '${AppConst.id} = ?', whereArgs: [id]);
    //     int result = await db.delete(AppConst.resumeTable, where: '${AppConst.id} = ?', whereArgs: [id]);
    //
    //     if (result == 1) {
    //       print("Resume ID $id and all related data deleted successfully.");
    //     } else {
    //       print("Failed to delete resume ID $id (it might not have existed).");
    //     }
    //   } catch (e) {
    //     print(e.toString());
    //   }
    // }
    Future<void> removeResume({required String id}) async {
      try {
        final db = await database;
        await db.delete(AppConst.summeryTable, where: '${AppConst.id} = ?', whereArgs: [id]);
        await db.delete(AppConst.signTable, where: '${AppConst.id} = ?', whereArgs: [id]);
        await db.delete(AppConst.introTable, where: '${AppConst.id} = ?', whereArgs: [id]);
        await db.delete(AppConst.contactTable, where: '${AppConst.id} = ?', whereArgs: [id]);
        await db.delete(AppConst.educationTable, where: '${AppConst.id} = ?', whereArgs: [id]);
        await db.delete(AppConst.workTable, where: '${AppConst.id} = ?', whereArgs: [id]);
        await db.delete(AppConst.additionalTable, where: '${AppConst.id} = ?', whereArgs: [id]);
        await db.delete(AppConst.coverLetterTable, where: '${AppConst.id} = ?', whereArgs: [id]);
        int result = await db.delete(AppConst.resumeTable, where: '${AppConst.id} = ?', whereArgs: [id]);

        if (result == 1) {
          print("Resume ID $id and all related data deleted successfully.");
        } else {
          print("Failed to delete resume ID $id (it might not have existed).");
        }
      } catch (e) {
        print(e.toString());
      }
    }

    Future<void> removeSingleEducation({required String id, required String eid}) async {
      try {
        final db = await database;
        int result = await db.delete(AppConst.educationTable,
            where: '${AppConst.id} = ? AND eid = ?', whereArgs: [id, eid]);
  
        if (result == 1) {
          print("Education entry EID $eid deleted successfully.");
        } else {
          print("Failed to delete education entry EID $eid.");
        }
      } catch (e) {
        print(e.toString());
      }
    }
  
    Future<void> removeSingleWorkplace({required String userId, required String id, required String wid}) async {
      try {
        final db = await database;
        int result = await db.delete(
          AppConst.workTable,
          where: 'userId = ? AND id = ? AND wid = ?',
          whereArgs: [userId, id, wid],
        );
  
        if (result == 1) {
          print("Workplace WID $wid deleted successfully.");
        } else {
          print("⚠️ Failed to delete workplace WID: $wid.");
        }
      } catch (e) {
        print("🔥 removeSingleWorkplace error: ${e.toString()}");
      }
    }
  
    Future<void> removeUser({required UserModel userModel}) async {
      try {
        final db = await database;
        int result = await db.delete(AppConst.userTable,
            where: '${AppConst.uidColumn} = ? AND ${AppConst.emailColumn} = ?',
            whereArgs: [userModel.uid, userModel.email]);
  
        if (result == 1) {
          print("User ${userModel.email} deleted successfully.");
        } else {
          print("Failed to delete user ${userModel.email}.");
        }
      } catch (e) {
        print(e.toString());
      }
    }
  
    Future<void> removeSingleSection({required String? id, required String sectionName}) async {
      try {
        final db = await database;
        int result = await db.delete(AppConst.additionalTable,
            where: '${AppConst.id} = ? AND ${AppConst.sectionName} = ?',
            whereArgs: [id, sectionName]);
  
        if (result == 1) {
          print("Section '$sectionName' deleted successfully.");
        } else {
          print("Failed to delete section '$sectionName'.");
        }
      } catch (e) {
        print(e.toString());
      }
    }

    Future<void> deleteSign(String resumeId) async {
      try {
        final db = await database;
        int result = await db.delete(
          AppConst.signTable,
          where: '${AppConst.id} = ?',
          whereArgs: [resumeId],
        );

        if (result == 1) {
          print("✅ Signature for resume ID $resumeId deleted successfully.");
        } else {
          print("⚠️ Failed to delete signature for resume ID $resumeId (it might not have existed).");
        }
      } catch (e) {
        print("❌ Error deleting signature: $e");
      }
    }


    Future<int> updateWork({required WorkModel workModel}) async {
      final db = await database;
      final data = workModel.toMap();
      return await db.update(
        AppConst.workTable,
        data,
        where: 'wid = ?',
        whereArgs: [workModel.wid],
      );
    }
  
    Future<void> updateSortOrder(String userId, String id, String wid, String sortOrder) async {
      final db = await database;
      await db.update(
        AppConst.workTable,
        {'sortOrder': sortOrder},
        where: 'userId = ? AND id = ? AND wid = ?',
        whereArgs: [userId, id, wid],
      );
    }
  
    Future<int> updateEducation({required EducationModel educationModel}) async {
      final db = await database;
      return await db.update(
        AppConst.educationTable,
        educationModel.toMap(),
        where: 'eid = ?',
        whereArgs: [educationModel.eid],
      );
    }
  
    Future<void> updateEducationSortOrder(int eid, int newSortOrder) async {
      final db = await instance.database;
      await db.update(
        AppConst.educationTable,
        {'sortOrder': newSortOrder},
        where: 'eid = ?',
        whereArgs: [eid],
      );
    }
  
    Future<void> clearWorkTable() async {
      final db = await database;
      await db.delete(AppConst.workTable);
      print("🧹 Work table cleared.");
    }

  getAdditionalSections(String userId, String resumeId) {}
  }