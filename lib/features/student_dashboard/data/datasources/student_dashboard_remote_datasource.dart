import 'package:mycampus/features/student_dashboard/data/models/student_profile_model.dart';
import 'package:mycampus/features/student_dashboard/data/models/student_university_model.dart';
import 'package:pocketbase/pocketbase.dart';

/// The only file in this feature that talks to the PocketBase SDK directly.
abstract class StudentDashboardRemoteDataSource {
  String? get currentStudentName;
  String? get currentStudentEmail;
  String? get currentUniversityId;
  String? get currentStatus;
  String? get currentAvatarFileName;
  String? get currentAvatarUrl;
  String? get currentUserId;

  Future<StudentUniversityModel> getUniversity(String id);

  /// Fetch the role-specific profile (studentId, department, batch) for the
  /// given user — `null` if none exists yet (registration still pending on
  /// the relation-write step).
  Future<StudentProfileModel?> getStudentProfile(String userId);

  Future<void> logout();

  /// Subscribe to changes on the signed-in student's `users` record (e.g.
  /// super-admin approval flipping `status` from `pending` → `approved`).
  /// Returns an unsubscribe handle, or null if there's no signed-in account
  /// to watch.
  Future<void> Function()? watchCurrentUser({required void Function() onChange});
}

class StudentDashboardRemoteDataSourceImpl
    implements StudentDashboardRemoteDataSource {
  StudentDashboardRemoteDataSourceImpl(this._pb);

  final PocketBase _pb;

  RecordModel? get _record => _pb.authStore.record;

  @override
  String? get currentStudentName =>
      _emptyToNull(_record?.getStringValue('name'));

  @override
  String? get currentStudentEmail =>
      _emptyToNull(_record?.getStringValue('email'));

  @override
  String? get currentUniversityId =>
      _emptyToNull(_record?.getStringValue('university'));

  @override
  String? get currentStatus => _emptyToNull(_record?.getStringValue('status'));

  @override
  String? get currentAvatarFileName => _emptyToNull(_record?.getStringValue('avatar'));

  @override
  String? get currentUserId => _record?.id;

  /// Authenticated URL for the signed-in user's `avatar` file, or null if
  /// none is set.
  @override
  String? get currentAvatarUrl {
    final fileName = currentAvatarFileName;
    final record = _record;
    if (fileName == null || record == null) return null;
    return _pb.files.getUrl(record, fileName).toString();
  }

  @override
  Future<StudentUniversityModel> getUniversity(String id) async {
    final record = await _pb.collection('universities').getOne(id);
    final logoField = record.getStringValue('logo');
    final logoUrl = logoField.isEmpty
        ? null
        : _pb.files.getUrl(record, logoField).toString();
    return StudentUniversityModel.fromRecord(record, logoUrl: logoUrl);
  }

  @override
  Future<StudentProfileModel?> getStudentProfile(String userId) async {
    final result = await _pb
        .collection('students')
        .getList(
          page: 1,
          perPage: 1,
          filter: "user = '$userId'",
        );
    if (result.items.isEmpty) return null;
    return StudentProfileModel.fromRecord(result.items.first);
  }

  @override
  Future<void> logout() async => _pb.authStore.clear();

  @override
  Future<void> Function()? watchCurrentUser({
    required void Function() onChange,
  }) {
    final id = _record?.id;
    if (id == null) return null;
    final handle = _pb.collection('users').subscribe(id, (e) {
      onChange();
    });
    return () async {
      final unsubscribe = await handle;
      await unsubscribe();
    };
  }

  String? _emptyToNull(String? value) =>
      value == null || value.isEmpty ? null : value;
}
