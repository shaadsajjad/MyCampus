import 'package:mycampus/features/super_admin_dashboard/data/models/university_model.dart';
import 'package:pocketbase/pocketbase.dart';

/// The only file in the `super_admin_dashboard` feature that talks to the
/// PocketBase SDK directly. `currentAdmin*` are local, synchronous reads of
/// the persisted auth store record — no network call.
abstract class SuperAdminDashboardRemoteDataSource {
  String? get currentAdminName;
  String? get currentAdminEmail;
  String? get currentUniversityId;

  Future<UniversityModel> getUniversity(String id);

  /// Number of `users` records matching [filter] — used to build the
  /// dashboard's counts without fetching full record pages.
  Future<int> countUsers(String filter);

  Future<void> logout();
}

class SuperAdminDashboardRemoteDataSourceImpl
    implements SuperAdminDashboardRemoteDataSource {
  new(this._pb);

  final PocketBase _pb;

  RecordModel? get _record => _pb.authStore.record;

  @override
  String? get currentAdminName => _emptyToNull(_record?.getStringValue('name'));

  @override
  String? get currentAdminEmail =>
      _emptyToNull(_record?.getStringValue('email'));

  @override
  String? get currentUniversityId =>
      _emptyToNull(_record?.getStringValue('university'));

  @override
  Future<UniversityModel> getUniversity(String id) async {
    final record = await _pb.collection('universities').getOne(id);
    final logoField = record.getStringValue('logo');
    final logoUrl = logoField.isEmpty
        ? null
        : _pb.files.getUrl(record, logoField).toString();
    return UniversityModel.fromRecord(record, logoUrl: logoUrl);
  }

  @override
  Future<int> countUsers(String filter) async {
    final result = await _pb
        .collection('users')
        .getList(page: 1, perPage: 1, filter: filter);
    return result.totalItems;
  }

  @override
  Future<void> logout() async => _pb.authStore.clear();

  String? _emptyToNull(String? value) =>
      value == null || value.isEmpty ? null : value;
}
