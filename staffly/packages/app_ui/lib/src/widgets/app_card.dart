import 'package:app_ui/app_ui.dart';

/// {@template app_card}
/// A padded surface with the app's corner radius.
///
/// Deliberately domain-agnostic — it knows nothing about what it contains, so
/// this package never has to depend on a domain package to render a list item.
/// {@endtemplate}
class AppCard extends StatelessWidget {
  /// {@macro app_card}
  const AppCard({required this.child, this.onTap, super.key});

  /// The card's content.
  final Widget child;

  /// Called when the card is tapped.
  ///
  /// When null the card offers no ink response at all, so it neither splashes
  /// nor swallows a gesture meant for something beneath it.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    final content = Padding(
      padding: EdgeInsets.all(context.appSpacing.xs),
      child: child,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
