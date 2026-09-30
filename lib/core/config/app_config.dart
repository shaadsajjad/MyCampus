/// The build flavor, set once at startup by the `main_*.dart` entrypoint.
enum AppFlavor { development, staging, production }

/// Per-flavor configuration (API base URLs, etc.), set once at startup by
/// the `main_*.dart` entrypoint before `bootstrap()` runs. Read via the
/// static getters anywhere in the app — never hardcode an environment URL
/// at the call site.
class AppConfig {
  AppConfig._();

  static AppFlavor? _flavor;
  static String? _pocketbaseUrl;

  static void init({required AppFlavor flavor, required String pocketbaseUrl}) {
    _flavor = flavor;
    _pocketbaseUrl = pocketbaseUrl;
  }

  static AppFlavor get flavor {
    assert(
      _flavor != null,
      'AppConfig.init() must run before AppConfig is read.',
    );
    return _flavor!;
  }

  static String get pocketbaseUrl {
    assert(
      _pocketbaseUrl != null,
      'AppConfig.init() must run before AppConfig is read.',
    );
    return _pocketbaseUrl!;
  }
}
