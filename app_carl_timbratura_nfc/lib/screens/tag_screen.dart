import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../label.dart';

import '../helpers/tag_helper.dart';

import '../widgets/cerchio_connessione_nfc.dart';

class TagScreen extends StatefulWidget {
  static const routeName = '/tag-screen';

  @override
  State<TagScreen> createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  String message = labels.attivazioneTagNFC;
  Color coloreCerchio = Colors.grey;
  IconData icona = Icons.sensors_off;

  // Funzione lettura Tag NFC
  void _tagRead(String? direzione) {
    // Modifico il CerchioConnessioneNFC per informare che l'app è pronta alla lettura del NFC
    setState(
      () {
        message = labels.letturaTagNFC;
        coloreCerchio = Theme.of(context).colorScheme.onPrimary;
        icona = Icons.sensors;
      },
    );

    // Inizio lettura tag
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // Fine lettura tag
        NfcManager.instance.stopSession();

        // Ri-setto il CerchioConnessioneNFC
        setState(
          () {
            message = labels.attivazioneTagNFC;
            coloreCerchio = Colors.grey;
            icona = Icons.sensors_off;
          },
        );

        // Controllo per eventuali errori
        try {
          // Ri-setto il CerchioConnessioneNFC
          setState(
            () {
              message = labels.letturaAvvenuta;
              coloreCerchio = Colors.green;
              icona = Icons.check;
            },
          );

          // Fase di timbratura
          if (direzione != null) {
            // Gestisco la lettura del tag NFC
            await TagHelper.gestisciTag(
              tag,
              context,
              direzione,
            );
          }
          // Fase di taggatura
          else {
            // Estraggo l'NFC ID
            String? nfcId = await TagHelper.estraiNFCId(context, tag);

            Navigator.of(context).pop(nfcId);
          }
        } catch (error) {
          // Ri-setto il CerchioConnessioneNFC
          setState(
            () {
              message = labels.erroreLettura;
              coloreCerchio = Theme.of(context).colorScheme.error;
              icona = Icons.error;
            },
          );
          // In caso di errori mostro il messaggio di errore
          _showErrorDialog(error.toString());
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    var parameterData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    // Variabile per la gestione della fase di timbratura o taggatura (nel caso è null)
    var direzione = parameterData['direzione'];

    // Lancio la funzione per preparare la lettura
    _tagRead(direzione);

    super.didChangeDependencies();
  }

  // Dialogo messaggio di errore
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(labels.erroreTitolo),
        content: Text(message),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(labels.conferma),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.background,
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
        title: Text(labels.letturaTag),
      ),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: NfcManager.instance.isAvailable(),
          builder: (context, ss) => ss.data != true
              ? Container(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: CerchioConnessioneNFC(
                      () {},
                      labels.erroreTagNFC,
                      Icons.error,
                      Theme.of(context).colorScheme.error,
                    ),
                  ),
                )
              : Container(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: CerchioConnessioneNFC(
                      () => _tagRead(direzione),
                      message,
                      icona,
                      coloreCerchio,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
