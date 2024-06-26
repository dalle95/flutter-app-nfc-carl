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
  String? urlAmbiente;
  String? nome;

  Auth({
    this.urlAmbiente,
    this.nome,
  });

  // Per gestire i log
  var logger = Logger();

  String? _token;
  Actor? _user;

  DateTime? _refreshDate;

  // Controllo se l'utente è loggato
  bool get isAuth {
    return _token != null;
  }

  // Recupero dell'utente collegato
  Actor? get user {
    return _user;
  }

  // Recupero del token di autenticazione
  String? get token {
    return _token;
  }

  // Recupero il nome utente
  String? get username {
    return nome;
  }

  // Refupero se è responsabile
  bool? get responsabile {
    return _user!.responsabile;
  }

  // Recupero la tipologia di timbratura
  String? get tipologiaTimbratura {
    return _user!.tipologiaTimbratura;
  }

  void settaUsername(String username) {
    nome = username;
    notifyListeners();
  }

  // Funzione di autenticazione
  Future<void> _authenticate(
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
        // Generali
        var actorID = responseData['data'][0]['id'];
        var actorCode = responseData['data'][0]['attributes']['code'];
        var actorNome = responseData['data'][0]['attributes']['fullName'];
        // Specifiche per questa app
        var actorResponsabile =
            responseData['data'][0]['attributes']['responsabile'] ?? false;
        var tipologiaTimbratura = 'Entrata - Uscita';
        if (responseData['data'][0]['attributes']
            .containsKey('tipologiaTimbratura')) {
          tipologiaTimbratura = responseData['data'][0]['attributes']
                  ['tipologiaTimbratura'] ??
              'Entrata - Uscita';
        }

        // Definisco l'utente
        _user = Actor(
          id: actorID,
          code: actorCode,
          nome: actorNome,
          responsabile: actorResponsabile,
          tipologiaTimbratura: tipologiaTimbratura,
        );

        notifyListeners();
      } catch (error) {
        logger.d(error);
        throw error;
      }
      notifyListeners();

      logger.d(
          'Autenticazione: Token: $_token, ActorID: ${_user!.id}, ActorCode: ${_user!.code}, ActorResponsabile: ${_user!.responsabile}, TipologiaTimnbratura: ${_user!.tipologiaTimbratura}, AmbienteUrl: $urlAmbiente, Data scadenza: ${_refreshDate.toString()}');

      // Preparo l'istanza FlutterSecureStorage per salvare i dati di autenticazione
      final storage = const FlutterSecureStorage();

      final userData = json.encode(
        {
          'token': _token,
          'username': username,
          'password': password,
          'user_id': _user!.id,
          'user_code': _user!.code,
          'user_nome': _user!.nome,
          'user_responsabile': _user!.responsabile,
          'tipologia_timbratura': _user!.tipologiaTimbratura,
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
    //String urlAmbiente,
    String username,
    String password,
  ) async {
    logger.d('Funzione login');
    return _authenticate(
      username,
      password,
    );
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

    if (username != null && password != null) {
// Controllo la data di refresh del token: se non è di oggi rifaccio l'autenticazione
      if (refreshDate !=
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          )) {
        // Refresh del token
        await _authenticate(
          username,
          password,
        );
        return isAuth;
      }

      // Definizione dati di autenticazione
      _token = extractedUserData['token'];

      _user = Actor(
        id: extractedUserData['user_id'],
        code: extractedUserData['user_code'],
        nome: extractedUserData['user_nome'],
        responsabile: extractedUserData['user_responsabile'],
        tipologiaTimbratura: extractedUserData['tipologia_timbratura'],
      );

      _refreshDate = refreshDate;

      notifyListeners();
      return true;
    }

    return false;
  }

  // Funzione per la disconnessione
  void logoout() async {
    logger.d('Funzione logout');

    // Inizializzo le variabili di autenticazione come nulle
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
        'token': null,
        'username': null,
        'password': null,
        'user_id': null,
        'user_code': null,
        'user_nome': null,
        'user_responsabile': null,
        'tipologia_timbratura': null,
        'expiryDate': null,
      },
    );

    // Aggiorno i dati di autenticazione
    storage.write(key: 'userData', value: userData);

    notifyListeners();
  }
}
