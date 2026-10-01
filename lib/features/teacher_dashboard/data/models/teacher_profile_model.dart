import 'package:pocketbase/pocketbase.dart';

/// DTO for a `teachers` record — the role-extension schema created
/// alongside the user's auth record by `registerTeacher`.
class TeacherProfileModel {
  const new({
    required this.id,
    required this.teacherId,
    required this.department,
    required this.designation,
  });

  factory fromRecord(RecordModel record) {
    return TeacherProfileModel(
      id: record.id,
      teacherId: record.getStringValue('teacherId'),
      department: record.getStringValue('department'),
      designation: record.getStringValue('designation'),
    );
  }

  final String id;
  final String teacherId;
  final String department;
  final String designation;
}
