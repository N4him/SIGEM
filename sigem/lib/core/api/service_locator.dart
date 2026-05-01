import 'package:get_it/get_it.dart';
import 'api_client.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
}