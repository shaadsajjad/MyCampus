import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/profile_widgets.dart';

/// Supported app locales, paired with their own-script display name.
///
/// A language's name is never run through `.tr()` — "English" doesn't
/// become "ইংরেজি" just because Bengali is the active locale; every
/// language names itself. This is the one sanctioned exception to "never
/// hardcode user-facing text" in `clean_architecture.md`.
const List<({Locale locale, String label})> _supportedLocales = [
  (locale: Locale('en'), label: 'English'),
  (locale: Locale('bn'), label: 'বাংলা'),
];

/// Tappable "Language" row for a profile screen's Preferences section —
/// shared by every role (`member_profile`, `super_admin_profile`) since
/// switching languages isn't a role-specific concern. Opens a bottom sheet
/// to pick the active locale; `easy_localization` persists the choice
/// itself, so there's nothing else to wire up.
class LanguagePreferenceRow extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final current = _supportedLocales.firstWhere(
      (entry) => entry.locale.languageCode == context.locale.languageCode,
      orElse: () => _supportedLocales.first,
    );
    return ProfileInfoRow(
      icon: Icons.language,
      label: 'profile.language'.tr(),
      value: current.label,
      onTap: () => _showLanguageSheet(context),
    );
  }
}

Future<void> _showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusXl),
      ),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceSm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'profile.language'.tr(),
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
          ),
          for (final entry in _supportedLocales)
            ListTile(
              leading: Icon(
                entry.locale.languageCode == sheetContext.locale.languageCode
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(sheetContext).colorScheme.primary,
              ),
              title: Text(entry.label),
              onTap: () {
                sheetContext.setLocale(entry.locale);
                Navigator.of(sheetContext).pop();
              },
            ),
          const SizedBox(height: AppTheme.spaceSm),
        ],
      ),
    ),
  );
}
