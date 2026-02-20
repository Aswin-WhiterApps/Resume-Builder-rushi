import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/my_singleton.dart';
import '../../../blocs/contact_tab/contact_bloc.dart';
import '../../../blocs/contact_tab/contact_event.dart';
import '../../../blocs/contact_tab/contact_state.dart';
import '../../resources/color_manager.dart';
import '../../resources/font_manager.dart';
import '../../resources/strings_manager.dart';
import '../../resources/values_manager.dart';

class ContactsTabView extends StatefulWidget {
  const ContactsTabView({super.key});

  @override
  State<ContactsTabView> createState() => ContactsTabViewState();
}

class ContactsTabViewState extends State<ContactsTabView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _socialMedia1Controller = TextEditingController();
  final _personnelWebController = TextEditingController();
  final _addr1Controller = TextEditingController();
  final _addr2Controller = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId != null && resumeId != null) {
      context
          .read<ContactBloc>()
          .add(LoadContactEvent(userId: userId, resumeId: resumeId));
    }

    _emailController.addListener(_onTextChanged);
    _phoneController.addListener(_onTextChanged);
    _socialMedia1Controller.addListener(_onTextChanged);
    _personnelWebController.addListener(_onTextChanged);
    _addr1Controller.addListener(_onTextChanged);
    _addr2Controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _emailController.dispose();
    _phoneController.dispose();
    _socialMedia1Controller.dispose();
    _personnelWebController.dispose();
    _addr1Controller.dispose();
    _addr2Controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      saveContact(showSnackbar: false); // Auto-save silently
    });
  }

  bool validateAndSave() {
    saveContact(showSnackbar: true);
    return _formKey.currentState?.validate() ?? false;
  }

  void saveContact({bool showSnackbar = true}) {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) return;

    final contact = ContactModel(
      email: _emailController.text,
      phone: _phoneController.text,
      socialMediaUrl1: _socialMedia1Controller.text,
      personnelWeb: _personnelWebController.text,
      addr1: _addr1Controller.text,
      addr2: _addr2Controller.text,
    );

    context.read<ContactBloc>().add(SaveContactEvent(
        userId: userId, resumeId: resumeId, contactModel: contact));

    if (showSnackbar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Contact Info Saved!"),
          duration: Duration(seconds: 1)));
    }
  }

  TextEditingController get emailController => _emailController;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactBloc, ContactState>(
      listener: (context, state) {
        if (state is ContactLoaded) {
          if (_emailController.text != (state.contact.email ?? '')) {
            _emailController.text = state.contact.email ?? '';
          }
          if (_phoneController.text != (state.contact.phone ?? '')) {
            _phoneController.text = state.contact.phone ?? '';
          }
          if (_socialMedia1Controller.text !=
              (state.contact.socialMediaUrl1 ?? '')) {
            _socialMedia1Controller.text = state.contact.socialMediaUrl1 ?? '';
          }
          if (_personnelWebController.text !=
              (state.contact.personnelWeb ?? '')) {
            _personnelWebController.text = state.contact.personnelWeb ?? '';
          }
          if (_addr1Controller.text != (state.contact.addr1 ?? '')) {
            _addr1Controller.text = state.contact.addr1 ?? '';
          }
          if (_addr2Controller.text != (state.contact.addr2 ?? '')) {
            _addr2Controller.text = state.contact.addr2 ?? '';
          }
        } else if (state is ContactError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: BlocBuilder<ContactBloc, ContactState>(
          builder: (context, state) {
            if (state is ContactLoading || state is ContactInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            return Container(
              color: ColorManager.tabBackground,
              child: ListView(
                padding: const EdgeInsets.all(AppPadding.p16),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppPadding.p20),
                    child: Text(
                      AppStrings.contactsHeader,
                      style: TextStyle(
                        fontSize: FontSize.s20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildContactForm(),
                  const SizedBox(height: 200),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _contactField(
                controller: _emailController,
                label: AppStrings.emailAddress,
                hint: AppStrings.emailHint,
                validator: _emailValidator,
                keyboardType: TextInputType.emailAddress),
            _contactField(
                controller: _phoneController,
                label: AppStrings.phoneNumber,
                hint: AppStrings.phoneHint,
                validator: _phoneValidator,
                keyboardType: TextInputType.phone),
            _contactField(
                controller: _socialMedia1Controller,
                label: AppStrings.socialMediaURL,
                hint: AppStrings.socialMediaHint),
            _contactField(
                controller: _personnelWebController,
                label: AppStrings.personnelWeb,
                hint: AppStrings.personnelWebHint),
            _contactField(
                controller: _addr1Controller,
                label: AppStrings.whtAddress,
                hint: AppStrings.addr1Hint),
            _contactField(
                controller: _addr2Controller, hint: AppStrings.addr2Hint),
            const Padding(
              padding: EdgeInsets.only(top: AppPadding.p18),
              child: Text(
                AppStrings.contactScreenText,
                style: TextStyle(color: Colors.grey, fontSize: FontSize.s16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactField({
    required TextEditingController controller,
    String? label,
    required String hint,
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: FontSize.s14,
                fontWeight: FontWeight.bold,
              ),
            ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: keyboardType == TextInputType.phone
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            maxLength: keyboardType == TextInputType.phone ? 10 : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              counterText: "",
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorManager.secondary)),
              errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red)),
              errorStyle: const TextStyle(color: Colors.red),
              focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email address";
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }
    if (value.trim().length < 10) {
      return "Enter a valid 10-digit phone number";
    }
    return null;
  }
}
