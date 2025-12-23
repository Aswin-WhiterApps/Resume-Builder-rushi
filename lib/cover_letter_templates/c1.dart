import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:resume_builder/model/model.dart';

import '../DB/db.dart';
import '../model/resume_theme_model.dart';
import '../my_singleton.dart';



class CoverLetter1{
   MemoryImage? signImage;
  Font? normalFont ;
  // Font? headerFont ;
  Font? nameFont ;

   PdfColor? normalTextColor;
   PdfColor? dividertColor;
   PdfColor? nameColor;
   PdfColor? backgroundColor;


  CL1ThemeModel? coverLetterModel;
  ResumeModel? resumeData;

  CoverLetter1({required this.coverLetterModel, this.resumeData}){
    if(coverLetterModel != null){
      normalFont = coverLetterModel!.normalFont!;
      // headerFont = coverLetterModel.headerFont!;
      nameFont = coverLetterModel!.nameFont!;
      normalTextColor = coverLetterModel!.normalTextColor!;
      dividertColor = coverLetterModel!.dividertColor!;
      nameColor = coverLetterModel!.nameColor!;
      backgroundColor = coverLetterModel!.backgroundColor!;
    }
  }
   final pdf = Document();
   Future<void> createPage() async {

     pdf.addPage(Page(
         margin: EdgeInsets.zero,
         pageFormat: PdfPageFormat.a4,
         build: (Context context){
           return coverLetter1();
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

   CoverLetterModel? coverLetterData;
   IntroModel? introData;
   SignModel? signData;

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
      // Use data from Firestore if available, otherwise fall back to local DB
      if (resumeData != null) {
        coverLetterData = resumeData!.coverLetter;
        introData = resumeData!.intro;
        
        // Handle signature - it's stored as URL in Firestore
        if (resumeData!.signatureUrl != null && resumeData!.signatureUrl!.isNotEmpty) {
          signImage = await _downloadImageFromUrl(resumeData!.signatureUrl!);
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
          }
          SignModel? signModel = await DbHelper.instance.getSign(MySingleton.resumeId!);
          if (signModel != null && signModel.signPath != null) {
            signData = signModel;
            signImage = await _loadImage(signModel.signPath);
          }
        }
      }
    } catch (e) {
      print("Error in getFonts: $e");
    }
  }


  Widget coverLetter1() {



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

    return Stack(
      children: [
     Container(
      height: double.infinity,
      padding: EdgeInsets.all(20),
      // decoration: BoxDecoration(image: DecorationImage(image: background!,fit: BoxFit.cover)),
      color: backgroundColor,
      child: Row(children: [
        SizedBox(height: 750,width: 50,
        child: VerticalDivider(thickness: 2,color: dividertColor),
        ),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${introData?.firstName ?? ""} ${introData?.lastName ?? ""}",
                style: TextStyle(
                    color: nameColor,
                    font: nameFont,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25),
              // SizedBox(height: )
              SizedBox(
                height: 550,width: 500,
                child: _getNormalTextRed6(width: 490, text: '''${coverLetterData?.text ?? ""}'''),
              ),
              Container(height: 50,width: 100,
                  // color: PdfColors.red300,
                  child:signImage != null ? Image(signImage!,width: 100,height: 50):Container()),//For Signature
              SizedBox(
                height: 30,
                child: _getNormalTextRed6(width: 300, text: "Your sincerely,\n ${introData?.firstName ?? ""} ${introData?.lastName ?? ""}"),
              ),

            ]),
      ]),
    ),

    (MySingleton.loggedInUser!.subscribed!)? SizedBox.shrink() : Positioned.fill(
        child: Opacity(
          opacity: 0.1,  
          child: Center(
            child: Transform.rotate(
              angle: -0.7854,
              child: Text(
                "Whiter Apps",
                style: TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),

      ]
    );
  }
}