import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../themes/app_theme.dart';

import '../label.dart';

import '../providers/auth.dart';
import '../providers/timbrature.dart';

import '../screens/homepage.dart';
import '../screens/auth_screen.dart';
import '../screens/spash_screen.dart';
import '../screens/tag_screen.dart';
import '../screens/result_screen.dart';
import '../screens/timbrature_list_screen.dart';

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

// Inizializzazione App
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inizializzazione Firebase
  await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      );
  FlutterError.onError = (errorDetails) {
    // If you wish to record a "non-fatal" exception, please use `FirebaseCrashlytics.instance.recordFlutterError` instead
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    // If you wish to record a "non-fatal" exception, please remove the "fatal" parameter
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(App());
}

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
        builder: (ctx, auth, _) => MaterialApp(
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
              ? MyHomePage()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            MyHomePage.routeName: (ctx) => MyHomePage(),
            TagScreen.routeName: (ctx) => TagScreen(),
            ResultScreen.routeName: (ctx) => ResultScreen(),
            TimbraturaListScreen.routeName: (ctx) => TimbraturaListScreen(),
          },
        ),
      ),
    );
  }
}
