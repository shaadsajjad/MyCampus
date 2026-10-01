import 'package:mycampus/features/join_university/data/models/university_preview_model.dart';
import 'package:pocketbase/pocketbase.dart';

/// The only file in this feature that talks to the PocketBase SDK directly.
abstract class JoinUniversityRemoteDataSource {
  Future<UniversityPreviewModel> getUniversity(String id);
  Future<void> updateOwnMembership(String universityId);
}

class JoinUniversityRemoteDataSourceImpl
    implements JoinUniversityRemoteDataSource {
  new(this._pb);

  final PocketBase _pb;

  @override
  Future<UniversityPreviewModel> getUniversity(String id) async {
    final record = await _pb.collection('universities').getOne(id);
    final logoField = record.getStringValue('logo');
    final logoUrl = logoField.isEmpty
        ? null
        : _pb.files.getUrl(record, logoField).toString();
    return UniversityPreviewModel.fromRecord(record, logoUrl: logoUrl);
  }

  @override
  Future<void> updateOwnMembership(String universityId) async {
    final userId = _pb.authStore.record?.id;
    if (userId == null) {
      throw StateError('No signed-in user to update.');
    }
    await _pb
        .collection('users')
        .update(
          userId,
          body: {'university': universityId, 'status': 'pending'},
        );
  }
}
