
import 'package:resume_builder/cover_letter_templates/c2.dart';

import '../../cover_letter_templates/c1.dart';
import '../../cover_letter_templates/c3.dart';
import '../../cover_letter_templates/c4.dart';
import '../../cover_letter_templates/c5.dart';
import '../../cover_letter_templates/c6.dart';
import '../../model/resume_theme_model.dart';
import '../resources/pdf_theme_manager.dart';
import '../../firestore/user_firestore.dart';
import '../../model/model.dart';
import '../../my_singleton.dart';

class CreateCoverLetter{
  final FireUser _fireUser = FireUser();

  /// Fetches resume data from Firestore
  Future<ResumeModel?> _fetchResumeData() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    
    if (userId == null || resumeId == null) {
      print("❌ User ID or Resume ID is null");
      return null;
    }

    try {
      final resume = await _fireUser.getResume(userId: userId, resumeId: resumeId);
      if (resume == null) {
        print("❌ Resume not found in Firestore");
        return null;
      }
      print("✅ Resume data fetched successfully");
      return resume;
    } catch (e) {
      print("❌ Error fetching resume data: $e");
      return null;
    }
  }

  Future<void> coverLetter1Theme1() async {//Cover Letter 1 Theme 1
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL1Theme1 cl1theme1 = CL1Theme1();
    CL1ThemeModel cl1themeModel = await cl1theme1.getModel().then((value) => cl1theme1.cl1themeModel);
    CoverLetter1 template1 = CoverLetter1(
      coverLetterModel: cl1themeModel,
      resumeData: resume,
    );
    await template1.getFonts();
    await template1.createPage();
  }
  Future<void> coverLetter1Theme2() async {//Cover Letter 1 Theme 2
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL1Theme2 cl1theme2 = CL1Theme2();
    CL1ThemeModel cl1themeModel = await cl1theme2.getModel().then((value) => cl1theme2.cl1themeModel);
    CoverLetter1 template1 = CoverLetter1(
      coverLetterModel: cl1themeModel,
      resumeData: resume,
    );
    await template1.getFonts();
    await template1.createPage();
  }
  Future<void> coverLetter1Theme3() async {//Cover Letter 1 Theme 3
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL1Theme3 cl1theme3 = CL1Theme3();
    CL1ThemeModel cl1themeModel = await cl1theme3.getModel().then((value) => cl1theme3.cl1themeModel);
    CoverLetter1 template1 = CoverLetter1(
      coverLetterModel: cl1themeModel,
      resumeData: resume,
    );
    await template1.getFonts();
    await template1.createPage();
  }


  Future<void> coverLetter2Theme1() async {//Cover Letter 2 Theme 1
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL2Theme1 cl2theme1 = CL2Theme1();
    CL2ThemeModel cl2themeModel = await cl2theme1.getModel().then((value) => cl2theme1.cl2themeModel);
    CoverLetter2 template2 = CoverLetter2(
      cl2themeModel: cl2themeModel,
      resumeData: resume,
    );
    await template2.getFonts();
    await template2.createPage();
  }

  Future<void> coverLetter2Theme2() async {//Cover Letter 2 Theme 2
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL2Theme2 cl2theme2 = CL2Theme2();
    CL2ThemeModel cl2themeModel = await cl2theme2.getModel().then((value) => cl2theme2.cl2themeModel);
    CoverLetter2 template2 = CoverLetter2(
      cl2themeModel: cl2themeModel,
      resumeData: resume,
    );
    await template2.getFonts();
    await template2.createPage();
  }

  Future<void> coverLetter2Theme3() async {//Cover Letter 2 Theme 3
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL2Theme3 cl2theme3 = CL2Theme3();
    CL2ThemeModel cl2themeModel = await cl2theme3.getModel().then((value) => cl2theme3.cl2themeModel);
    CoverLetter2 template2 = CoverLetter2(
      cl2themeModel: cl2themeModel,
      resumeData: resume,
    );
    await template2.getFonts();
    await template2.createPage();
  }

  Future<void> coverLetter3Theme1() async {//Cover Letter 3 Theme 1
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL3Theme1 cl3theme1 = CL3Theme1();
    CL3ThemeModel cl3themeModel = await cl3theme1.getModel().then((value) => cl3theme1.cl3themeModel);
    CoverLetter3 template3 = CoverLetter3(
      cl3themeModel: cl3themeModel,
      resumeData: resume,
    );
    await template3.getFonts();
    await template3.createPage();
  }

  Future<void> coverLetter3Theme2() async {//Cover Letter 3 Theme 2
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL3Theme2 cl3theme2 = CL3Theme2();
    CL3ThemeModel cl3themeModel = await cl3theme2.getModel().then((value) => cl3theme2.cl3themeModel);
    CoverLetter3 template3 = CoverLetter3(
      cl3themeModel: cl3themeModel,
      resumeData: resume,
    );
    await template3.getFonts();
    await template3.createPage();
  }

  Future<void> coverLetter3Theme3() async {//Cover Letter 3 Theme 3
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL3Theme3 cl3theme3 = CL3Theme3();
    CL3ThemeModel cl3themeModel = await cl3theme3.getModel().then((value) => cl3theme3.cl3themeModel);
    CoverLetter3 template3 = CoverLetter3(
      cl3themeModel: cl3themeModel,
      resumeData: resume,
    );
    await template3.getFonts();
    await template3.createPage();
  }

  Future<void> coverLetter4Theme1() async {//Cover Letter 4 Theme 1
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL4Theme1 cl4theme1 = CL4Theme1();
    CL4ThemeModel cl4themeModel = await cl4theme1.getModel().then((value) => cl4theme1.cl4themeModel);
    CoverLetter4 template4 = CoverLetter4(
      cl4themeModel: cl4themeModel,
      resumeData: resume,
    );
    await template4.getFonts();
    await template4.createPage();
  }

  Future<void> coverLetter4Theme2() async {//Cover Letter 4 Theme 2
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL4Theme2 cl4theme2 = CL4Theme2();
    CL4ThemeModel cl4themeModel = await cl4theme2.getModel().then((value) => cl4theme2.cl4themeModel);
    CoverLetter4 template4 = CoverLetter4(
      cl4themeModel: cl4themeModel,
      resumeData: resume,
    );
    await template4.getFonts();
    await template4.createPage();
  }

  Future<void> coverLetter4Theme3() async {//Cover Letter 4 Theme 3
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL4Theme3 cl4theme3 = CL4Theme3();
    CL4ThemeModel cl4themeModel = await cl4theme3.getModel().then((value) => cl4theme3.cl4themeModel);
    CoverLetter4 template4 = CoverLetter4(
      cl4themeModel: cl4themeModel,
      resumeData: resume,
    );
    await template4.getFonts();
    await template4.createPage();
  }

  Future<void> coverLetter5Theme1() async {//Cover Letter 5 Theme 1
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL5Theme1 cl5theme1 = CL5Theme1();
    CL5ThemeModel cl5themeModel = await cl5theme1.getModel().then((value) => cl5theme1.cl5themeModel);
    CoverLetter5 template5 = CoverLetter5(
      cl5themeModel: cl5themeModel,
      resumeData: resume,
    );
    await template5.getFonts();
    await template5.createPage();
  }

  Future<void> coverLetter5Theme2() async {//Cover Letter 5 Theme 2
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL5Theme2 cl5theme2 = CL5Theme2();
    CL5ThemeModel cl5themeModel = await cl5theme2.getModel().then((value) => cl5theme2.cl5themeModel);
    CoverLetter5 template5 = CoverLetter5(
      cl5themeModel: cl5themeModel,
      resumeData: resume,
    );
    await template5.getFonts();
    await template5.createPage();
  }

  Future<void> coverLetter5Theme3() async {//Cover Letter 5 Theme 3
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL5Theme3 cl5theme3 = CL5Theme3();
    CL5ThemeModel cl5themeModel = await cl5theme3.getModel().then((value) => cl5theme3.cl5themeModel);
    CoverLetter5 template5 = CoverLetter5(
      cl5themeModel: cl5themeModel,
      resumeData: resume,
    );
    await template5.getFonts();
    await template5.createPage();
  }

  Future<void> coverLetter5Theme4() async {//Cover Letter 5 Theme 4
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL5Theme4 cl5theme4 = CL5Theme4();
    CL5ThemeModel cl5themeModel = await cl5theme4.getModel().then((value) => cl5theme4.cl5themeModel);
    CoverLetter5 template5 = CoverLetter5(
      cl5themeModel: cl5themeModel,
      resumeData: resume,
    );
    await template5.getFonts();
    await template5.createPage();
  }

  Future<void> coverLetter6Theme1() async {//Cover Letter 6 Theme 1
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL6Theme1 cl6theme1 = CL6Theme1();
    CL6ThemeModel cl6themeModel = await cl6theme1.getModel().then((value) => cl6theme1.cl6themeModel);
    CoverLetter6 template6 = CoverLetter6(
      cl6themeModel: cl6themeModel,
      resumeData: resume,
    );
    await template6.getFonts();
    await template6.createPage();
  }

  Future<void> coverLetter6Theme2() async {//Cover Letter 6 Theme 2
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL6Theme2 cl6theme2 = CL6Theme2();
    CL6ThemeModel cl6themeModel = await cl6theme2.getModel().then((value) => cl6theme2.cl6themeModel);
    CoverLetter6 template6 = CoverLetter6(
      cl6themeModel: cl6themeModel,
      resumeData: resume,
    );
    await template6.getFonts();
    await template6.createPage();
  }

  Future<void> coverLetter6Theme3() async {//Cover Letter 6 Theme 3
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL6Theme3 cl6theme3 = CL6Theme3();
    CL6ThemeModel cl6themeModel = await cl6theme3.getModel().then((value) => cl6theme3.cl6themeModel);
    CoverLetter6 template6 = CoverLetter6(
      cl6themeModel: cl6themeModel,
      resumeData: resume,
    );
    await template6.getFonts();
    await template6.createPage();
  }

  Future<void> coverLetter6Theme4() async {//Cover Letter 6 Theme 4
    final resume = await _fetchResumeData();
    if (resume == null) return;

    CL6Theme4 cl6theme4 = CL6Theme4();
    CL6ThemeModel cl6themeModel = await cl6theme4.getModel().then((value) => cl6theme4.cl6themeModel);
    CoverLetter6 template6 = CoverLetter6(
      cl6themeModel: cl6themeModel,
      resumeData: resume,
    );
    await template6.getFonts();
    await template6.createPage();
  }
  // Future<void> resume1Theme3() async {
  //   //For Resume
  //   Resume1Theme3 resume1theme3=Resume1Theme3();
  //   Resume1ThemeModel resume1themeModelInit = await resume1theme3.getModel().then((value) => resume1theme3.resume1theme1dec);
  //   //For Cover Letter
  //   CL1Theme3 cl1theme1 = CL1Theme3();
  //   CL1ThemeModel cl1themeModel = await cl1theme1.getModel().then((value) => cl1theme1.cl1themeModel);
  //   Template1 template1 = Template1(resume1theme: resume1themeModelInit,cl1themeModel: cl1themeModel);
  //   template1.getImage().then((value) => template1.createPage());
  // }
  //
  // Future<void> resume2Theme1() async {
  //   Resume2Theme1 resume2theme1=Resume2Theme1();
  //   Resume2ThemeModel resume2themeModelInit = await resume2theme1.getModel().then((value) => resume2theme1.resume2theme1);
  //   //For Cover Letter
  //   CL2Theme1 cl2theme1 = CL2Theme1();
  //   CL2ThemeModel cl2themeModel = await cl2theme1.getModel().then((value) => cl2theme1.cl2themeModel);
  //
  //   Template2 template2 = Template2(resume2themeModel: resume2themeModelInit,cl2themeModel: cl2themeModel);
  //   template2.getAssets().then((value) => template2.createPage());
  // }
  //
  // Future<void> resume2Theme2() async {
  //   Resume2Theme2 resume2theme1=Resume2Theme2();
  //   Resume2ThemeModel resume2themeModelInit = await resume2theme1.getModel().then((value) => resume2theme1.resume2theme1);
  //   //For Cover Letter
  //   CL2Theme2 cl2theme1 = CL2Theme2();
  //   CL2ThemeModel cl2themeModel = await cl2theme1.getModel().then((value) => cl2theme1.cl2themeModel);
  //
  //   Template2 template2 = Template2(resume2themeModel: resume2themeModelInit,cl2themeModel: cl2themeModel);
  //   template2.getAssets().then((value) => template2.createPage());
  // }
  //
  // Future<void> resume2Theme3() async {
  //   Resume2Theme3 resume2theme1=Resume2Theme3();
  //   Resume2ThemeModel resume2themeModelInit = await resume2theme1.getModel().then((value) => resume2theme1.resume2theme1);
  //   //For Cover Letter
  //   CL2Theme3 cl2theme3 = CL2Theme3();
  //   CL2ThemeModel cl2themeModel = await cl2theme3.getModel().then((value) => cl2theme3.cl2themeModel);
  //
  //   Template2 template2 = Template2(resume2themeModel: resume2themeModelInit,cl2themeModel: cl2themeModel);
  //   template2.getAssets().then((value) => template2.createPage());
  // }
  //
  // Future<void> resume3Theme1() async {
  //   Resume3Theme1 resume3theme1=Resume3Theme1();
  //   Resume3ThemeModel resume3themeModelInit = await resume3theme1.getModel().then((value) => resume3theme1.resume2theme1);
  //   //For Cover Letter
  //   CL3Theme1 cl3theme1 = CL3Theme1();
  //   CL3ThemeModel cl3themeModel = await cl3theme1.getModel().then((value) => cl3theme1.cl3themeModel);
  //
  //   Template3 template3 = Template3(resume3themeModel: resume3themeModelInit,cl3themeModel: cl3themeModel);
  //   template3.getImage().then((value) => template3.createPage());
  // }
  //
  // Future<void> resume3Theme2() async {
  //   Resume3Theme2 resume3theme1=Resume3Theme2();
  //   Resume3ThemeModel resume3themeModelInit = await resume3theme1.getModel().then((value) => resume3theme1.resume2theme1);
  //   //For Cover Letter
  //   CL3Theme2 cl3theme1 = CL3Theme2();
  //   CL3ThemeModel cl3themeModel = await cl3theme1.getModel().then((value) => cl3theme1.cl3themeModel);
  //
  //   Template3 template3 = Template3(resume3themeModel: resume3themeModelInit,cl3themeModel: cl3themeModel);
  //   template3.getImage().then((value) => template3.createPage());
  // }
  //
  // Future<void> resume3Theme3() async {
  //   Resume3Theme3 resume3theme1=Resume3Theme3();
  //   Resume3ThemeModel resume3themeModelInit = await resume3theme1.getModel().then((value) => resume3theme1.resume2theme1);
  //   //For Cover Letter
  //   CL3Theme3 cl3theme3 = CL3Theme3();
  //   CL3ThemeModel cl3themeModel = await cl3theme3.getModel().then((value) => cl3theme3.cl3themeModel);
  //
  //   Template3 template3 = Template3(resume3themeModel: resume3themeModelInit,cl3themeModel: cl3themeModel);
  //   template3.getImage().then((value) => template3.createPage());
  // }
  //
  // Future<void> resume4Theme1() async {
  //   Resume4Theme1 resume4theme1=Resume4Theme1();
  //   Resume4ThemeModel resume4themeModelInit = await resume4theme1.getModel().then((value) => resume4theme1.resume2theme1);
  //   //For Cover Letter
  //   CL4Theme1 cl4theme1 = CL4Theme1();
  //   CL4ThemeModel cl4themeModel = await cl4theme1.getModel().then((value) => cl4theme1.cl4themeModel);
  //
  //   Template4 template4 = Template4(resume4themeModel: resume4themeModelInit,cl4themeModel: cl4themeModel);
  //   template4.getImage().then((value) => template4.createPage());
  // }
  // Future<void> resume4Theme2() async {
  //   Resume4Theme2 resume4theme1=Resume4Theme2();
  //   Resume4ThemeModel resume4themeModelInit = await resume4theme1.getModel().then((value) => resume4theme1.resume2theme1);
  //   //For Cover Letter
  //   CL4Theme2 cl4theme1 = CL4Theme2();
  //   CL4ThemeModel cl4themeModel = await cl4theme1.getModel().then((value) => cl4theme1.cl4themeModel);
  //
  //   Template4 template4 = Template4(resume4themeModel: resume4themeModelInit,cl4themeModel: cl4themeModel);
  //   template4.getImage().then((value) => template4.createPage());
  // }
  // Future<void> resume4Theme3() async {
  //   Resume4Theme3 resume4theme1=Resume4Theme3();
  //   Resume4ThemeModel resume4themeModelInit = await resume4theme1.getModel().then((value) => resume4theme1.resume2theme1);
  //   //For Cover Letter
  //   CL4Theme3 cl4theme1 = CL4Theme3();
  //   CL4ThemeModel cl4themeModel = await cl4theme1.getModel().then((value) => cl4theme1.cl4themeModel);
  //
  //   Template4 template4 = Template4(resume4themeModel: resume4themeModelInit,cl4themeModel: cl4themeModel);
  //   template4.getImage().then((value) => template4.createPage());
  // }
  // Future<void> resume5Theme1() async {
  //   Resume5Theme1 resume5theme1=Resume5Theme1();
  //   Resume5ThemeModel resume5themeModelInit = await resume5theme1.getModel().then((value) => resume5theme1.resume2theme1);
  //   //For Cover Letter
  //   CL5Theme1 cl5theme1 = CL5Theme1();
  //   CL5ThemeModel cl5themeModel = await cl5theme1.getModel().then((value) => cl5theme1.cl5themeModel);
  //
  //   Template5 template5 = Template5(resume5themeModel: resume5themeModelInit,cl5themeModel: cl5themeModel);
  //   template5.getImage().then((value) => template5.createPage());
  // }
  // Future<void> resume5Theme2() async {
  //   Resume5Theme2 resume5theme1=Resume5Theme2();
  //   Resume5ThemeModel resume5themeModelInit = await resume5theme1.getModel().then((value) => resume5theme1.resume2theme1);
  //   //For Cover Letter
  //   CL5Theme2 cl5theme2 = CL5Theme2();
  //   CL5ThemeModel cl5themeModel = await cl5theme2.getModel().then((value) => cl5theme2.cl5themeModel);
  //
  //   Template5 template5 = Template5(resume5themeModel: resume5themeModelInit,cl5themeModel: cl5themeModel);
  //   template5.getImage().then((value) => template5.createPage());
  // }
  //
  // Future<void> resume5Theme3() async {
  //   Resume5Theme3 resume5theme1=Resume5Theme3();
  //   Resume5ThemeModel resume5themeModelInit = await resume5theme1.getModel().then((value) => resume5theme1.resume2theme1);
  //   //For Cover Letter
  //   CL5Theme3 cl5theme3 = CL5Theme3();
  //   CL5ThemeModel cl5themeModel = await cl5theme3.getModel().then((value) => cl5theme3.cl5themeModel);
  //
  //   Template5 template5 = Template5(resume5themeModel: resume5themeModelInit,cl5themeModel: cl5themeModel);
  //   template5.getImage().then((value) => template5.createPage());
  // }
  //
  // Future<void> resume5Theme4() async {
  //   Resume5Theme4 resume5theme1=Resume5Theme4();
  //   Resume5ThemeModel resume5themeModelInit = await resume5theme1.getModel().then((value) => resume5theme1.resume2theme1);
  //   //For Cover Letter
  //   CL5Theme4 cl5theme4 = CL5Theme4();
  //   CL5ThemeModel cl5themeModel = await cl5theme4.getModel().then((value) => cl5theme4.cl5themeModel);
  //
  //   Template5 template5 = Template5(resume5themeModel: resume5themeModelInit,cl5themeModel: cl5themeModel);
  //   template5.getImage().then((value) => template5.createPage());
  // }
  // Future<void> resume6Theme1() async {
  //   Resume6Theme1 resume6theme1=Resume6Theme1();
  //   Resume6ThemeModel resume6themeModelInit = await resume6theme1.getModel().then((value) => resume6theme1.resume2theme1);
  //   //For Cover Letter
  //   CL6Theme1 cl6theme1 = CL6Theme1();
  //   CL6ThemeModel cl6themeModel = await cl6theme1.getModel().then((value) => cl6theme1.cl6themeModel);
  //
  //   Template6 template6 = Template6(resume6themeModel: resume6themeModelInit,cl6themeModel: cl6themeModel);
  //   template6.getImage().then((value) => template6.createPage());
  // }
  //
  // Future<void> resume6Theme2() async {
  //   Resume6Theme2 resume6theme1=Resume6Theme2();
  //   Resume6ThemeModel resume6themeModelInit = await resume6theme1.getModel().then((value) => resume6theme1.resume2theme1);
  //   //For Cover Letter
  //   CL6Theme2 cl6theme1 = CL6Theme2();
  //   CL6ThemeModel cl6themeModel = await cl6theme1.getModel().then((value) => cl6theme1.cl6themeModel);
  //
  //   Template6 template6 = Template6(resume6themeModel: resume6themeModelInit,cl6themeModel: cl6themeModel);
  //   template6.getImage().then((value) => template6.createPage());
  // }
  // Future<void> resume6Theme3() async {
  //   Resume6Theme3 resume6theme1=Resume6Theme3();
  //   Resume6ThemeModel resume6themeModelInit = await resume6theme1.getModel().then((value) => resume6theme1.resume2theme1);
  //   //For Cover Letter
  //   CL6Theme3 cl6theme1 = CL6Theme3();
  //   CL6ThemeModel cl6themeModel = await cl6theme1.getModel().then((value) => cl6theme1.cl6themeModel);
  //
  //   Template6 template6 = Template6(resume6themeModel: resume6themeModelInit,cl6themeModel: cl6themeModel);
  //   template6.getImage().then((value) => template6.createPage());
  // }
  //
  // Future<void> resume6Theme4() async {
  //   Resume6Theme4 resume6theme1=Resume6Theme4();
  //   Resume6ThemeModel resume6themeModelInit = await resume6theme1.getModel().then((value) => resume6theme1.resume2theme1);
  //   //For Cover Letter
  //   CL6Theme4 cl6theme1 = CL6Theme4();
  //   CL6ThemeModel cl6themeModel = await cl6theme1.getModel().then((value) => cl6theme1.cl6themeModel);
  //
  //   Template6 template6 = Template6(resume6themeModel: resume6themeModelInit,cl6themeModel: cl6themeModel);
  //   template6.getImage().then((value) => template6.createPage());
  // }
}