/// DTO for a `notices` record plus its expanded `author` name — matches
/// PocketBase's wire format exactly (raw `audience` string, not the parsed
/// domain enum). Parsing into the domain-level `Notice` is the
/// repository's job, not this model's.
class NoticeRecordModel {
  const NoticeRecordModel({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    required this.authorId,
    required this.authorName,
    required this.created,
  });

  final String id;
  final String title;
  final String body;
  final String audience;
  final String authorId;
  final String authorName;
  final String created;
}
