import 'package:app_carl_timbratura_nfc/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../themes/app_theme.dart';

import '../label.dart';

import '../providers/auth.dart';
import '../providers/timbrature.dart';

import '../screens/homepage.dart';
import '../screens/auth_screen.dart';
import '../screens/spash_screen.dart';

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFlutterFire();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Timbrature>(
          create: (ctx) => Timbrature(
            timbratureLista: [],
          ),
          update: (ctx, auth, previousTimbrature) => Timbrature(
            urlAmbiente: auth.urlAmbiente,
            authToken: auth.token,
            user: auth.user,
            timbratureLista:
                previousTimbrature == null ? [] : previousTimbrature.timbrature,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) {
          return MaterialApp(
            title: labels.titoloApp,
            theme: theme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('it'),
            ],
            home: auth.isAuth
                ? HomePage()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: routes,
          );
        },
      ),
    );
  }
}
