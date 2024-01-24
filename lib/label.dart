final LabelMap labels = LabelMap();

class LabelMap {
  // Titoli App Bar
  String get tagScreenTitolo => 'InGiro';
  String get letturaTag => 'Lettura Tag';
  String get resultScreenTitolo => 'Dati timbratura';
  String get detailPosizioneScreen => 'Dati pozisione';

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
      'Non è presente nessuna posizione associata a questo tag NFC.\nEffettuare l\'associazione del tag alla posizione.';
  String get erroreTitoloQrCodeInvalido => 'QR Code non valido';
  String get erroreContentQrCodeInvalido =>
      'Scannerizzare il QR Code dell\'ambiente per completare la configurazione';

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

  // Pagina Config
  String get infoConfigurazione =>
      'Scannerizzare il QR Code dell\'ambiente per completare la configurazione';
  String get scannerizzare => 'Scannerizzare';

  // Pagina Login
  String get titoloApp => 'InGiro';
  String get password => 'Password';

  // Drawer
  String get elencoTimbrature => 'Elenco timbrature';
  String get elencoPosizioni => 'Elenco posizioni';
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

  // Pagina PosizioniList
  String get nessunaPosizione => 'Non sono presenti posizioni.';

  // Widget PosizioneItem
  String get stato_duepunti => 'Stato:';
  String get tagId_duepunti => 'Tag Id:';

  // Pagina PosizioneDetailScreen
  String get descrizione => 'Descrizione';
  String get tag => 'TagID';
  String get associaTag => 'Associa Tag';
  String get disassociaTag => 'Disassocia Tag';
  String get disassociazioneTagInCorso => 'Disassociazione Tag in corso';
  String get associazioneTagInCorso => 'Associazione Tag in corso';
  String get erroreTagAssociato =>
      'Il tag è già associato ad un altra posizione.\nPer poterlo associare nuovamente è necessario disassociarlo dalla precedente posizione.';
}
