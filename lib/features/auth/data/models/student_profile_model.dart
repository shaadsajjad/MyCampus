import 'package:pocketbase/pocketbase.dart';

/// DTO for a `students` record — the role-specific fields a `users`
/// record doesn't hold, linked back via [userId].
class StudentProfileModel {
  const StudentProfileModel({
    required this.id,
    required this.userId,
    required this.studentId,
    this.department,
    this.batch,
  });

  factory StudentProfileModel.fromRecord(RecordModel record) {
    return StudentProfileModel(
      id: record.id,
      userId: record.getStringValue('user'),
      studentId: record.getStringValue('studentId'),
      department: _emptyToNull(record.getStringValue('department')),
      batch: _emptyToNull(record.getStringValue('batch')),
    );
  }

  final String id;
  final String userId;
  final String studentId;
  final String? department;
  final String? batch;

  static String? _emptyToNull(String value) => value.isEmpty ? null : value;
}
