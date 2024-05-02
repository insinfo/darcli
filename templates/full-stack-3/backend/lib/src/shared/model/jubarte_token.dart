/// token da Jubarte
class JubarteToken {
  int idSistema; //ok
  int idPessoa; //ok
  int idOrganograma; //ok
  int? idSecretaria;
  String loginName; //ok
  String? pws;
  String? ipClientPrivate;
  String? ipClientPublic;
  String? ipClientVisibleByServer;
  String? host;
  String? origin;
  String cpfPessoa; //ok
  String? userAgent;

  JubarteToken({
    required this.idSistema,
    required this.idPessoa,
    required this.idOrganograma,
    this.idSecretaria,
    required this.loginName,
    this.pws,
    this.ipClientPrivate,
    this.ipClientPublic,
    this.ipClientVisibleByServer,
    this.host,
    this.origin,
    required this.cpfPessoa,
    this.userAgent,
  });

  factory JubarteToken.fromMap(Map<String, dynamic> map) {
    return JubarteToken(
        idSistema: map['idSistema'],
        idPessoa: map['idPessoa'],
        loginName: map['loginName'],
        idOrganograma: map['idOrganograma'],
        pws: map['pws'],
        ipClientPrivate: map['ipClientPrivate'],
        ipClientPublic: map['ipClientPublic'],
        ipClientVisibleByServer: map['ipClientVisibleByServer'],
        host: map['host'],
        origin: map['origin'],
        cpfPessoa: map['cpfPessoa'],
        userAgent: map['userAgent']);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['idSistema'] = idSistema;
    map['loginName'] = loginName;
    map['idPessoa'] = idPessoa;
    map['idOrganograma'] = idOrganograma;
    map['pws'] = pws;
    map['ipClientPrivate'] = ipClientPrivate;
    map['ipClientPublic'] = ipClientPublic;
    map['ipClientVisibleByServer'] = ipClientVisibleByServer;
    map['host'] = host;
    map['origin'] = origin;
    map['cpfPessoa'] = cpfPessoa;
    map['userAgent'] = userAgent;
    return map;
  }
}
