import 'package:flutter/material.dart';

import '../label.dart';

class DownloadNuovaVersioneApp extends StatelessWidget {
  const DownloadNuovaVersioneApp({
    Key? key,
    required this.deviceSize,
    required double percentuale,
  })  : _percentuale = percentuale,
        super(key: key);

  final Size deviceSize;
  final double _percentuale;

  @override
  Widget build(BuildContext context) {
    String lableDownload =
        _percentuale == 0 ? labels.initDownload : labels.progressDownload;

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      alignment: Alignment.center,
      child: Container(
        width: deviceSize.width,
        height: deviceSize.height,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(labels.aggiornamentoApp),
          content: Container(
            alignment: Alignment.center,
            height: 100,
            width: deviceSize.width * 0.95,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          value: _percentuale,
                          color: Theme.of(context).colorScheme.primary,
                          minHeight: 50,
                        ),
                      ),
                      Center(
                        child: Text(
                          '${(_percentuale * 100).toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_percentuale != 1) Text(lableDownload),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
