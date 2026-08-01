/// The employee CRUD feature.
///
/// Only the view layer is exported. `EmployeesBloc` is provided by
/// `EmployeesPage` and `EmployeeUpsertCubit` by the modal that owns it, so
/// nothing outside this feature ever constructs either — the composition root
/// needs the page and nothing else.
library;

export 'view/view.dart';
