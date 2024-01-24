import '../screens/homepage.dart';
import '../screens/tag_screen.dart';
import '../screens/result_screen.dart';
import '../screens/timbrature_list_screen.dart';
import '../screens/posizioni_list_screen.dart';
import '../screens/qr_reader_screen.dart';
import '../screens/posizione_detail_screen.dart';

var routes = {
  HomePage.routeName: (ctx) => HomePage(),
  TagScreen.routeName: (ctx) => TagScreen(),
  ResultScreen.routeName: (ctx) => ResultScreen(),
  TimbraturaListScreen.routeName: (ctx) => TimbraturaListScreen(),
  PosizioneListScreen.routeName: (ctx) => PosizioneListScreen(),
  QRCodeReaderScreen.routeName: (ctx) => QRCodeReaderScreen(),
  PosizioneDetailScreen.routeName: (ctx) => PosizioneDetailScreen(),
};
