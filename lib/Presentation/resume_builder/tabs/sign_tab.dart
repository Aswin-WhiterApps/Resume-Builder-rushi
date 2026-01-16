import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resume_builder/my_singleton.dart';
import '../../../firestore/user_firestore.dart';
import '../../resources/assets_manager.dart';
import '../../resources/color_manager.dart';
import '../../resources/font_manager.dart';
import '../../resources/strings_manager.dart';
import '../../resources/style_manager.dart';
import '../../resources/values_manager.dart';
import '../../../utils/image_loader.dart';

class SignTabView extends StatefulWidget {
  SignTabView({super.key});

  @override
  State<SignTabView> createState() => _SignTabViewState();
}

class _SignTabViewState extends State<SignTabView> {
  String? _signatureUrl;
  bool _isLoading = false;

  final FireUser _fireUser = FireUser();

  @override
  void initState() {
    super.initState();
    _loadCurrentSign();
  }

  void _loadCurrentSign() {
    final resume = MySingleton.resume;
    if (resume?.signatureUrl != null) {
      setState(() {
        _signatureUrl = resume!.signatureUrl;
      });
    }
  }

  /// Handles picking, uploading, and saving the signature.
  Future<void> _pickAndUploadImage(ImageSource source) async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a resume first.')));
      return;
    }

    final XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    setState(() { _isLoading = true; });

    // 1. Upload the file to Firebase Storage.
    final String? downloadUrl = await _fireUser.uploadFile(
      userId: userId,
      resumeId: resumeId,
      filePath: pickedFile.path,
      storagePath: 'signatures',
    );

    if (downloadUrl != null) {
      await _fireUser.saveSignatureForResume(
        userId: userId,
        resumeId: resumeId,
        signatureUrl: downloadUrl,
      );
      setState(() {
        _signatureUrl = downloadUrl;
        MySingleton.resume = MySingleton.resume?.copyWith(signatureUrl: downloadUrl, additionalSections: []);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload signature. Please try again.')));
    }

    setState(() { _isLoading = false; });
  }

  Future<void> _removeSignature() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) return;

    setState(() { _isLoading = true; });

    await _fireUser.deleteFileFromStorage(userId: userId, resumeId: resumeId, storagePath: 'signatures');

    await _fireUser.saveSignatureForResume(userId: userId, resumeId: resumeId, signatureUrl: null);

    setState(() {
      _signatureUrl = null;
      _isLoading = false;
      MySingleton.resume = MySingleton.resume?.copyWith(signatureUrl: null, additionalSections: []);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signature removed.')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManager.tabBackground,
      child: Stack( // Use a Stack to show a loading indicator over the UI.
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(AppSize.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p8, bottom: AppPadding.p20, top: AppPadding.p8),
                    child: Text(AppStrings.signScreenHeader, style: headerTextStyle()),
                  ),
                  _buildUploadButton(),
                  SizedBox(height: AppSize.s20),
                  Padding(
                    padding: const EdgeInsets.all(AppPadding.p8),
                    child: Text(
                      AppStrings.or,
                      style: TextStyle(color: ColorManager.orText, fontSize: FontSize.s18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _pickAndUploadImage(ImageSource.camera),
                    icon: SvgPicture.asset(ImageAssets.cameraIc),
                    label: Text('Open Camera', style: TextStyle(color: ColorManager.orText)),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: _signatureUrl == null ? () => _pickAndUploadImage(ImageSource.gallery) : null,
      child: Container(
        height: 350,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black38, offset: Offset.fromDirection(2, 2))],
          image: _signatureUrl == null ? DecorationImage(image: AssetImage(ImageAssets.upSignBtnBack), fit: BoxFit.cover) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _signatureUrl == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(ImageAssets.upSignIc),
              SizedBox(height: AppSize.s20),
              Text(AppStrings.upSignBtn, style: TextStyle(color: ColorManager.white)),
            ],
          )
              : Stack(
            fit: StackFit.expand,
            children: [
              // Display the image directly from the network URL.
              ImageLoader.loadNetworkImage(
                _signatureUrl!, 
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(50),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: _removeSignature,
                    tooltip: 'Remove Signature',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:resume_builder/my_singleton.dart';
//
// import '../../../DB/db.dart';
// import '../../../model/model.dart';
// import '../../resources/assets_manager.dart';
// import '../../resources/color_manager.dart';
// import '../../resources/font_manager.dart';
// import '../../resources/strings_manager.dart';
// import '../../resources/style_manager.dart';
// import '../../resources/values_manager.dart';
//
// class SignTabView extends StatefulWidget {
//   SignTabView({super.key});
//
//   @override
//   State<SignTabView> createState() => _SignTabViewState();
// }
//
// class _SignTabViewState extends State<SignTabView> {
//   File? _image;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentSign();
//   }
//
//   /// Loads the signature from the local DB when the widget initializes.
//   Future<void> _loadCurrentSign() async {
//     final resumeId = MySingleton.resumeId;
//     if (resumeId == null) return;
//
//     SignModel? signModel = await DbHelper.instance.getSign(resumeId);
//     if (signModel?.signPath != null) {
//       // Check if file exists before setting state to avoid errors.
//       final imageFile = File(signModel!.signPath!);
//       if (await imageFile.exists()) {
//         setState(() {
//           _image = imageFile;
//         });
//       }
//     }
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     final resumeId = MySingleton.resumeId;
//     if (resumeId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a resume first.')),
//       );
//       return;
//     }
//
//     final XFile? pickedFile = await ImagePicker().pickImage(source: source);
//
//     if (pickedFile != null) {
//       await _saveSignToDB(id: resumeId, signPath: pickedFile.path);
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _saveSignToDB({required String id, required String signPath}) async {
//     SignModel signModel = SignModel(id: id, signPath: signPath);
//     await DbHelper.instance.insertSign(signModel: signModel);
//     print("Signature saved for resume ID: $id");
//   }
//
//   Future<void> _removeSignature() async {
//     final resumeId = MySingleton.resumeId;
//     if (resumeId == null) return;
//
//     await DbHelper.instance.deleteSign(resumeId);
//     setState(() {
//       _image = null;
//     });
//     print("Signature removed for resume ID: $resumeId");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: ColorManager.tabBackground,
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(AppSize.s16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: AppPadding.p8, bottom: AppPadding.p20, top: AppPadding.p8),
//                 child: Text(AppStrings.signScreenHeader, style: headerTextStyle()),
//               ),
//               _buildUploadButton(),
//               SizedBox(height: AppSize.s20),
//               Padding(
//                 padding: const EdgeInsets.all(AppPadding.p8),
//                 child: Text(
//                   AppStrings.or,
//                   style: TextStyle(color: ColorManager.orText, fontSize: FontSize.s18, fontWeight: FontWeight.w500),
//                 ),
//               ),
//               TextButton.icon(
//                 onPressed: () => _pickImage(ImageSource.camera),
//                 icon: SvgPicture.asset(ImageAssets.cameraIc),
//                 label: Text('Open Camera', style: TextStyle(color: ColorManager.orText)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUploadButton() {
//     return GestureDetector(
//       onTap: _image == null ? () => _pickImage(ImageSource.gallery) : null,
//       child: Container(
//         height: 350,
//         width: MediaQuery.of(context).size.width,
//         decoration: BoxDecoration(
//           color: ColorManager.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black38, offset: Offset.fromDirection(2, 2))],
//           image: _image == null ? DecorationImage(image: AssetImage(ImageAssets.upSignBtnBack), fit: BoxFit.cover) : null,
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: _image == null
//               ? Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SvgPicture.asset(ImageAssets.upSignIc),
//               SizedBox(height: AppSize.s20),
//               Text(AppStrings.upSignBtn, style: TextStyle(color: ColorManager.white)),
//             ],
//           )
//               : Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.file(_image!, fit: BoxFit.cover, isAntiAlias: true),
//               Positioned(
//                 top: 10,
//                 right: 10,
//                 child: Material(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(50),
//                   child: IconButton(
//                     icon: Icon(Icons.delete_outline, color: Colors.white),
//                     onPressed: _removeSignature,
//                     tooltip: 'Remove Signature',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // import 'dart:io';
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_svg/svg.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:resume_builder/my_singleton.dart';
// //
// // import '../../../DB/db.dart';
// // import '../../../model/model.dart';
// // import '../../resources/assets_manager.dart';
// // import '../../resources/color_manager.dart';
// // import '../../resources/font_manager.dart';
// // import '../../resources/strings_manager.dart';
// // import '../../resources/style_manager.dart';
// // import '../../resources/values_manager.dart';
// //
// // class SignTabView extends StatefulWidget {
// //   // String id;
// //   SignTabView({super.key});
// //
// //   @override
// //   State<SignTabView> createState() => _SignTabViewState();
// // }
// //
// // class _SignTabViewState extends State<SignTabView> {
// //   // String id;
// //   late String imagepat;
// //   File? image;
// //   _SignTabViewState();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     getCurrentSign();
// //   }
// //
// //   Future<void> getCurrentSign() async {
// //     SignModel? signModel = await DbHelper.instance.getSign(MySingleton.resumeId!);
// //     if (signModel != null) {
// //       setState(() {
// //         image = File(signModel!.signPath!);
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       color: ColorManager.tabBackground,
// //       child: SingleChildScrollView(
// //         child: Padding(
// //           padding: EdgeInsets.all(AppSize.s16),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Padding(
// //                 padding: const EdgeInsets.only(
// //                     left: AppPadding.p8,
// //                     bottom: AppPadding.p20,
// //                     top: AppPadding.p8),
// //                 child: Text(
// //                   AppStrings.signScreenHeader,
// //                   style: headerTextStyle(),
// //                 ),
// //               ),
// //               InkWell(
// //                 onTap: () => _getFromGallery(),
// //                 child: _getUpSignLargeBtn(),
// //               ),
// //               SizedBox(
// //                 height: AppSize.s20,
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.all(AppPadding.p8),
// //                 child: Text(
// //                   AppStrings.or,
// //                   style: TextStyle(
// //                       color: ColorManager.orText,
// //                       fontSize: FontSize.s18,
// //                       fontWeight: FontWeight.w500),
// //                 ),
// //               ),
// //               TextButton(
// //                 onPressed: () => _getFromCamera(),
// //                 child: Row(
// //                   children: [
// //                     Padding(
// //                       padding: const EdgeInsets.only(
// //                           left: AppPadding.p12, right: AppPadding.p12),
// //                       child: SvgPicture.asset(ImageAssets.cameraIc),
// //                     ),
// //                     Text(
// //                       AppStrings.openCameraBtn,
// //                       style: TextStyle(
// //                         color: ColorManager.orText,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _saveSignToDB({required String id, required String signPath}) {
// //     SignModel signModel = SignModel(id: id, signPath: signPath);
// //     DbHelper.instance.insertSign(signModel: signModel);
// //   }
// //
// //   void _getFromGallery() async {
// //     XFile? pickedFile = await ImagePicker.platform.getImageFromSource(
// //       source: ImageSource.gallery,
// //       // maxWidth: 1800,
// //       // maxHeight: 1800,
// //     );
// //     if (pickedFile != null) {
// //       _saveSignToDB(id: MySingleton.resumeId!, signPath: pickedFile.path);
// //       setState(() {
// //         imagepat = pickedFile.path;
// //         image = File(pickedFile.path);
// //       });
// //     }
// //   }
// //
// //   void _getFromCamera() async {
// //     XFile? pickedFile = await ImagePicker.platform.getImageFromSource(
// //       source: ImageSource.camera,
// //       // maxWidth: 1800,
// //       // maxHeight: 1800,
// //     );
// //     if (pickedFile != null) {
// //       _saveSignToDB(id: MySingleton.resumeId!, signPath: pickedFile.path);
// //       setState(() {
// //         imagepat = pickedFile.path;
// //         image = File(pickedFile.path);
// //       });
// //     }
// //   }
// //
// //   _getUpSignLargeBtn() {
// //     return Container(
// //       // padding: EdgeInsets.all(20),
// //       height: 350,
// //       width: MediaQuery.of(context).size.width,
// //       decoration: BoxDecoration(
// //         image: DecorationImage(
// //             image: Image.asset(ImageAssets.upSignBtnBack).image,
// //             fit: BoxFit.cover,
// //             isAntiAlias: true),
// //         color: ColorManager.white,
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [
// //           BoxShadow(
// //               blurRadius: 5,
// //               color: Colors.black38,
// //               offset: Offset.fromDirection(2, 2))
// //         ],
// //       ),
// //       child: Padding(
// //         padding: EdgeInsets.zero,
// //         // padding: EdgeInsets.only(
// //         //   left: AppSize.s8,
// //         //   right: AppSize.s8,
// //         //   top: AppPadding.p12,
// //         // ),
// //         child: image == null
// //             ? Container(
// //                 decoration: BoxDecoration(
// //                   // image: DecorationImage(image: Image.asset(ImageAssets.upSignBtnBack).image,fit: BoxFit.cover,isAntiAlias: true),
// //                   color: Colors.transparent,
// //                   borderRadius: BorderRadius.circular(20),
// //                   // boxShadow: [
// //                   //   BoxShadow(
// //                   //       blurRadius: 5,
// //                   //       color: Colors.black38,
// //                   //       offset: Offset.fromDirection(2, 2))
// //                   // ],
// //                 ),
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     Padding(
// //                       padding: EdgeInsets.only(
// //                           left: AppPadding.p8,
// //                           right: AppPadding.p8,
// //                           bottom: AppPadding.p18,
// //                           top: AppPadding.p18),
// //                       child: SvgPicture.asset(ImageAssets.upSignIc),
// //                     ),
// //                     Padding(
// //                       padding: const EdgeInsets.only(
// //                           top: AppPadding.p18,
// //                           bottom: AppPadding.p30,
// //                           left: AppPadding.p8,
// //                           right: AppPadding.p8),
// //                       child: Text(
// //                         AppStrings.upSignBtn,
// //                         style: TextStyle(color: ColorManager.white),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               )
// //             : Container(
// //                 decoration: BoxDecoration(
// //                   // image: DecorationImage(image: Image.asset(ImageAssets.upSignBtnBack).image,fit: BoxFit.cover,isAntiAlias: true),
// //                   color: ColorManager.white,
// //                   borderRadius: BorderRadius.circular(20),
// //                   // boxShadow: [
// //                   //   BoxShadow(
// //                   //       blurRadius: 5,
// //                   //       color: Colors.black38,
// //                   //       offset: Offset.fromDirection(2, 2))
// //                   // ],
// //                 ),
// //                 child: ClipRRect(
// //                   borderRadius: BorderRadius.circular(20),
// //                   child: Image.file(
// //                     image!,
// //                     fit: BoxFit.cover,
// //                     isAntiAlias: true,
// //                   ),
// //                 ),
// //               ),
// //       ),
// //     );
// //   }
// // }
