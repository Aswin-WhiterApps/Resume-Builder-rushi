// lib/Presentation/resume_builder/tabs/intro_tab.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/my_singleton.dart';

import '../../resources/assets_manager.dart';
import '../../resources/color_manager.dart';
import '../../resources/font_manager.dart';
import '../../resources/strings_manager.dart';
import '../../resources/values_manager.dart';

class IntroTabView extends StatefulWidget {
  const IntroTabView({super.key});

  @override
  State<IntroTabView> createState() => IntroTabViewState();
}

class IntroTabViewState extends State<IntroTabView> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  final FireUser _fireUser = FireUser();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  IntroModel? _currentIntro;
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadIntroData();
    firstNameController.addListener(_onTextChanged);
    lastNameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    firstNameController.removeListener(_onTextChanged);
    lastNameController.removeListener(_onTextChanged);
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  // --- DATA METHODS ---

  Future<void> _loadIntroData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;

    if (userId == null || resumeId == null) {
      if (mounted) setState(() { _isLoading = false; });
      return;
    }

    final resume = await _fireUser.getResume(userId: userId, resumeId: resumeId);

    if (mounted) {
      setState(() {
        if (resume != null && resume.intro != null) {
          _currentIntro = resume.intro;
          firstNameController.text = _currentIntro!.firstName ?? '';
          lastNameController.text = _currentIntro!.lastName ?? '';
          if (_currentIntro?.imagePath != null && _currentIntro!.imagePath!.isNotEmpty) {
            // This assumes the path is a local file path for now.
            // For a real app, you'd check if it's a URL and use NetworkImage.
            _imageFile = File(_currentIntro!.imagePath!);
          }
        }
        _isLoading = false;
      });
    }
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      saveIntroData();
    });
  }

  // Future<IntroModel?> saveIntroData() async {
  //   final userId = MySingleton.userId;
  //   final resumeId = MySingleton.resumeId;
  //
  //   if (userId == null || resumeId == null) return;
  //
  //   _currentIntro = IntroModel(
  //     firstName:firstNameController.text.trim(),
  //     lastName: lastNameController.text.trim(),
  //     imagePath: _currentIntro?.imagePath,
  //   );
  //
  //   await _fireUser.saveIntroForResume(
  //     userId: userId,
  //     resumeId: resumeId,
  //     intro: _currentIntro!,
  //   );
  //   print("✅ Intro text auto-saved to Firestore.");
  // }

  Future<IntroModel?> saveIntroData() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;

    if (userId == null || resumeId == null) {
      print("Cannot save intro: User or Resume ID is missing.");
      return null; // Return null on failure
    }

    final introToSave = IntroModel(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      imagePath: _currentIntro?.imagePath,
    );

    await _fireUser.saveIntroForResume(
      userId: userId,
      resumeId: resumeId,
      intro: introToSave,
    );

    print("Intro data explicitly saved to Firestore.");
    _currentIntro = introToSave;

    return introToSave; // Return the saved model on success
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) return;

    // IMPORTANT: In a production app, you would upload the file to Firebase Storage
    // and get back a public URL to save in the database.
    // For now, we are just saving the local device path for testing.
    final String imagePathForDb = pickedFile.path;

    await _fireUser.saveIntroImageForResume(
        userId: userId,
        resumeId: resumeId,
        imagePath: imagePathForDb
    );

    if(mounted) {
      setState(() {
        _imageFile = File(pickedFile.path); // Update the UI to show the new image
        _currentIntro?.imagePath = imagePathForDb; // Update local state
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image Saved!"), duration: Duration(seconds: 1)),
    );
  }

  // --- UI WIDGETS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        height: MediaQuery.of(context).size.height,
        color: ColorManager.tabBackground,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p8, bottom: 20, top: AppPadding.p8),
                  child: Text(
                    AppStrings.chooseName,
                    style: TextStyle(
                        fontSize: FontSize.s20,
                        fontWeight: FontWeight.bold,
                        fontFamily: FontFamily.roboto),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5,
                          color: Colors.black38,
                          offset: Offset.fromDirection(2, 2))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSize.s8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppSize.s16),
                          child: InkWell(
                            onTap: _pickAndUploadImage,
                            child: CircleAvatar(
                              radius: AppSize.s40,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : const AssetImage(ImageAssets.userImage) as ImageProvider,
                            ),
                          ),
                        ),
                        _buildTextField(
                            controller: firstNameController,
                            hint: AppStrings.firstName),
                        const SizedBox(height: AppSize.s8),
                        _buildTextField(
                            controller: lastNameController,
                            hint: AppStrings.lastName),
                        const Padding(
                          padding: EdgeInsets.only(
                              left: AppPadding.p8,
                              right: AppPadding.p8,
                              bottom: AppPadding.p18,
                              top: AppPadding.p18),
                          child: Text(
                            AppStrings.introScreenText,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: FontSize.s14,
                              fontFamily: FontFamily.roboto,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
          color: Colors.black,
          fontSize: FontSize.s20,
          fontWeight: FontWeight.normal),
      decoration: InputDecoration(
        hintText: "  $hint",
        hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: FontSize.s20,
            fontWeight: FontWeight.normal),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide:
          BorderSide(color: Colors.blueAccent, width: 2),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}