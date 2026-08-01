/// The `employees` table: its name, its columns, and the statement that
/// creates it.
///
/// Internal to this package. `employee_repository` deals in `EmployeeRecord`s
/// and never sees a column name.
///
/// Gathering the identifiers here is what stops the schema, the DDL and the
/// row mapping from drifting apart — before this, `full_name` was spelled out
/// in the `CREATE TABLE` string *and* in both directions of the row mapping,
/// so a rename was three edits with nothing to catch a missed one.
abstract final class EmployeesTable {
  /// The table name.
  static const name = 'employees';

  /// Primary key. Uniquely identifies the employee.
  static const id = 'id';

  /// The employee's full name.
  static const fullName = 'full_name';

  /// The employee's job title.
  static const jobTitle = 'job_title';

  /// The country the employee works from.
  static const country = 'country';

  /// The employee's salary, in minor units.
  static const salaryMinorUnits = 'salary_minor_units';

  /// Creates the table.
  ///
  /// Every column the brief requires is `NOT NULL`, so an incomplete employee
  /// is rejected by the database itself and not only by the Dart constructor.
  /// [id] spells out `NOT NULL` because SQLite does not imply it for a
  /// non-`INTEGER` primary key.
  ///
  /// The column names are interpolated rather than written out, which costs
  /// the aligned formatting the literal used to have and buys a single source
  /// of truth for each one.
  static const createStatement =
      '''
CREATE TABLE $name (
  $id TEXT PRIMARY KEY NOT NULL,
  $fullName TEXT NOT NULL,
  $jobTitle TEXT NOT NULL,
  $country TEXT NOT NULL,
  $salaryMinorUnits INTEGER NOT NULL
)''';
}
