///
class AuthTokenJubarte {
  String cpfPessoa;
  String? host;
  int? idOrganograma;
  int idPessoa;
  int? idSecretaria;
  int idSistema;
  String? ipClientPrivate;
  String? ipClientPublic;
  String? ipClientVisibleByServer;
  String loginName;
  String? origin;
  String? pws;
  String? userAgent;
  AuthTokenJubarte({
    required this.cpfPessoa,
    this.host,
    this.idOrganograma,
    required this.idPessoa,
    this.idSecretaria,
    required this.idSistema,
    this.ipClientPrivate,
    this.ipClientPublic,
    this.ipClientVisibleByServer,
    required this.loginName,
    this.origin,
    this.pws,
    this.userAgent,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'cpfPessoa': cpfPessoa,
      'idPessoa': idPessoa,
      'idSistema': idSistema,
      'loginName': loginName,
    };
    if (host != null) {
      map['host'] = host;
    }
    if (pws != null) {
      map['pws'] = pws;
    }
    if (origin != null) {
      map['origin'] = origin;
    }
    if (userAgent != null) {
      map['userAgent'] = userAgent;
    }
    if (ipClientVisibleByServer != null) {
      map['ipClientVisibleByServer'] = ipClientVisibleByServer;
    }
    if (ipClientPublic != null) {
      map['ipClientPublic'] = ipClientPublic;
    }
    if (ipClientPrivate != null) {
      map['ipClientPrivate'] = ipClientPrivate;
    }
    if (idSecretaria != null) {
      map['idSecretaria'] = idSecretaria;
    }
    if (idOrganograma != null) {
      map['idOrganograma'] = idOrganograma;
    }
    return map;
  }

  factory AuthTokenJubarte.fromMap(Map<String, dynamic> map) {
    var token = AuthTokenJubarte(
      cpfPessoa: map['cpfPessoa'],
      idPessoa: map['idPessoa'],
      idSistema: map['idSistema'],
      // ipClientPrivate: map['ipClientPrivate'],
      // ipClientPublic: map['ipClientPublic'],
      // ipClientVisibleByServer: map['ipClientVisibleByServer'],
      loginName: map['loginName'],
      //origin: map['origin'],
      // pws: map['pws'],
      // userAgent: map['userAgent'],
    );
    if (map['host'] != null) {
      token.host = map['host'];
    }
    if (map['idOrganograma'] != null) {
      token.idOrganograma = map['idOrganograma'];
    }
    if (map['idSecretaria'] != null) {
      token.idSecretaria = map['idSecretaria'];
    }
    if (map['ipClientPrivate'] != null) {
      token.ipClientPrivate = map['ipClientPrivate'];
    }
    if (map['ipClientPublic'] != null) {
      token.ipClientPublic = map['ipClientPublic'];
    }
    if (map['ipClientVisibleByServer'] != null) {
      token.ipClientVisibleByServer = map['ipClientVisibleByServer'];
    }
    if (map['origin'] != null) {
      token.origin = map['origin'];
    }
    if (map['pws'] != null) {
      token.pws = map['pws'];
    }
    if (map['userAgent'] != null) {
      token.userAgent = map['userAgent'];
    }
    return token;
  }
}
