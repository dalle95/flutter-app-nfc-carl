import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../error_handling/http_exception.dart';

import '../models/actor.dart';
import '../models/box.dart';

class TimbraturaHelper {
  // Funzione per estrarre il codice per la timbratura
  static Future<String> estraiCodiceTimbratura(
    String authToken,
    String urlAmbiente,
    Actor user,
  ) async {
    var logger = Logger();
    logger.d('Funzione estraiCodiceTimbratura');
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
    int numero = 1;
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

      logger.d(
          'Stato estrazione codice: ${json.decode(response.statusCode.toString())}');

      // Controllo lo stato della chiamata per sapere se è andata a buon fine
      if (response.statusCode >= 400) {
        throw HttpException(
          json.decode(response.body)['errors'][0]['title'].toString(),
        );
      } else {
        // Estrazione dati
        extractedData = json.decode(response.body) as Map<String, dynamic>;
        numero = extractedData['data'].length + 1;
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
    var logger = Logger();
    logger.d('Funzione estraiBoxTimbratura');
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

      logger.d(extractedData);

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
}
