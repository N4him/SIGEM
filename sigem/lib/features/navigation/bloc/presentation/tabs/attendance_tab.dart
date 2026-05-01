import 'package:flutter/material.dart';
import 'package:sigem/features/attendance/presentation/pages/attendance_page.dart';
import 'package:sigem/features/auth/domain/entities/user_entity.dart';

class AttendanceTab extends StatefulWidget {
  final UserEntity user;
  const AttendanceTab({super.key, required this.user});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AttendancePage(user: widget.user);
  }
}