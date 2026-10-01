import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// Shared scaffold for the login/register screens: an [AppBar] with the
/// page title, an optional subtitle, and a scrollable, padded body.
class AuthScaffold extends StatelessWidget {
  const new({
    required this.title,
    required this.child,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (subtitle != null) ...[
                Text(subtitle!, style: textTheme.bodyMedium),
                const SizedBox(height: AppTheme.spaceLg),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
