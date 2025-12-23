import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/shared_preference/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/auth/auth.dart';
import 'package:resume_builder/my_singleton.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FireUser fireUser;

  AuthBloc(this.fireUser) : super(AuthInitial()) {
    on<CheckAuthStatus>((event, emit) async {
      emit(AuthLoading());
      try {
        final storedUid = await SharedPrefHelper.getUserUid();

        if (storedUid != null) {
          final user = Auth().currentUser;

          if (user != null && user.uid == storedUid) {
            final userModel = await fireUser.getCurrentUser(storedUid);
            if (userModel != null) {
              MySingleton.loggedInUser = userModel;
              MySingleton.userId = storedUid;
              emit(AuthAuthenticated(userModel));
            } else {
              emit(AuthUnauthenticated());
            }
          } else {
            await Auth().signOut();
            await SharedPrefHelper.clearUserUid();
            emit(AuthUnauthenticated());
          }
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthError("Something went wrong: $e"));
      }
    });

    on<LoginWithEmailPassword>(
      (event, emit) async {
        emit(AuthLoading());

        try {
          await Auth()
              .signInWithEmail(email: event.email, password: event.password);

          final user = Auth().currentUser;

          if (user != null) {
            final userModel = await fireUser.getCurrentUser(user.uid);
            if (userModel != null) {
              MySingleton.loggedInUser = userModel;
              MySingleton.userId = user.uid;
              await SharedPrefHelper.saveUserUid(user.uid);
              emit(AuthAuthenticated(userModel));
            } else {
              emit(AuthError("User profile not found"));
            }
          } else {
            emit(AuthError("Login failed"));
          }
        } catch (e) {
          emit(AuthError("Something went wrong"));
        }
      },
    );

    on<SignupWithEmailPassword>((event, emit) async {
      emit(AuthLoading());

      try {
        await Auth().createNewUserWithEmail(
          email: event.email,
          password: event.password,
        );

        final user = Auth().currentUser;

        if (user != null) {
          final existingUser = await fireUser.getCurrentUser(user.uid);
          if (existingUser == null) {
            UserModel userData = UserModel(
              userName: event.userName,
              email: user.email,
              uid: user.uid,
              subscribed: false,
            );
            await fireUser.addUser(userModel: userData);
          }
          MySingleton.loggedInUser = await fireUser.getCurrentUser(user.uid);
          MySingleton.userId = user.uid;
          await SharedPrefHelper.saveUserUid(user.uid);

          emit(AuthAuthenticated(MySingleton.loggedInUser!));
        } else {
          emit(AuthError("Signup failed"));
        }
      } catch (e) {
        emit(AuthError("Something went wrong: $e"));
      }
    });

    on<LoginWithGoogle>((event, emit) async {
      emit(AuthLoading());

      try {
        await Auth().signInWithGoogle();

        final user = Auth().currentUser;
        if (user != null) {
          final existingUser = await fireUser.getCurrentUser(user.uid);
          if (existingUser == null) {
            UserModel userData = UserModel(
              userName: user.displayName ?? '',
              email: user.email ?? '',
              uid: user.uid,
              subscribed: false,
            );
            await fireUser.addUser(userModel: userData);
          }
          MySingleton.loggedInUser = await fireUser.getCurrentUser(user.uid);
          MySingleton.userId = user.uid;
          await SharedPrefHelper.saveUserUid(user.uid);
          emit(AuthAuthenticated(MySingleton.loggedInUser!));
        } else {
          emit(AuthError("Google Sign-In failed"));
        }
      } catch (e) {
        emit(AuthError("Something went wrong: $e"));
      }
    });
  }
}
