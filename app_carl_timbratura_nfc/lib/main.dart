import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

import '../screens/auth_screen.dart';
import '../screens/spash_screen.dart';
import '../screens/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'NFC Reader App',
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blue,
            secondaryHeaderColor: Colors.orange,
            primaryColorDark: const Color.fromARGB(255, 11, 50, 113),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Colors.blue,
              secondary: Colors.orange,
              background: Colors.white,
              error: Colors.redAccent,
            ),
            backgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
            ),
            textTheme: const TextTheme(
              headline1: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              headline6: TextStyle(fontSize: 25, fontStyle: FontStyle.normal),
              bodyText1: TextStyle(
                  fontSize: 20.0, color: Colors.white, fontFamily: 'Hind'),
              bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
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
          },
        ),
      ),
    );
  }
}
