import 'package:pocketbase/pocketbase.dart';

/// The only file in the `dashboard` feature that talks to the PocketBase
/// SDK directly. `currentUser*` are local, synchronous reads of the
/// persisted auth store record — no network call.
abstract class DashboardRemoteDataSource {
  String? get currentUserRole;
  String? get currentUserName;
  String? get currentUserEmail;
  String? get currentUserStatus;

  Future<void> logout();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl(this._pb);

  final PocketBase _pb;

  RecordModel? get _record => _pb.authStore.record;

  @override
  String? get currentUserRole => _emptyToNull(_record?.getStringValue('role'));

  @override
  String? get currentUserName => _emptyToNull(_record?.getStringValue('name'));

  @override
  String? get currentUserEmail =>
      _emptyToNull(_record?.getStringValue('email'));

  @override
  String? get currentUserStatus =>
      _emptyToNull(_record?.getStringValue('status'));

  @override
  Future<void> logout() async => _pb.authStore.clear();

  String? _emptyToNull(String? value) =>
      value == null || value.isEmpty ? null : value;
}
