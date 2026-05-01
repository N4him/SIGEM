import '../../../../core/api/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<({String access, String refresh, UserEntity user})> login({
    required String email,
    required String password,
  }) async {
    final result = await dataSource.login(email: email, password: password);
    await TokenStorage.saveTokens(
      access: result.access,
      refresh: result.refresh,
    );
    return result;
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String password2,
  }) async {
    return await dataSource.register(
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      password: password,
      password2: password2,
    );
  }

  @override
  Future<UserEntity> getMe() async {
    return await dataSource.getMe();
  }
}