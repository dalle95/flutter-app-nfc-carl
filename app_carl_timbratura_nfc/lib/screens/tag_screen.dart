import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

import '../label.dart';

import '../models/box.dart';
import '../models/actor.dart';
import '../models/timbratura.dart';
import '../providers/timbrature.dart';
import '../providers/auth.dart';
import '../helper/timbratura_helper.dart';

import '../screens/result_screen.dart';

import '../widgets/cerchio_connessione_nfc.dart';

class TagScreen extends StatefulWidget {
  static const routeName = '/tag-screen';

  @override
  State<TagScreen> createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  String message = labels.attivazioneTagNFC;
  Color coloreCerchio = Colors.orange;

  var logger = Logger();

  // Funzione lettura Tag NFC
  void _tagRead(String direzione) {
    // Modifico il CerchioConnessioneNFC per informare che l'app è pronta alla lettura del NFC
    setState(() {
      message = labels.letturaTagNFC;
      coloreCerchio = Colors.green;
    });

    // Inizio lettura tag
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // Fine lettura tag
        NfcManager.instance.stopSession();

        // Ri-setto il CerchioConnessioneNFC
        setState(() {
          message = labels.attivazioneTagNFC;
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

          logger.d(nfcId);

          // Richiamo del provider per estrarre le informazioni di accesso
          var provider = Provider.of<Auth>(context, listen: false);

          // Definizione informazioni di accesso necessarie per la timbratura
          String? authToken = provider.token;
          Actor? user = provider.user;
          String? urlAmbiente = provider.urlAmbiente;

          // Estrazione codice timbratura
          String codice = await TimbraturaHelper.estraiCodiceTimbratura(
            authToken!,
            urlAmbiente!,
            user!,
          );

          // Estrazione box associato alla timbratura
          Box? box = await TimbraturaHelper.estraiBoxTimbratura(
            authToken,
            urlAmbiente,
            nfcId,
          );

          // Definizione timbratura
          Timbratura timbratura = Timbratura(
            code: codice,
            attore: user,
            box: box,
            dataTimbratura: DateTime.now(),
            direzione: direzione,
          );

          // Funzione per registrare la timbratura
          await Provider.of<Timbrature>(
            context,
            listen: false,
          ).addTimbratura(timbratura);

          // Apro la pagina di risultato timbratura passandogli la timbratura
          Navigator.pushReplacementNamed(
            context,
            ResultScreen.routeName,
            arguments: {
              'timbratura': timbratura,
            },
          );
        } catch (error) {
          // In caso di errori mostro il messaggio di errore
          _showErrorDialog(error.toString());
        }
      },
    );
  }

  // Dialogo messaggio di errore
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(labels.erroreTitolo),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(labels.conferma),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.background,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Controllo dei parametri passati nel nuovo schermo
    var parameterData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var direzione = parameterData['direzione'];

    return Scaffold(
      appBar: AppBar(
        title: Text(labels.tagScreenTitolo),
      ),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: NfcManager.instance.isAvailable(),
          builder: (context, ss) => ss.data != true
              ? Container(
                  child: Center(
                    child: CerchioConnessioneNFC(
                      () {},
                      labels.erroreTagNFC,
                      Theme.of(context).colorScheme.error,
                    ),
                  ),
                )
              : Container(
                  child: Center(
                    child: CerchioConnessioneNFC(
                      () {
                        _tagRead(direzione);
                      },
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
