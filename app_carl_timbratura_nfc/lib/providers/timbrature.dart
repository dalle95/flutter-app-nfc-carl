import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/actor.dart';
import '../models/box.dart';
import '../models/timbratura.dart';

import '../error_handling/http_exception.dart';

// Classe per gestire la lista delle timbrature
class Timbrature with ChangeNotifier {
  final String? authToken;
  final Actor? user;
  final String? urlAmbiente;

  // Per gestire i log
  var logger = Logger();

  // Inizializzo la lista delle timbrature come vuota
  List<Timbratura> timbratureLista = [];

  Timbrature({
    this.urlAmbiente,
    this.authToken,
    this.user,
    required this.timbratureLista,
  });

  // Lista delle timbrature
  List<Timbratura> get timbrature {
    return [...timbratureLista];
  }

  // Recupera una timbratura per ID
  Timbratura findById(String id) {
    return timbratureLista.firstWhere((element) => element.id == id);
  }

  // Funzione per estrarre le timbrature tramite richiesta get
  Future<void> fetchAndSetTimbrature() async {
    logger.d('Funzione fetchAndSetTimbrature');

    // Inizializzazione lista vuota
    final List<Timbratura> loadedTimbrature = [];

    // Definizione dell'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken!,
    };

    // Definizione del link della chiamata
    var url = Uri.parse(
      '$urlAmbiente/api/entities/v1/road?include=box&filter[utente.code]=${user!.code}&filter[roadType]=Timbratura&page[limit]=50&sort=-code',
    );

    // Preparazione del try-catch degli errori
    try {
      // Creazione della chiamata per estrarre i dati
      var response = await http.get(
        url,
        headers: headers,
      );
      // Estrazione del risultato della chiamata
      var extractedData = json.decode(response.body) as Map<String, dynamic>;

      // Se non sono presenti dati esco dalla funzione
      if (extractedData['data'] == null) {
        return;
      }

      // Definisco l'attore
      Actor attore = Actor(
        id: user!.id,
        code: user!.code,
        nome: user!.nome,
      );

      // Iterazione per ogni risultato
      for (var timbratura in extractedData['data']) {
        // Definisco il BOX nullo
        var box = Box(
          id: null,
          code: '',
          description: '',
          eqptType: '',
          statusCode: '',
        );

        logger.d(
            '${timbratura['id']}, ${timbratura['attributes']['code']}, ${timbratura['attributes']['dataTimbratura']}, ${timbratura['attributes']['direzione']}');

        // Recupero del BOX associato
        for (var record in extractedData['included']) {
          // Controllo che il BOX non sia nullo
          if (timbratura['relationships']['box']['data'] != null) {
            // Controllo il BOX collegato
            if (record['id'] ==
                timbratura['relationships']['box']['data']['id']) {
              // Definizione BOX associato
              box = Box(
                id: record['id'],
                code: record['attributes']['code'],
                description: record['attributes']['description'] ?? '',
                eqptType: record['attributes']['eqptType'] ?? '',
              );
            }
          }
        }

        // Per gestire l'orario locale e non quello UTC della data
        DateTime dataTimbratura =
            DateTime.parse(timbratura['attributes']['dataTimbratura'])
                .toLocal();

        // Aggiunta WorkTime alla lista
        loadedTimbrature.add(
          Timbratura(
            id: timbratura['id'],
            code: timbratura['attributes']['code'],
            attore: attore,
            box: box,
            dataTimbratura: dataTimbratura,
            direzione: timbratura['attributes']['direzione'] ?? '',
          ),
        );
      }
    } catch (error) {
      // Controllo di eventuali errori
      logger.d(error.toString());
      throw error;
    } finally {
      // Aggiornamento della lista
      timbratureLista = loadedTimbrature;
      notifyListeners();
    }
  }

  Future<void> addTimbratura(Timbratura timbratura, {int index = 0}) async {
    logger.d('Funzione addTimbratura');

    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken!,
      "Content-Type": "application/vnd.api+json",
    };

    final url = Uri.parse('$urlAmbiente/api/entities/v1/road');

    final data = json.encode(
      {
        'data': {
          'type': 'road',
          'attributes': {
            'UOwner': user!.code,
            'code': timbratura.code,
            'direzione': timbratura.direzione,
            'dataTimbratura':
                "${timbratura.dataTimbratura.toIso8601String().substring(0, 23)}+02:00",
            'roadType': 'Timbratura'
          },
          'relationships': {
            "utente": {
              "data": {
                "type": "actor",
                "id": timbratura.attore.id,
              }
            },
            "box": {
              "data": {
                "type": "box",
                "id": timbratura.box!.id,
              }
            }
          }
        }
      },
    );

    try {
      final response = await http.post(
        url,
        body: data,
        headers: headers,
      );

      logger.d(
          'Stato timbratura: ${json.decode(response.statusCode.toString())}');

      // Controllo del della risposta, se restituisce 404 restituisco un errore
      if (response.statusCode >= 400) {
        throw HttpException(
          json.decode(response.body)['errors'][0]['title'].toString(),
        );
      }

      timbratura.id = json.decode(response.body)['data']['id'];

      timbratureLista.insert(index, timbratura);

      notifyListeners();
    } catch (error) {
      logger.d(error);
      throw error;
    }
  }
}
