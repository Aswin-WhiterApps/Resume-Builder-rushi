import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';

import 'package:pdf/widgets.dart';
import 'package:resume_builder/DB/db.dart';

import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:resume_builder/model/model.dart';

import 'Presentation/resources/strings_manager.dart';

class PdfGenerator {
  // static final PdfGenerator instance = PdfGenerator._init();
  // PdfGenerator._init();

  MemoryImage? imageLogo;
  MemoryImage? t3_verticle;
  MemoryImage? t3_horizontle;
  late MemoryImage profileImage;

  PdfGenerator() {
    getImage();
  }

  Future<void> getImage() async {
    try {
      t3_horizontle = MemoryImage((await rootBundle
          .load('assets/pdf_assets/template3/t31_rect_horizontle.png'))
          .buffer
          .asUint8List());
      t3_verticle = MemoryImage((await rootBundle
          .load('assets/pdf_assets/template3/t31_rect_verticle.png'))
          .buffer
          .asUint8List());
    } catch (e) {
      print(e);
    }

    imageLogo = MemoryImage(
        (await rootBundle.load('assets/images/samp_prof_img.png'))
            .buffer
            .asUint8List());
    IntroModel? introModel = await DbHelper.instance.getIntro("1");
    if (introModel != null && introModel.imagePath != null && introModel.imagePath!.isNotEmpty) {
      try {
        final imageFile = File(introModel.imagePath!);
        if (await imageFile.exists()) {
          profileImage = MemoryImage(await imageFile.readAsBytes());
        }
      } catch (e) {
        print('Error loading profile image: $e');
        // Use default profile image or continue without image
      }
    }

    // profileImage = MemoryImage(
    //   (await rootBundle.load(ImageAssets.profile_img)).buffer.asUint8List(),
    // );
  }

  // final imageLogo = MemoryImage((await rootBundle.load('assets/technical_logo.png')).buffer.asUint8List());
  final pdf = Document();

  // Future<void> createPage() async {
  //   pdf.addPage(Page(
  //       margin: EdgeInsets.zero,
  //       pageFormat: PdfPageFormat.a4,
  //       build: (Context context) {
  //         return template2(); // Center
  //       }));
  //   String datetime = DateTime.now().toString();
  //   // final output = await getExternalStorageDirectories(type: StorageDirectory.downloads);
  //   // final file = File("${output![0].path}/Resume2.pdf");
  //   // This is the correct, modern approach
  //   final output = await getApplicationDocumentsDirectory();
  //   final file = File("${output.path}/Resume.pdf");
  //   File res = await file.writeAsBytes(await pdf.save());
  //   if (res != null) {
  //     OpenFil e.open("${output![0].path}/Resume2.pdf");
  //     print("Pdf Saved To ${output[0].path}");
  //   } else {
  //     print('Failed Save Pdf');
  //   }
  // }
  Future<void> createPage() async {
    pdf.addPage(Page(
        margin: EdgeInsets.zero,
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          return template2();
        }));

    try {
      final output = await getApplicationDocumentsDirectory();
      final String uniqueFileName = "Resume_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${output.path}/$uniqueFileName");
      await file.writeAsBytes(await pdf.save());
      print("PDF Saved To: ${file.path}");
      await OpenFile.open(file.path);

    } catch (e) {
      print('Failed to save or open PDF: $e');
    }
  }

  Widget template1() {
    return Container(
      margin: EdgeInsets.all(25),
      width: double.infinity,
      height: double.infinity,
      // decoration: const BoxDecoration(gradient: LinearGradient(
      //   colors: [PdfColor(0, 1, 1), PdfColor(0, 1, 0.9921568627450981)],
      //   stops: [0, 0.9],
      //   begin: Alignment.topCenter,
      //   end: Alignment.bottomCenter,
      // )
      // ),
      // color: PdfColors.lightGreen50,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: PdfColors.red300,
              ),
              child: Image(profileImage,
                  width: 100, height: 100, fit: BoxFit.cover),
            ),
            Container(
              // color: PdfColors.lightBlue200,
              margin: EdgeInsets.only(top: 15, bottom: 15),
              child: Text(
                "JAMES BOND",
                style: TextStyle(
                    color: PdfColors.amber,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
            ),

            //Contacts Row
            Container(
              // color: PdfColors.lightGreen200,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _getHeaderText1(text: "+1-222-3212"),
                    SizedBox(width: 15),
                    _getHeaderText1(text: "jamesbond@example.com"),
                    SizedBox(width: 15),
                    _getHeaderText1(text: "http//:jamesbond.com"),
                  ]),
            ),
            SizedBox(height: 30),
            Container(
              height: 560,
              width: double.infinity,
              // color: PdfColors.red300,
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      // mainAxisSize: pw.MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            // color: PdfColors.green,
                            width: 180,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _getHeaderText1(text: "Language"),
                                  SizedBox(width: 25),
                                  for (int i = 0; i < 4; i++)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: AppPadding.p12,
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Image(profileImage,
                                                width: 5, height: 5),
                                            SizedBox(width: 10),
                                            _getNormalText1(
                                                width: 100, text: "English"),
                                          ]),
                                    ),
                                  SizedBox(height: 30),
                                  _getHeaderText1(text: "Interest & Hobbies"),
                                  for (int i = 0; i < 3; i++)
                                    Container(
                                      width: 150,
                                      padding:
                                      EdgeInsets.only(left: AppPadding.p12),
                                      child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Image(profileImage,
                                                width: 5, height: 5),
                                            SizedBox(width: 10),
                                            _getNormalText1(
                                                width: 100,
                                                text:
                                                "Excellent physical fitness and endurance."),
                                            SizedBox(height: 15),
                                          ]),
                                    ),
                                  SizedBox(height: 30),
                                  _getHeaderText1(
                                      text: "Achievements & Awards"),
                                  _getNormalText1(
                                      width: 150,
                                      text:
                                      "Received multiple commendations and awards for bravery and exceptional performance in the line of duty."),
                                ]),
                          ),
                          VerticalDivider(
                              thickness: 2,
                              width: 30,
                              color: PdfColor(0.7529411764705882,
                                  0.7529411764705882, 0.7529411764705882)),
                          Container(
                            // color: PdfColors.blue,
                              width: 335,
                              height: 560,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _getHeaderText1(text: AppStrings.t5),
                                    _getNormalText1(
                                        width: 330,
                                        text: AppStrings.summeryPdfText),
                                    SizedBox(height: 30),
                                    //Education
                                    _getHeaderText1(text: AppStrings.t3),
                                    for (int i = 0; i < 3; i++)
                                      Container(
                                        width: 150,
                                        padding: EdgeInsets.only(
                                            left: AppPadding.p12),
                                        child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Image(profileImage,
                                                  width: 5, height: 5),
                                              SizedBox(width: 10),
                                              _getNormalText1(
                                                  width: 300,
                                                  text:
                                                  "Bachelor of Arts in International Relations"),
                                              SizedBox(height: 15),
                                            ]),
                                      ),
                                    SizedBox(height: 30),
                                    //Work
                                    _getHeaderText1(text: AppStrings.t4),
                                    for (int i = 0; i < 3; i++)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 20),
                                        width: 150,
                                        padding: EdgeInsets.only(
                                            left: AppPadding.p12),
                                        child: _getNormalText1(
                                            width: 150,
                                            text:
                                            "${i + 1}. Secret Intelligence Service (MI6) Position: Field Agent (Agent 007) Duration: [2007] - Present"),
                                      ),
                                  ])),
                        ]),
                  ]),
            ),
          ]),
    );
  }

  Widget _getNormalText1({required double width, required String text}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: TextStyle(
          color: PdfColor(
              0.5372549019607843, 0.396078431372549, 0.396078431372549),
          fontSize: 8,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _getHeaderText1({required String text}) {
    return Text(
      text,
      style: TextStyle(
          color: PdfColor(
              0.5372549019607843, 0.396078431372549, 0.396078431372549),
          fontSize: 15,
          fontWeight: FontWeight.normal),
    );
  }

  Widget template2() {
    Widget _getNormalTextwhite2({required double width, required String text}) {
      return SizedBox(
        width: width,
        child: Text(
          text,
          style: TextStyle(
            color: PdfColor(
                0.9725490196078431, 0.9294117647058824, 0.9294117647058824),
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    }

    Widget _getNormalTextRed2({required double width, required String text}) {
      return SizedBox(
        width: width,
        child: Text(
          text,
          style: TextStyle(
            color: PdfColor(
                0.6980392156862745, 0.4823529411764706, 0.5019607843137255),
            fontSize: 8,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    }

    Widget _getDetText2({required double width, required String text}) {
      return SizedBox(
        width: width,
        child: Text(
          text,
          style: TextStyle(
            color: PdfColor(
                0.9725490196078431, 0.9294117647058824, 0.9294117647058824),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    Widget _getHeaderTextRed2({required String text}) {
      return Text(
        text, //Summary Header
        style: TextStyle(
            color: PdfColor(
                0.6980392156862745, 0.4823529411764706, 0.5019607843137255),
            fontSize: 15,
            fontWeight: FontWeight.normal),
      );
    }

    Widget _getHeaderTextWhite2({required String text}) {
      return Text(
        text, //Summary Header
        style: TextStyle(
            color: PdfColor(
                0.9725490196078431, 0.9294117647058824, 0.9294117647058824),
            fontSize: 15,
            fontWeight: FontWeight.normal),
      );
    }

    return Container(
      // color: PdfColor(0.6980392156862745, 0.4823529411764706,
      //     0.5019607843137255,),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Left Part Of the PDF
              Container(
                padding: EdgeInsets.only(top: 40),
                height: 800,
                width: 220,
                decoration: BoxDecoration(
                  color: PdfColor(0.6980392156862745, 0.4823529411764706,
                      0.5019607843137255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(110),
                    topRight: Radius.circular(110),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      // width: 120,
                      // height: 120,
                      // padding: EdgeInsets.symmetric(vertical: 20),
                      margin: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 10,
                            color: PdfColor(0.9725490196078431,
                                0.9294117647058824, 0.9294117647058824)),
                        shape: BoxShape.circle,
                        // color: PdfColors.red300,
                      ),
                      child: ClipOval(
                          child: SizedBox.fromSize(
                            size: PdfPoint(150, 150),
                            child: Image(profileImage,
                                // width: 100, height: 100,
                                fit: BoxFit.cover),
                          )),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "JAMES BOND",
                      style: TextStyle(
                          color: PdfColor(0.9725490196078431,
                              0.9294117647058824, 0.9294117647058824),
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: _getDetText2(
                          width: 210, text: "jamesbond@example.com"),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: _getDetText2(
                          width: 210, text: "http//:jamesbond.com"),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: _getDetText2(width: 210, text: "+1-222-3212"),
                    ),

                    SizedBox(height: 30),
                    //Languages Section
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Row(children: [
                        _getHeaderTextWhite2(text: AppStrings.languages),
                      ]),
                    ),

                    SizedBox(height: 10),
                    for (int i = 0; i < 4; i++)
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipOval(
                                  child: SizedBox.fromSize(
                                    size: PdfPoint(5, 5),
                                    child: Image(profileImage,
                                        // width: 100, height: 100,
                                        fit: BoxFit.cover),
                                  )),
                              SizedBox(width: 10),
                              _getNormalTextwhite2(width: 200, text: "English"),
                            ]),
                      ),
                    SizedBox(height: 30),
                    //Skill Section
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Row(children: [
                        _getHeaderTextWhite2(text: AppStrings.skills),
                      ]),
                    ),

                    SizedBox(height: 10),
                    for (int i = 0; i < 4; i++)
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image(profileImage, width: 5, height: 5),
                              SizedBox(width: 10),
                              _getNormalTextwhite2(
                                  width: 200,
                                  text:
                                  "Covert operations and intelligence gathering"),
                            ]),
                      ),
                  ],
                ),
              ),
              Container(
                // color: PdfColors.red300,
                width: 340,
                margin: EdgeInsets.only(top: 100),
                padding: EdgeInsets.only(
                  bottom: 30,
                  left: 20,
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Summary Section
                      _getHeaderTextRed2(text: AppStrings.t5),
                      //Summary Header
                      SizedBox(height: 10),
                      _getNormalTextRed2(
                          width: 340, text: AppStrings.summeryPdfText),
                      SizedBox(height: 20),
                      //Education Section
                      _getHeaderTextRed2(text: AppStrings.t3),
                      //Education Header
                      SizedBox(height: 10),
                      for (int i = 0; i < 3; i++)
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipOval(
                                    child: SizedBox.fromSize(
                                      size: PdfPoint(5, 5),
                                      child: Image(profileImage,
                                          // width: 100, height: 100,
                                          fit: BoxFit.cover),
                                    )),
                                SizedBox(width: 10),
                                _getNormalTextRed2(
                                    width: 250,
                                    text:
                                    "Bachelor of Arts in International Relations"),
                              ]),
                        ),

                      SizedBox(height: 20),
                      _getHeaderTextRed2(text: AppStrings.t4),
                      SizedBox(height: 10),
                      for (int i = 0; i < 3; i++)
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: _getNormalTextRed2(
                                width: 250,
                                text:
                                "${i + 1}.  Secret Intelligence Service (MI6) Position: Field Agent (Agent 007) Duration: [2007] - Present"),
                          ),
                        ),

                      SizedBox(height: 5),
                      _getHeaderTextRed2(text: "Interest & Hobbies"),
                      SizedBox(height: 10),
                      for (int i = 0; i < 3; i++)
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipOval(
                                    child: SizedBox.fromSize(
                                      size: PdfPoint(5, 5),
                                      child: Image(profileImage,
                                          // width: 100, height: 100,
                                          fit: BoxFit.cover),
                                    )),
                                SizedBox(width: 10),
                                _getNormalTextRed2(
                                    width: 250,
                                    text:
                                    "Extensive knowledge of international politics, security threats, and terrorist organizations"),
                              ]),
                        ),
                      SizedBox(height: 20),
                      _getHeaderTextRed2(text: "Achievements & Awards"),
                      SizedBox(height: 10),
                      _getNormalTextRed2(
                          width: 250,
                          text:
                          "Received multiple commendations and awards for bravery and exceptional performance in the line of duty."),
                    ]),
              ),
            ]),
      ),
    );
  }




}