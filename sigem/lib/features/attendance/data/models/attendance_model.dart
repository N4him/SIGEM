import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.userName,
    required super.roomName,
    required super.checkIn,
    super.checkOut,
    super.hoursWorked,
    required super.photoUrl,
    required super.status,
    required super.latCheckin,
    required super.lonCheckin,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      userName: json['user_name'] ?? '',
      roomName: json['room_name'] ?? '',
      checkIn: DateTime.parse(json['check_in']),
      checkOut: json['check_out'] != null ? DateTime.parse(json['check_out']) : null,
      hoursWorked: json['hours_worked']?.toDouble(),
      photoUrl: json['photo_url'] ?? '',
      status: json['status'] ?? 'open',
      latCheckin: (json['lat_checkin'] ?? 0).toDouble(),
      lonCheckin: (json['lon_checkin'] ?? 0).toDouble(),
    );
  }
}