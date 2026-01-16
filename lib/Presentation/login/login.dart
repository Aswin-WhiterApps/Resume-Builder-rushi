import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:resume_builder/Presentation/resources/color_manager.dart';
import 'package:resume_builder/Presentation/resources/font_manager.dart';
import 'package:resume_builder/Presentation/resources/route_manager.dart';
import 'package:resume_builder/blocs/auth/auth_bloc.dart';
import 'package:resume_builder/blocs/auth/auth_event.dart';
import 'package:resume_builder/blocs/auth/auth_state.dart';
import 'package:resume_builder/constants/colours.dart';
import 'package:resume_builder/utils/navigation_helper.dart';
import 'package:wc_form_validators/wc_form_validators.dart';
import '../resources/assets_manager.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool isPassVisible = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return Future(() => true);
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            NavigationHelper.safeShowAuthDialog(
              context,
              const Center(
                child: SpinKitFadingCircle(
                  color: Colors.blue,
                  size: 50.0,
                ),
              ),
            );
          } else {
            NavigationHelper.safeRemoveAuthDialog(context);
          }

          if (state is AuthAuthenticated) {
            // Use enhanced navigation for auth success
            NavigationHelper.navigateToHomeAfterAuth(context);
          } else if (state is AuthError) {
            showAlertDialog(context, message: state.message);
          }
        },
        child: Scaffold(
          backgroundColor: login_bg,
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.s20, vertical: AppSize.s20),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(ImageAssets.homeBackground),
                    fit: BoxFit.cover),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Text(
                      AppStrings.appBarTitle,
                      style: TextStyle(
                        color: ColorManager.primary,
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
                        fontFamily: FontFamily.emblema,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Image.asset(
                        ImageAssets.appLogo,
                        width: 150,
                        height: 150,
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _getEmailField(),
                          const SizedBox(height: 20),
                          _getPasswordField(),
                          const SizedBox(height: 30),
                          _getSignInButton(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: FontFamily.roboto),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, Routes.signupPage);
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FloatingActionButton(
                      backgroundColor: Colors.white,
                      tooltip: 'Sign in with Google',
                      child: SvgPicture.asset(
                        ImageAssets.googleIc,
                        height: 35,
                        width: 35,
                      ),
                      onPressed: () async {
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

  Widget _getSignInButton() {
    return Semantics(
      button: true,
      label: 'Sign In Button',
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final email = _emailController.text.trim();
            final password = _passController.text.trim();

            context.read<AuthBloc>().add(
                  LoginWithEmailPassword(email: email, password: password),
                );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 40),
        ),
        child: Text(
          AppStrings.signIn,
          style: TextStyle(
            fontFamily: FontFamily.roboto,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: FontSize.s16 * 1.5,
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
      decoration: InputDecoration(
        hintText: 'Email@example.com',
        labelText: 'Enter email',
        filled: true,
        fillColor: ColorManager.faintWhite,
        labelStyle: TextStyle(
          fontFamily: FontFamily.roboto,
          color: ColorManager.grey,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSize.s28),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorManager.grey),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorManager.primary),
        ),
      ),
    );
  }

  Widget _getPasswordField() {
    return TextFormField(
      controller: _passController,
      obscureText: !isPassVisible,
      validator: (value) {
        print('Entered password: "${value?.trim()}"');
        final password = value?.trim();
        final regex = RegExp(
          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
        );

        if (!regex.hasMatch(password!)) {
          return 'Password should contain:\n'
              '• at least one uppercase\n'
              '• at least one lowercase\n'
              '• at least one number\n'
              '• at least one special character\n'
              '• at least 8 characters';
        }

        return null;
      },
      style: TextStyle(
        color: ColorManager.primary,
        fontFamily: FontFamily.roboto,
      ),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Password',
        filled: true,
        fillColor: ColorManager.faintWhite,
        labelStyle: TextStyle(
          fontFamily: FontFamily.roboto,
          color: ColorManager.grey,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPassVisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            color: ColorManager.darkGrey,
          ),
          onPressed: () {
            setState(() {
              isPassVisible = !isPassVisible;
            });
          },
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSize.s28),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorManager.grey),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorManager.primary),
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context, {required String message}) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Alert"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              if (Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
              }
            },
          ),
        ],
      ),
    );
  }
}
