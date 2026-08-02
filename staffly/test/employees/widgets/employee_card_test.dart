import 'package:app_ui/app_ui.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staffly/app/routes/routes.dart';
import 'package:staffly/employees/bloc/bloc.dart';
import 'package:staffly/employees/widgets/widgets.dart';

import '../../helpers/helpers.dart';

class _MockEmployeesBloc extends MockBloc<EmployeesEvent, EmployeesState>
    implements EmployeesBloc {}

void main() {
  group(EmployeeCard, () {
    const employee = Employee(
      id: 'e1b9f0c4',
      fullName: 'Jane Doe',
      jobTitle: 'Senior Product Designer',
      country: 'United States',
      salary: Salary(14500000),
    );

    setUpAll(() {
      registerFallbackValue(
        const EmployeesEmployeeDeleted(
          employee: Employee(
            id: 'e1b9f0c4',
            fullName: 'Jane Doe',
            jobTitle: 'Senior Product Designer',
            country: 'United States',
            salary: Salary(14500000),
          ),
        ),
      );
    });

    testWidgets(
      'renders the full name, job title, country and formatted salary',
      (tester) async {
        await tester.pumpApp(const EmployeeCard(employee: employee));

        expect(find.text(employee.fullName), findsOneWidget);
        expect(find.text(employee.jobTitle), findsOneWidget);
        expect(find.text(employee.country), findsOneWidget);
        expect(find.text(employee.salary.format()), findsOneWidget);
      },
    );

    group('delete button', () {
      late EmployeesBloc employeesBloc;

      setUp(() {
        employeesBloc = _MockEmployeesBloc();
        when(() => employeesBloc.state).thenReturn(
          const EmployeesState(
            fetchState: FetchState(status: FetchStatus.success),
          ),
        );
      });

      Widget buildSubject() => BlocProvider.value(
        value: employeesBloc,
        child: const EmployeeCard(employee: employee),
      );

      testWidgets('opens an $AppConfirmDialog when tapped', (tester) async {
        await tester.pumpApp(buildSubject());

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.byType(AppConfirmDialog), findsOneWidget);
      });

      testWidgets(
        'dispatches $EmployeesEmployeeDeleted when the dialog is confirmed',
        (tester) async {
          await tester.pumpApp(buildSubject());

          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          // Tap the confirm button inside the dialog
          await tester.tap(find.text('Delete').last);
          await tester.pumpAndSettle();

          verify(
            () => employeesBloc.add(
              const EmployeesEmployeeDeleted(employee: employee),
            ),
          ).called(1);
        },
      );

      testWidgets('does not dispatch when the dialog is cancelled', (
        tester,
      ) async {
        await tester.pumpApp(buildSubject());

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        verifyNever(
          () => employeesBloc.add(any()),
        );
      });
    });

    group('edit button', () {
      late EmployeesBloc employeesBloc;

      setUp(() {
        employeesBloc = _MockEmployeesBloc();
        when(() => employeesBloc.state).thenReturn(
          const EmployeesState(
            fetchState: FetchState(status: FetchStatus.success),
          ),
        );
      });

      // The edit route is stubbed rather than real: what is under test here is
      // what the card does with the value the route pops, not the form.
      GoRouter buildRouter({required bool? popValue}) => GoRouter(
        initialLocation: Routes.home,
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (_, _) => BlocProvider.value(
              value: employeesBloc,
              child: const Scaffold(
                body: EmployeeCard(employee: employee),
              ),
            ),
            routes: [
              GoRoute(
                path: 'upsert/:employeeId',
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
        'dispatches $EmployeesFetchRequested when the edit screen '
        'reports a change',
        (tester) async {
          await tester.pumpRouted(buildRouter(popValue: true));

          await tester.tap(find.text('Edit'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('close'));
          await tester.pumpAndSettle();

          verify(
            () => employeesBloc.add(const EmployeesFetchRequested()),
          ).called(1);
        },
      );

      testWidgets(
        'does not dispatch when the edit screen is dismissed unchanged',
        (tester) async {
          await tester.pumpRouted(buildRouter(popValue: null));

          await tester.tap(find.text('Edit'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('close'));
          await tester.pumpAndSettle();

          verifyNever(() => employeesBloc.add(any()));
        },
      );
    });
  });
}
