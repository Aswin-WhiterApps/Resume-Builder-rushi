import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginWithEmailPassword extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailPassword({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignupWithEmailPassword extends AuthEvent {
  final String email;
  final String password;
  final String userName;

  const SignupWithEmailPassword({
    required this.email,
    required this.password,
    required this.userName,
  });

  @override
  List<Object> get props => [email, password, userName];
}

class LoginWithGoogle extends AuthEvent {}
