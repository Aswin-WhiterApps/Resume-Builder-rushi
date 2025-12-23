import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../DB/db.dart';
import '../model/model.dart';
import '../model/resume_theme_model.dart';
import '../my_singleton.dart';



class CoverLetter5{

   MemoryImage? profileImage;
  late MemoryImage background;
   MemoryImage? signImage;
  // Font? headerFont ;
  // late MemoryImage borderImg;
  Font? normalFont ;
  Font? nameFont ;
  late String back;
  late PdfColor normalTextColor;
  late PdfColor imageBorder;
  late PdfColor nameColor;
  // late MemoryImage phoneIc;

  CL5ThemeModel cl5themeModel;
  ResumeModel? resumeData;
  
  CoverLetter5({required this.cl5themeModel, this.resumeData}){
    normalFont = cl5themeModel.normalFont!;
    nameFont  = cl5themeModel.nameFont!;
    back  = cl5themeModel.background!;
    normalTextColor  = cl5themeModel.normalTextColor!;
    imageBorder  = cl5themeModel.imageBorder!;
    nameColor  = cl5themeModel.nameColor!;
}

   CoverLetterModel? coverLetterData;
   IntroModel? introData;
   SignModel? signData;
   ContactModel? contactData;

  /// Downloads image from URL and returns as MemoryImage
  Future<MemoryImage?> _downloadImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return MemoryImage(response.bodyBytes);
      } else {
        print("Failed to download image from URL: $url. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error downloading image from URL: $url. Error: $e");
      return null;
    }
  }

  /// Loads image from URL or local path
  Future<MemoryImage?> _loadImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    // Check if it's a URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return await _downloadImageFromUrl(imagePath);
    } else {
      // Local file path
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          return MemoryImage(await file.readAsBytes());
        }
      } catch (e) {
        print("Error loading local image: $e");
      }
    }
    return null;
  }

  Future<void> getFonts() async {
    try {
      background = MemoryImage((await rootBundle
          .load(back))
          .buffer
          .asUint8List());

      // Use data from Firestore if available, otherwise fall back to local DB
      if (resumeData != null) {
        coverLetterData = resumeData!.coverLetter;
        introData = resumeData!.intro;
        contactData = resumeData!.contact;
        
        // Handle signature - it's stored as URL in Firestore
        if (resumeData!.signatureUrl != null && resumeData!.signatureUrl!.isNotEmpty) {
          signImage = await _downloadImageFromUrl(resumeData!.signatureUrl!);
        }
        
        // Handle profile image - it's stored as imagePath in IntroModel (could be URL or local path)
        if (introData?.imagePath != null && introData!.imagePath!.isNotEmpty) {
          profileImage = await _loadImage(introData!.imagePath);
        }
      } else {
        // Fallback to local DB
        if (MySingleton.resumeId != null) {
          CoverLetterModel? coverLetterModel = await DbHelper.instance.getCoverLetter(MySingleton.resumeId!);
          if (coverLetterModel != null) {
            coverLetterData = coverLetterModel;
          }
          IntroModel? introModel = await DbHelper.instance.getIntro(MySingleton.resumeId!);
          if (introModel != null) {
            introData = introModel;
            if (introModel.imagePath != null && introModel.imagePath!.isNotEmpty) {
              profileImage = await _loadImage(introModel.imagePath);
            }
          }
          SignModel? signModel = await DbHelper.instance.getSign(MySingleton.resumeId!);
          if (signModel != null && signModel.signPath != null) {
            signData = signModel;
            signImage = await _loadImage(signModel.signPath);
          }
          ContactModel? contactModel = await DbHelper.instance.getContacts(MySingleton.resumeId!);
          if (contactModel != null) {
            contactData = contactModel;
          }
        }
      }
    } catch (e) {
      print("Error in getFonts: $e");
    }
  }

   final pdf = Document();
   Future<void> createPage() async {

     pdf.addPage(Page(
         margin: EdgeInsets.zero,
         pageFormat: PdfPageFormat.a4,
         build: (Context context){
           return coverLetter5();
         }));


     final output =
     await getExternalStorageDirectories(type: StorageDirectory.downloads);
     if (output != null && output.isNotEmpty) {
       final file = File("${output[0].path}/CoverLetter.pdf");
       await file.writeAsBytes(await pdf.save());
       OpenFile.open("${output[0].path}/CoverLetter.pdf");
       print("Pdf Saved To ${output[0].path}");
     } else {
       print('Failed to get download directory');
     }
   }

  Widget coverLetter5() {

    Widget _getNormalTextRed6({required double width, required String text}) {
      return SizedBox(
        width: width,
        child: Text(
          text,
          style: TextStyle(
            color: normalTextColor,
            fontSize: 8,
            font: normalFont,
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
            font: normalFont,
            color: normalTextColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(image: DecorationImage(image: background,fit: BoxFit.cover)),
      // color: backgroundColor,
      child: Stack(
          children: [
            Positioned(
              top: 40,bottom: 20,left: 20,right: 20,
              child: Container(
                // color: PdfColors.yellow100,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // margin: EdgeInsets.only(top: 20,right: 20),
                        // color: PdfColors.green50,
                        // height:530,width: double.infinity,
                        child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${introData?.firstName??""} ${introData?.lastName??""}",
                                style: TextStyle(
                                    color: nameColor,
                                    font: nameFont,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 50),
                              SizedBox(
                                // height: 520,
                                width: 300,
                                child: _getNormalTextRed6(width: 490, text: "${contactData?.addr1??""}\n ${contactData?.addr2??""}"),
                              ),
                              SizedBox(
                                // height: 520,
                                width: 300,
                                child: _getNormalTextRed6(width: 490, text: "${contactData?.email??""}"),
                              ),
                              SizedBox(
                                // height: 520,
                                width: 300,
                                child: _getNormalTextRed6(width: 490, text: "${contactData?.phone??""}"),
                              ),
                              SizedBox(height: 30),
                              SizedBox(
                                height: 480,width: 500,
                                child: _getNormalTextRed6(width: 490, text: '''${coverLetterData?.text??""}'''),
                              ),

                            ]), ),
                      Container(
                          height: 50,width: 100,
                          // color: PdfColors.red300,
                          child: signImage!=null? Image(signImage!,width: 100,height: 50):Container()),//For Signature
                      SizedBox(
                        height: 30,
                        child: _getNormalTextRed6(width: 300, text: "Your sincerely,\n ${introData?.firstName??""} ${introData?.lastName??""}"),
                      ),
                    ]),),),
            Positioned(
              top: 20,right: 10,
              child: Container(
                height: 150,width: 150,
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(20),
                    // image: DecorationImage(image: imgBack!,fit: BoxFit.cover),
                    border: Border.all(
                      width: 10,
                      color:imageBorder,
                    ),
                    shape: BoxShape.circle,
                    // color: PdfColors.red300,
                  ),
                  child:   ClipOval(
                    child: profileImage !=null ?Image(profileImage!,
                        // width: 100, height: 100,
                        fit: BoxFit.cover):Container(),
                  ),),

            ),
          ]
      ),
    );
  }
}