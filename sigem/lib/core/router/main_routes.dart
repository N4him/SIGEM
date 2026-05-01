import 'package:go_router/go_router.dart';
import 'package:sigem/features/admin/data/datasources/presentation/pages/admin_page.dart';
import 'package:sigem/features/attendance/presentation/pages/attendance_page.dart';
import 'package:sigem/features/attendance/presentation/pages/my_records_page.dart';
import 'package:sigem/features/auth/domain/entities/user_entity.dart';
import 'package:sigem/features/home/presentation/pages/home_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final user = state.extra as UserEntity;
        return HomePage(user: user);
      },),
    GoRoute(
      path: '/my-records',
      builder: (context, state) => MyRecordsPage(),
    ),
    GoRoute(
      path: '/attendance',
      builder: (context, state) {
        final user = state.extra as UserEntity;
        return AttendancePage(user: user);
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => AdminPage(),
    ),

  ],
);