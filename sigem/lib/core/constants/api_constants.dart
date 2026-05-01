import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    return 'http://10.0.2.2:8000/api';
  }

  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String refresh = '/auth/refresh/';
  static const String me = '/auth/me/';
  static const String checkIn = '/attendance/checkin/';
  static const String checkOut = '/attendance/checkout/';
  static const String myRecords = '/attendance/my-records/';
  static const String rooms = '/rooms/';
  static const String weeklySummary = '/attendance/weekly-summary/';
}