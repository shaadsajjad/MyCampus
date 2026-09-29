import 'package:pocketbase/pocketbase.dart';

/// DTO for a `universities` record.
class UniversityModel {
  const UniversityModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.adminId,
    this.type,
    this.city,
    this.country,
    this.logoUrl,
  });

  factory UniversityModel.fromRecord(RecordModel record, {String? logoUrl}) {
    return UniversityModel(
      id: record.id,
      name: record.getStringValue('name'),
      shortName: record.getStringValue('shortName'),
      adminId: record.getStringValue('admin'),
      type: _emptyToNull(record.getStringValue('type')),
      city: _emptyToNull(record.getStringValue('city')),
      country: _emptyToNull(record.getStringValue('country')),
      logoUrl: logoUrl,
    );
  }

  final String id;
  final String name;
  final String shortName;
  final String adminId;
  final String? type;
  final String? city;
  final String? country;
  final String? logoUrl;

  static String? _emptyToNull(String value) => value.isEmpty ? null : value;
}
