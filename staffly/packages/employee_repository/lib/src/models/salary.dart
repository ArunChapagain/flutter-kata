import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Matches an unsigned amount in rupees with at most two decimal places.
///
/// Anchored at both ends, so anything else — a sign, a grouping separator, a
/// third decimal digit, a word — simply fails to match and is reported as
/// unparseable rather than silently truncated.
final _rupeesPattern = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$');

/// {@template salary}
/// An employee's salary.
///
/// The currency is the Nepalese rupee: the rupee is the major unit, the paisa
/// the minor, 100 paisa to the rupee. The amount is held as whole paisa in an
/// `int`, never as a `double` — binary floating point cannot represent most
/// decimal money values exactly, and `0.1 + 0.2 != 0.3` is a defect in a
/// salary application rather than a curiosity.
///
/// This is the only place in the codebase that crosses between the two units.
/// [fromRupees] converts in; [toPaisa], [format] and [toEditString] convert
/// out. Nothing else multiplies or divides a salary by 100.
/// {@endtemplate}
class Salary extends Equatable {
  /// {@macro salary}
  ///
  /// Takes the amount in whole paisa.
  const Salary(this._paisa);

  /// Converts an amount typed in [rupees] into a [Salary].
  ///
  /// Returns `null` when [rupees] is not a well-formed amount — a user typing
  /// is the normal path, not an emergency, so this reports failure by
  /// returning rather than by throwing.
  ///
  /// A single decimal place reads as tens of paisa, so `'500.7'` is 500
  /// rupees and 70 paisa. The conversion is integer arithmetic throughout:
  /// routing the value through `double.parse` would reintroduce exactly the
  /// imprecision that storing paisa exists to prevent.
  static Salary? fromRupees(String rupees) {
    final match = _rupeesPattern.firstMatch(rupees);
    if (match == null) return null;

    final wholeRupees = int.parse(match.group(1)!);
    final paisa = int.parse((match.group(2) ?? '').padRight(2, '0'));

    return Salary(wholeRupees * 100 + paisa);
  }

  final int _paisa;

  /// The amount in whole paisa, as the api stores it.
  int toPaisa() => _paisa;

  /// The amount as rupees for display, grouped for [locale].
  ///
  /// The paisa fraction appears only when there is one: `'50,000.50'`, but
  /// `'50,000'` for a whole number of rupees.
  ///
  /// Not for a text field — see [toEditString].
  String format({String? locale}) {
    final numberFormat = NumberFormat.decimalPattern(locale);
    final grouped = numberFormat.format(_paisa ~/ 100);

    final paisa = _paisa % 100;
    if (paisa == 0) return grouped;

    return '$grouped'
        '${numberFormat.symbols.DECIMAL_SEP}'
        '${paisa.toString().padLeft(2, '0')}';
  }

  /// The amount as rupees for seeding a `TextEditingController`.
  ///
  /// Ungrouped and always two decimal places, so that
  /// `Salary.fromRupees(s.toEditString()) == s` for any `s`. [format] is not
  /// interchangeable here: its grouping separators would have to survive
  /// [fromRupees], and an untouched edit form would then fail validation
  /// against its own pre-filled value.
  String toEditString() =>
      '${_paisa ~/ 100}.${(_paisa % 100).toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [_paisa];
}
