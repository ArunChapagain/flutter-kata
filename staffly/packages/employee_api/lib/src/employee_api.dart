import 'package:employee_api/src/exceptions/exceptions.dart';
import 'package:employee_api/src/models/models.dart';

/// {@template employee_api}
/// The contract every employee store honours.
///
/// `employee_repository` depends on this rather than on a concrete store, so
/// its tests can mock the whole data layer without pulling `sqflite` in, and
/// the storage backend can be replaced without the repository changing.
///
/// Every method reports failure as an [EmployeeApiException]. No
/// implementation may let a storage-library type escape.
/// {@endtemplate}
abstract class EmployeeApi {
  /// Opens the store, preparing it for use.
  ///
  /// Must be awaited before any other method.
  ///
  /// Throws an [EmployeeStorageApiException] if the store cannot be opened.
  Future<void> open();

  /// Stores [record].
  ///
  /// Throws an [EmployeeStorageApiException] if it cannot be stored.
  Future<void> create(EmployeeRecord record);

  /// Returns every stored employee.
  ///
  /// Throws an [EmployeeStorageApiException] if they cannot be read.
  Future<List<EmployeeRecord>> readAll();

  /// Overwrites the stored employee whose id matches [record]'s.
  ///
  /// Throws an [EmployeeNotFoundApiException] if no employee has that id, and
  /// an [EmployeeStorageApiException] if the write fails.
  Future<void> update(EmployeeRecord record);

  /// Removes the stored employee with the given [id].
  ///
  /// Throws an [EmployeeNotFoundApiException] if no employee has that id, and
  /// an [EmployeeStorageApiException] if the removal fails.
  Future<void> delete(String id);

  /// Releases the store. No other method may be called afterwards.
  Future<void> close();
}
