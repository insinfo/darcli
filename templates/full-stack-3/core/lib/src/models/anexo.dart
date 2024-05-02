import 'dart:typed_data';
import 'package:sibem_core/src/models/serialize_base.dart';

/// TODO verificar a necessidade desta classe
class Anexo implements SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'anexos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id;
  String? tipoAnexo;
  String? fisicalFileName;
  String name;
  String? link;

  /// type mimeType
  String type;

  // Size in bytes
  int size;
  bool publicarNoSite = false;

  /// File from dart:html | File from dart:io | UploadedFile
  dynamic fileRef;
  Stream<List<int>>? fileDataStrem;

  /// file bytes Uint8List
  Uint8List? bytes;
  dynamic dataUrl;

  bool isNew = false;
  bool isRemove = false;

  Anexo({
    this.id = -1,
    this.bytes,
    this.fileRef,
    this.dataUrl,
    this.tipoAnexo,
    this.fisicalFileName,
    required this.name,
    this.link,
    required this.type,
    required this.size,
    this.publicarNoSite = false,
    this.isNew = false,
    this.isRemove = false,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'tipoAnexo': tipoAnexo,
      'fisicalFileName': fisicalFileName,
      'name': name,
      'link': link,
      'type': type,
      'size': size,
      'publicarNoSite': publicarNoSite,
      'isNew': isNew,
      'isRemove': isRemove
    };
    map['id'] = id;
    return map;
  }

  Map<String, dynamic> toDbInsert() {
    return toMap()..remove('id')..remove('isNew')..remove('isRemove');
  }

  factory Anexo.fromMap(Map<String, dynamic> map) {
    return Anexo(
      id: map['id'],
      tipoAnexo: map['tipoAnexo'],
      fisicalFileName: map['fisicalFileName'],
      name: map['name'],
      link: map['link'],
      type: map['type'],
      size: map['size'],
      publicarNoSite: map['publicarNoSite'],
      isNew: map['isNew'] == true ? true : false,
      isRemove: map['isRemove'],
    );
  }
}
