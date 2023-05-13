import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../label.dart';

import '../providers/auth.dart';
import '../providers/timbrature.dart';

import '../screens/homepage.dart';
import '../screens/auth_screen.dart';
import '../screens/spash_screen.dart';
import '../screens/tag_screen.dart';
import '../screens/result_screen.dart';
import '../screens/timbrature_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blue,
            primaryColorDark: const Color.fromARGB(255, 11, 50, 113),
            secondaryHeaderColor: Colors.orange,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Colors.blue,
              onPrimary: Colors.blueAccent,
              secondary: Colors.orange,
              onSecondary: Colors.orangeAccent,
              background: Colors.white,
              error: Colors.redAccent,
            ),
            appBarTheme: const AppBarTheme(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
            buttonTheme: const ButtonThemeData(
              buttonColor: Colors.orange,
            ),
            textTheme: const TextTheme(
              displayLarge:
                  TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              displayMedium:
                  TextStyle(fontSize: 25, fontStyle: FontStyle.normal),
              bodyLarge: TextStyle(
                  fontSize: 20.0, color: Colors.white, fontFamily: 'Hind'),
              bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
            ),
          ),
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
