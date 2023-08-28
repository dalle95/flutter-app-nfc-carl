import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/widgets.dart';

// Classe per gestire l'autenticazione
class ConfigurazioneAmbiente with ChangeNotifier {
  String? _urlAmbiente;

  // Per gestire i log
  var logger = Logger();

  // Controllo se l'ambiente è configurato
  bool get isConfigured {
    return _urlAmbiente != null;
  }

  // Recupero dell'url ambiente
  String? get urlAmbiente {
    return _urlAmbiente;
  }

  // Funzione di autenticazione
  Future<void> configuraAmbiente(
    String urlAmbiente,
  ) async {
    logger.d("Funzione configuraAmbiente");

    logger.d(
      'urlAmbiente: ${urlAmbiente}',
    );

    _urlAmbiente = urlAmbiente;

    notifyListeners();

    // Preparo l'istanza FlutterSecureStorage per salvare i dati di autenticazione
    final storage = const FlutterSecureStorage();

    final configurationData = json.encode(
      {
        'url': _urlAmbiente,
      },
    );

    try {
      // Salvo i dati di configurazione
      await storage.write(key: 'configurationData', value: configurationData);

      logger.d('Credenziali salvate');
    } catch (error) {
      throw 'Funzione configuraAmbiente: $error';
    }
  }

  // Funzione per il login automatico all'apertura dell'app
  Future<bool> recuperaConfigurazione() async {
    logger.d('Funzione recuperaConfigurazione');

    // Preparo l'istanza FlutterSecureStorage per recuperare i dati di autenticazione
    final storage = const FlutterSecureStorage();

    // Controllo se è già presente la configurazione
    if (!await storage.containsKey(key: 'configurationData')) {
      _urlAmbiente = null;
      logger.d('Nessuna configurazione sul dispositivo');
      return false;
    }

    logger.d('Dati trovati');

    // Estrazione dei dati
    final extractedConfigurationData =
        json.decode(await storage.read(key: 'configurationData') ?? '')
            as Map<String, dynamic>;

    logger.d(extractedConfigurationData);

    // Definizione dati di configurazione
    _urlAmbiente = extractedConfigurationData['url'];

    notifyListeners();
    return true;
  }
}
