import 'package:mycampus/features/super_admin_dashboard/domain/entities/university_type.dart';

/// The app-level view of a PocketBase `universities` record.
class University {
  const new({
    required this.id,
    required this.name,
    required this.shortName,
    this.type,
    this.city,
    this.country,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String shortName;
  final UniversityType? type;
  final String? city;
  final String? country;
  final String? logoUrl;
}
