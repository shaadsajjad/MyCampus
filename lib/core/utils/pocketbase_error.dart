import 'package:pocketbase/pocketbase.dart';

/// PocketBase returns structured field-level validation errors (e.g.
/// `{"data": {"email": {"message": "..."}}}`) — surface the first one when
/// present, otherwise fall back to its top-level message. This is
/// necessarily plain English: translating arbitrary backend error text is
/// out of scope, so it isn't run through `en.json`.
///
/// Shared by every feature's repository — each still defines its own
/// exception *type* (`LoginException`, `RegisterException`, ...), but the
/// text extraction is identical PocketBase-response parsing, not feature
/// business logic, so it lives here rather than being copy-pasted per
/// feature.
String pocketBaseErrorMessage(ClientException e) {
  final data = e.response['data'];
  if (data is Map && data.isNotEmpty) {
    final field = data.keys.first;
    final firstError = data.values.first;
    if (firstError is Map && firstError['message'] is String) {
      return '$field: ${firstError['message']}';
    }
  }
  final message = e.response['message'];
  if (message is String && message.isNotEmpty) return message;
  // Temporary: surfaces the raw server response so an unexpected shape is
  // debuggable instead of hidden behind a generic message.
  return 'Request failed (${e.statusCode}): ${e.response}';
}
