import 'package:employee_api/employee_api.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:staffly/app/app.dart';
import 'package:staffly/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final employeeApi = SqliteEmployeeApi(databaseFactory: databaseFactory);
  await employeeApi.open();

  final employeeRepository = EmployeeRepository(employeeApi: employeeApi);

  await bootstrap(() => App(employeeRepository: employeeRepository));
}
