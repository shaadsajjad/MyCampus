import 'package:pocketbase/pocketbase.dart';

/// DTO for a `universities` record as seen by the teacher dashboard.
class TeacherUniversityModel {
  const new({
    required this.id,
    required this.name,
    required this.shortName,
    this.logoUrl,
  });

  factory fromRecord(RecordModel record, {String? logoUrl}) {
    return TeacherUniversityModel(
      id: record.id,
      name: record.getStringValue('name'),
      shortName: record.getStringValue('shortName'),
      logoUrl: logoUrl,
    );
  }

  final String id;
  final String name;
  final String shortName;
  final String? logoUrl;
}
