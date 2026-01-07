// lib/Presentation/resume_builder/tabs/summary_tab.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resume_builder/blocs/summary/summary_bloc.dart';
import 'package:resume_builder/blocs/summary/summary_event.dart';
import 'package:resume_builder/blocs/summary/summary_state.dart';
import 'package:resume_builder/my_singleton.dart';
import 'package:resume_builder/services/comprehensive_resume_service.dart';
import 'package:resume_builder/services/ai_text_service.dart';
import '../../resources/color_manager.dart';
import '../../resources/font_manager.dart';
import '../../resources/strings_manager.dart';
import '../../resources/values_manager.dart';
import '../../../widgets/ai_suggestions_widget.dart';
import '../../../services/ai_service_manager.dart';

class SummaryTabView extends StatefulWidget {
  const SummaryTabView({super.key});

  @override
  State<SummaryTabView> createState() => SummaryTabViewState();
}

class SummaryTabViewState extends State<SummaryTabView> {
  final TextEditingController _summaryController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadInitialSummary();
    _summaryController.addListener(_onSummaryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _summaryController.removeListener(_onSummaryChanged);
    _summaryController.dispose();
    super.dispose();
  }

  void _loadInitialSummary() {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId != null && resumeId != null) {
      context
          .read<SummaryBloc>()
          .add(LoadSummary(userId: userId, resumeId: resumeId));
    }
  }

  void _onSummaryChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      final userId = MySingleton.userId;
      final resumeId = MySingleton.resumeId;
      if (userId != null && resumeId != null) {
        context.read<SummaryBloc>().add(UpdateSummary(
              userId: userId,
              resumeId: resumeId,
              summary: _summaryController.text,
            ));
      }
    });
  }

  void saveSummary() {
    // Cancel any pending debounced save
    _debounce?.cancel();
    // And trigger an immediate save.
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId != null && resumeId != null) {
      context.read<SummaryBloc>().add(UpdateSummary(
            userId: userId,
            resumeId: resumeId,
            summary: _summaryController.text,
          ));
    }
  }

  /// Sets the controller's text to a given example and triggers a save.
  void _copyExampleToSummary(String text) {
    _summaryController.text = text;
    // The listener will automatically handle saving this change.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SummaryBloc, SummaryState>(
        listener: (context, state) {
          if (state is SummaryLoaded) {
            // Update the controller's text if it's different from the state.
            // This prevents the cursor from jumping during typing.
            if (_summaryController.text != state.summary) {
              _summaryController.text = state.summary;
            }
          } else if (state is SummaryError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ));
          }
        },
        child: BlocBuilder<SummaryBloc, SummaryState>(
          builder: (context, state) {
            if (state is SummaryLoading || state is SummaryInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            return Container(
              color: ColorManager.tabBackground,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSize.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow(),
                    _buildSummaryInputContainer(),
                    const SizedBox(height: AppSize.s20),
                    // AI Suggestions Widget
                    if (AIServiceManager.instance.isAvailable)
                      AISuggestionsWidget(
                        currentText: _summaryController.text,
                        context: 'summary',
                        onSuggestionSelected: (suggestion) {
                          _summaryController.text = suggestion;
                          saveSummary();
                        },
                      ),
                    const SizedBox(height: AppSize.s20),
                    _buildExamplesHeader(),
                    _buildExamplesListView(),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppPadding.p8, bottom: AppPadding.p20, top: AppPadding.p8),
      child: Row(
        children: [
          const Text(
            AppStrings.yourSummeryStat,
            style:
                TextStyle(fontSize: FontSize.s20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Future<void> _refreshSummaryWithAI() async {
    try {
      setState(() {});

      final userId = MySingleton.userId;
      final resumeId = MySingleton.resumeId;
      if (userId == null || resumeId == null) {
        throw Exception('User or resume not found');
      }

      // Collect comprehensive resume details
      final data =
          await ComprehensiveResumeService.instance.collectAllResumeData(
        userId: userId,
        resumeId: resumeId,
      );

      final name = data.fullName.isNotEmpty ? data.fullName : 'Professional';
      final position = data.position ?? 'Professional';
      final skills = data.skills;
      final experiences = data.workExperience
          .map((e) =>
              (e.position ?? '') +
              (e.description != null ? ': ' + e.description! : ''))
          .where((s) => s.trim().isNotEmpty)
          .toList();

      final aiText = await AITextService.instance.generateResumeSummary(
        name: name,
        position: position,
        skills: skills,
        experiences: experiences,
      );

      _summaryController.text = aiText;
      saveSummary();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('AI summary generated'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to refresh with AI: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildSummaryInputContainer() {
    return Container(
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
        padding: const EdgeInsets.fromLTRB(
            AppSize.s8, AppPadding.p12, AppSize.s8, AppPadding.p12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppPadding.p18),
              child: Text(
                AppStrings.summeryScreenText,
                style: TextStyle(color: Colors.grey, fontSize: FontSize.s12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppPadding.p8),
              child: _getMultiLineTextField(
                  textEditingController: _summaryController,
                  hint: AppStrings.yourSummeryHint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamplesHeader() {
    return const Padding(
      padding: EdgeInsets.all(AppPadding.p8),
      child: Text(
        AppStrings.exapmles,
        style: TextStyle(
            color: Colors.black,
            fontSize: FontSize.s12,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExamplesListView() {
    final examples = [
      AppStrings.summaryExample1,
      AppStrings.summaryExample2,
      AppStrings.summaryExample3,
      AppStrings.summaryExample4,
      AppStrings.summaryExample5,
    ];
    return SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: examples.length,
        itemBuilder: (context, index) {
          return _getExampleBox(text: examples[index]);
        },
      ),
    );
  }

  Widget _getMultiLineTextField(
      {required TextEditingController textEditingController,
      required String hint}) {
    return TextField(
      maxLength: 500,
      maxLines: 5,
      minLines: 5,
      controller: textEditingController,
      style: const TextStyle(
          color: Colors.black,
          fontSize: FontSize.s20,
          fontWeight: FontWeight.normal),
      decoration: InputDecoration(
        counterText: '',
        hintText: "  $hint",
        hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: FontSize.s12,
            fontWeight: FontWeight.normal),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.s20),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.s20),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.s20),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _getExampleBox({required String text}) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.p12),
      child: Container(
        height: 700,
        width: 200,
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: TextButton(
                  onPressed: () => _copyExampleToSummary(text),
                  child: Text(
                    AppStrings.copyToDesc,
                    style: TextStyle(
                        color: ColorManager.secondary,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 9,
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
