import 'package:mycampus/core/config/app_config.dart';
import 'package:mycampus/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mycampus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mycampus/features/auth/domain/repositories/auth_repository.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal manual dependency injection. `DI.init()` runs once during
/// `bootstrap()`, before anything else reads from this class; every other
/// static member here is a singleton wired from [AppConfig].
class DI {
  DI._();

  static const _authStoreKey = 'pb_auth';

  static late final PocketBase pocketBase;
  static late final AuthRepository authRepository;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    pocketBase = PocketBase(
      AppConfig.pocketbaseUrl,
      authStore: AsyncAuthStore(
        save: (data) async => (await prefs.setString(_authStoreKey, data)),
        initial: prefs.getString(_authStoreKey),
      ),
    );

    authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(pocketBase),
    );
  }
}
