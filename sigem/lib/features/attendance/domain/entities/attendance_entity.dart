class AttendanceEntity {
  final String id;
  final String userName;
  final String roomName;
  final DateTime checkIn;
  final DateTime? checkOut;
  final double? hoursWorked;
  final String photoUrl;
  final String status;
  final double latCheckin;
  final double lonCheckin;

  const AttendanceEntity({
    required this.id,
    required this.userName,
    required this.roomName,
    required this.checkIn,
    this.checkOut,
    this.hoursWorked,
    required this.photoUrl,
    required this.status,
    required this.latCheckin,
    required this.lonCheckin,
  });

  bool get isOpen => status == 'open';
}