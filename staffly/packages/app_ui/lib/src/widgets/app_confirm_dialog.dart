import 'package:app_ui/app_ui.dart';

/// {@template app_confirm_dialog}
/// A two-action confirmation prompt.
///
/// The confirm action is drawn in the error palette: every confirmation this
/// app asks for is destructive, and a flag that only swaps a colour would be
/// a branch no behavioural test could tell apart.
///
/// Dismissal is the caller's job — the dialog reports the choice and nothing
/// more, so this package never reaches for a [Navigator].
/// {@endtemplate}
class AppConfirmDialog extends StatelessWidget {
  /// {@macro app_confirm_dialog}
  const AppConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  /// The question being asked.
  final String title;

  /// What will happen if the user confirms.
  final String message;

  /// The label on the confirming action.
  final String confirmLabel;

  /// The label on the dismissing action.
  final String cancelLabel;

  /// Called when the user confirms.
  final VoidCallback onConfirm;

  /// Called when the user backs out.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: onCancel, child: Text(cancelLabel)),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
