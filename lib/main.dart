import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:resume_builder/google_ads/admob_service.dart';
import 'package:resume_builder/blocs/additional_tab/additional_bloc.dart';
import 'package:resume_builder/blocs/auth/auth_bloc.dart';
import 'package:resume_builder/blocs/work/work_bloc.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/services/ai_service_manager.dart';
import 'app/app.dart';
import 'blocs/contact_tab/contact_bloc.dart';
import 'blocs/summary/summary_bloc.dart';

Future<void> main() async {
  // Initialize Flutter bindings at the very beginning
  WidgetsFlutterBinding.ensureInitialized();

  // Set this BEFORE other INITIALIZATIONS
  BindingBase.debugZoneErrorsAreFatal = false;

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('dotenv load skipped or failed: $e');
  }

  // Initialize AdMob
  await AdMobService.initialize();

  // Set preferred orientations and UI mode
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } catch (e) {
    debugPrint('SystemChrome setting failed: $e');
  }

  // Initialize Firebase and Crashlytics
  try {
    if (const bool.fromEnvironment('FLUTTER_TEST_ENV') ||
        Platform.environment.containsKey('FLUTTER_TEST')) {
      debugPrint(
          'Firebase initialization skipped: running in test environment');
    } else {
      await Firebase.initializeApp();

      // Initialize Crashlytics
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Catch async errors using modern PlatformDispatcher
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize AI services
  try {
    await AIServiceManager.instance.initialize();
    debugPrint('AI services initialized successfully');
  } catch (e) {
    debugPrint('AI services initialization failed: $e');
  }

  // Run the app directly
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(FireUser()),
      ),
      BlocProvider<ContactBloc>(
        create: (_) => ContactBloc(fireUser: FireUser()),
      ),
      BlocProvider<AdditionalBloc>(
        create: (_) => AdditionalBloc(),
      ),
      BlocProvider<WorkBloc>(
        create: (_) => WorkBloc(fireUser: FireUser()),
      ),
      BlocProvider(
        create: (_) => SummaryBloc(fireUser: FireUser()),
      ),
    ],
    child: MyApp(),
  ));
}
