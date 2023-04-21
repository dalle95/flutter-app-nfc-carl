import 'dart:convert';

import 'package:app_carl_timbratura_nfc/models/http_exception.dart';
import 'package:http/http.dart' as http;

import '/providers/actor.dart';
import '/providers/box.dart';

class Timbratura {
  // Funzione per estrarre il codice per la timbratura
  static Future<String> estraiCodiceTimbratura(
    String authToken,
    String urlAmbiente,
    Actor user,
  ) async {
    print('Funzione estraiCodiceTimbratura');
    // Definizione Headers per le chiamate a Carl
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    // Definizione variabili necessarie per gestire le chiamate http
    Uri url;
    Map<String, dynamic> extractedData;
    http.Response response;

    // Definizione variabili per gestione codice
    int numero = 0;
    String codice;
    String numeroStringa;

    // Funzione per estrarre le timbrature

    // Definizione URL per lista timbrature
    url =
        Uri.parse('$urlAmbiente/api/entities/v1/road?filter[code][LIKE]=TIM-');

    // Creazione chiamata GET ricerca timbrature
    try {
      response = await http.get(
        url,
        headers: headers,
      );

      print(
          'Stato estrazione codice: ${json.decode(response.statusCode.toString())}');

      // Controllo lo stato della chiamata per sapere se è andata a buon fine
      if (response.statusCode >= 400) {
        throw HttpException(
          json.decode(response.body)['errors'][0]['title'].toString(),
        );
      } else {
        // Estrazione dati
        extractedData = json.decode(response.body) as Map<String, dynamic>;
        for (var wo in extractedData['data']) {
          numero++;
        }
      }
      // Converto il numero in stringa
      numeroStringa = '0000$numero';

      // Definisco il codice della timbratura
      codice = 'TIM-${numeroStringa.substring(numeroStringa.length - 5)}';

      // Restituisco il codice della timbratura
      return codice;
    } catch (error) {
      throw error;
    }
  }

  // Funzione per registrare la timbratura
  static Future<Box?> estraiBoxTimbratura(
    String authToken,
    String urlAmbiente,
    String nfcId,
  ) async {
    print('Funzione estraiBoxTimbratura');
    // Definizione Headers per le chiamate a Carl
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    // Definizione variabili necessarie per gestire le chiamate http
    Uri url;
    Map<String, dynamic> extractedData;
    http.Response response;

    // Definisco il box che restituisco
    Box box;

    // Funzione per estrarre il BOX associato al tag NFC

    // Definizione URL per ricerca BOX con filtro tag NFC
    url = Uri.parse(
        '$urlAmbiente/api/entities/v1/box?filter[equipmentTag.nfcId]=$nfcId');

    // Creazione chiamata GET per cercare il BOX
    try {
      response = await http.get(
        url,
        headers: headers,
      );

      // Controllo lo stato della chiamata per sapere se è andata a buon fine
      if (response.statusCode >= 400) {
        throw HttpException(
          json.decode(response.body)['errors'][0]['title'].toString(),
        );
      }

      // Estrazione dati
      extractedData = json.decode(response.body) as Map<String, dynamic>;

      print(extractedData);

      // Se i dati sono nulli restituisco l'errore
      if (extractedData['data'].toString() == '[]') {
        throw HttpException(
          'Non esiste un box associato a questo tag NFC. Esequire prima l\'associazione',
        );
      }
    } catch (error) {
      throw error;
    }

    // Definizione BOX associato al tag NFC
    box = Box(
      id: extractedData['data'][0]['id'],
      code: extractedData['data'][0]['attributes']['code'],
      description: extractedData['data'][0]['attributes']['description'],
      eqptType: extractedData['data'][0]['attributes']['eqptType'],
      statusCode: extractedData['data'][0]['attributes']['statusCode'],
    );

    return box;
  }

  // Funzione per registrare la timbratura
  static Future<void> registraTimbratura(
    String authToken,
    String urlAmbiente,
    Actor user,
    String codice,
    Box box,
  ) async {
    print('Funzione registraTimbratura');
    // Definizione Headers per le chiamate a Carl
    Map<String, String> headers = {
      "X-CS-Access-Token": authToken,
      "Content-Type": "application/vnd.api+json",
    };

    // Definizione variabili necessarie per gestire le chiamate http
    Uri url;
    Map<String, dynamic> extractedData;
    http.Response response;

    // Definizioni dati timbratura
    String code = codice;
    String description = user.nome;
    DateTime now = DateTime.now();

    // Funzione per creare il record della timbratura

    // Definizione URL per registrazione timbratura
    url = Uri.parse('$urlAmbiente/api/entities/v1/road');

    // Definizione dati per registrazione timbratura su Carl
    final dataTimbratura = json.encode(
      {
        'data': {
          "type": "road",
          "attributes": {
            "code": code,
            "description": description,
            "xtraTxt01": box.description,
            "xtraTxt02": now.toIso8601String(),
          },
          // "relationships": {
          //   "structure": {
          //     "data": {"type": "structure", "id": "LOCATION"}
          //   }
          // }
        },
      },
    );

    // Creazione chiamata POST per creare la timbratura
    try {
      response = await http.post(
        url,
        body: dataTimbratura,
        headers: headers,
      );

      print('Stato timbratura: ${json.decode(response.statusCode.toString())}');
      // Recupero l'ID del Box appena creato
      //box.id = json.decode(response.body)['data']['id'];

      // Controllo lo stato della chiamata per sapere se è andata a buon fine
      if (response.statusCode >= 400) {
        throw HttpException(
          json.decode(response.body)['errors'][0]['title'].toString(),
        );
      }
    } catch (error) {
      throw error;
    }
  }
}
