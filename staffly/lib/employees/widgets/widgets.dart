/// Domain-aware widgets — the employee card and the form body.
///
/// These know about `Employee`, which is why they live here and not in
/// `app_ui`: a design-system package must not depend on a domain package.
library;

export 'employee_card.dart';
