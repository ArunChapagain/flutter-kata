import 'package:app_ui/app_ui.dart';

/// {@template app_text_form_field}
/// A labelled text field.
///
/// The label sits above the field rather than floating inside it, so a form
/// reads as a list of questions even while every field is filled.
///
/// Validation is not performed here — [errorText] is supplied by the caller,
/// which keeps the rules in the form state where they can be unit tested.
/// {@endtemplate}
class AppTextFormField extends StatelessWidget {
  /// {@macro app_text_form_field}
  const AppTextFormField({
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.errorText,
    this.initialValue,
    this.onChanged,
    this.keyboardType,
    this.enabled = true,
    this.isRequired = false,
    super.key,
  });

  /// The label shown above the field.
  final String label;

  /// Placeholder text shown while the field is empty.
  final String? hintText;

  /// An optional icon shown inside the field, before the text.
  final IconData? prefixIcon;

  /// The validation message to surface, or null when the field is valid.
  final String? errorText;

  /// The value the field starts with.
  final String? initialValue;

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether to mark the label as required.
  final bool isRequired;

  /// The type of keyboard to use for the text field.
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.appSpacing;
    final labelStyle = theme.textTheme.titleSmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: labelStyle),
            if (isRequired) ...[
              SizedBox(width: spacing.xxs),
              Text(
                '*',
                style: labelStyle?.copyWith(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
        SizedBox(height: spacing.xs),
        TextFormField(
          initialValue: initialValue,
          enabled: enabled,
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          ),
        ),
      ],
    );
  }
}
