import 'package:flutter/material.dart';
import 'package:resume_builder/Presentation/homescreen/homescreen.dart';
import 'package:resume_builder/Presentation/login/login.dart';
import 'package:resume_builder/Presentation/login/signup.dart';
import 'package:resume_builder/Presentation/pdf_viewer/pdf_viewer.dart';
import 'package:resume_builder/Presentation/pp/privacy_policy_page.dart';
import 'package:resume_builder/Presentation/resources/strings_manager.dart';
import 'package:resume_builder/Presentation/resume_builder/resume_builder.dart';
import 'package:resume_builder/Presentation/splash/splash.dart';
import 'package:resume_builder/Presentation/subscription_screen/subscription_screen.dart';
import 'package:resume_builder/Presentation/tou/term_of_use.dart';
import 'package:resume_builder/screens/ats_optimization_screen.dart';
import 'package:resume_builder/screens/enhanced_download_screen.dart';

class Routes {
  static const String splash = "/splash";
  static const String resume_builder = "/resume_builder";
  static const String homescreen = "/homescreen";
  static const String pdfViewer = "/pdfView";
  static const String testPage = "/testPage";
  static const String loginPage = "/loginPage";
  static const String signupPage = "/signupPage";
  static const String subscriptionPage = "/subscriptionPage";
  static const String touPage = "/touPage";
  static const String ppPage = "/ppPage";
  static const String atsOptimizationPage = "/atsOptimizationPage";
  static const String enhancedDownloadPage = "/enhancedDownloadPage";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => SplashView());
      case Routes.resume_builder:
        return MaterialPageRoute(builder: (_) => ResumeBuilderView());
      case Routes.homescreen:
        return MaterialPageRoute(builder: (_) => HomeScreenView());
      case Routes.pdfViewer:
        return MaterialPageRoute(builder: (_) => PdfViewerView());
      case Routes.loginPage:
        return MaterialPageRoute(builder: (_) => LoginView());
      case Routes.signupPage:
        return MaterialPageRoute(builder: (_) => SignupView());
      case Routes.subscriptionPage:
        return MaterialPageRoute(builder: (_) => SubscriptionView());
      case Routes.touPage:
        return MaterialPageRoute(builder: (_) => TouView());
      case Routes.ppPage:
        return MaterialPageRoute(builder: (_) => PrivacyPolicyPage());
      case Routes.atsOptimizationPage:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ATSOptimizationScreen(
            resumeContent: args?['resumeContent'] ?? '',
            jobDescription: args?['jobDescription'],
          ),
        );
     
      case Routes.enhancedDownloadPage:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EnhancedDownloadScreen(
            templateId: args?['templateId'] ?? '1',
            resumeData: args?['resumeData'] ?? {},
            existingPdfFile: args?['existingPdfFile'],
          ),
        );
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.noRouteFound),
        ),
        body: Center(
          child: Text(AppStrings.noRouteFound),
        ),
      ),
    );
  }
}
