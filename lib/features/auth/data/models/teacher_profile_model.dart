import 'package:pocketbase/pocketbase.dart';

/// DTO for a `teachers` record — the role-specific fields a `users`
/// record doesn't hold, linked back via [userId].
class TeacherProfileModel {
  const TeacherProfileModel({
    required this.id,
    required this.userId,
    required this.teacherId,
    this.department,
    this.designation,
  });

  factory TeacherProfileModel.fromRecord(RecordModel record) {
    return TeacherProfileModel(
      id: record.id,
      userId: record.getStringValue('user'),
      teacherId: record.getStringValue('teacherId'),
      department: _emptyToNull(record.getStringValue('department')),
      designation: _emptyToNull(record.getStringValue('designation')),
    );
  }

  final String id;
  final String userId;
  final String teacherId;
  final String? department;
  final String? designation;

  static String? _emptyToNull(String value) => value.isEmpty ? null : value;
}
