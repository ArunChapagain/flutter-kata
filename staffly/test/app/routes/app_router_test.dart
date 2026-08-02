import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staffly/app/app.dart';
import 'package:staffly/employees/view/view.dart';

class _MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  group('router', () {
    const arun = Employee(
      id: 'e1b9f0c4',
      fullName: 'Arun Chapagai',
      jobTitle: 'Software Engineer',
      country: 'Nepal',
      salary: Salary(10000050),
    );

    late EmployeeRepository employeeRepository;

    setUp(() {
      employeeRepository = _MockEmployeeRepository();
      when(
        () => employeeRepository.fetchEmployees(),
      ).thenAnswer((_) async => [arun]);
      when(
        () => employeeRepository.fetchEmployee(any()),
      ).thenAnswer((_) async => arun);
    });

    // `router` is a top-level singleton, so its location survives a test.
    // Put it back where it started so the next test begins at home.
    tearDown(() => router.go(Routes.home));

    testWidgets('builds an $EmployeesPage at ${Routes.home}', (tester) async {
      await tester.pumpWidget(App(employeeRepository: employeeRepository));
      await tester.pumpAndSettle();

      expect(find.byType(EmployeesPage), findsOneWidget);
    });

    testWidgets(
      'builds an add-mode $EmployeeUpsertPage at ${Routes.upsert}',
      (tester) async {
        await tester.pumpWidget(App(employeeRepository: employeeRepository));
        await tester.pumpAndSettle();

        router.go(Routes.upsert);
        await tester.pumpAndSettle();

        expect(find.byType(EmployeeUpsertPage), findsOneWidget);
        expect(find.text('Add Employee'), findsWidgets);
      },
    );

    testWidgets(
      'builds an edit-mode $EmployeeUpsertPage at ${Routes.upsertEditTemplate}, '
      'passing the employeeId path parameter through',
      (tester) async {
        await tester.pumpWidget(App(employeeRepository: employeeRepository));
        await tester.pumpAndSettle();

        router.go(Routes.upsertEdit(arun.id));
        await tester.pumpAndSettle();

        expect(find.byType(EmployeeUpsertPage), findsOneWidget);
        expect(find.text('Edit Employee'), findsWidgets);
        // The id reached the page — the only way the fetch could fire with it.
        verify(() => employeeRepository.fetchEmployee(arun.id)).called(1);
      },
    );
  });
}
