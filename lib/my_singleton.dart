import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'model/model.dart';

class MySingleton {
  static UserModel? loggedInUser;
  static String? userId;
  static String? resumeId;
  static ResumeModel? resume;
  static int currentIndex = 0;
  static bool hasDetails = false;
  //static String? id;
  static String? eid;
  static String? wid;
  static int? initialEduPage;
  static int? initialWorkPage;
  static File? image;
  static late String imagePath;
  static bool skipBtnVisible = false;
  static bool isLogin = false;
  static bool hasAccount = false;

  static String delimeter = '@';

  static final GlobalKey<FormState> contactsFormKey = GlobalKey<FormState>();
  static final GlobalKey<FormState> workFormKey = GlobalKey<FormState>();
  static final GlobalKey<FormState> EducaionFormKey = GlobalKey<FormState>();


  static bool presentEdu = false;
  static bool presentWork = false;

  static TextEditingController companyNameController = TextEditingController();
  static TextEditingController companyLocController = TextEditingController();
  static TextEditingController companyPosController = TextEditingController();
  static TextEditingController companyPosFromController =
      TextEditingController();
  static TextEditingController companyPosUntilController =
      TextEditingController();
  //static TextEditingController firstNameController = TextEditingController();
  //static TextEditingController lastNameController = TextEditingController();
  // static TextEditingController emailController = TextEditingController();
  // static TextEditingController phoneController = TextEditingController();
  // static TextEditingController socialMedia1Controller = TextEditingController();
  // static TextEditingController socialMedia2Controller = TextEditingController();
  // static TextEditingController personnelWebController = TextEditingController();
  // static TextEditingController addr1Controller = TextEditingController();
  // static TextEditingController addr2Controller = TextEditingController();
  static TextEditingController schoolNameController = TextEditingController();
  static TextEditingController schoolFromController = TextEditingController();
  static TextEditingController schoolToController = TextEditingController();
  static TextEditingController summeryController = TextEditingController();
  static TextEditingController newSectionController = TextEditingController();
  static TextEditingController newSection2Controller = TextEditingController();
  static TextEditingController coverLetterController = TextEditingController();
  static List<SectionModel> additionDetails = [];
  // static TextEditingController addSectionDetController1 = TextEditingController();
  // static TextEditingController addSectionDetController2 = TextEditingController();
  // static TextEditingController addSectionDetController3 = TextEditingController();
  // static TextEditingController addSectionDetController4 = TextEditingController();
  static TextEditingController companyWorkDetailsController =
      TextEditingController();

  static StreamController<List<EducationModel?>?> eduStreamcontroller =
      StreamController<List<EducationModel?>?>.broadcast();
  static StreamController<List<WorkModel?>?> workStreamController =
      StreamController<List<WorkModel?>?>.broadcast();
}
