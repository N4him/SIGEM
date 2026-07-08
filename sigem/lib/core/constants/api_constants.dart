
class ApiConstants {
static String get baseUrl {
  return 'https://eiscapp.univalle.edu.co/sigem/api';
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