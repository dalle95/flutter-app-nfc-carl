import 'package:flutter/material.dart';

import '../label.dart';

import '../screens/tag_screen.dart';

import '../widgets/drawer.dart';

class MyHomePage extends StatefulWidget {
  static const routeName = '/home';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final sizeButton = const Size(300, 200);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(labels.titoloApp),
      ),
      drawer: MainDrawer(),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                shadowColor: Theme.of(context).colorScheme.onSecondary,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                minimumSize: sizeButton,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  TagScreen.routeName,
                  arguments: {
                    'direzione': labels.entrata,
                  },
                );
              },
              child: Text(
                labels.registraEntrata,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            const Flexible(
              flex: 1,
              child: SizedBox(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                shadowColor: Theme.of(context).colorScheme.onSecondary,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                minimumSize: sizeButton,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  TagScreen.routeName,
                  arguments: {
                    'direzione': labels.uscita,
                  },
                );
              },
              child: Text(
                labels.registraUscita,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            const Flexible(
              flex: 2,
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
