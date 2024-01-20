import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/label.dart';

import '/providers/auth.dart';
import '/providers/configurazioneAmbiente.dart';

import '/screens/qr_reader_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  var qrCodeDati;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.secondary),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8.0,
          child: Container(
            height: 450,
            constraints: const BoxConstraints(minHeight: 230),
            width: deviceSize.width * 0.75,
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  labels.infoConfigurazione,
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 150,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Recupero i dati
                    qrCodeDati = await Navigator.of(context)
                        .pushNamed(QRCodeReaderScreen.routeName);

                    Provider.of<Auth>(
                      context,
                      listen: false,
                    ).settaUsername(qrCodeDati['username']);

                    // Aggiorno il provider
                    await Provider.of<ConfigurazioneAmbiente>(
                      context,
                      listen: false,
                    ).configuraAmbiente(qrCodeDati['urlAmbiente']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shadowColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    minimumSize: Size(200, 50),
                  ),
                  child: Text(labels.scannerizzare),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
