import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:open_filex/open_filex.dart';

import '../label.dart';

class AggiornamentoAppHelper {
  // Funzione per estrarre le informazioni app
  static Future<void> controlloAggiornamenti(
    BuildContext context,
    Function aggiornamentoApp,
    Function aggiornaPercentuale,
  ) async {
    // Per gestire i log
    var logger = Logger();

    // Recupero la versione dell'applicazione
    final infoApp = await PackageInfo.fromPlatform();
    final infoVersioneApp = '${infoApp.version}.${infoApp.buildNumber}';

    // Recupero le remote config di Firebase
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 1),
      ),
    );

    await remoteConfig.fetchAndActivate();

    // Recupero l'ultima versione dell'app settata su Firebase
    final infoVersioneFirebase = remoteConfig.getString('lastAppVersion');

    logger.d(
      'Versione App: $infoVersioneApp\n Versione Firebase: $infoVersioneFirebase',
    );

    // Confronto Versioni in formato stringa
    if (infoVersioneFirebase == infoVersioneApp) {
      return;
    }

    bool permessoDiAggiornare = false;

    // Nel caso le versioni sono diverse mostro il messaggio di aggiornamento app
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(labels.aggiornamentoApp),
        content: Text(labels.messaggioAggiornamento),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              // Setto l'applicazione in aggiornamento
              aggiornamentoApp(true);
              permessoDiAggiornare = true;
              // Chiudo il dialogo
              Navigator.of(context).pop();
            },
            child: Text(labels.scarica),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.background,
            ),
          )
        ],
      ),
    );

    // Per continuare controllo se è stato dato il permesso per scaricare la nuova versione
    if (permessoDiAggiornare == false) {
      return;
    }

    // Recupero URL per download nuova versione app
    final downloadUrl = remoteConfig.getString('downloadUrl');

    // Definizione URL per richiesta get
    final url = Uri.parse('$downloadUrl');

    // Chiamata get per download apk
    final request = await http.Request(
      'GET',
      url,
    );

    // Definifione Client
    var httpClient = http.Client();

    // Recupero la risposta alla chiamata
    var response = httpClient.send(request);

    // Definisco la directory per i download
    String directoryDownload = (await getApplicationDocumentsDirectory()).path;
    // Definisco la directory per salvare il file
    File directoryFile = File('$directoryDownload/Timbratore NFC.apk');

    // Definisco le variabili per controllare il download
    List<List<int>> chunks = [];
    int downloaded = 0;
    double downloadPercentuale = 0;

    // Inizio la stream per controllare il progresso
    response.asStream().listen(
      (http.StreamedResponse r) {
        r.stream.listen(
          (List<int> chunk) {
            // Calcolo la percentuale di download
            downloadPercentuale =
                downloaded / num.parse(r.contentLength.toString());

            // Aggiorno la percentuale nella homepage
            aggiornaPercentuale(downloadPercentuale);

            chunks.add(chunk);
            downloaded += chunk.length;
          },
          onDone: () async {
            // Calcolo la percentuale di download
            downloadPercentuale =
                downloaded / num.parse(r.contentLength.toString());

            // Aggiorno la percentuale nella homepage
            aggiornaPercentuale(downloadPercentuale);

            // Salvataggio del file
            final Uint8List bytes = Uint8List(r.contentLength!);
            int offset = 0;
            for (List<int> chunk in chunks) {
              bytes.setRange(offset, offset + chunk.length, chunk);
              offset += chunk.length;
            }
            await directoryFile.writeAsBytes(bytes);

            logger.d(directoryFile.path);
            // Apro il file per installarlo
            OpenFilex.open(directoryFile.path);
          },
        );
      },
    );
  }
}
