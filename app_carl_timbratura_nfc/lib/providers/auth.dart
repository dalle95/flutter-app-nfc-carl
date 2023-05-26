import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../label.dart';

import '../models/actor.dart';

import '../error_handling/http_exception.dart';

// Classe per gestire l'autenticazione
class Auth with ChangeNotifier {
  String? _urlAmbiente;
  String? _token;
  Actor? _user;

  DateTime? _refreshDate;

  // Per gestire i log
  var logger = Logger();

  // Controllo se l'utente è loggato
  bool get isAuth {
    return _token != null;
  }

  // Recupero dell'url ambiente
  String? get urlAmbiente {
    return _urlAmbiente;
  }

  // Recupero dell'utente collegato
  Actor? get user {
    return _user;
  }

  // Recupero del token di autenticazione
  String? get token {
    return _token;
  }

  // Funzione di autenticazione
  Future<void> _authenticate(
    String urlAmbiente,
    String username,
    String password,
  ) async {
    logger.d("Funzione authenticate");

    logger.d(
        'urlAmbiente: ${urlAmbiente}, username: ${username}, password: ${password}');

    // Chiamata per autenticare l'utente richiedendo il token
    try {
      var url = Uri.parse(
        '$urlAmbiente/api/auth/v1/authenticate?login=$username&password=$password&origin=Postman_SCA',
      ); // Per eseguire l'autenticazione

      var response = await http.post(url);

      logger.d(response.body);

      // Gestione errore credenziali
      if (response.statusCode >= 400) {
        throw HttpException(labels.credenzialiNonValideOUtenteBloccato);
      }

      var responseData = json.decode(response.body);

      _urlAmbiente = urlAmbiente;
      _token = responseData['X-CS-Access-Token'];
      _refreshDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      // Chiamata per estrarre le informazioni utente
      try {
        url = Uri.parse(
          '$urlAmbiente/api/entities/v1/actor?filter[code]=$username', // username = codice attore
        );
        response = await http.get(
          url,
          headers: {
            "X-CS-Access-Token": _token!,
          },
        );

        logger.d(response.body);

        // Gestione errore credenziali
        if (response.statusCode >= 400) {
          throw HttpException(labels.erroreAutenticazione);
        }

        responseData = json.decode(response.body);

        // Recupero dell'attore associato e definizione delle informazioni
        var actorID = responseData['data'][0]['id'];
        var actorCode = responseData['data'][0]['attributes']['code'];
        var actorNome = responseData['data'][0]['attributes']['fullName'];

        // Definisco l'utente
        _user = Actor(
          id: actorID,
          code: actorCode,
          nome: actorNome,
        );

        notifyListeners();
      } catch (error) {
        logger.d(error);
        throw error;
      }
      notifyListeners();

      logger.d(
          'Autenticazione: Token: $_token, ActorID: ${_user!.id}, ActorCode: ${_user!.code}, AmbienteUrl: $_urlAmbiente, Data scadenza: ${_refreshDate.toString()}');

      // Preparo l'istanza FlutterSecureStorage per salvare i dati di autenticazione
      final storage = const FlutterSecureStorage();

      final userData = json.encode(
        {
          'url': _urlAmbiente,
          'token': _token,
          'username': username,
          'password': password,
          'user_id': _user!.id,
          'user_code': _user!.code,
          'user_nome': _user!.nome,
          'user_password': password,
          'refreshDate': _refreshDate!.toIso8601String(),
        },
      );

      logger.d(userData);

      // Salvo i dati di autenticazione
      await storage.write(key: 'userData', value: userData);

      logger.d('Credenziali salvate');
    } catch (error) {
      throw error;
    }
  }

  // Funzione di login
  Future<void> login(
      String urlAmbiente, String username, String password) async {
    logger.d('Funzione login');
    return _authenticate(urlAmbiente, username, password);
  }

  // Funzione per il login automatico all'apertura dell'app
  Future<bool> tryAutoLogin() async {
    logger.d('Funzione tryAutoLogin');

    // Preparo l'istanza FlutterSecureStorage per recuperare i dati di autenticazione
    final storage = const FlutterSecureStorage();

    if (!await storage.containsKey(key: 'userData')) {
      logger.d('Nessun dato sul dispositivo');
      return false;
    }

    logger.d('Dati trovati');

    // Estrazione dei dati
    final extractedUserData =
        json.decode(await storage.read(key: 'userData') ?? '')
            as Map<String, dynamic>;

    logger.d(extractedUserData);

    // Recupero le informazioni principali
    final refreshDate = DateTime.parse(extractedUserData['refreshDate']);
    final username = extractedUserData['username'];
    final password = extractedUserData['password'];
    final urlAmbiente = extractedUserData['url'];

    // Controllo la data di refresh del token: se non è di oggi rifaccio l'autenticazione
    if (refreshDate !=
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        )) {
      // Refresh del token
      await _authenticate(urlAmbiente, username, password);
      return isAuth;
    }

    // Definizione dati di autenticazione
    _urlAmbiente = extractedUserData['url'];
    _token = extractedUserData['token'];

    _user = Actor(
      id: extractedUserData['user_id'],
      code: extractedUserData['user_code'],
      nome: extractedUserData['user_nome'],
    );

    _refreshDate = refreshDate;

    notifyListeners();
    return true;
  }

  // Funzione per la disconnessione
  void logoout() async {
    logger.d('Funzione logout');

    // Inizializzo le variabili di autenticazione come nulle
    _urlAmbiente = null;
    _token = null;
    _user = Actor(
      id: null,
      code: '',
      nome: '',
    );
    _refreshDate = null;

    // Preparo l'istanza FlutterSecureStorage per aggiornare i dati di autenticazione
    final storage = const FlutterSecureStorage();

    final userData = json.encode(
      {
        'url': null,
        'token': null,
        'username': null,
        'password': null,
        'user_id': null,
        'user_code': null,
        'user_nome': null,
        'expiryDate': null,
      },
    );

    // Aggiorno i dati di autenticazione
    storage.write(key: 'userData', value: userData);

    notifyListeners();
  }
}
