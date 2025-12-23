// FIX: Removed redundant import. Only one is needed.
import 'package:resume_builder/resume_templates/t17.dart';
import 'package:resume_builder/resume_templates/t18.dart';
import 'package:resume_builder/resume_templates/t19.dart';
import 'package:resume_builder/resume_templates/t20.dart';
import 'package:resume_builder/resume_templates/t21.dart';
import 'package:resume_builder/resume_templates/t8.dart';

import '../../resume_templates/t1.dart';
import '../../resume_templates/t10.dart';
import '../../resume_templates/t11.dart';
import '../../resume_templates/t12.dart';
import '../../resume_templates/t13.dart';
import '../../resume_templates/t14.dart';
import '../../resume_templates/t15.dart';
import '../../resume_templates/t16.dart';
import '../../resume_templates/t2.dart';
import '../../resume_templates/t3.dart';
import '../../resume_templates/t4.dart';
import '../../resume_templates/t5.dart' as t5template;
import '../../resume_templates/t6.dart';
import '../../resume_templates/t7.dart';
import '../../resume_templates/t9.dart';
import '../resources/pdf_theme_manager.dart';

class CreatePDF {
  Future<void> resume1Theme1() async {
    Resume1Theme1 resumeTheme = Resume1Theme1();
    await resumeTheme.getModel();
    CL1Theme1 clTheme = CL1Theme1();
    await clTheme.getModel();

    Template1 template1 = Template1(
        resume1theme: resumeTheme.resume1theme1dec,
        cl1themeModel: clTheme.cl1themeModel);
    await template1.createPage();
  }

  Future<void> resume1Theme2() async {
    Resume1Theme2 resumeTheme = Resume1Theme2();
    await resumeTheme.getModel();
    CL1Theme2 clTheme = CL1Theme2();
    await clTheme.getModel();

    Template1 template1 = Template1(
        resume1theme: resumeTheme.resume1theme1dec,
        cl1themeModel: clTheme.cl1themeModel);
    await template1.createPage();
  }

  Future<void> resume1Theme3() async {
    Resume1Theme3 resumeTheme = Resume1Theme3();
    await resumeTheme.getModel();
    CL1Theme3 clTheme = CL1Theme3();
    await clTheme.getModel();

    Template1 template1 = Template1(
        resume1theme: resumeTheme.resume1theme1dec,
        cl1themeModel: clTheme.cl1themeModel);
    await template1.createPage();
  }

  Future<void> resume2Theme1() async {
    Resume2Theme1 resumeTheme = Resume2Theme1();
    await resumeTheme.getModel();
    CL2Theme1 clTheme = CL2Theme1();
    await clTheme.getModel();

    Template2 template2 = Template2(
        resume2theme: resumeTheme.resume2theme1,
        cl2themeModel: clTheme.cl2themeModel);

    await template2.createPage();
  }

  Future<void> resume2Theme2() async {
    Resume2Theme2 resumeTheme = Resume2Theme2();
    await resumeTheme.getModel();
    CL2Theme2 clTheme = CL2Theme2();
    await clTheme.getModel();

    Template2 template2 = Template2(
        resume2theme: resumeTheme.resume2theme2,
        cl2themeModel: clTheme.cl2themeModel);
    await template2.createPage();
  }

  Future<void> resume2Theme3() async {
    Resume2Theme3 resumeTheme = Resume2Theme3();
    await resumeTheme.getModel();
    CL2Theme3 clTheme = CL2Theme3();
    await clTheme.getModel();

    Template2 template2 = Template2(
        resume2theme: resumeTheme.resume2theme3,
        cl2themeModel: clTheme.cl2themeModel);
    await template2.createPage();
  }

  // FIX: Corrected all property access errors below (e.g., .resume2theme1 -> .resume3theme1)
  Future<void> resume3Theme1() async {
    Resume3Theme1 resumeTheme = Resume3Theme1();
    await resumeTheme.getModel();
    CL3Theme1 clTheme = CL3Theme1();
    await clTheme.getModel();

    Template3 template3 = Template3(
        resume3themeModel: resumeTheme.resume3theme1,
        cl3themeModel: clTheme.cl3themeModel);
    await template3.createPage();
  }

  Future<void> resume3Theme2() async {
    Resume3Theme2 resumeTheme = Resume3Theme2();
    await resumeTheme.getModel();
    CL3Theme2 clTheme = CL3Theme2();
    await clTheme.getModel();

    Template3 template3 = Template3(
        resume3themeModel: resumeTheme.resume3theme2,
        cl3themeModel: clTheme.cl3themeModel);
    await template3.createPage();
  }

  Future<void> resume3Theme3() async {
    Resume3Theme3 resumeTheme = Resume3Theme3();
    await resumeTheme.getModel();
    CL3Theme3 clTheme = CL3Theme3();
    await clTheme.getModel();

    Template3 template3 = Template3(
        resume3themeModel: resumeTheme.resume3theme3,
        cl3themeModel: clTheme.cl3themeModel);
    await template3.createPage();
  }

  Future<void> resume4Theme1() async {
    Resume4Theme1 resumeTheme = Resume4Theme1();
    await resumeTheme.getModel();
    CL4Theme1 clTheme = CL4Theme1();
    await clTheme.getModel();

    Template4 template4 = Template4(
        resume4themeModel: resumeTheme.resume4theme1,
        cl4themeModel: clTheme.cl4themeModel);
    await template4.createPage();
  }

  Future<void> resume4Theme2() async {
    Resume4Theme2 resumeTheme = Resume4Theme2();
    await resumeTheme.getModel();
    CL4Theme2 clTheme = CL4Theme2();
    await clTheme.getModel();

    Template4 template4 = Template4(
        resume4themeModel: resumeTheme.resume4theme2,
        cl4themeModel: clTheme.cl4themeModel);
    await template4.createPage();
  }

  Future<void> resume4Theme3() async {
    Resume4Theme3 resumeTheme = Resume4Theme3();
    await resumeTheme.getModel();
    CL4Theme3 clTheme = CL4Theme3();
    await clTheme.getModel();

    Template4 template4 = Template4(
        resume4themeModel: resumeTheme.resume4theme3,
        cl4themeModel: clTheme.cl4themeModel);
    await template4.createPage();
  }

  Future<void> resume5Theme1() async {
    Resume5Theme1 resumeTheme = Resume5Theme1();
    await resumeTheme.getModel();
    CL5Theme1 clTheme = CL5Theme1();
    await clTheme.getModel();

    t5template.Template5 template5 = t5template.Template5(
        resume5themeModel: resumeTheme.resume5theme1,
        cl5themeModel: clTheme.cl5themeModel);
    await template5.createPage();
  }

  Future<void> resume5Theme2() async {
    Resume5Theme2 resumeTheme = Resume5Theme2();
    await resumeTheme.getModel();
    CL5Theme2 clTheme = CL5Theme2();
    await clTheme.getModel();

    t5template.Template5 template5 = t5template.Template5(
        resume5themeModel: resumeTheme.resume5theme2,
        cl5themeModel: clTheme.cl5themeModel);
    await template5.createPage();
  }

  Future<void> resume5Theme3() async {
    Resume5Theme3 resumeTheme = Resume5Theme3();
    await resumeTheme.getModel();
    CL5Theme3 clTheme = CL5Theme3();
    await clTheme.getModel();

    t5template.Template5 template5 = t5template.Template5(
        resume5themeModel: resumeTheme.resume5theme3,
        cl5themeModel: clTheme.cl5themeModel);
    await template5.createPage();
  }

  Future<void> resume5Theme4() async {
    Resume5Theme4 resumeTheme = Resume5Theme4();
    await resumeTheme.getModel();
    CL5Theme4 clTheme = CL5Theme4();
    await clTheme.getModel();

    t5template.Template5 template5 = t5template.Template5(
        resume5themeModel: resumeTheme.resume5theme4,
        cl5themeModel: clTheme.cl5themeModel);
    await template5.createPage();
  }

  Future<void> resume6Theme1() async {
    Resume6Theme1 resumeTheme = Resume6Theme1();
    await resumeTheme.getModel();
    CL6Theme1 clTheme = CL6Theme1();
    await clTheme.getModel();

    Template6 template6 = Template6(
        resume6themeModel: resumeTheme.resume6theme1,
        cl6themeModel: clTheme.cl6themeModel);
    await template6.createPage();
  }

  Future<void> resume6Theme2() async {
    Resume6Theme2 resumeTheme = Resume6Theme2();
    await resumeTheme.getModel();
    CL6Theme2 clTheme = CL6Theme2();
    await clTheme.getModel();

    Template6 template6 = Template6(
        resume6themeModel: resumeTheme.resume6theme2,
        cl6themeModel: clTheme.cl6themeModel);
    await template6.createPage();
  }

  Future<void> resume6Theme3() async {
    Resume6Theme3 resumeTheme = Resume6Theme3();
    await resumeTheme.getModel();
    CL6Theme3 clTheme = CL6Theme3();
    await clTheme.getModel();

    Template6 template6 = Template6(
        resume6themeModel: resumeTheme.resume6theme3,
        cl6themeModel: clTheme.cl6themeModel);
    await template6.createPage();
  }

  Future<void> resume6Theme4() async {
    Resume6Theme4 resumeTheme = Resume6Theme4();
    await resumeTheme.getModel();
    CL6Theme4 clTheme = CL6Theme4();
    await clTheme.getModel();

    Template6 template6 = Template6(
        resume6themeModel: resumeTheme.resume6theme4,
        cl6themeModel: clTheme.cl6themeModel);
    await template6.createPage();
  }

  // --- Templates without Cover Letters ---
  Future<void> resume7Theme1() async {
    Resume7Theme1 resumeTheme = Resume7Theme1();
    await resumeTheme.getModel();
    Template7 template7 =
        Template7(resume7themeModel: resumeTheme.resume7theme1);
    await template7.createPage();
  }

  Future<void> resume7Theme2() async {
    Resume7Theme2 resumeTheme = Resume7Theme2();
    await resumeTheme.getModel();
    Template7 template7 =
        Template7(resume7themeModel: resumeTheme.resume7theme2);
    await template7.createPage();
  }

  Future<void> resume7Theme3() async {
    Resume7Theme3 resumeTheme = Resume7Theme3();
    await resumeTheme.getModel();
    Template7 template7 =
        Template7(resume7themeModel: resumeTheme.resume7theme3);
    await template7.createPage();
  }

  Future<void> resume8Theme1() async {
    Resume8Theme1 resumeTheme = Resume8Theme1();
    await resumeTheme.getModel();
    Template8 template8 =
        Template8(resume8themeModel: resumeTheme.resume8theme1);
    await template8.createPage();
  }

  Future<void> resume8Theme2() async {
    Resume8Theme2 resumeTheme = Resume8Theme2();
    await resumeTheme.getModel();
    Template8 template8 =
        Template8(resume8themeModel: resumeTheme.resume8theme2);
    await template8.createPage();
  }

  Future<void> resume8Theme3() async {
    Resume8Theme3 resumeTheme = Resume8Theme3();
    await resumeTheme.getModel();
    Template8 template8 =
        Template8(resume8themeModel: resumeTheme.resume8theme3);
    await template8.createPage();
  }

  Future<void> resume9Theme1() async {
    Resume9Theme1 resumeTheme = Resume9Theme1();
    await resumeTheme.getModel();
    Template9 template9 =
        Template9(resume9themeModel: resumeTheme.resume9theme1);
    await template9.createPage();
  }

  Future<void> resume10Theme1() async {
    Resume10Theme1 resumeTheme = Resume10Theme1();
    await resumeTheme.getModel();
    Template10 template10 =
        Template10(resume10theme: resumeTheme.resume10theme1);
    await template10.createPage();
  }

  Future<void> resume11Theme1() async {
    Resume11Theme1 resumeTheme = Resume11Theme1();
    await resumeTheme.getModel();
    Template11 template11 =
        Template11(resume11theme: resumeTheme.resume11theme1);
    await template11.createPage();
  }

  Future<void> resume12Theme1() async {
    Resume12Theme1 resumeTheme = Resume12Theme1();
    await resumeTheme.getModel();
    Template12 template12 =
        Template12(resume12theme: resumeTheme.resume12theme1);
    await template12.createPage();
  }

  Future<void> resume13Theme1() async {
    Resume13Theme1 resumeTheme = Resume13Theme1();
    await resumeTheme.getModel();
    Template13 template13 =
        Template13(resume13theme: resumeTheme.resume13theme1);
    await template13.createPage();
  }

  Future<void> resume14Theme1() async {
    Resume14Theme1 resumeTheme = Resume14Theme1();
    await resumeTheme.getModel();
    Template14 template14 =
        Template14(resume14theme: resumeTheme.resume14theme1);
    await template14.createPage();
  }

  Future<void> resume15Theme1() async {
    Resume15Theme1 resumeTheme = Resume15Theme1();
    await resumeTheme.getModel();
    Template15 template15 =
        Template15(resume15theme: resumeTheme.resume15theme1);
    await template15.createPage();
  }

  Future<void> resume16Theme1() async {
    Resume16Theme1 resumeTheme = Resume16Theme1();
    await resumeTheme.getModel();
    Template16 template16 =
        Template16(resume16theme: resumeTheme.resume16theme1);
    await template16.createPage();
  }

  Future<void> resume17Theme1() async {
    Resume17Theme1 resumeTheme = Resume17Theme1();
    await resumeTheme.getModel();
    Template17 template17 =
        Template17(resume17theme: resumeTheme.resume17theme1);
    await template17.createPage();
  }

  Future<void> resume18Theme1() async {
    Resume18Theme1 resumeTheme = Resume18Theme1();
    await resumeTheme.getModel();
    Template18 template18 =
        Template18(resume18theme: resumeTheme.resume18theme1);
    await template18.createPage();
  }

  Future<void> resume19Theme1() async {
    Resume19Theme1 resumeTheme = Resume19Theme1();
    await resumeTheme.getModel();
    Template19 template19 =
        Template19(resume19theme: resumeTheme.resume19theme1);
    await template19.createPage();
  }

  Future<void> resume20Theme1() async {
    Resume20Theme1 resumeTheme = Resume20Theme1();
    await resumeTheme.getModel();
    Template20 template20 =
        Template20(resume20theme: resumeTheme.resume20theme1);
    await template20.createPage();
  }

  Future<void> resume21Theme1() async {
    Resume21Theme1 resumeTheme = Resume21Theme1();
    await resumeTheme.getModel();
    Template21 template21 =
        Template21(resume21themeModel: resumeTheme.resume21theme1);
    await template21.createPage();
  }
}
