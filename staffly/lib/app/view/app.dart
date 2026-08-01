import 'package:flutter/material.dart';
import 'package:staffly/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Seat for `EmployeesPage`, which the composition root fills once the
      // presentation layer exists. Empty until then rather than showing a
      // placeholder screen no one asked for.
      home: const Scaffold(),
    );
  }
}
