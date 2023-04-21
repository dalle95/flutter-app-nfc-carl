import 'package:app_carl_timbratura_nfc/providers/box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

import '../providers/timbratura.dart';
import '../providers/actor.dart';
import '../providers/auth.dart';

import '../widgets/bt_flat_button.dart';
import '../widgets/cerchio_connessione_nfc.dart';
import '../widgets/drawer.dart';

class MyHomePage extends StatefulWidget {
  static const routeName = '/home';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message = 'Premere per rilevare la lettura.';
  Color coloreCerchio = Colors.orange;

  // Funzione lettura Tag NFC
  void _tagRead() {
    // Modifico il CerchioConnessioneNFC per informare che l'app è pronta alla lettura del NFC
    setState(() {
      message = 'Pronto a leggere l\'NFC';
      coloreCerchio = Colors.green;
    });

    // Inizio lettura tag
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // Fine lettura tag
        NfcManager.instance.stopSession();

        // Ri-setto il CerchioConnessioneNFC
        setState(() {
          message = 'Premere per rilevare la lettura.';
          coloreCerchio = Colors.orange;
        });

        // Controllo per eventuali errori
        try {
          // Passaggi per decodificare l'ID del tag NFC (Serial Number)
          Uint8List identifier =
              Uint8List.fromList(tag.data["mifareclassic"]['identifier']);

          String nfcId = identifier
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join(':');

          // Estrazione NFC ID senza : e in maiuscolo
          nfcId = nfcId.replaceAll(RegExp(r':'), '').toUpperCase();

          print(nfcId);

          // Richiamo del provider per estrarre le informazioni di accesso
          var provider = Provider.of<Auth>(context, listen: false);

          // Definizione informazioni di accesso necessarie per la timbratura
          String? authToken = provider.token;
          Actor? user = provider.user;
          String? urlAmbiente = provider.urlAmbiente;

          String codice = await Timbratura.estraiCodiceTimbratura(
            authToken!,
            urlAmbiente!,
            user!,
          );

          Box? box = await Timbratura.estraiBoxTimbratura(
            authToken,
            urlAmbiente,
            nfcId,
          );

          // Funzione per registrare la timbratura
          Timbratura.registraTimbratura(
            authToken,
            urlAmbiente,
            user,
            codice,
            box!,
          );

          String messagge =
              'Utente: ${user.nome}\nPostazione: ${box.description}\nData: ${DateTime.now().toString()}\nCodice timbratura: $codice';

          // Mostra dati timbratura
          _mostraDatiTimbratura(messagge);
        } catch (error) {
          // In caso di errori mostro il messaggio di errore
          _showErrorDialog(error.toString());
        }
      },
    );
  }

  // Dialogo dati timbratura
  void _mostraDatiTimbratura(String messagge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dati Timbratura'),
        content: Text(messagge),
        actions: [
          FlatButton(
            () {
              Navigator.of(ctx).pop();
            },
            const Text('Ok'),
            Theme.of(ctx).colorScheme.background,
          ),
        ],
      ),
    );
  }

  // Dialogo messaggio di errore
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Si è verificato un errore'),
        content: Text(message),
        actions: [
          FlatButton(
            () {
              Navigator.of(ctx).pop();
            },
            const Text('Conferma'),
            Theme.of(ctx).colorScheme.background,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timbratore NFC')),
      drawer: MainDrawer(),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: NfcManager.instance.isAvailable(),
          builder: (context, ss) => ss.data != true
              ? Container(
                  child: Center(
                    child: CerchioConnessioneNFC(
                      () {},
                      'Sensore NFC non disponibile.',
                      Theme.of(context).colorScheme.error,
                    ),
                  ),
                )
              : Container(
                  child: Center(
                    child: CerchioConnessioneNFC(
                      _tagRead,
                      message,
                      coloreCerchio,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
