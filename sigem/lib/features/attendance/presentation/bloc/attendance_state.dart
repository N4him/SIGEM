import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}
class AttendanceLoading extends AttendanceState {}

class CheckInSuccess extends AttendanceState {
  final AttendanceEntity record;
  const CheckInSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

class CheckOutSuccess extends AttendanceState {
  final AttendanceEntity record;
  const CheckOutSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}