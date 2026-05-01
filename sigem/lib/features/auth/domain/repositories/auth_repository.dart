import '../../domain/entities/user_entity.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<({String access, String refresh, UserEntity user})> login({
    required String email,
    required String password,
  });

  Future<UserEntity> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String password2,
  });

  Future<UserEntity> getMe();
}