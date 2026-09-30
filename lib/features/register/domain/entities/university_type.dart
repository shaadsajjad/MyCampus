/// The governance type of a university being registered by a super admin.
enum UniversityType { public, private, international }

extension UniversityTypeLabel on UniversityType {
  /// The `en.json` key for this type's display name.
  String get labelKey {
    switch (this) {
      case UniversityType.public:
        return 'university.typePublic';
      case UniversityType.private:
        return 'university.typePrivate';
      case UniversityType.international:
        return 'university.typeInternational';
    }
  }
}
