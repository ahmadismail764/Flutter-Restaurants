import 'package:get_it/get_it.dart';
import '../services/api_service.dart';
import '../services/http_api_service.dart';
import '../services/location_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<ApiService>(() => HttpApiService());
  getIt.registerLazySingleton<LocationService>(() => LocationService());
}
