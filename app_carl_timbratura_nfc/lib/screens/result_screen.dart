import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../label.dart';

import '../models/timbratura.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);
  static const routeName = '/result-screen';

  // Widget per la visualizzazione dei dati della timbratura
  Widget buildVisualizzazioneDati({
    String titolo = '',
    Color titoloColor = Colors.black,
    String testo = '',
    Color testoColor = Colors.black,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          titolo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: titoloColor,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          testo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            color: testoColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Controllo dei parametri passati nel nuovo schermo
    var parameterData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Timbratura timbratura = parameterData['timbratura'];

    return Scaffold(
      appBar: AppBar(
        title: Text(labels.resultScreenTitolo),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.secondary,
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 100,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            color: Theme.of(context).colorScheme.background,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildVisualizzazioneDati(
                    titolo: labels.utente,
                    titoloColor: Theme.of(context).colorScheme.primary,
                    testo: timbratura.attore.nome!,
                    testoColor: Colors.black,
                  ),
                  Divider(),
                  buildVisualizzazioneDati(
                    titolo: labels.posizione,
                    titoloColor: Theme.of(context).colorScheme.primary,
                    testo: timbratura.box!.description,
                    testoColor: Colors.black,
                  ),
                  Divider(),
                  buildVisualizzazioneDati(
                    titolo: labels.dataEora,
                    titoloColor: Theme.of(context).colorScheme.primary,
                    testo:
                        '${DateFormat(labels.formatoData).format(timbratura.dataTimbratura)} ${DateFormat.Hm().format(timbratura.dataTimbratura)}',
                    testoColor: Colors.black,
                  ),
                  Divider(),
                  buildVisualizzazioneDati(
                    titolo: labels.direzione,
                    titoloColor: Theme.of(context).colorScheme.primary,
                    testo: timbratura.direzione,
                    testoColor: Colors.black,
                  ),
                  Divider(),
                  buildVisualizzazioneDati(
                    titolo: labels.codice,
                    titoloColor: Theme.of(context).colorScheme.primary,
                    testo: timbratura.code,
                    testoColor: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
