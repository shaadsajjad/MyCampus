import 'package:mycampus/features/join_requests/data/models/member_record_model.dart';
import 'package:mycampus/features/join_requests/domain/exceptions/join_requests_exception.dart'
    show JoinRequestsException;
import 'package:pocketbase/pocketbase.dart';

/// The only file in the `join_requests` feature that talks to the
/// PocketBase SDK directly — `JoinRequestsRepositoryImpl` works with
/// [MemberRecordModel] and [JoinRequestsException], never `RecordModel`/
/// `ClientException`.
abstract class JoinRequestsRemoteDataSource {
  String? get currentUniversityId;

  Future<List<MemberRecordModel>> getMembers(String universityId);

  Future<void> updateStatus(String userId, String status);
}

class JoinRequestsRemoteDataSourceImpl implements JoinRequestsRemoteDataSource {
  new(this._pb);

  final PocketBase _pb;

  @override
  String? get currentUniversityId {
    final value = _pb.authStore.record?.getStringValue('university');
    return value == null || value.isEmpty ? null : value;
  }

  @override
  Future<List<MemberRecordModel>> getMembers(String universityId) async {
    final result = await _pb
        .collection('users')
        .getList(
          page: 1,
          perPage: 500,
          filter: "university = '$universityId'",
          sort: '-created',
          expand: 'students_via_user,teachers_via_user',
        );
    return result.items.map(_toModel).toList();
  }

  @override
  Future<void> updateStatus(String userId, String status) async {
    await _pb.collection('users').update(userId, body: {'status': status});
  }

  MemberRecordModel _toModel(RecordModel record) {
    final studentProfile = _firstOrNull(
      record.get<List<RecordModel>>('expand.students_via_user', const []),
    );
    final teacherProfile = _firstOrNull(
      record.get<List<RecordModel>>('expand.teachers_via_user', const []),
    );
    final avatarField = record.getStringValue('avatar');

    String? roleId;
    String? department;
    String? subInfo;
    if (studentProfile != null) {
      roleId = _emptyToNull(studentProfile.getStringValue('studentId'));
      department = _emptyToNull(studentProfile.getStringValue('department'));
      subInfo = _emptyToNull(studentProfile.getStringValue('batch'));
    } else if (teacherProfile != null) {
      roleId = _emptyToNull(teacherProfile.getStringValue('teacherId'));
      department = _emptyToNull(teacherProfile.getStringValue('department'));
      subInfo = _emptyToNull(teacherProfile.getStringValue('designation'));
    }

    return MemberRecordModel(
      id: record.id,
      name: record.getStringValue('name'),
      email: record.getStringValue('email'),
      role: record.getStringValue('role'),
      status: record.getStringValue('status'),
      created: record.getStringValue('created'),
      avatarUrl: avatarField.isEmpty
          ? null
          : _pb.files.getUrl(record, avatarField).toString(),
      roleId: roleId,
      department: department,
      subInfo: subInfo,
    );
  }

  String? _emptyToNull(String value) => value.isEmpty ? null : value;

  RecordModel? _firstOrNull(List<RecordModel>? records) =>
      records != null && records.isNotEmpty ? records.first : null;
}
