import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:resume_builder/blocs/auth/auth_bloc.dart';
import 'package:resume_builder/blocs/auth/auth_event.dart';
import 'package:resume_builder/blocs/auth/auth_state.dart';
import 'package:resume_builder/constants/colours.dart';
import '../resources/assets_manager.dart';
import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/route_manager.dart';
import '../resources/strings_manager.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _animationController.forward();

    context.read<AuthBloc>().add(CheckAuthStatus());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          await Future.delayed(const Duration(seconds: 3));
          if (state is AuthAuthenticated) {
            if (Navigator.canPop(context)) {
              Navigator.pushReplacementNamed(context, Routes.homescreen);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.homescreen,
                (route) => false,
              );
            }
          } else if (state is AuthUnauthenticated) {
            if (Navigator.canPop(context)) {
              Navigator.pushReplacementNamed(context, Routes.loginPage);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginPage,
                (route) => false,
              );
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Auth Error: ${state.message}")),
            );
          }
        },
        child: Scaffold(
          backgroundColor: splash_back,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: ColorManager.splashBackColor,
              image: DecorationImage(
                image: AssetImage(ImageAssets.homeBackground),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(_animationController),
                          child: const Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: AppPadding.p20),
                            child: Row(children: []),
                          ),
                        ),
                        FadeTransition(
                          opacity: _animationController,
                          child: Text(
                            AppStrings.appBarTitle,
                            style: TextStyle(
                              color: ColorManager.primary,
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                              fontFamily: FontFamily.emblema,
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(_animationController),
                          child: const Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: AppPadding.p20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        FadeTransition(
                          opacity: _animationController,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Semantics(
                              label: 'Resume Builder Application Logo',
                              image: true,
                              child: Image.asset(
                                ImageAssets.appLogo,
                                width: 200,
                                height: 200,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        Semantics(
                          label: 'Whiterapps Logo',
                          image: true,
                          child: FadeTransition(
                            opacity: _animationController,
                            child: Image.asset(
                              ImageAssets.Whiterapps_logo,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _animationController,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Semantics(
                              header: true,
                              child: Text(
                                AppStrings.splashStatement,
                                style: TextStyle(
                                  color: ColorManager.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: FontFamily.emblema,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
