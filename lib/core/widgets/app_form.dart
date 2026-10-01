import 'package:flutter/material.dart';

/// Wraps a [Form] and centralizes the "validate then submit" sequence.
///
/// Exists to take form-key ownership off the cubit: the cubit's `submit`
/// method doesn't need to know whether a [Form] is on screen, which is
/// what lets it stay free of `package:flutter` imports (see
/// `clean_architecture.md`'s form-key discussion). The page stays a plain
/// `StatelessWidget` — the [GlobalKey]s below live on this widget, the
/// only `StatefulWidget` in the form flow.
///
/// Typical use:
///
/// ```dart
/// class _MyPageState extends State<MyPage> {
///   final _formKey = GlobalKey<AppFormState>();
///
///   @override
///   Widget build(BuildContext context) => BlocProvider(
///     create: (_) => MyCubit(),
///     child: AppForm(
///       formKey: _formKey,
///       onSubmit: () => context.read<MyCubit>().submit(),
///       child: Column(children: [
///         ...
///         PrimaryActionButton(
///           onPressed: () => _formKey.currentState?.submit(),
///         ),
///       ]),
///     ),
///   );
/// }
/// ```
class AppForm extends StatefulWidget {
  const AppForm({
    required this.onSubmit,
    required this.child,
    this.formKey,
    super.key,
  });

  /// Called only after the form's validation passes.
  final Future<void> Function() onSubmit;

  final Widget child;

  /// Optional. Pass a [GlobalKey] if the parent needs to trigger [submit]
  /// from a button that lives outside this widget's tree (the common case
  /// — the submit button is below the form fields). Without it, the parent
  /// can only submit via something inside the [child] subtree that has its
  /// own reference to the form key.
  final GlobalKey<AppFormState>? formKey;

  @override
  State<AppForm> createState() => AppFormState();
}

class AppFormState extends State<AppForm> {
  final _formKey = GlobalKey<FormState>();

  /// Validates the form and, if it passes, invokes [AppForm.onSubmit].
  /// No-op when the form has already been validated or is empty (treat
  /// that as a passthrough — the submit button guards against calls in
  /// the middle of a submission via [PrimaryActionButton]).
  Future<void> submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: widget.child,
    );
  }
}
