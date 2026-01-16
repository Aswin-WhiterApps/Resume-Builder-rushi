import 'dart:async';
import 'package:flutter/material.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/my_singleton.dart';
import '../../resources/color_manager.dart';
import '../../resources/font_manager.dart';
import '../../resources/strings_manager.dart';
import '../../resources/values_manager.dart';

class CoverLetterTabView extends StatefulWidget {
  const CoverLetterTabView({super.key});

  @override
  State<CoverLetterTabView> createState() => CoverLetterTabViewState();
}

class CoverLetterTabViewState extends State<CoverLetterTabView> {
  final TextEditingController _controller = TextEditingController();
  final FireUser _fireUser = FireUser();
  Timer? _debounce;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoverLetter();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCoverLetter() async {
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
        _controller.text = resume?.coverLetter?.text ?? '';
        _isLoading = false;
      });
    }
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      _saveCoverLetter();
    });
  }

  Future<void> _saveCoverLetter() async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) return;

    final coverLetter = CoverLetterModel(id: resumeId,text: _controller.text.trim());
    await _fireUser.saveCoverLetterForResume(
        userId: userId, resumeId: resumeId, coverLetter: coverLetter);
    print("✅ Cover Letter auto-saved.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        color: ColorManager.tabBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSize.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: AppPadding.p8, bottom: AppPadding.p20, top: AppPadding.p8),
                child: Text(AppStrings.coverLetterHeader, style: TextStyle(fontSize: FontSize.s20, fontWeight: FontWeight.bold)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black38, offset: Offset.fromDirection(2, 2))],
                ),
                padding: const EdgeInsets.all(AppPadding.p12),
                child: Column(
                  children: [
                    const Text(AppStrings.coverLetterScreenText, style: TextStyle(color: Colors.grey, fontSize: FontSize.s12)),
                    Padding(
                      padding: const EdgeInsets.only(top: AppPadding.p18, bottom: AppPadding.p30),
                      child: _getMultiLineTextField(controller: _controller, hint: AppStrings.coverLetterHint),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSize.s20),
              const Padding(
                padding: EdgeInsets.all(AppPadding.p8),
                child: Text(AppStrings.exapmles, style: TextStyle(color: Colors.black, fontSize: FontSize.s12, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 300,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _getExampleBox(text: AppStrings.coverLetterExample1),
                    _getExampleBox(text: AppStrings.coverLetterExample2),
                  ],
                ),
              ),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMultiLineTextField({required TextEditingController controller, required String hint}) {
    return TextField(
      maxLines: 10,
      minLines: 5,
      controller: controller,
      style: const TextStyle(color: Colors.black, fontSize: FontSize.s16, fontWeight: FontWeight.normal),
      decoration: InputDecoration(
        hintText: "  $hint",
        hintStyle: const TextStyle(color: Colors.grey, fontSize: FontSize.s12, fontWeight: FontWeight.normal),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSize.s20), borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSize.s20), borderSide: const BorderSide(color: Colors.blueAccent)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSize.s20), borderSide: const BorderSide(color: Colors.grey)),
      ),
    );
  }

  Widget _getExampleBox({required String text}) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.p12),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black38, offset: Offset.fromDirection(2, 2))],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () => setState(() => _controller.text = text),
                child: Text(AppStrings.copyToDesc, style: TextStyle(color: ColorManager.secondary, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: AppSize.s20),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}