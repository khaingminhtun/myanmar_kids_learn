import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'presentation/session/session_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(MyanmarKidsApp(session: getIt<SessionCubit>()));
}
