import 'package:flutter/material.dart';

class CerchioConnessioneNFC extends StatelessWidget {
  final Function()? tapHandler;
  final String text;
  final IconData icon;
  final Color accentColor;

  CerchioConnessioneNFC(
    this.tapHandler,
    this.text,
    this.icon,
    this.accentColor,
  );

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    // Grandezza pulsante
    final sizeButton = Size(deviceSize.width * 0.9, deviceSize.width * 0.9);

    return SizedBox.fromSize(
      size: sizeButton,
      child: ClipOval(
        child: Material(
          color: accentColor, // Button color
          child: InkWell(
              splashColor: Theme.of(context).colorScheme.onPrimary,
              onTap: tapHandler,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 100,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.background,
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
