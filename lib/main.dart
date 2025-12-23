import 'package:firebase_core/firebase_core.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('dotenv load skipped or failed: $e');
  }

  // Initialize AdMob with automatic test/production switching
  await AdMobService.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();

  // Initialize AI services
  try {
    await AIServiceManager.instance.initialize();
    print('AI services initialized successfully');
  } catch (e) {
    print('AI services initialization failed: $e');
  }



  runApp(MultiBlocProvider(
    providers: [
             BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(FireUser()),
      ),
      BlocProvider<ContactBloc>(create: (_) => ContactBloc(fireUser: FireUser()),
      ),
      BlocProvider<AdditionalBloc>(create: (_) => AdditionalBloc( ),
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
