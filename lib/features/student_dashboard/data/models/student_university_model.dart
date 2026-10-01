import 'package:pocketbase/pocketbase.dart';

/// DTO for a `universities` record as seen by the student dashboard.
class StudentUniversityModel {
  const StudentUniversityModel({
    required this.id,
    required this.name,
    required this.shortName,
    this.logoUrl,
  });

  factory StudentUniversityModel.fromRecord(
    RecordModel record, {
    String? logoUrl,
  }) {
    return StudentUniversityModel(
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
