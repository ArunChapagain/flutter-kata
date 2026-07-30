import 'package:staffly/app/app.dart';
import 'package:staffly/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
