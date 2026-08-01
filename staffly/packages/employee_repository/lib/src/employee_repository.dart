import 'package:employee_api/employee_api.dart';
import 'package:employee_repository/src/exceptions/exceptions.dart';
import 'package:employee_repository/src/models/models.dart';
import 'package:uuid/uuid.dart';

/// {@template employee_repository}
/// Orchestrates employee storage and translates between the two shapes an
/// employee has.
///
/// The data layer speaks in `EmployeeRecord`s, whose salary is a bare `int` of
/// paisa matching the SQLite column. Everything above this class speaks in
/// [Employee]s, whose salary is a [Salary]. Mapping between them is this
/// class's job, and it is the only crossing point — which is what keeps
/// `employee_api` out of the app entirely.
///
/// The [EmployeeApi] arrives by constructor and is expected to be open
/// already; opening and closing the store belongs to whoever owns its
/// lifetime, which is the composition root.
/// {@endtemplate}
class EmployeeRepository {
  /// {@macro employee_repository}
  ///
  /// Callers pass `employeeApi:` — the field stays private, so no consumer can
  /// reach the data layer back through this class.
  ///
  /// [idGenerator] exists so tests can pin the id a created employee gets.
  /// Left out, employees are identified by a UUID v4.
  EmployeeRepository({
    required this._employeeApi,
    String Function()? idGenerator,
  }) : _idGenerator = idGenerator ?? const Uuid().v4;

  final EmployeeApi _employeeApi;
  final String Function() _idGenerator;

  /// Returns every stored employee.
  Future<List<Employee>> fetchEmployees() =>
      _translatingApiExceptions(() async {
        final records = await _employeeApi.readAll();

        return records.map(_toEmployee).toList();
      });

  /// Stores a new employee and returns it.
  ///
  /// The id is assigned here rather than passed in: identity is a domain
  /// concern, so the presentation layer never invents one.
  Future<Employee> createEmployee({
    required String fullName,
    required String jobTitle,
    required String country,
    required Salary salary,
  }) async {
    final employee = Employee(
      id: _idGenerator(),
      fullName: fullName,
      jobTitle: jobTitle,
      country: country,
      salary: salary,
    );

    await _translatingApiExceptions(
      () => _employeeApi.create(_toRecord(employee)),
    );

    return employee;
  }

  /// Overwrites the stored employee that [employee] shares an id with, and
  /// returns it.
  Future<Employee> updateEmployee(Employee employee) async {
    await _translatingApiExceptions(
      () => _employeeApi.update(_toRecord(employee)),
    );

    return employee;
  }

  /// Removes the stored employee with the given [id].
  Future<void> deleteEmployee(String id) =>
      _translatingApiExceptions(() => _employeeApi.delete(id));

  Future<T> _translatingApiExceptions<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on EmployeeApiException catch (error) {
      throw switch (error) {
        EmployeeNotFoundApiException() => EmployeeNotFoundException(
          error.cause,
        ),
        EmployeeStorageApiException() => EmployeeStorageException(error.cause),
      };
    }
  }

  Employee _toEmployee(EmployeeRecord record) => Employee(
    id: record.id,
    fullName: record.fullName,
    jobTitle: record.jobTitle,
    country: record.country,
    salary: Salary(record.salaryMinorUnits),
  );

  EmployeeRecord _toRecord(Employee employee) => EmployeeRecord(
    id: employee.id,
    fullName: employee.fullName,
    jobTitle: employee.jobTitle,
    country: employee.country,
    salaryMinorUnits: employee.salary.toPaisa(),
  );
}
