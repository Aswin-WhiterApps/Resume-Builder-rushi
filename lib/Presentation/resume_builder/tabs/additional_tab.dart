import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../blocs/additional_tab/additional_bloc.dart';
import '../../../blocs/additional_tab/additional_event.dart';
import '../../../blocs/additional_tab/additional_state.dart';
import '../../../model/model.dart';
import '../../../my_singleton.dart';
import '../../resources/assets_manager.dart';
import '../../resources/color_manager.dart';
import '../../resources/font_manager.dart';
import '../../resources/strings_manager.dart';
import '../../resources/values_manager.dart';

class AdditionalView extends StatefulWidget {
  final String id;
  AdditionalView({super.key, required this.id});

  @override
  State<AdditionalView> createState() => _AdditionalViewState();
}

class _AdditionalViewState extends State<AdditionalView> {
  @override
  void initState() {
    super.initState();
    final userId = MySingleton.userId;
    if (userId != null) {
      context
          .read<AdditionalBloc>()
          .add(LoadAdditionalSections(userId: userId, resumeId: widget.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManager.tabBackground,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSize.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppSize.s8, bottom: AppSize.s20, top: AppSize.s8),
                  child: Text(AppStrings.additionalHeader,
                      style: TextStyle(
                          fontSize: FontSize.s20, fontWeight: FontWeight.bold)),
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
                    padding: EdgeInsets.only(
                        left: AppSize.s8, right: AppSize.s8, top: AppSize.s12),
                    child: BlocBuilder<AdditionalBloc, AdditionalState>(
                      builder: (context, state) {
                        if (state is AdditionalLoading) {
                          return Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator()));
                        }
                        if (state is AdditionalLoaded) {
                          return Column(
                            children: [
                              ...state.sections
                                  .map((section) => _getSection(section))
                                  .toList(),
                              _getAddSectionButton(context: context),
                            ],
                          );
                        }
                        if (state is AdditionalError) {
                          return Center(child: Text(state.message));
                        }
                        return Center(child: Text("Loading..."));
                      },
                    ),
                  ),
                ),
                SizedBox(height: 200),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addSectionDialog({required String title}) {
    final _newSectionController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          alignment: Alignment.center,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                  height: 190,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: FontSize.s20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSize.s28),
                      _getOnlyTextField(
                          controller: _newSectionController,
                          hint: AppStrings.nameHint),
                      const SizedBox(height: AppSize.s28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text(AppStrings.cancel,
                                  style: TextStyle(color: Colors.black))),
                          TextButton(
                              onPressed: () {
                                String value =
                                    _newSectionController.text.trim();
                                if (value.isNotEmpty) {
                                  context
                                      .read<AdditionalBloc>()
                                      .add(AddCustomSection(value));
                                }
                                Navigator.of(dialogContext).pop();
                              },
                              child: Text(AppStrings.done,
                                  style: TextStyle(
                                      color: ColorManager.secondary))),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        );
      },
    ).then((_) {
      _newSectionController.dispose();
    });
  }

  void _addSectionDetailsDialog({required SectionModel section}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SectionDetailsDialog(section: section),
    );
  }

  Future<void> _showDeleteDialog({required SectionModel sectionModel}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          title: Text('Delete ${sectionModel.id}'),
          content: const Text(
              'Are you sure you want to delete this section? This cannot be undone.'),
          actions: <Widget>[
            TextButton(
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.black)),
                onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(
              child:
                  Text('Delete', style: TextStyle(color: ColorManager.primary)),
              onPressed: () {
                context
                    .read<AdditionalBloc>()
                    .add(DeleteCustomSection(sectionModel.id));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getAddSectionButton({required BuildContext context}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _addSectionDialog(title: AppStrings.nameNewSect),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(ImageAssets.addSectIc),
              SizedBox(width: AppSize.s12),
              Text(AppStrings.addSection,
                  style: TextStyle(
                      color: ColorManager.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getSection(SectionModel sectionModel) {
    bool isActive = (sectionModel.value?.isNotEmpty ?? false) ||
        (sectionModel.description?.isNotEmpty ?? false);

    return ListTile(
      onLongPress: () => _showDeleteDialog(sectionModel: sectionModel),
      onTap: () => _addSectionDetailsDialog(section: sectionModel),
      leading: SvgPicture.asset(
          isActive ? ImageAssets.radiaBtnActive : ImageAssets.radioBtnInactive),
      title: Text(
        sectionModel.id,
        style: TextStyle(
            color: Colors.black,
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  /// General purpose TextField widget.
  Widget _getOnlyTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Colors.black, fontSize: FontSize.s16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey, fontSize: FontSize.s16),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent)),
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
      ),
    );
  }
}

class SectionDetailsDialog extends StatefulWidget {
  final SectionModel section;
  const SectionDetailsDialog({Key? key, required this.section})
      : super(key: key);

  @override
  State<SectionDetailsDialog> createState() => _SectionDetailsDialogState();
}

class _SectionDetailsDialogState extends State<SectionDetailsDialog> {
  late List<TextEditingController> _valueControllers;
  late List<TextEditingController> _descriptionControllers;
  final ScrollController _scrollController = ScrollController();
  final String delimiter = '@@@';

  @override
  void initState() {
    super.initState();
    final values = widget.section.value
            ?.split(delimiter)
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    final descriptions = widget.section.description?.split(delimiter) ?? [];

    _valueControllers =
        values.map((v) => TextEditingController(text: v)).toList();
    _descriptionControllers = List.generate(
        _valueControllers.length,
        (i) => TextEditingController(
            text: i < descriptions.length ? descriptions[i] : ''));

    if (_valueControllers.isEmpty) {
      _addEntry();
    }
  }

  @override
  void dispose() {
    for (var c in _valueControllers) {
      c.dispose();
    }
    for (var c in _descriptionControllers) {
      c.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addEntry() {
    if (_valueControllers.length < 3) {
      setState(() {
        _valueControllers.add(TextEditingController());
        _descriptionControllers.add(TextEditingController());
      });
      Timer(
          Duration(milliseconds: 100),
          () => _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Maximum of 3 entries allowed."),
            duration: Duration(seconds: 2)),
      );
    }
  }

  void _removeEntry(int index) {
    setState(() {
      _valueControllers[index].dispose();
      _descriptionControllers[index].dispose();
      _valueControllers.removeAt(index);
      _descriptionControllers.removeAt(index);
    });
  }

  void _onDone() {
    final valuesString =
        _valueControllers.map((c) => c.text.trim()).join(delimiter);
    final descriptionsString =
        _descriptionControllers.map((c) => c.text.trim()).join(delimiter);

    context.read<AdditionalBloc>().add(UpdateSectionDetails(
        widget.section.id, valuesString, descriptionsString));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.section.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: FontSize.s20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_valueControllers.length < 3)
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: Colors.blue, size: 30),
                      onPressed: _addEntry,
                      tooltip: 'Add Entry',
                    ),
                ],
              ),
              const SizedBox(height: AppSize.s20),
              Flexible(
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _valueControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _getOnlyTextField(
                                    controller: _valueControllers[index],
                                    hint: "Name / Title ${index + 1}"),
                                const SizedBox(height: 8),
                                _getOnlyTextField(
                                    controller: _descriptionControllers[index],
                                    hint: "Description (Optional)",
                                    maxLines: 2),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () => _removeEntry(index),
                            tooltip: 'Remove Entry',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSize.s28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(AppStrings.cancel,
                          style: TextStyle(color: Colors.black))),
                  TextButton(
                      onPressed: _onDone,
                      child: Text(AppStrings.done,
                          style: TextStyle(color: ColorManager.secondary))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getOnlyTextField(
      {required TextEditingController controller,
      required String hint,
      int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Colors.black, fontSize: FontSize.s16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey, fontSize: FontSize.s16),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent)),
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
      ),
    );
  }
}
