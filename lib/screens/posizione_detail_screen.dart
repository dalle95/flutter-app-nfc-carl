import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../label.dart';

import '../models/box.dart';

import '/providers/boxes.dart';

import '/helpers/tag_helper.dart';

import '/screens/tag_screen.dart';

class PosizioneDetailScreen extends StatefulWidget {
  const PosizioneDetailScreen({Key? key}) : super(key: key);
  static const routeName = '/posizione-screen';

  @override
  State<PosizioneDetailScreen> createState() => _PosizioneDetailScreenState();
}

class _PosizioneDetailScreenState extends State<PosizioneDetailScreen> {
  String testoPulsanteDisassociazioneTag = labels.disassociaTag;
  String testoPulsanteAssociazioneTag = labels.associaTag;

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

  // Funzione per gestire la disassociazione del tag
  void _disassociaTag(BuildContext context, Box posizione) async {
    // Passo al Provider il compito di disassociare il Tag
    await Provider.of<Boxes>(context, listen: false).removeTag(posizione);
    // Aggiorno la posizione
    Box posizioneAggiornata = Box(
      id: posizione.id,
      code: posizione.code,
      description: posizione.description,
      eqptType: posizione.eqptType,
      statusCode: posizione.statusCode,
      tag: null,
    );
    // Aggiorno la schermata
    Navigator.of(context).pushReplacementNamed(
      PosizioneDetailScreen.routeName,
      arguments: {
        'box': posizioneAggiornata,
      },
    );
  }

  // Funzione per gestire l'associazione del tag
  void _associaTag(BuildContext context, Box posizione) async {
    // Estrazione dell'id dal Tag NFC
    dynamic nfcID = await Navigator.of(context).pushNamed(
      TagScreen.routeName,
      arguments: {
        'direzione': null,
      },
    );

    // Controllo di aver ricevuto il tag
    if (nfcID != null) {
      // Controllo se il Tag NFC è già associato
      var tagAssociato = await TagHelper.checkTagAssegnato(
        context,
        nfcID,
      );

      // Se è già associato un Box al Tag NFC restituisco errore
      if (tagAssociato) {
        // Risetto il pulsante
        setState(
          () {
            testoPulsanteAssociazioneTag = labels.associaTag;
          },
        );
        // Mostro l'errore se il tag è già associato
        _showErrorDialog(labels.erroreTagAssociato);
      } else if (nfcID != null) {
        // Passo al Provider il compito di associare il Tag
        await Provider.of<Boxes>(context, listen: false)
            .addTag(posizione, nfcID);
        // Recupero la posizione aggiornata
        Box posizioneAggiornata =
            Provider.of<Boxes>(context, listen: false).findById(posizione.id!);
        // Aggiorno la schermata
        Navigator.of(context).pushReplacementNamed(
          PosizioneDetailScreen.routeName,
          arguments: {
            'box': posizioneAggiornata,
          },
        );
      }
    } else {
      // Risetto il pulsante
      setState(
        () {
          testoPulsanteAssociazioneTag = labels.associaTag;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Controllo dei parametri passati nel nuovo schermo
    var parameterData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Box posizione = parameterData['box'];

    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(labels.detailPosizioneScreen),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.secondary,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                height: deviceSize.height * 0.55,
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
                        titolo: labels.codice,
                        titoloColor: Theme.of(context).colorScheme.primary,
                        testo: posizione.code,
                        testoColor: Colors.black,
                      ),
                      Divider(),
                      buildVisualizzazioneDati(
                        titolo: labels.descrizione,
                        titoloColor: Theme.of(context).colorScheme.primary,
                        testo: posizione.description,
                        testoColor: Colors.black,
                      ),
                      Divider(),
                      buildVisualizzazioneDati(
                        titolo: labels.tag,
                        titoloColor: Theme.of(context).colorScheme.primary,
                        testo: posizione.tag != null
                            ? posizione.tag!.nfcId ?? 'Nessuno'
                            : 'Nessuno',
                        testoColor: Colors.black,
                      ),
                      Divider(),
                      posizione.tag != null
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shadowColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  testoPulsanteDisassociazioneTag =
                                      labels.disassociazioneTagInCorso;
                                });
                                _disassociaTag(context, posizione);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_disabled_sharp,
                                      size: 50,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      testoPulsanteDisassociazioneTag,
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shadowColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  testoPulsanteAssociazioneTag =
                                      labels.associazioneTagInCorso;
                                });
                                _associaTag(context, posizione);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.my_location,
                                      size: 50,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      testoPulsanteAssociazioneTag,
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
