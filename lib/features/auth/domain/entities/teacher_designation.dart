/// A teacher's academic rank, selected during registration.
enum TeacherDesignation {
  professor,
  associateProfessor,
  assistantProfessor,
  lecturer,
}

extension TeacherDesignationLabel on TeacherDesignation {
  /// The `en.json` key for this designation's display name.
  String get labelKey {
    switch (this) {
      case TeacherDesignation.professor:
        return 'teacher.designationProfessor';
      case TeacherDesignation.associateProfessor:
        return 'teacher.designationAssociateProfessor';
      case TeacherDesignation.assistantProfessor:
        return 'teacher.designationAssistantProfessor';
      case TeacherDesignation.lecturer:
        return 'teacher.designationLecturer';
    }
  }
}
