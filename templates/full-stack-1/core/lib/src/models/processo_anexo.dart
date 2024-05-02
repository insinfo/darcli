import 'dart:typed_data';
import 'package:new_sali_core/src/models/base_model.dart';

class ProcessoAnexo implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_processo_anexos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id;

  /// tipo de documento da tabela sw_documento
  int codDocumento;

  /// Descrição do arquivo opcional
  String? descricao;

  /// numero de ordem opcional
  String? numero;
  bool sigiloso = false;

  String link = '';
  DateTime dataCadastro;

  /// miniatura ou preview do arquivo
  String? imagem;

  /// name original do arquivo
  String originalFilename = '';
  String fisicalFilename = '';

  /// tamanho do arquivo em bytes
  int size;

  /// type mimeType
  String type;

  /// File from dart:html | File from dart:io | UploadedFile
  dynamic fileRef;
  //Stream<List<int>>? fileDataStrem;

  /// file bytes Uint8List
  List<int>? bytes;
  dynamic dataUrl;
  bool isNew = false;
  bool isRemove = false;

  /// deseja assinar ?
  bool isAssinar = false;

  /// esta assinado ?
  bool isAssinado = false;

  /// total de paginas
  int? pageCount;

  /// id usuario que adicionou
  int codUsuario;

  /// id do processo
  int codProcesso;

  /// ano do processo
  String anoExercicio;

  /// opcional usado so se for anexo de despacho
  int? codAndamento;

  /// propriedade anexada nom_documento
  String? nomDocumento;

  /// propriedade anexada nome pessoa que adicionou
  String? nomCgm;

  /// propriedade anexada
  String? username;

  /// propriedade anexada usada no frontend para determinar se este anexo ja foi salvo
  bool isEnviado = false;

  ProcessoAnexo({
    required this.id,
    required this.codDocumento,
    this.descricao,
    this.numero,
    this.sigiloso = false,
    required this.link,
    required this.dataCadastro,
    this.imagem,
    this.originalFilename = '',
    this.fisicalFilename = '',
    required this.size,
    this.pageCount,
    required this.codUsuario,
    required this.codProcesso,
    required this.anoExercicio,
    this.codAndamento,
    this.isNew = false,
    this.isRemove = false,
    required this.type,
    this.fileRef,
    //this.fileDataStrem,
    this.bytes,
    this.dataUrl,
    this.isAssinar = false,
    this.isAssinado = false,
  });

  factory ProcessoAnexo.invalido() {
    return ProcessoAnexo(
      anoExercicio: '',
      codDocumento: -1,
      codProcesso: -1,
      codUsuario: -1,
      dataCadastro: DateTime.now(),
      id: -1,
      link: '',
      sigiloso: false,
      size: 0,
      type: '',
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'cod_documento': codDocumento,
      'descricao': descricao,
      'numero': numero,
      'sigiloso': sigiloso,
      'link': link,
      'data_cadastro': dataCadastro.toIso8601String(),
      'imagem': imagem,
      'original_filename': originalFilename,
      'fisical_filename': fisicalFilename,
      'size': size,
      'page_count': pageCount,
      'cod_usuario': codUsuario,
      'cod_processo': codProcesso,
      'ano_exercicio': anoExercicio,
      'type': type,
      'is_assinar': isAssinar,
      'is_assinado': isAssinado
    };
    if (codAndamento != null) {
      map['cod_andamento'] = codAndamento;
    }
    if (nomDocumento != null) {
      map['nom_documento'] = nomDocumento;
    }

    if (nomCgm != null) {
      map['nom_cgm'] = nomCgm;
    }
    if (username != null) {
      map['username'] = username;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    dataCadastro = DateTime.now();
    return toMap()
      ..remove('id')
      ..remove('isNew')
      ..remove('isRemove')
      ..remove('nom_documento')
      ..remove('nom_cgm')
      ..remove('username');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('id')
      ..remove('data_cadastro')
      ..remove('isNew')
      ..remove('isRemove')
      ..remove('nom_documento')
      ..remove('nom_cgm')
      ..remove('username');
  }

  factory ProcessoAnexo.fromMap(Map<String, dynamic> map) {
    var proc = ProcessoAnexo(
      id: map['id'] as int,
      codDocumento: map['cod_documento'] as int,
      descricao: map['descricao'] != null ? map['descricao'] as String : null,
      numero: map['numero'] != null ? map['numero'] as String : null,
      sigiloso: map['sigiloso'] as bool,
      link: map['link'] as String,
      dataCadastro: DateTime.parse(map['data_cadastro']),
      imagem: map['imagem'],
      originalFilename: map['original_filename'] as String,
      fisicalFilename: map['fisical_filename'] as String,
      size: map['size'],
      pageCount: map['page_count'],
      codUsuario: map['cod_usuario'],
      codProcesso: map['cod_processo'],
      anoExercicio: map['ano_exercicio'],
      codAndamento: map['cod_andamento'],
      type: map['type'],
      isAssinar: map['is_assinar'],
      isAssinado: map['is_assinado'],
    );

    if (map.containsKey('nom_documento')) {
      proc.nomDocumento = map['nom_documento'];
    }

    if (map.containsKey('nom_cgm')) {
      proc.nomCgm = map['nom_cgm'];
    }

    if (map.containsKey('username')) {
      proc.username = map['username'];
    }

    return proc;
  }

  @override
  String toString() {
    return 'ProcessoAnexo(id: $id, cod_documento: $codDocumento, descricao: $descricao, numero: $numero, sigiloso: $sigiloso, link: $link, dataCadastro: $dataCadastro, imagem: $imagem, original_filename: $originalFilename, fisical_filename: $fisicalFilename, size: $size, page_count: $pageCount)';
  }

  @override
  bool operator ==(covariant ProcessoAnexo other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  ProcessoAnexo copyWith({
    int? id,
    int? codDocumento,
    String? descricao,
    String? numero,
    bool? sigiloso,
    String? link,
    DateTime? dataCadastro,
    String? imagem,
    String? originalFilename,
    String? fisicalFilename,
    int? size,
    String? type,
    dynamic fileRef,
    // Stream<List<int>>? fileDataStrem,
    Uint8List? bytes,
    dynamic dataUrl,
    bool? isNew,
    bool? isRemove,
    int? pageCount,
    int? codUsuario,
    int? codProcesso,
    String? anoExercicio,
    int? codAndamento,
  }) {
    return ProcessoAnexo(
      id: id ?? this.id,
      codDocumento: codDocumento ?? this.codDocumento,
      descricao: descricao ?? this.descricao,
      numero: numero ?? this.numero,
      sigiloso: sigiloso ?? this.sigiloso,
      link: link ?? this.link,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      imagem: imagem ?? this.imagem,
      originalFilename: originalFilename ?? this.originalFilename,
      fisicalFilename: fisicalFilename ?? this.fisicalFilename,
      size: size ?? this.size,
      type: type ?? this.type,
      fileRef: fileRef ?? this.fileRef,
      //fileDataStrem: fileDataStrem ?? this.fileDataStrem,
      bytes: bytes ?? this.bytes,
      dataUrl: dataUrl ?? this.dataUrl,
      isNew: isNew ?? this.isNew,
      isRemove: isRemove ?? this.isRemove,
      pageCount: pageCount ?? this.pageCount,
      codUsuario: codUsuario ?? this.codUsuario,
      codProcesso: codProcesso ?? this.codProcesso,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      codAndamento: codAndamento ?? this.codAndamento,
    );
  }
}
