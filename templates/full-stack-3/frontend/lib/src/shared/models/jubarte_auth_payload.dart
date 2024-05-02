

import 'package:sibem_frontend/src/shared/services/auth_service.dart';

class JubarteAuthPayload {
  bool authorizedAccess;
  bool isUserAllowedToRoute;
  //"id": 1 = ADMINISTRADOR || Administrador de Sistema Padrão (Atenção não vincular este perfil a nenhum sistema especifico esse perfil é para todos sistemas)
  //"id": 3 = USUÁRIO || Perfil de usuário padrão  (Atenção não vincular este perfil a nenhum sistema especifico esse perfil é para todos sistemas)
  int idUserPerfil;
  String? message;
  List<SistemaOfUser>? sistemasOfUser;
  bool isAdmin = false;

  JubarteAuthPayload(
      {required this.authorizedAccess,
      required this.isUserAllowedToRoute,
      required this.idUserPerfil,
      this.message,
      this.sistemasOfUser});

  factory JubarteAuthPayload.invalid() {
    final ap = JubarteAuthPayload(
      authorizedAccess: false,
      isUserAllowedToRoute: false,
      idUserPerfil: -1,
      message: '',
    );
    return ap;
  }

  factory JubarteAuthPayload.fromMap(Map<String, dynamic> json) {
    final ap = JubarteAuthPayload(
      authorizedAccess: json['authorizedAccess'],
      isUserAllowedToRoute: json['isUserAllowedToRoute'],
      idUserPerfil: json['idUserPerfil'],
      message: json['message'],
    );

    if (json['sistemasOfUser'] is List) {
      ap.sistemasOfUser = <SistemaOfUser>[];
      json['sistemasOfUser'].forEach((v) {
        ap.sistemasOfUser!.add(SistemaOfUser.fromMap(v));
      });
      ap.checkIsAdmin();
    }

    return ap;
  }

  void checkIsAdmin() {
    if (sistemasOfUser != null) {
      for (final item in sistemasOfUser!) {
        if (item.idSistema == AuthService.idSistema) {
          if (item.idPerfil == 1) {          
            isAdmin = true;
            break;
          }
        }
      }
    }
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['authorizedAccess'] = authorizedAccess;
    data['isUserAllowedToRoute'] = isUserAllowedToRoute;
    data['idUserPerfil'] = idUserPerfil;
    data['message'] = message;
    if (sistemasOfUser != null) {
      data['sistemasOfUser'] = sistemasOfUser!.map((v) => v.toMap()).toList();
    }
    return data;
  }
}

class SistemaOfUser {
  int idPessoa;
  int idOrganograma;
  String? login;
  bool ativo;
  int idSistema;
  int idPerfil;
  String? registradoEm;
  String? pass;
  String? passLdap;
  String? origin;
  int? idSecretaria;
  Sistema? sistema;
  Perfil? perfil;

  SistemaOfUser(
      {required this.idPessoa,
      required this.idOrganograma,
      this.login,
      required this.ativo,
      required this.idSistema,
      required this.idPerfil,
      this.registradoEm,
      this.pass,
      this.passLdap,
      this.origin,
      this.idSecretaria,
      this.sistema,
      this.perfil});

  factory SistemaOfUser.fromMap(Map<String, dynamic> json) {
    return SistemaOfUser(
        idPessoa: json['idPessoa'],
        idOrganograma: json['idOrganograma'],
        login: json['login'],
        ativo: json['ativo'],
        idSistema: json['idSistema'],
        idPerfil: json['idPerfil'],
        registradoEm: json['registradoEm'],
        pass: json['pass'],
        passLdap: json['pass_ldap'],
        origin: json['origin'],
        idSecretaria: json['idSecretaria'],
        sistema:
            json['sistema'] != null ? Sistema.fromMap(json['sistema']) : null,
        perfil: json['perfil'] != null ? Perfil.fromMap(json['perfil']) : null);
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['idPessoa'] = idPessoa;
    data['idOrganograma'] = idOrganograma;
    data['login'] = login;
    data['ativo'] = ativo;
    data['idSistema'] = idSistema;
    data['idPerfil'] = idPerfil;
    data['registradoEm'] = registradoEm;
    data['pass'] = pass;
    data['pass_ldap'] = passLdap;
    data['origin'] = origin;
    data['idSecretaria'] = idSecretaria;
    if (sistema != null) {
      data['sistema'] = sistema!.toMap();
    }
    if (perfil != null) {
      data['perfil'] = perfil!.toJson();
    }
    return data;
  }
}

class Sistema {
  int id;
  String? sigla;
  String? descricao;
  int? ordem;
  bool ativo;
  String? icon;

  Sistema(
      {required this.id,
      this.sigla,
      this.descricao,
      this.ordem,
      required this.ativo,
      this.icon});

  factory Sistema.fromMap(Map<String, dynamic> json) {
    return Sistema(
      id: json['id'],
      sigla: json['sigla'],
      descricao: json['descricao'],
      ordem: json['ordem'],
      ativo: json['ativo'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['sigla'] = sigla;
    data['descricao'] = descricao;
    data['ordem'] = ordem;
    data['ativo'] = ativo;
    data['icon'] = icon;
    return data;
  }
}

class Perfil {
  int id;
  int? idSistema;
  String? sigla;
  String? descricao;
  int? prioridade;
  bool ativo;

  Perfil(
      {required this.id,
      this.idSistema,
      this.sigla,
      this.descricao,
      this.prioridade,
      required this.ativo});

  factory Perfil.fromMap(Map<String, dynamic> map) {
    return Perfil(
        id: map['id'],
        idSistema: map['idSistema'],
        sigla: map['sigla'],
        descricao: map['descricao'],
        prioridade: map['prioridade'],
        ativo: map['ativo']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['idSistema'] = idSistema;
    data['sigla'] = sigla;
    data['descricao'] = descricao;
    data['prioridade'] = prioridade;
    data['ativo'] = ativo;
    return data;
  }
}
