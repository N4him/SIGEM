import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class CheckInRequested extends AttendanceEvent {
  final int roomId;
  final double latitude;
  final double longitude;

  const CheckInRequested({
    required this.roomId,
    required this.latitude,
    required this.longitude,
  });
}

class CheckOutRequested extends AttendanceEvent {
  final double latitude;
  final double longitude;
  final String photoPath;

  const CheckOutRequested({
    required this.latitude,
    required this.longitude,
    required this.photoPath,
  });
}