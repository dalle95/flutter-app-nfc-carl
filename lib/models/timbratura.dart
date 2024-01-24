import '../models/actor.dart';
import '../models/box.dart';

class Timbratura {
  String? id;
  String code;
  Actor attore;
  Box? box;
  DateTime dataTimbratura;
  String direzione;

  Timbratura({
    this.id,
    required this.code,
    required this.attore,
    required this.box,
    required this.dataTimbratura,
    required this.direzione,
  });
}
