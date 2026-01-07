import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:resume_builder/Presentation/resources/assets_manager.dart';
import 'package:resume_builder/Presentation/resources/color_manager.dart';
import 'package:resume_builder/Presentation/resources/font_manager.dart';
import 'package:resume_builder/Presentation/resources/strings_manager.dart';
import 'package:resume_builder/blocs/work/work_bloc.dart';
import 'package:resume_builder/blocs/work/work_event.dart';
import 'package:resume_builder/blocs/work/work_state.dart';
import '../../../model/model.dart';
import '../../../my_singleton.dart';
import '../../resources/values_manager.dart';

class WorkTabView extends StatefulWidget {
  WorkTabView({super.key});

  @override
  State<WorkTabView> createState() => WorkTabViewState();
}

class WorkTabViewState extends State<WorkTabView> {
  @override
  void initState() {
    super.initState();
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId != null && resumeId != null) {
      context.read<WorkBloc>().add(LoadWorkList(userId: userId, id: resumeId));
    }
  }

  void _showWorkForm({WorkModel? work}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (ctx) => BlocProvider.value(
        value: context.read<WorkBloc>(),
        child: WorkForm(
          work: work,
          onSave: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WorkModel work) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: const Text("This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<WorkBloc>().add(
                  DeleteWorkplace(
                      id: MySingleton.resumeId!,
                      wid: work.id!,
                      userId: MySingleton.userId!),
                );
              },
              child: const Text("DELETE", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _moveUp(int index) {
    context.read<WorkBloc>().add(MoveWorkUp(index));
  }

  void _moveDown(int index) {
    context.read<WorkBloc>().add(MoveWorkDown(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.tabBackground,
      body: BlocBuilder<WorkBloc, WorkState>(
        builder: (context, state) {
          if (state is WorkLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkLoaded) {
            return Stack(children: [
              if (state.works.isEmpty)
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 150.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _getWorkForm(),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 80, left: 16, right: 16, top: 26),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 150),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.works.length,
                    itemBuilder: (context, index) {
                      final work = state.works[index];

                      final String companyName = (work.compName ?? '').trim();
                      final String position = (work.compPosition ?? '').trim();
                      final String location = (work.compLocation ?? '').trim();
                      final String from = (work.dateFrom ?? '').trim();
                      final String to = ((work.present ?? false)
                              ? 'Present'
                              : (work.dateTo ?? ''))
                          .trim();
                      final String dateRange = [
                        if (from.isNotEmpty) from,
                        if (to.isNotEmpty) to,
                      ].join(' - ');
                      final String roleLine = [
                        if (position.isNotEmpty) position,
                        if (location.isNotEmpty) location,
                      ].join(' • ');
                      final String details = (work.details ?? '').trim();

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: AppPadding.p8),
                        padding: const EdgeInsets.all(AppPadding.p12),
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
                          padding: const EdgeInsets.only(
                              left: AppPadding.p12,
                              top: 7,
                              bottom: AppPadding.p12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                companyName.isEmpty
                                    ? 'No Company Name'
                                    : companyName,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: FontSize.s20),
                              ),
                              if (roleLine.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: AppPadding.p8),
                                  child: Text(
                                    roleLine,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                      fontSize: FontSize.s14,
                                    ),
                                  ),
                                ),
                              if (dateRange.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: AppPadding.p4),
                                  child: Text(
                                    dateRange,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                      fontSize: FontSize.s12,
                                    ),
                                  ),
                                ),
                              if (details.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: AppPadding.p8),
                                  child: Text(
                                    details,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400,
                                      fontSize: FontSize.s12,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: FontSize.s18),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showWorkForm(work: work),
                                    child: Text(
                                      AppStrings.edit,
                                      style: TextStyle(
                                          color: ColorManager.secondary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: FontSize.s35),
                                  GestureDetector(
                                    onTap: () =>
                                        _showDeleteConfirmationDialog(
                                            context, work),
                                    child: const Text(
                                      AppStrings.delete,
                                      style: TextStyle(
                                        color: Colors
                                            .red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                      onPressed:
                                      index == state.works.length - 1
                                          ? null
                                          : () => _moveDown(index),
                                      icon: Icon(
                                        Icons.arrow_downward_outlined,
                                        color:
                                        index == state.works.length - 1
                                            ? Colors.grey
                                            : ColorManager.secondary,
                                      )),
                                  IconButton(
                                    onPressed: index == 0
                                        ? null
                                        : () => _moveUp(index),
                                    icon: Icon(
                                      Icons.arrow_upward_outlined,
                                      color: index == 0
                                          ? Colors.grey
                                          : ColorManager.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (state.works.isNotEmpty)
                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: FloatingActionButton.extended(
                      onPressed: () => _showWorkForm(),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      icon: SvgPicture.asset(
                        ImageAssets.addSectIc,
                        height: 24,
                        color: ColorManager.secondary,
                      ),
                      label: Text(
                        AppStrings.addWorkPlace,
                        style: TextStyle(
                          color: ColorManager.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ]);
          } else if (state is WorkError) {
            return Center(child: Text("Error: ${state.message}"));
          } else {
            return const Center(child: Text("Loading experiences..."));
          }
        },
      ),
    );
  }

  Widget _getWorkForm() {
    return WorkForm(
      onSave: () {},
    );
  }
}


class WorkForm extends StatefulWidget {
  final WorkModel? work;
  final VoidCallback onSave;

  const WorkForm({Key? key, this.work, required this.onSave}) : super(key: key);

  @override
  _WorkFormState createState() => _WorkFormState();
}

class _WorkFormState extends State<WorkForm> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _companyLocController = TextEditingController();
  final _companyPosController = TextEditingController();
  final _companyPosFromController = TextEditingController();
  final _companyPosUntilController = TextEditingController();
  final _companyWorkDetailsController = TextEditingController();

  bool _presentWork = false;

  @override
  void initState() {
    super.initState();
    if (widget.work != null) {
      _companyNameController.text = widget.work!.compName ?? '';
      _companyLocController.text = widget.work!.compLocation ?? '';
      _companyPosController.text = widget.work!.compPosition ?? '';
      _companyPosFromController.text = widget.work!.dateFrom ?? '';
      _companyPosUntilController.text = widget.work!.dateTo ?? '';
      _presentWork = widget.work!.present ?? false;
      _companyWorkDetailsController.text = widget.work!.details ?? '';
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyLocController.dispose();
    _companyPosController.dispose();
    _companyPosFromController.dispose();
    _companyPosUntilController.dispose();
    _companyWorkDetailsController.dispose();
    super.dispose();
  }

  void _saveWork() {
    if (_formKey.currentState!.validate()) {
      if (!_presentWork &&
          _companyPosFromController.text.isNotEmpty &&
          _companyPosUntilController.text.isNotEmpty) {
        final fromParts = _companyPosFromController.text.split('/');
        final toParts = _companyPosUntilController.text.split('/');

        if (fromParts.length == 2 && toParts.length == 2) {
          final fromDate =
          DateTime(int.parse(fromParts[1]), int.parse(fromParts[0]));
          final toDate =
          DateTime(int.parse(toParts[1]), int.parse(toParts[0]));

          if (toDate.isBefore(fromDate)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Until date cannot be before From date.")),
            );
            return;
          }
        }
      }

      final newWork = WorkModel(
        id: widget.work?.id,
        compName: _companyNameController.text.trim(),
        compLocation: _companyLocController.text.trim(),
        compPosition: _companyPosController.text.trim(),
        dateFrom: _companyPosFromController.text.trim(),
        dateTo: _presentWork ? null : _companyPosUntilController.text.trim(),
        present: _presentWork,
        details: _companyWorkDetailsController.text.trim(),
        sortOrder: widget.work?.sortOrder,
      );

      final bloc = context.read<WorkBloc>();
      if (widget.work == null) {
        bloc.add(AddWork(newWork));
      } else {
        bloc.add(UpdateWork(newWork));
      }

      widget.onSave();
    }
  }

  Widget _getInputTextField({
    required TextEditingController textEditingController,
    required String question,
    required String hint,
    bool isRequired = false,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            color: Colors.black,
            fontSize: FontSize.s14,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          controller: textEditingController,
          maxLines: maxLines ?? 1,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: isRequired
              ? (value) {
            if (value == null || value.trim().isEmpty) {
              return '$question is required';
            }
            return null;
          }
              : null,
          style: const TextStyle(
            color: Colors.black,
            fontSize: FontSize.s20,
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintText: "  $hint",
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: FontSize.s20,
              fontWeight: FontWeight.normal,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ColorManager.secondary),
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectMonthYear(
      BuildContext context,
      TextEditingController controller, {
        DateTime? firstDate,
      }) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate ?? DateTime(1950),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: ColorManager.secondary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ColorManager.secondary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedDate =
          "${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      controller.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.black38,
                      offset: Offset.fromDirection(2, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppPadding.p20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.work == null
                            ? "Add Work Experience"
                            : "Edit Work Experience",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.s18,
                        ),
                      ),
                      const SizedBox(height: AppSize.s20),
                      _getInputTextField(
                        textEditingController: _companyNameController,
                        question: AppStrings.whtCompany,
                        hint: AppStrings.whtCompanyHint,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSize.s20),
                      _getInputTextField(
                        textEditingController: _companyLocController,
                        question: AppStrings.whereCompany,
                        hint: AppStrings.whereCompanyHint,
                      ),
                      const SizedBox(height: AppSize.s20),
                      _getInputTextField(
                        textEditingController: _companyPosController,
                        question: AppStrings.posCompany,
                        hint: AppStrings.posCompanyHint,
                        isRequired: true,
                      ),
                      const SizedBox(height: AppSize.s20),
                      _getInputTextField(
                        textEditingController: _companyWorkDetailsController,
                        question: "WORK DETAILS: ",
                        hint:
                        "Describe your responsibilities, achievements...",
                        isRequired: true,
                        maxLines: 4,
                      ),
                      const SizedBox(height: AppSize.s20),
                      GestureDetector(
                        onTap: () =>
                            _selectMonthYear(context, _companyPosFromController),
                        child: AbsorbPointer(
                          child: _getInputTextField(
                            textEditingController: _companyPosFromController,
                            question: AppStrings.posCompanyFrom,
                            hint: AppStrings.attendedFromHint,
                            isRequired: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSize.s20),
                      GestureDetector(
                        onTap: _presentWork
                            ? null
                            : () {
                          final fromDateText =
                              _companyPosFromController.text;
                          DateTime? fromDate;
                          if (fromDateText.isNotEmpty) {
                            final parts = fromDateText.split('/');
                            if (parts.length == 2) {
                              final month = int.tryParse(parts[0]);
                              final year = int.tryParse(parts[1]);
                              if (month != null && year != null) {
                                fromDate = DateTime(year, month);
                              }
                            }
                          }
                          _selectMonthYear(
                            context,
                            _companyPosUntilController,
                            firstDate: fromDate,
                          );
                        },
                        child: AbsorbPointer(
                          child: _getInputTextField(
                            textEditingController: _companyPosUntilController,
                            question: AppStrings.until,
                            hint: AppStrings.attendedFromHint,
                            isRequired: !_presentWork,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSize.s8),
                      Row(
                        children: [
                          Switch(
                            value: _presentWork,
                            activeColor: Colors.lightBlue,
                      activeThumbImage: AssetImage(ImageAssets.thumbActiveIc),
                      activeTrackColor: Colors.lightBlueAccent.withOpacity(0.3),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: ColorManager.tabBackground,
                            onChanged: (bool value) {
                              setState(() {
                                _presentWork = value;
                                if (value) {
                                  _companyPosUntilController.clear();
                                }
                              });
                            },
                          ),
                          const Text(
                            AppStrings.present,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: FontSize.s12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSize.s20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.secondary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                          onPressed: _saveWork,
                          child: Text(
                            "Save",
                            style: TextStyle(
                              fontSize: 15,
                              color: ColorManager.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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