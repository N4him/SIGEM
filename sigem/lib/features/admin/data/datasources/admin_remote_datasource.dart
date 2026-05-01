import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';

class AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSource(this.apiClient);

  Future<List<Map<String, dynamic>>> getMonitors() async {
    try {
      final response = await apiClient.get('/admin/users/');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception('Error al obtener monitores');
    }
  }

  Future<void> createMonitor({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String password2,
  }) async {
    try {
      await apiClient.post('/admin/users/create/', data: {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'password': password,
        'password2': password2,
      });
    } on DioException catch (e) {
      final error = e.response?.data['errors']?.toString() ?? 'Error al crear monitor';
      throw Exception(error);
    }
  }

  Future<void> updateMonitor({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      await apiClient.patch('/admin/users/$userId/', data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      });
    } on DioException catch (e) {
      throw Exception('Error al actualizar monitor');
    }
  }

  Future<void> toggleUserActive(String userId) async {
    try {
      await apiClient.patch('/admin/users/$userId/toggle/');
    } on DioException catch (e) {
      throw Exception('Error al cambiar estado del usuario');
    }
  }

  Future<void> deleteMonitor(String userId) async {
    try {
      await apiClient.delete('/admin/users/$userId/');
    } on DioException catch (e) {
      throw Exception('Error al borrar monitor');
    }
  }

Future<Map<String, dynamic>> getReports({
  String filter = 'all',
  String? fromDate,
  String? toDate,
  int? roomId,
  String? userId,
}) async {
  try {
    final params = <String, dynamic>{'filter': filter};
    if (fromDate != null) params['from'] = fromDate;
    if (toDate != null) params['to'] = toDate;
    if (roomId != null) params['room_id'] = roomId;
    if (userId != null) params['user_id'] = userId;
    final response = await apiClient.get('/admin/reports/', params: params);
    return response.data as Map<String, dynamic>;
  } on DioException catch (e) {
    throw Exception('Error al obtener reportes');
  }
}

Future<Map<String, dynamic>> getFilterOptions() async {
  try {
    final response = await apiClient.get('/admin/reports/filters/');
    return response.data as Map<String, dynamic>;
  } on DioException catch (e) {
    throw Exception('Error al obtener opciones de filtro');
  }
}
}