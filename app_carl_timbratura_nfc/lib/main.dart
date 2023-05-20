import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

final theme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  primaryColorDark: const Color.fromARGB(255, 11, 50, 113),
  secondaryHeaderColor: Colors.orange,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: Color.fromRGBO(255, 152, 0, 1),
    onPrimary: Colors.orangeAccent,
    secondary: Color.fromRGBO(82, 68, 56, 1),
    onSecondary: Colors.black87,
    background: Colors.white,
    onBackground: Colors.black87,
    error: Colors.redAccent,
  ),
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.white,
    backgroundColor: Colors.orangeAccent,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.orange,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
        fontSize: 20, color: Colors.orange, fontStyle: FontStyle.normal),
    bodyLarge: TextStyle(
      fontSize: 25.0,
      color: Colors.black,
      fontFamily: 'Hind',
    ),
    bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
  ),
);

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
