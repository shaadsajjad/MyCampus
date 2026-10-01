import 'package:mycampus/features/member_directory/data/models/directory_member_model.dart';
import 'package:pocketbase/pocketbase.dart';

/// The only file in the `member_directory` feature that talks to the
/// PocketBase SDK directly — `MemberDirectoryRepositoryImpl` works with
/// [DirectoryMemberModel] and `MemberDirectoryException`, never
/// `RecordModel`/`ClientException`.
abstract class MemberDirectoryRemoteDataSource {
  String? get currentUniversityId;

  Future<List<DirectoryMemberModel>> getApprovedMembers(String universityId);
}

class MemberDirectoryRemoteDataSourceImpl
    implements MemberDirectoryRemoteDataSource {
  MemberDirectoryRemoteDataSourceImpl(this._pb);

  final PocketBase _pb;

  @override
  String? get currentUniversityId {
    final value = _pb.authStore.record?.getStringValue('university');
    return value == null || value.isEmpty ? null : value;
  }

  @override
  Future<List<DirectoryMemberModel>> getApprovedMembers(
    String universityId,
  ) async {
    final result = await _pb
        .collection('users')
        .getList(
          page: 1,
          perPage: 500,
          // `status = 'approved'` is what makes this a directory rather
          // than a second copy of the join-requests queue: pending and
          // rejected accounts are excluded server-side.
          filter: "university = '$universityId' && status = 'approved'",
          sort: 'name',
          expand: 'students_via_user,teachers_via_user',
        );
    return result.items.map(_toModel).toList();
  }

  DirectoryMemberModel _toModel(RecordModel record) {
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

    return DirectoryMemberModel(
      id: record.id,
      name: record.getStringValue('name'),
      email: record.getStringValue('email'),
      role: record.getStringValue('role'),
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
