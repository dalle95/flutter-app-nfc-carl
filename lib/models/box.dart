import '/models/tag.dart';

class Box {
  String? id;
  String code;
  String description;
  String? eqptType;
  String? statusCode;
  Tag? tag;

  Box({
    required this.id,
    required this.code,
    required this.description,
    this.eqptType,
    this.statusCode,
    this.tag,
  });
}
