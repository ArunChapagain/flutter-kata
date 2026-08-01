import 'package:app_ui/app_ui.dart';

/// {@template app_empty_state}
/// The placeholder shown where a list would be, when there is nothing in it.
/// {@endtemplate}
class AppEmptyState extends StatelessWidget {
  /// {@macro app_empty_state}
  const AppEmptyState({
    required this.title,
    required this.message,
    this.icon,
    this.action,
    super.key,
  });

  /// The headline — what is missing.
  final String title;

  /// The supporting line — what to do about it.
  final String message;

  /// An optional illustration above the title.
  final IconData? icon;

  /// An optional call to action below the message.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.appSpacing;
    final action = this.action;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: spacing.xxlg,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: spacing.md),
            ],
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.xs),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[SizedBox(height: spacing.lg), action],
          ],
        ),
      ),
    );
  }
}
