import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String role;
  final String phone;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.role,
    required this.phone,
    required this.isActive,
  });

  bool get isMonitor => role == 'monitor';
  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, email, role];
}