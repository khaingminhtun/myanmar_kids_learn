import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/session/session_cubit.dart';

class MyanmarKidsApp extends StatefulWidget {
  const MyanmarKidsApp({super.key, required this.session});

  final SessionCubit session;

  @override
  State<MyanmarKidsApp> createState() => _MyanmarKidsAppState();
}

class _MyanmarKidsAppState extends State<MyanmarKidsApp> {
  late final GoRouter _router = createAppRouter(session: widget.session);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionCubit>.value(
      value: widget.session,
      child: MaterialApp.router(
        title: 'မြန်မာ ကလေးများ — အော့ဖ်လိုင်း သင်ယူရေး',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
        locale: const Locale('my'),
        supportedLocales: const [
          Locale('my'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
