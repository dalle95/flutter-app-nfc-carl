import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../label.dart';

import '../models/timbratura.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);
  static const routeName = '/result-screen';

  @override
  Widget build(BuildContext context) {
    // Controllo dei parametri passati nel nuovo schermo
    var parameterData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Timbratura timbratura = parameterData['timbratura'];

    // Definizione informazioni timbratura
    final String infoTimbratura =
        'Utente: ${timbratura.attore.nome}\nPostazione: ${timbratura.box!.description}\nData: ${DateFormat(labels.formatoData).format(timbratura.dataTimbratura)} ${DateFormat.Hm().format(timbratura.dataTimbratura)}\nDirezione: ${timbratura.direzione}\nCodice: ${timbratura.code}';

    return Scaffold(
      appBar: AppBar(
        title: Text(labels.resultScreenTitolo),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: Center(
            child: Text(
              infoTimbratura,
            ),
          ),
        ),
      ),
    );
  }
}
