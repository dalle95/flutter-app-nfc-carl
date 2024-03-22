import 'package:app_carl_timbratura_nfc/providers/auth.dart';
import 'package:app_carl_timbratura_nfc/widgets/timbratura_entrata_uscita.dart';
import 'package:app_carl_timbratura_nfc/widgets/timbratura_passaggio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimbraturaView extends StatelessWidget {
  const TimbraturaView({
    Key? key,
    required this.deviceSize,
    required this.sizeButton,
  }) : super(key: key);

  final Size deviceSize;
  final Size sizeButton;

  @override
  Widget build(BuildContext context) {
    final tipologiaTimbratura =
        Provider.of<Auth>(context, listen: false).tipologiaTimbratura;

    return tipologiaTimbratura == 'Entrata - Uscita'
        ? TimbraturaEntrataUscita(
            deviceSize: deviceSize,
            sizeButton: sizeButton,
          )
        : TimbraturaPassaggio(
            deviceSize: deviceSize,
            sizeButton: sizeButton,
          );
  }
}
