import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/room_model.dart';

class RoomRemoteDataSource {
  final ApiClient apiClient;

  RoomRemoteDataSource(this.apiClient);

  Future<List<RoomModel>> getRooms() async {
    try {
      final response = await apiClient.get(ApiConstants.rooms);
      return (response.data as List)
          .map((e) => RoomModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error al obtener salas');
    }
  }
}