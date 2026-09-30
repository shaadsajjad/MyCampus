import 'package:mycampus/core/config/app_config.dart';
import 'package:mycampus/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:mycampus/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mycampus/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mycampus/features/join_requests/data/datasources/join_requests_remote_datasource.dart';
import 'package:mycampus/features/join_requests/data/repositories/join_requests_repository_impl.dart';
import 'package:mycampus/features/join_requests/domain/repositories/join_requests_repository.dart';
import 'package:mycampus/features/login/data/datasources/login_remote_datasource.dart';
import 'package:mycampus/features/login/data/repositories/login_repository_impl.dart';
import 'package:mycampus/features/login/domain/repositories/login_repository.dart';
import 'package:mycampus/features/notices/data/datasources/notices_remote_datasource.dart';
import 'package:mycampus/features/notices/data/repositories/notices_repository_impl.dart';
import 'package:mycampus/features/notices/domain/repositories/notices_repository.dart';
import 'package:mycampus/features/register/data/datasources/register_remote_datasource.dart';
import 'package:mycampus/features/register/data/repositories/register_repository_impl.dart';
import 'package:mycampus/features/register/domain/repositories/register_repository.dart';
import 'package:mycampus/features/super_admin_dashboard/data/datasources/super_admin_dashboard_remote_datasource.dart';
import 'package:mycampus/features/super_admin_dashboard/data/repositories/campus_pass_repository_impl.dart';
import 'package:mycampus/features/super_admin_dashboard/data/repositories/super_admin_dashboard_repository_impl.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/repositories/campus_pass_repository.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/repositories/super_admin_dashboard_repository.dart';
import 'package:mycampus/features/super_admin_profile/data/datasources/super_admin_profile_remote_datasource.dart';
import 'package:mycampus/features/super_admin_profile/data/repositories/super_admin_profile_repository_impl.dart';
import 'package:mycampus/features/super_admin_profile/domain/repositories/super_admin_profile_repository.dart';
import 'package:mycampus/features/verification/data/datasources/verification_remote_datasource.dart';
import 'package:mycampus/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:mycampus/features/verification/domain/repositories/verification_repository.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal manual dependency injection. `DI.init()` runs once during
/// `bootstrap()`, before anything else reads from this class; every other
/// static member here is a singleton wired from [AppConfig].
///
/// Each feature that talks to PocketBase (`login`, `register`,
/// `verification`, `dashboard`, `super_admin_dashboard`, `join_requests`,
/// `super_admin_profile`, `notices`) owns its own repository/datasource/
/// domain types — none of them import another feature's. [pocketBase] is
/// the one thing they all share: a single client so a session started by
/// `login` is visible to `dashboard`, `logout` from any of them clears the
/// same store, etc.
class DI {
  DI._();

  static const _authStoreKey = 'pb_auth';

  static late final PocketBase pocketBase;
  static late final LoginRepository loginRepository;
  static late final RegisterRepository registerRepository;
  static late final VerificationRepository verificationRepository;
  static late final DashboardRepository dashboardRepository;
  static late final SuperAdminDashboardRepository superAdminDashboardRepository;
  static late final JoinRequestsRepository joinRequestsRepository;
  static late final SuperAdminProfileRepository superAdminProfileRepository;
  static late final NoticesRepository noticesRepository;

  /// Device-side export (photo library / share sheet) — no PocketBase.
  static late final CampusPassRepository campusPassRepository;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    pocketBase = PocketBase(
      AppConfig.pocketbaseUrl,
      authStore: AsyncAuthStore(
        save: (data) async {
          await prefs.setString(_authStoreKey, data);
        },
        initial: prefs.getString(_authStoreKey),
      ),
    );

    loginRepository = LoginRepositoryImpl(
      remoteDataSource: LoginRemoteDataSourceImpl(pocketBase),
    );
    registerRepository = RegisterRepositoryImpl(
      remoteDataSource: RegisterRemoteDataSourceImpl(pocketBase),
    );
    verificationRepository = VerificationRepositoryImpl(
      remoteDataSource: VerificationRemoteDataSourceImpl(pocketBase),
    );
    dashboardRepository = DashboardRepositoryImpl(
      remoteDataSource: DashboardRemoteDataSourceImpl(pocketBase),
    );
    superAdminDashboardRepository = SuperAdminDashboardRepositoryImpl(
      remoteDataSource: SuperAdminDashboardRemoteDataSourceImpl(pocketBase),
    );
    joinRequestsRepository = JoinRequestsRepositoryImpl(
      remoteDataSource: JoinRequestsRemoteDataSourceImpl(pocketBase),
    );
    superAdminProfileRepository = SuperAdminProfileRepositoryImpl(
      remoteDataSource: SuperAdminProfileRemoteDataSourceImpl(pocketBase),
    );
    campusPassRepository = CampusPassRepositoryImpl();
    noticesRepository = NoticesRepositoryImpl(
      remoteDataSource: NoticesRemoteDataSourceImpl(pocketBase),
    );
  }
}
