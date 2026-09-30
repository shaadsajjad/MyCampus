/// Whether a registered account has been reviewed by a super admin yet.
///
/// Super admins are auto-[approved] — they create the university, so
/// there's no one else to approve them. Students and teachers start
/// [pending] until a super admin reviews their request.
enum AccountStatus { pending, approved, rejected }
