/// Corner radius tokens.
///
/// One token per component rather than a single shared constant: they happen
/// to agree today, and naming them separately means a change to one does not
/// silently travel to the others.
abstract final class AppRadii {
  /// The radius of a card or any other elevated surface.
  static const card = 8.0;

  /// The radius of a text field or dropdown.
  static const input = 8.0;

  /// The radius of a button.
  static const button = 8.0;
}
