import 'package:pocketbase/pocketbase.dart';

/// DTO for a `students` record — the role-extension schema that the
/// `register_student` flow creates alongside the user's auth record.
class StudentProfileModel {
  const new({
    required this.id,
    required this.studentId,
    required this.department,
    required this.batch,
  });

  factory fromRecord(RecordModel record) {
    return StudentProfileModel(
      id: record.id,
      studentId: record.getStringValue('studentId'),
      department: record.getStringValue('department'),
      batch: record.getStringValue('batch'),
    );
  }

  final String id;
  final String studentId;
  final String department;
  final String batch;
}
