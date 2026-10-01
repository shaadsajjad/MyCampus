import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mycampus/features/member_profile/data/models/member_profile_model.dart';
import 'package:pocketbase/pocketbase.dart';

/// The only file in the `member_profile` feature that talks to the
/// PocketBase SDK directly.
abstract class MemberProfileRemoteDataSource {
  /// Read from the persisted auth store — no network call.
  MemberProfileModel? get cachedProfile;

  Future<MemberProfileModel> refresh();

  Future<MemberProfileModel> updateName(String userId, String name);

  Future<MemberProfileModel> updateAvatar(String userId, Uint8List bytes);

  Future<MemberProfileModel> removeAvatar(String userId);

  Future<void> requestPasswordReset(String email);

  Future<void> logout();
}

class MemberProfileRemoteDataSourceImpl
    implements MemberProfileRemoteDataSource {
  new(this._pb);

  final PocketBase _pb;

  /// One round trip pulls everything the profile shows: the `users` row,
  /// its university, and the role-extension row. `students_via_user` /
  /// `teachers_via_user` are PocketBase's auto-generated reverse-relation
  /// names for the single-valued `user` relation on those collections
  /// (the same names `join_requests` expands).
  static const _expand = 'university,students_via_user,teachers_via_user';

  @override
  MemberProfileModel? get cachedProfile {
    final record = _pb.authStore.record;
    return record == null ? null : _toModel(record);
  }

  @override
  Future<MemberProfileModel> refresh() async {
    // authRefresh (rather than getOne) also re-saves the fresh record into
    // the auth store, so every other feature's cached reads stay current.
    final auth = await _pb.collection('users').authRefresh(expand: _expand);
    return _toModel(auth.record);
  }

  @override
  Future<MemberProfileModel> updateName(String userId, String name) async {
    final record = await _pb
        .collection('users')
        .update(userId, body: {'name': name}, expand: _expand);
    return _toModel(record);
  }

  @override
  Future<MemberProfileModel> updateAvatar(
    String userId,
    Uint8List bytes,
  ) async {
    final record = await _pb
        .collection('users')
        .update(
          userId,
          files: [
            http.MultipartFile.fromBytes('avatar', bytes, filename: 'avatar.jpg'),
          ],
          expand: _expand,
        );
    return _toModel(record);
  }

  @override
  Future<MemberProfileModel> removeAvatar(String userId) async {
    final record = await _pb
        .collection('users')
        .update(userId, body: {'avatar': null}, expand: _expand);
    return _toModel(record);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _pb.collection('users').requestPasswordReset(email);
  }

  @override
  Future<void> logout() async => _pb.authStore.clear();

  MemberProfileModel _toModel(RecordModel record) {
    return MemberProfileModel(
      id: record.id,
      email: record.getStringValue('email'),
      verified: record.getBoolValue('verified'),
      role: record.getStringValue('role'),
      status: record.getStringValue('status'),
      name: _emptyToNull(record.getStringValue('name')),
      phone: _emptyToNull(record.getStringValue('phone')),
      created: _emptyToNull(record.getStringValue('created')),
      avatarUrl: _fileUrl(record, 'avatar'),
      campus: _toCampus(record),
      student: _toStudent(record),
      teacher: _toTeacher(record),
    );
  }

  MemberCampusModel? _toCampus(RecordModel record) {
    final university = record.get<RecordModel?>('expand.university');
    if (university == null) return null;
    return MemberCampusModel(
      id: university.id,
      name: university.getStringValue('name'),
      shortName: university.getStringValue('shortName'),
      type: _emptyToNull(university.getStringValue('type')),
      city: _emptyToNull(university.getStringValue('city')),
      country: _emptyToNull(university.getStringValue('country')),
      logoUrl: _fileUrl(university, 'logo'),
    );
  }

  MemberStudentModel? _toStudent(RecordModel record) {
    final rows = record.get<List<RecordModel>>(
      'expand.students_via_user',
      const [],
    );
    if (rows.isEmpty) return null;
    final student = rows.first;
    return MemberStudentModel(
      studentId: student.getStringValue('studentId'),
      department: student.getStringValue('department'),
      batch: student.getStringValue('batch'),
    );
  }

  MemberTeacherModel? _toTeacher(RecordModel record) {
    final rows = record.get<List<RecordModel>>(
      'expand.teachers_via_user',
      const [],
    );
    if (rows.isEmpty) return null;
    final teacher = rows.first;
    return MemberTeacherModel(
      teacherId: teacher.getStringValue('teacherId'),
      department: teacher.getStringValue('department'),
      designation: teacher.getStringValue('designation'),
    );
  }

  String? _fileUrl(RecordModel record, String field) {
    final filename = record.getStringValue(field);
    if (filename.isEmpty) return null;
    return _pb.files.getUrl(record, filename).toString();
  }

  String? _emptyToNull(String value) => value.isEmpty ? null : value;
}
