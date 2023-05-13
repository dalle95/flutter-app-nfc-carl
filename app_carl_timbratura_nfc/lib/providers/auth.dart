import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/actor.dart';
import '../error_handling/http_exception.dart';

// Classe per gestire l'autenticazione
class Auth with ChangeNotifier {
  String? _urlAmbiente;
  String? _token;
  Actor? _user;

  DateTime? _expiryDate;
  Timer? _authTimer;

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
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  // Funzione di autenticazione
  Future<void> _authenticate(
    String urlAmbiente,
    String username,
    String password,
  ) async {
    logger.d("Funzione authenticate");

    // Chiamata per autenticare l'utente richiedendo il token
    try {
      var url = Uri.parse(
          '$urlAmbiente/api/auth/v1/authenticate?login=$username&password=$password&origin=Postman_SCA'); // Per eseguire l'autenticazione

      var response = await http.post(url);

      // Gestione errore credenziali
      if (response.statusCode >= 400) {
        throw HttpException('Le credenziali non sono valide');
      }

      logger.d(json.decode(response.body));

      var responseData = json.decode(response.body);

      _urlAmbiente = urlAmbiente;
      _token = responseData['X-CS-Access-Token'];
      _expiryDate = DateTime.now().add(
        const Duration(seconds: 432000),
      );

      // Chiamata per estrarre le informazioni utente
      try {
        url = Uri.parse(
            '$urlAmbiente/api/entities/v1/user?include=actor&filter[login]=$username');
        response = await http.get(
          url,
          headers: {
            "X-CS-Access-Token": _token.toString(),
          },
        );

        responseData = json.decode(response.body);

        logger.d(responseData);

        // Recupero dell'attore associato e definizione delle informazioni
        var actorID = responseData['included'][0]['id'];
        var actorNome = responseData['included'][0]['attributes']['fullName'];

        // Definisco l'utente
        _user = Actor(
          id: actorID,
          code: username,
          nome: actorNome,
        );

        notifyListeners();
      } catch (error) {
        logger.d(error);
        throw error;
      }
      notifyListeners();
      _autoLogout();

      logger.d(
          'Autenticazione: Token: $_token, ActorID: ${_user!.id}, ActorCode: ${_user!.code}, AmbienteUrl: $_urlAmbiente, Data scadenza: ${_expiryDate.toString()}');

      // Preparo l'istanza SharePreferences per salvare i dati di autenticazione
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'url': _urlAmbiente,
          'token': _token,
          'user_id': _user!.id,
          'user_code': _user!.code,
          'user_nome': _user!.nome,
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );

      logger.d(userData);

      prefs.setString('userDataTimbratore', userData);
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

    // Preparo l'istanza SharePreferences per recuperare i dati di autenticazione
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userDataTimbratore')) {
      logger.d('Nessun dato sul dispositivo');
      return false;
    }

    logger.d('Dati trovati');

    // Estrazione dei dati
    final String? extractedUserData = prefs.getString('userDataTimbratore');

    final extractedUserDataMap =
        json.decode(extractedUserData!) as Map<String, dynamic>;

    logger.d(extractedUserDataMap);

    logger.d(
      'Dati sul dispositivo: ${json.decode(prefs.getString('userDataTimbratore').toString())}',
    );

    final expiryDate =
        DateTime.parse(extractedUserDataMap['expiryDate'].toString());
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    // Definizione dati di autenticazione
    _urlAmbiente = extractedUserDataMap['url'];
    _token = extractedUserDataMap['token'];

    _user = Actor(
      id: extractedUserDataMap['user_id'],
      code: extractedUserDataMap['user_code'],
      nome: extractedUserDataMap['user_nome'],
    );

    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
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
    _expiryDate = null;

    // Se è attivo un timer lo elimino
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    // Aggiorno le sharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode(
      {
        'url': null,
        'token': null,
        'user_id': null,
        'user_code': null,
        'user_nome': null,
        'expiryDate': null,
      },
    );
    prefs.setString('userDataTimbratore', userData);
    notifyListeners();
  }

  // Funzione per la disconnessione automatica allo scadere del token
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logoout);
  }
}
