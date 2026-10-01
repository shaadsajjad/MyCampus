import 'package:mycampus/core/domain/entities/notice_audience.dart';

export 'package:mycampus/core/domain/entities/notice_audience.dart'
    show NoticeAudience;

/// A campus-wide announcement posted by a super admin, scoped to their own
/// university.
class Notice {
  const new({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final NoticeAudience audience;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
}
