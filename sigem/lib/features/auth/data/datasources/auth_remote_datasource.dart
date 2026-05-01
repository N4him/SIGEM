import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sigem/core/storage/token_storage.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

Future<({String access, String refresh, UserModel user})> login({
  required String email,
  required String password,
}) async {
  try {
    // 1. Obtener tokens
    final tokenResponse = await apiClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );


    // Parsear si viene como String
    Map<String, dynamic> tokenData;
    if (tokenResponse.data is String) {
      tokenData = jsonDecode(tokenResponse.data);
    } else {
      tokenData = tokenResponse.data as Map<String, dynamic>;
    }

    final access = tokenData['access'] as String;
    final refresh = tokenData['refresh'] as String;

    // 2. Guardar tokens
    await TokenStorage.saveTokens(access: access, refresh: refresh);

    // 3. Obtener datos del usuario
    final meResponse = await apiClient.get(ApiConstants.me);
    
    Map<String, dynamic> meData;
    if (meResponse.data is String) {
      meData = jsonDecode(meResponse.data);
    } else {
      meData = meResponse.data as Map<String, dynamic>;
    }

    final user = UserModel.fromJson(meData);

    return (access: access, refresh: refresh, user: user);
  } on DioException catch (e) {
    final message = e.response?.data['detail'] ??
        e.response?.data['errors']?.toString() ??
        'Credenciales incorrectas';
    throw Exception(message);
  }
}

  Future<UserModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String password2,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'password': password,
          'password2': password2,
        },
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      final message = e.response?.data['errors']?.toString() ?? 'Error al registrarse';
      throw Exception(message);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await apiClient.get(ApiConstants.me);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error al obtener usuario');
    }
  }
}