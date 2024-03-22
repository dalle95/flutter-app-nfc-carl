import 'package:flutter/material.dart';

import '../label.dart';
import '../screens/tag_screen.dart';

class TimbraturaEntrataUscita extends StatelessWidget {
  const TimbraturaEntrataUscita({
    Key? key,
    required this.deviceSize,
    required this.sizeButton,
  }) : super(key: key);

  final Size deviceSize;
  final Size sizeButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      alignment: Alignment.center,
      child: Container(
        width: deviceSize.width * 0.95,
        height: deviceSize.height,
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Flexible(
              flex: 1,
              child: SizedBox(),
            ),
            Flexible(
              flex: 8,
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  color: Theme.of(context).colorScheme.background,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shadowColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.login,
                              size: 60,
                            ),
                            Text(
                              labels.registraEntrata,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shadowColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              size: 60,
                            ),
                            Text(
                              labels.registraUscita,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
