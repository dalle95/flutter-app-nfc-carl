import 'package:logger/logger.dart';

class QRCodeHelper {
  static Map<String, String>? estraiDati(String qrcodeDati) {
    Map<String, String>? dati;
    String? urlAmbiente;
    String? username;

    // Per gestire i log
    var logger = Logger();

    try {
      urlAmbiente = qrcodeDati.toString().substring(
            0,
            qrcodeDati.toString().indexOf('?'),
          );
      username = qrcodeDati.toString().substring(
            qrcodeDati.toString().indexOf('userLogin=') + 10,
          );

      dati = {
        'urlAmbiente': urlAmbiente,
        'username': '',
      };

      logger.d(dati);
    } catch (error) {
      throw error;
    }

    return dati;
  }
}
