import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mycampus/features/super_admin_profile/data/models/profile_model.dart';
import 'package:pocketbase/pocketbase.dart';

/// The only file in the `super_admin_profile` feature that talks to the
/// PocketBase SDK directly.
abstract class SuperAdminProfileRemoteDataSource {
  /// Read from the persisted auth store — no network call.
  ProfileModel? get cachedProfile;

  Future<ProfileModel> refresh();

  Future<ProfileModel> updateName(String userId, String name);

  Future<ProfileModel> updateAvatar(String userId, Uint8List bytes);

  Future<ProfileModel> removeAvatar(String userId);

  Future<void> requestPasswordReset(String email);

  Future<void> logout();
}

class SuperAdminProfileRemoteDataSourceImpl
    implements SuperAdminProfileRemoteDataSource {
  new(this._pb);

  final PocketBase _pb;

  static const _expand = 'university';

  @override
  ProfileModel? get cachedProfile {
    final record = _pb.authStore.record;
    return record == null ? null : _toModel(record);
  }

  @override
  Future<ProfileModel> refresh() async {
    // authRefresh (rather than getOne) also re-saves the fresh record into
    // the auth store, so every other feature's cached reads stay current.
    final auth = await _pb.collection('users').authRefresh(expand: _expand);
    return _toModel(auth.record);
  }

  @override
  Future<ProfileModel> updateName(String userId, String name) async {
    final record = await _pb
        .collection('users')
        .update(userId, body: {'name': name}, expand: _expand);
    return _toModel(record);
  }

  @override
  Future<ProfileModel> updateAvatar(String userId, Uint8List bytes) async {
    final record = await _pb
        .collection('users')
        .update(
          userId,
          files: [
            http.MultipartFile.fromBytes(
              'avatar',
              bytes,
              filename: 'avatar.jpg',
            ),
          ],
          expand: _expand,
        );
    return _toModel(record);
  }

  @override
  Future<ProfileModel> removeAvatar(String userId) async {
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

  ProfileModel _toModel(RecordModel record) {
    final university = record.get<RecordModel?>('expand.$_expand');
    return ProfileModel(
      id: record.id,
      email: record.getStringValue('email'),
      verified: record.getBoolValue('verified'),
      name: _emptyToNull(record.getStringValue('name')),
      created: _emptyToNull(record.getStringValue('created')),
      avatarUrl: _fileUrl(record, 'avatar'),
      university: university == null
          ? null
          : ProfileUniversityModel(
              id: university.id,
              name: university.getStringValue('name'),
              shortName: university.getStringValue('shortName'),
              type: _emptyToNull(university.getStringValue('type')),
              city: _emptyToNull(university.getStringValue('city')),
              country: _emptyToNull(university.getStringValue('country')),
              establishedAt: _emptyToNull(
                university.getStringValue('establishedAt'),
              ),
              logoUrl: _fileUrl(university, 'logo'),
            ),
    );
  }

  String? _fileUrl(RecordModel record, String field) {
    final filename = record.getStringValue(field);
    if (filename.isEmpty) return null;
    return _pb.files.getUrl(record, filename).toString();
  }

  String? _emptyToNull(String value) => value.isEmpty ? null : value;
}
