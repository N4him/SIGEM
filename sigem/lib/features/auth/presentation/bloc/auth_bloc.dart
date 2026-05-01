import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/api/service_locator.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final AuthRepositoryImpl _repository;

  AuthBloc() : super(AuthInitial()) {
    _repository = AuthRepositoryImpl(
      AuthRemoteDataSource(sl()),
    );

    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }

Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    final result = await _repository.login(
      email: event.email,
      password: event.password,
    );
    emit(AuthSuccess(result.user));
  } catch (e, stackTrace) {
    emit(AuthError(e.toString().replaceAll('Exception: ', '')));
  }
}

  Future<void> _onRegister(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repository.register(
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        password: event.password,
        password2: event.password2,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await TokenStorage.clearTokens();
    emit(AuthLoggedOut());
  }
}