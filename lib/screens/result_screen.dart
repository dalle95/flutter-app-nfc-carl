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

    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(labels.resultScreenTitolo),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.secondary,
        alignment: Alignment.center,
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
                width: deviceSize.width * 0.95,
                height: deviceSize.height,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  color: Theme.of(context).colorScheme.background,
                ),
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
