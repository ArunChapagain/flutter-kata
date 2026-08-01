import 'package:employee_repository/employee_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staffly/app/routes/routes.dart';
import 'package:staffly/employees/view/employee_upsert_page.dart';
import 'package:staffly/employees/view/employees_page.dart';

/// Global navigator key so that go_router owns the root navigator.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// The application's [GoRouter] configuration.
final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: Routes.home,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (_, _) => const EmployeesPage(),
    ),
    GoRoute(
      path: Routes.upsert,
      builder: (_, state) {
        final employee = state.extra as Employee?;
        return EmployeeUpsertPage(employee: employee);
      },
    ),
  ],
);
