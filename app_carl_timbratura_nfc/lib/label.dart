final LabelMap labels = LabelMap();

class LabelMap {
  // Titoli App Bar
  String get tagScreenTitolo => 'Timbratore NFC';
  String get resultScreenTitolo => 'Dati timbratura';

  // Formato data
  String get formatoData => 'dd/MM/yyyy';

  // Generiche
  String get conferma => 'Conferma';
  String get annulla => 'Annulla';
  String get connessione => 'Connessione';
  String get caricamento => 'In caricamento..';
  String get logout => 'Logout';
  String get login => 'Login';
  String get disconnessioneMessaggio => 'Disconnettersi dall\'applicazione?';
  String get utente_duepunti => 'Utente:';
  String get aggiornamentoApp => 'Aggiornamento App';
  String get messaggioAggiornamento =>
      'É disponibile una nuova versione dell\'app.\nPremendo su scarica verrà eseguito il download e aggiornata ora.';
  String get scarica => 'Scarica';
  String get initDownload => 'Inizializzazione download';
  String get progressDownload => 'Download in corso';

  // Errori
  String get erroreTitolo => 'Si è verificato un errore';
  String get erroreAutenticazione =>
      'Non è possibile esesguire l\'autenticazione, prova più tardi.';
  String get erroreNomeNullo => 'Nome invalido!';
  String get errorePasswordNulla => 'La password non può essere nulla!';
  String get credenzialiNonValideOUtenteBloccato =>
      'Le credenziali non sono valide o l\'utente è bloccato';
  String get tagNonAssociato =>
      'Non esiste un box associato a questo tag NFC.\nContattare gli amministratori di sistema.';

  // Homepage
  String get registraEntrata => 'Registra entrata';
  String get registraUscita => 'Registra uscita';
  String get uscita => 'Uscita';

  // Pagina TagScreen
  String get attivazioneTagNFC => 'Premere per rilevare la lettura';
  String get letturaTagNFC => 'Pronto a leggere l\'NFC';
  String get erroreTagNFC => 'Sensore NFC non disponibile.';

  // Pagina ResultScreen
  String get utente => 'Utente';
  String get posizione => 'Posizione';
  String get dataEora => 'Data e ora';
  String get direzione => 'Direzione';
  String get codice => 'Codice';
  String get letturaAvvenuta => 'Lettura avvenuta';
  String get erroreLettura => 'Errore nella lettura';

  // Pagina Login
  String get titoloApp => 'Timbratore';
  String get password => 'Password';

  // Drawer
  String get elencoTimbrature => 'Elenco timbrature';
  String get infoApp => 'Informazioni App';

  // Pagina TimbratureList
  String get nessunaTimbratura => 'Non sono presenti timbrature.';

  // Widget TimbraturaItem
  String get entrata => 'Entrata';
  String get posizione_duepunti => 'Posizione:';
  String get direzione_dueounti => 'Direzione:';
  String get codice_duepunti => 'Codice:';
  String get data_duepunti => 'Data:';
  String get ora_duepunti => 'Ora:';
}
