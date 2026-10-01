import 'package:easy_localization/easy_localization.dart';

/// Heuristic for distinguishing a translation key from a real error
/// message. Translation keys always live under the `error.` namespace
/// here (see `assets/translations/en.json`), and they're never going to
/// include spaces — PocketBase's English messages always do.
final RegExp _keyPattern = RegExp(r'^error\.[a-zA-Z][a-zA-Z0-9_]*$');

/// Translates [message] only when it looks like a translation key from
/// our `en.json`. Real (server-supplied) text is returned unchanged so we
/// never silently mangle arbitrary backend error strings.
///
/// Used by every cubit that surfaces a repository exception: the data
/// layer throws with a *key* for the paths it controls (`error.unknown`,
/// `error.unreachableServer`) and with the server's English text for
/// everything else (see `core/utils/pocketbase_error.dart`'s doc comment
/// for why translating backend text is out of scope).
String translateError(String message) {
  if (_keyPattern.hasMatch(message)) return message.tr();
  return message;
}
