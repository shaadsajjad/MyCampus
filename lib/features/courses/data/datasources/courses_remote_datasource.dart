import 'package:mycampus/features/courses/data/models/course_record_model.dart';
import 'package:pocketbase/pocketbase.dart';

/// The only file in the `courses` feature that talks to the PocketBase SDK
/// directly — `CoursesRepositoryImpl` works with [CourseRecordModel] and
/// `CoursesException`, never `RecordModel`/`ClientException`.
abstract class CoursesRemoteDataSource {
  String? get currentUniversityId;

  Future<List<CourseRecordModel>> getCourses(String universityId);

  Future<void> createCourse({
    required String universityId,
    required String code,
    required String title,
    required int credits,
    required int contactHours,
    String? department,
  });

  Future<void> deleteCourse(String courseId);
}

class CoursesRemoteDataSourceImpl implements CoursesRemoteDataSource {
  CoursesRemoteDataSourceImpl(this._pb);

  final PocketBase _pb;

  @override
  String? get currentUniversityId {
    final value = _pb.authStore.record?.getStringValue('university');
    return value == null || value.isEmpty ? null : value;
  }

  @override
  Future<List<CourseRecordModel>> getCourses(String universityId) async {
    final result = await _pb
        .collection('courses')
        .getList(
          page: 1,
          perPage: 500,
          filter: "university = '$universityId'",
          sort: 'code',
        );
    return result.items.map(_toModel).toList();
  }

  @override
  Future<void> createCourse({
    required String universityId,
    required String code,
    required String title,
    required int credits,
    required int contactHours,
    String? department,
  }) {
    return _pb.collection('courses').create(
      body: {
        'university': universityId,
        'code': code,
        'title': title,
        'credits': credits,
        'contactHours': contactHours,
        if (department != null && department.isNotEmpty)
          'department': department,
      },
    );
  }

  @override
  Future<void> deleteCourse(String courseId) {
    return _pb.collection('courses').delete(courseId);
  }

  CourseRecordModel _toModel(RecordModel record) {
    final department = record.getStringValue('department');
    return CourseRecordModel(
      id: record.id,
      code: record.getStringValue('code'),
      title: record.getStringValue('title'),
      // Number fields come back as a non-null `int` (0 when unset), so
      // they're stringified here to keep the DTO on PocketBase's wire
      // format and let the repository do the parsing.
      credits: '${record.getIntValue('credits')}',
      contactHours: '${record.getIntValue('contactHours')}',
      department: department.isEmpty ? null : department,
    );
  }
}
