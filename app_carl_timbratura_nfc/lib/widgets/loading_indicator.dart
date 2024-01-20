import 'package:flutter/material.dart';

import '/label.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  LoadingIndicator(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            color: Color.fromRGBO(
              255,
              255,
              255,
              1,
            ), //Theme.of(context).colorScheme.background,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            height: double.infinity,
            child: SizedBox(
              width: 150,
              height: 70,
              child: FittedBox(
                fit: BoxFit.cover,
                child: Image.asset('assets/gifs/spinner.gif'),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 200),
              child: Text(
                labels.titoloApp,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 200),
              child: Text(message),
            ),
          ),
        ],
      ),
    );
  }
}
