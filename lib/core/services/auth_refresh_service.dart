import 'package:pocketbase/pocketbase.dart';

/// Re-fetches the signed-in `users` record from PocketBase and rewrites it
/// into the shared [PocketBase] auth store so every feature's
/// `_pb.authStore.record` readers (dashboard, join_university, student/
/// teacher dashboards, notices, ...) automatically pick up the new values
/// after a server-side change.
///
/// The motivating flow is: a student or teacher sits on the "waiting for
/// admin approval" screen; the super admin taps Approve in their join-requests
/// tab; without this refresh nothing on the student side changes until the
/// next login. Calling [refreshCurrentUser] on the realtime event makes
/// the dashboard rebuild itself with the new status.
///
/// This lives in `core/`, so it must not know *how* a [PocketBase] client is
/// obtained — [AuthRefreshServiceImpl]'s client is injected by the composition
/// root (`DI.init`) rather than read off the locator. That is what keeps the
/// `core/` → `DI` → every feature's data layer circular import out of the
/// app, and it's the same injection shape `DeepLinkService` already uses
/// for its repository.
///
/// Returns `true` only when a fresh record was fetched *and* written back
/// into the auth store. Callers should treat `false` as "couldn't refresh,
/// ignore the change": there's no signed-in account, the fetch failed, or
/// the record came back but wasn't saved.
abstract class AuthRefreshService {
  Future<bool> refreshCurrentUser();
}

class AuthRefreshServiceImpl implements AuthRefreshService {
  AuthRefreshServiceImpl(this._pocketBase);

  final PocketBase _pocketBase;

  @override
  Future<bool> refreshCurrentUser() async {
    final record = _pocketBase.authStore.record;
    final token = _pocketBase.authStore.token;
    if (record == null || token.isEmpty) return false;

    try {
      final fresh = await _pocketBase.collection('users').getOne(record.id);
      _pocketBase.authStore.save(token, fresh);
      return true;
    } catch (_) {
      // Best-effort: if the network blip fails, leave the stale record
      // in place — the next realtime event (or manual reload) will pick
      // it up. Don't surface as an exception since callers are already
      // reacting to a successful upstream event.
      return false;
    }
  }
}
