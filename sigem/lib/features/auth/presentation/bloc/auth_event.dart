import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String password;
  final String password2;

  const RegisterRequested({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
    required this.password2,
  });
}

class LogoutRequested extends AuthEvent {}