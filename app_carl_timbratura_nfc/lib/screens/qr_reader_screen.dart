import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../label.dart';

import '../helpers/qrcode_reader_helper.dart';

class QRCodeReaderScreen extends StatefulWidget {
  static const routeName = '/qrcodereader';

  @override
  State<QRCodeReaderScreen> createState() => _QRCodeReaderScreenState();
}

class _QRCodeReaderScreenState extends State<QRCodeReaderScreen> {
  // Dialogo QR Code non valido
  void _qrCodeNonValido(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(labels.erroreTitoloQrCodeInvalido),
        content: Text(labels.erroreContentQrCodeInvalido),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var dati;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.expand_more),
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
          torchEnabled: false,
        ),
        // fit: BoxFit.contain,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            // Assegno alla lettura il valore presente nel qr code
            String? lettura = barcode.rawValue;

            if (lettura != null) {
              try {
                // Estraggo le informazioni
                dati = QRCodeHelper.estraiDati(lettura);

                // Restituisco la lettura
                Navigator.of(context).pop(dati);
              } catch (error) {
                _qrCodeNonValido(context);
              }
            }
          }
        },
      ),
    );
  }
}
