import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/attendance_model.dart';

class AttendanceRemoteDataSource {
  final ApiClient apiClient;

  AttendanceRemoteDataSource(this.apiClient);

  Future<AttendanceModel> checkIn({
    required int roomId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.checkIn,
        data: {
          'room_id': roomId,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return AttendanceModel.fromJson(response.data['record']);
    } on DioException catch (e) {
      final error = e.response?.data['error'] ??
          e.response?.data['errors']?.toString() ??
          'Error al hacer check-in';
      throw Exception(error);
    }
  }

  Future<AttendanceModel> checkOut({
    required double latitude,
    required double longitude,
    required String photoPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'latitude': latitude,
        'longitude': longitude,
        'photo': await MultipartFile.fromFile(
          photoPath,
          filename: 'checkout.jpg',
        ),
      });

      final response = await apiClient.post(
        ApiConstants.checkOut,
        data: formData,
        isMultipart: true,
      );
      return AttendanceModel.fromJson(response.data['record']);
    } on DioException catch (e) {
      final error = e.response?.data['error'] ??
          e.response?.data['errors']?.toString() ??
          'Error al hacer check-out';
      throw Exception(error);
    }
  }

  Future<List<AttendanceModel>> getMyRecords() async {
    try {
      final response = await apiClient.get(ApiConstants.myRecords);
      return (response.data as List)
          .map((e) => AttendanceModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error al obtener registros');
    }
  }
}