import 'package:flutter/material.dart';

import '/helpers/aggiornamento_app_helper.dart';

import '/widgets/drawer.dart';
import '/widgets/download_nuova_versione.dart';
import '/widgets/timbratura_view.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final sizeButton = const Size(350, 250);
  bool _isAggiornamentoApp = false;
  double _percentuale = 0;

  @override
  void initState() {
    // Funzione che scatta dopo la prima build della homepage
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => AggiornamentoAppHelper.controlloAggiornamenti(
        context,
        _aggiornamentoApp,
        _aggiornaPercentuale,
      ),
    );

    super.initState();
  }

  // Funzione per aggiornare la percentuale dell'app
  void _aggiornaPercentuale(double percentuale) {
    setState(
      () {
        _percentuale = percentuale;
        if (percentuale == 1) {
          _isAggiornamentoApp = false;
        }
      },
    );
  }

  // Funzione per sapere se l'app è in aggiornamento
  void _aggiornamentoApp(bool inAggiornamento) {
    setState(
      () {
        _isAggiornamentoApp = inAggiornamento;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 100,
          height: 40,
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.asset('assets/images/injenia_logo_color 4.png'),
          ),
        ),
      ),
      drawer: _isAggiornamentoApp ? null : MainDrawer(),
      body: _isAggiornamentoApp
          ? DownloadNuovaVersioneApp(
              deviceSize: deviceSize,
              percentuale: _percentuale,
            )
          : TimbraturaView(
              deviceSize: deviceSize,
              sizeButton: sizeButton,
            ),
    );
  }
}
