import 'package:employee_repository/employee_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staffly/app/routes/routes.dart';
import 'package:staffly/employees/bloc/bloc.dart';
import 'package:staffly/employees/view/view.dart';

import '../../helpers/helpers.dart';

class _MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  group(EmployeesPage, () {
    late EmployeeRepository employeeRepository;

    setUp(() {
      employeeRepository = _MockEmployeeRepository();
      when(
        () => employeeRepository.fetchEmployees(),
      ).thenAnswer((_) async => []);
    });

    Widget buildSubject() => RepositoryProvider.value(
      value: employeeRepository,
      child: const EmployeesPage(),
    );

    testWidgets('renders an app bar with the title "Employee Directory"', (
      tester,
    ) async {
      await tester.pumpApp(buildSubject());
      await tester.pump(); // let the fetch complete

      expect(find.text('Employee Directory'), findsOneWidget);
    });

    testWidgets(
      'renders an app bar with the subtitle '
      '"Manage your team members and details"',
      (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.pump();

        expect(
          find.text('Manage your team members and details'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'dispatches $EmployeesFetchRequested on init by calling fetchEmployees',
      (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.pump();

        // fetchEmployees is called as a direct consequence of the bloc
        // handling EmployeesFetchRequested — the only way it is called.
        verify(() => employeeRepository.fetchEmployees()).called(1);
      },
    );

    testWidgets('contains an $EmployeesView', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.byType(EmployeesView), findsOneWidget);
    });

    group('FAB', () {
      // The upsert route is stubbed rather than real: what is under test here
      // is what the page does with the value the route pops, not the form.
      GoRouter buildRouter({required bool? popValue}) => GoRouter(
        initialLocation: Routes.home,
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (_, _) => buildSubject(),
            routes: [
              GoRoute(
                path: 'upsert',
                builder: (context, _) => Scaffold(
                  body: TextButton(
                    onPressed: () => context.pop(popValue),
                    child: const Text('close'),
                  ),
                ),
              ),
            ],
          ),
        ],
      );

      testWidgets(
        'refetches the list when the upsert screen reports a change',
        (tester) async {
          await tester.pumpRouted(buildRouter(popValue: true));
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          await tester.tap(find.text('close'));
          await tester.pumpAndSettle();

          // Once on init, once because the upsert screen popped `true`.
          verify(() => employeeRepository.fetchEmployees()).called(2);
        },
      );

      testWidgets(
        'does not refetch when the upsert screen is dismissed unchanged',
        (tester) async {
          await tester.pumpRouted(buildRouter(popValue: null));
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          await tester.tap(find.text('close'));
          await tester.pumpAndSettle();

          verify(() => employeeRepository.fetchEmployees()).called(1);
        },
      );
    });
  });
}
