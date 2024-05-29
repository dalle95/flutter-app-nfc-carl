import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '/models/actor.dart';
import '/models/box.dart';
import '/models/tag.dart';

import '../error_handling/http_exception.dart';

// Classe per gestire la lista delle Boxes
class Boxes with ChangeNotifier {
  final String? authToken;
  final Actor? user;
  final String? urlAmbiente;

  // Per gestire i log
  var logger = Logger();

  // Inizializzo la lista delle Boxes come vuota
  List<Box> boxesLista = [];
  List<Box> boxesListaPerFiltro = [];

  Boxes({
    this.urlAmbiente,
    this.authToken,
    this.user,
    required this.boxesLista,
  });

  // Lista delle Boxes
  List<Box> get boxes {
    return [...boxesLista];
  }

  // Lista delle Boxes per filtro
  List<Box> get boxesPerFiltro {
    return [...boxesListaPerFiltro];
  }

  // Recupera una Box per ID
  Box findById(String id) {
    return boxesLista.firstWhere((element) => element.id == id);
  }

  // Funzione per filtrare le posizioni
  void filtraPosizioni(bool bool) {
    logger.d('Funzione filtraPosizioni');

    logger.d('Booleano: $bool');

    // Inizializzazione lista vuota
    List<Box> loadedBoxes = [];

    List<Box> listaBoxes = boxesListaPerFiltro;

    if (bool == true) {
      // Iterazione per ogni risultato
      for (var posizione in listaBoxes) {
        // Controllo se la posizione ha un tag associato
        if (posizione.tag == null) {
          loadedBoxes.add(posizione);
        }
      }
    } else {
      loadedBoxes = listaBoxes;
    }

    // Aggiornamento della lista
    boxesLista = loadedBoxes;
    notifyListeners();
  }

  // Funzione per estrarre le Boxes tramite richiesta get
  Future<void> fetchAndSetBoxes() async {
    logger.d('Funzione fetchAndSetBoxes');

    // Inizializzazione lista vuota
    List<Box> loadedBoxes = [];

    // Definizione dell'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken!,
    };

    // Definizione del link della chiamata
    var url = Uri.parse(
      '$urlAmbiente/api/entities/v1/box?fields=code,description,eqptType,statusCode,equipmentTag&include=equipmentTag&filter[posizione]=TRUE&filter[statusCode]=VALIDATE&sort=code',
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

      // Iterazione per ogni risultato
      for (var box in extractedData['data']) {
        // Definisco il BOX nullo
        Tag? tag;

        if (extractedData['included'] != null) {
          // Recupero del tag associato
          for (var record in extractedData['included']) {
            // Controllo che il tag non sia nullo
            if (box['relationships']['equipmentTag']['data'] != null) {
              // Controllo il tag collegato
              if (record['id'] ==
                  box['relationships']['equipmentTag']['data']['id']) {
                // Definizione tag associato
                tag = Tag(
                  id: record['id'],
                  nfcId: record['attributes']['nfcId'],
                );
              }
            }
          }
        }

        logger.d(
            'Box ID: ${box['id']}, Box Code: ${box['attributes']['code']} ${box['attributes']['description']}, ${box['attributes']['eqptType']}, ${box['attributes']['statusCode']}, ${tag != null ? tag.nfcId ?? 'nessuno' : 'nessuno'}');

        // Aggiunta Box
        loadedBoxes.add(
          Box(
            id: box['id'],
            code: box['attributes']['code'],
            description: box['attributes']['description'] ?? '',
            eqptType: box['attributes']['eqptType'],
            statusCode: box['attributes']['statusCode'],
            tag: tag,
          ),
        );
      }
    } catch (error) {
      // Controllo di eventuali errori
      logger.d(error.toString());
      throw error;
    } finally {
      // Aggiornamento della lista
      boxesLista = loadedBoxes;
      boxesListaPerFiltro = loadedBoxes;
      notifyListeners();
    }
  }

  // Funzione per associare un tag NFC ad un BOX
  Future<void> addTag(
    Box box,
    String nfcID,
  ) async {
    logger.d('Funzione addTag');

    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken!,
      "Content-Type": "application/vnd.api+json",
    };

    // Variabile per definire il Tag NFC
    Tag tag;

    // Creazione record del Tag NFC
    var url = Uri.parse('$urlAmbiente/api/entities/v1/equipmenttag');

    var data = json.encode(
      {
        "data": {
          "type": "equipmenttag",
          "attributes": {
            "qrCode": null,
            "nfcId": nfcID,
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

      logger.d('Stato Tag: ${json.decode(response.statusCode.toString())}');

      // Controllo del della risposta, se restituisce 404 restituisco un errore
      if (response.statusCode >= 400) {
        throw HttpException(
          json.decode(response.body)['errors'][0]['title'].toString(),
        );
      }

      // Definizione tag associato
      tag = Tag(
        id: json.decode(response.body)['data']['id'],
        nfcId: json.decode(response.body)['data']['attributes']['nfcId'],
      );
    } catch (error) {
      logger.d(error);
      throw error;
    }

    // Aggiornamento Box per associazione Tag NFC
    url = Uri.parse('$urlAmbiente/api/entities/v1/box/${box.id}');

    data = json.encode(
      {
        "data": {
          "type": "box",
          "relationships": {
            "equipmentTag": {
              "data": {
                "id": tag.id,
                "type": "equipmenttag",
              }
            }
          }
        }
      },
    );

    try {
      final response = await http.patch(
        url,
        body: data,
        headers: headers,
      );

      logger.d(
          'Stato Aggiornamento Box: ${json.decode(response.statusCode.toString())}');

      // Controllo del della risposta, se restituisce 404 restituisco un errore
      if (response.statusCode >= 400) {
        throw HttpException(
          json.decode(response.body)['errors'][0]['title'].toString(),
        );
      }
      // Definisco il nuovo BOX senza il tag NFC
      Box boxAggiornato = Box(
        id: box.id,
        code: box.code,
        description: box.description,
        eqptType: box.eqptType,
        statusCode: box.statusCode,
        tag: tag,
      );

      // Recupero l'indice del BOX per aggiornarlo nella lista
      final boxIndex = boxesLista.indexWhere((el) => el.id == box.id);

      // Aggiorno il BOX nella lista
      boxesLista[boxIndex] = boxAggiornato;
      // Aggiorno il BOX nella lista per il filtro
      boxesListaPerFiltro[boxIndex] = boxAggiornato;

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Funzione per disassociare un tag NFC da un BOX
  Future<void> removeTag(Box box) async {
    logger.d('Funzione removeTag');

    // Preparo l'header
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken!,
      "Content-Type": "application/vnd.api+json",
    };

    // Aggiornamento Box per disassociazione Tag NFC
    var url = Uri.parse('$urlAmbiente/api/entities/v1/box/${box.id}');

    logger.d(url);

    var data = json.encode(
      {
        "data": {
          "type": "box",
          "relationships": {
            "equipmentTag": {
              "data": null,
            }
          }
        }
      },
    );

    try {
      final response = await http.patch(
        url,
        body: data,
        headers: headers,
      );

      logger.d(
          'Stato Aggiornamento Box: ${json.decode(response.statusCode.toString())}');
      logger.d(response.body);
      // Controllo del della risposta, se restituisce 404 restituisco un errore
      if (response.statusCode >= 400) {
        throw HttpException(
          json.decode(response.body)['errors'][0]['title'].toString(),
        );
      }
    } catch (error) {
      throw error;
    }

    // Creazione record del Tag NFC
    url = Uri.parse('$urlAmbiente/api/entities/v1/equipmenttag/${box.tag!.id}');

    try {
      final response = await http.delete(
        url,
        headers: headers,
      );

      logger.d('Stato Tag: ${json.decode(response.statusCode.toString())}');

      // Controllo del della risposta, se restituisce 404 restituisco un errore
      if (response.statusCode >= 400) {
        throw HttpException(
          json.decode(response.body)['errors'][0]['title'].toString(),
        );
      }

      // Definisco il nuovo BOX senza il tag NFC
      Box boxAggiornato = Box(
        id: box.id,
        code: box.code,
        description: box.description,
        eqptType: box.eqptType,
        statusCode: box.statusCode,
        tag: null,
      );

      // Recupero l'indice del BOX per aggiornarlo nella lista
      final boxIndex = boxesLista.indexWhere((el) => el.id == box.id);

      // Aggiorno il BOX nella lista
      boxesLista[boxIndex] = boxAggiornato;
      // Aggiorno il BOX nella lista per il filtro
      boxesListaPerFiltro[boxIndex] = boxAggiornato;

      notifyListeners();
    } catch (error) {
      logger.d(error);
      throw error;
    }
  }
}
