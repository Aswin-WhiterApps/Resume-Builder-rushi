import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:resume_builder/Presentation/resources/assets_manager.dart';
import 'package:resume_builder/Presentation/resources/color_manager.dart';
import 'package:resume_builder/Presentation/resources/font_manager.dart';
import 'package:resume_builder/Presentation/resources/route_manager.dart';
import 'package:resume_builder/Presentation/resources/strings_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:resume_builder/blocs/auth/auth_bloc.dart';
import 'package:resume_builder/blocs/auth/auth_event.dart';
import 'package:resume_builder/blocs/auth/auth_state.dart';
import 'package:resume_builder/constants/colours.dart';

import 'package:wc_form_validators/wc_form_validators.dart';
import 'package:flutter/cupertino.dart';

class SignupView extends StatefulWidget {
  const SignupView({Key? key}) : super(key: key);

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passController = TextEditingController();
  final _confPassController = TextEditingController();
  bool isPassVisible = false;
  bool isPassVisible1 = false;
  String passMatch = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                  child: SpinKitFadingCircle(
                color: Colors.blue,
                size: 50.0,
              )),
            );
          } else {
            Navigator.of(context, rootNavigator: true).pop();
          }

          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, Routes.homescreen);
          } else if (state is AuthError) {
            _showAlertDialog(context, message: state.message);
          }
        },
        child: Scaffold(
          backgroundColor: SignUp_bg,
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.s20, vertical: AppSize.s28),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImageAssets.homeBackground),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.appBarTitle,
                      style: TextStyle(
                        color: ColorManager.primary,
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
                        fontFamily: FontFamily.emblema,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Image.asset(
                      ImageAssets.appLogo,
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _getEmailField(),
                          const SizedBox(height: 20),
                          _getUserNameField(),
                          const SizedBox(height: 20),
                          _getPasswordField(),
                          const SizedBox(height: 20),
                          _getConfirmPasswordField(),
                          const SizedBox(height: 5),
                          Text(passMatch,
                              style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 10),
                          _getSignUpButton(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already having an account?",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: FontFamily.roboto)),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, Routes.loginPage);
                                },
                                child: const Text("Sign In",
                                    style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    FloatingActionButton(
                      backgroundColor: Colors.white,
                      child: SvgPicture.asset(
                        ImageAssets.googleIc,
                        height: 35,
                        width: 35,
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(LoginWithGoogle());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getEmailField() {
    return TextFormField(
      controller: _emailController,
      validator: Validators.email('Invalid email address'),
      style:
          TextStyle(color: ColorManager.primary, fontFamily: FontFamily.roboto),
      decoration: _inputDecoration('Enter email', 'Email@example.com'),
    );
  }

  Widget _getUserNameField() {
    return TextFormField(
      controller: _userNameController,
      style:
          TextStyle(color: ColorManager.primary, fontFamily: FontFamily.roboto),
      decoration: _inputDecoration('UserName', 'UserName'),
    );
  }

  Widget _getPasswordField() {
    return TextFormField(
      controller: _passController,
      obscureText: !isPassVisible,
      validator: Validators.patternRegExp(
        RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$"),
        AppStrings.passwordError,
      ),
      style:
          TextStyle(color: ColorManager.primary, fontFamily: FontFamily.roboto),
      decoration: _passwordInputDecoration('Password', isPassVisible, () {
        setState(() {
          isPassVisible = !isPassVisible;
        });
      }),
    );
  }

  Widget _getConfirmPasswordField() {
    return TextFormField(
      controller: _confPassController,
      obscureText: !isPassVisible1,
      validator: Validators.patternRegExp(
        RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$"),
        AppStrings.passwordError,
      ),
      style:
          TextStyle(color: ColorManager.primary, fontFamily: FontFamily.roboto),
      decoration:
          _passwordInputDecoration('Confirm Password', isPassVisible1, () {
        setState(() {
          isPassVisible1 = !isPassVisible1;
        });
      }),
    );
  }

  Widget _getSignUpButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          if (_passController.text == _confPassController.text) {
            context.read<AuthBloc>().add(
                  SignupWithEmailPassword(
                    email: _emailController.text.trim(),
                    password: _passController.text.trim(),
                    userName: _userNameController.text.trim(),
                  ),
                );
          } else {
            setState(() {
              passMatch = "Password and Confirm Password do not match.";
            });
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.primary,
        shape: const StadiumBorder(),
        minimumSize: const Size(double.infinity, 40),
      ),
      child: Text(
        AppStrings.signUp,
        textScaleFactor: 1.5,
        style: TextStyle(
          fontFamily: FontFamily.roboto,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: ColorManager.faintWhite,
      labelStyle:
          TextStyle(fontFamily: FontFamily.roboto, color: ColorManager.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSize.s28),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorManager.grey)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorManager.primary)),
    );
  }

  InputDecoration _passwordInputDecoration(
      String label, bool isVisible, VoidCallback toggleVisibility) {
    return _inputDecoration(label, label).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
          color: ColorManager.darkGrey,
        ),
        onPressed: toggleVisibility,
      ),
    );
  }

  void _showAlertDialog(BuildContext context, {required String message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Alert"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
