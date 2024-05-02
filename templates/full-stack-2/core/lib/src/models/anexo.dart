import 'dart:typed_data';
import 'package:esic_core/src/models/serialize_base.dart';

class Anexo implements SerializeBase {
  static const TABLE_NAME = 'lda_anexo';

  int id;
  int idsolicitacao;
  String nome;
  DateTime datainclusao;
  int idusuarioinclusao;

  String? fisicalFileName;
  String? link;

  /// type mimeType
  String type;

  // Size in bytes
  int size;

  /// File from dart:html | File from dart:io | UploadedFile
  dynamic fileRef;
  Stream<List<int>>? fileDataStrem;

  /// file bytes Uint8List
  List<int> bytes;
  dynamic dataUrl;

  bool isNew = false;
  bool isRemove = false;

  Anexo({
    this.id = -1,
    required this.idsolicitacao,
    required this.nome,
    required this.datainclusao,
    required this.idusuarioinclusao,
    required this.bytes,
    this.fileRef,
    this.dataUrl,
    this.fisicalFileName,
    this.link,
    required this.type,
    required this.size,
    this.isNew = false,
    this.isRemove = false,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'fisicalfilename': fisicalFileName,
      'idsolicitacao': idsolicitacao,
      'nome': nome,
      'datainclusao': datainclusao.toString(),
      'idusuarioinclusao': idusuarioinclusao,
      'link': link,
      'type': type,
      'size': size,
      'isNew': isNew,
      'isRemove': isRemove
    };
    map['idanexo'] = id;
    return map;
  }

  Map<String, dynamic> toDbInsert() {
    datainclusao = DateTime.now();
    return toMap()
      ..remove('idanexo')
      ..remove('tipoAnexo')
      //..remove('fisicalFileName')
      ..remove('link')
      // ..remove('type')
      // ..remove('size')
      ..remove('isNew')
      ..remove('isRemove');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap()
      ..remove('idanexo')
      ..remove('tipoAnexo')
      //..remove('fisicalFileName')
      ..remove('link')
      // ..remove('type')
      //  ..remove('size')
      ..remove('isNew')
      ..remove('isRemove')
      ..remove('datainclusao');
  }

  factory Anexo.fromMap(Map<String, dynamic> map) {
    var an = Anexo(
        id: map['idanexo'],
        fisicalFileName: map['fisicalfilename'],
        nome: map['nome'],
        idsolicitacao: map['idsolicitacao'],
        datainclusao: DateTime.parse(map['datainclusao'].toString()),
        idusuarioinclusao: map['idusuarioinclusao'],
        link: map['link'] != null ? map['link'] : '',
        type: map['type'] != null ? map['type'] : '',
        size: map['size'] != null ? map['size'] : 0,
        isNew: map['isNew'] == true ? true : false,
        isRemove: map['isRemove'] == true ? true : false,
        bytes: Uint8List.fromList([]));
    return an;
  }
}
