import 'package:pocketbase/pocketbase.dart';

/// DTO for a `universities` record as seen by the join flow — just enough
/// to render a confirmation card, not the full profile `super_admin_
/// dashboard` reads for its own owner.
class UniversityPreviewModel {
  const UniversityPreviewModel({
    required this.id,
    required this.name,
    required this.shortName,
    this.city,
    this.country,
    this.logoUrl,
  });

  factory UniversityPreviewModel.fromRecord(
    RecordModel record, {
    String? logoUrl,
  }) {
    return UniversityPreviewModel(
      id: record.id,
      name: record.getStringValue('name'),
      shortName: record.getStringValue('shortName'),
      city: _emptyToNull(record.getStringValue('city')),
      country: _emptyToNull(record.getStringValue('country')),
      logoUrl: logoUrl,
    );
  }

  final String id;
  final String name;
  final String shortName;
  final String? city;
  final String? country;
  final String? logoUrl;

  static String? _emptyToNull(String value) => value.isEmpty ? null : value;
}
