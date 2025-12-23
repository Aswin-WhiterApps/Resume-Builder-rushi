import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resume_builder/blocs/auth/auth_bloc.dart';
import 'package:resume_builder/blocs/auth/auth_state.dart';
import 'package:resume_builder/blocs/work/work_bloc.dart';
import 'package:resume_builder/blocs/work/work_state.dart';
import 'package:resume_builder/my_singleton.dart';
import 'package:resume_builder/model/model.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:async';

// Mock classes
class MockAuthBloc extends Mock implements AuthBloc {
  @override
  Stream<AuthState> get stream => Stream.value(AuthInitial());
}

class MockWorkBloc extends Mock implements WorkBloc {
  @override
  Stream<WorkState> get stream => Stream.value(WorkInitial());
}

Future<void> initializeTestDatabase() async {
  // Initialize FFI
  sqfliteFfiInit();
  // Set databaseFactory to FFI
  databaseFactory = databaseFactoryFfi;
}

Widget createWidgetUnderTest(Widget child) {
  // Setup mock data
  MySingleton.userId = 'test-user-id';
  MySingleton.resumeId = 'test-resume-id';
  MySingleton.loggedInUser = UserModel(
    uid: 'test-user-id',
    email: 'test@example.com',
    subscribed: false,
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(create: (_) => MockAuthBloc()),
      BlocProvider<WorkBloc>(create: (_) => MockWorkBloc()),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

Future<void> pumpApp(WidgetTester tester, Widget widget) async {
  await initializeTestDatabase();
  await tester.pumpWidget(createWidgetUnderTest(widget));
  await tester.pumpAndSettle();
}