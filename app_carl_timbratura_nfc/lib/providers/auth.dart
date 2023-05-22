import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

    logger.d(
        'urlAmbiente: ${urlAmbiente}, username: ${username}, password: ${password}');

    // Chiamata per autenticare l'utente richiedendo il token
    try {
      var url = Uri.parse(
          '$urlAmbiente/api/auth/v1/authenticate?login=$username&password=$password&origin=Postman_SCA'); // Per eseguire l'autenticazione

      var response = await http.post(url);

      // Gestione errore credenziali
      if (response.statusCode >= 400) {
        throw HttpException(
            'Le credenziali non sono valide o l\'utente è bloccato');
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
            "X-CS-Access-Token": _token!,
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

      // Inizializzo la funzione per l'auto logout
      _autoLogout();

      logger.d(
          'Autenticazione: Token: $_token, ActorID: ${_user!.id}, ActorCode: ${_user!.code}, AmbienteUrl: $_urlAmbiente, Data scadenza: ${_expiryDate.toString()}');

      // Preparo l'istanza FlutterSecureStorage per salvare i dati di autenticazione
      final storage = const FlutterSecureStorage();

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

    logger.d(
      'Dati sul dispositivo: ${json.decode(await storage.read(key: 'userData') ?? '')}',
    );

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    // Definizione dati di autenticazione
    _urlAmbiente = extractedUserData['url'];
    _token = extractedUserData['token'];

    _user = Actor(
      id: extractedUserData['user_id'],
      code: extractedUserData['user_code'],
      nome: extractedUserData['user_nome'],
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

    // Preparo l'istanza FlutterSecureStorage per aggiornare i dati di autenticazione
    final storage = const FlutterSecureStorage();

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

    // Aggiorno i dati di autenticazione
    storage.write(key: 'userData', value: userData);

    notifyListeners();
  }

  // Funzione per la disconnessione automatica allo scadere del token
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    // Definisco il tempo di scadenza del token
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    // Inizializzo un timer per la disconnessione automatica
    _authTimer = Timer(Duration(seconds: timeToExpiry), logoout);
  }
}
