import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

import '../../helpers/timbratura_helper.dart';

import '../../models/actor.dart';
import '../../models/box.dart';
import '../../models/timbratura.dart';

import '../../providers/auth.dart';
import '../../providers/timbrature.dart';

import '../../screens/result_screen.dart';

class TagHelper {
  static Future<void> gestisciTag(
    NfcTag tag,
    BuildContext context,
    String direzione,
  ) async {
    var logger = Logger();

    try {
      // Passaggi per decodificare l'ID del tag NFC (Serial Number)
      Uint8List identifier =
          Uint8List.fromList(tag.data["mifareclassic"]['identifier']);

      String nfcId =
          identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':');

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
      throw error;
    }
  }
}
