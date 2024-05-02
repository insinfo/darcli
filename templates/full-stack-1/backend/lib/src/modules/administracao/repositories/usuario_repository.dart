import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class UsuarioRepository {
  /// Conexão com o bamco de dados
  final Connection db;

  UsuarioRepository(this.db);

  /// lista os usuarios
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    var query = db.table(Usuario.fqtn);

    query.selectRaw(''' 
    usuario.*,
    sw_cgm.nom_cgm
    ,orgao.nom_orgao 
    ,unidade.nom_unidade
    ,departamento.nom_departamento
    ,setor.nom_setor
    ''');

    query.join('sw_cgm', 'sw_cgm.numcgm', '=', 'usuario.numcgm');

    //join setor
    // TODO checar o impacto de trazer orgao,unidade junto
    query.join('administracao.orgao AS orgao', (JoinClause jc) {
      jc.on('orgao.cod_orgao', '=', 'usuario.cod_orgao');
      jc.on('orgao.ano_exercicio', '=', 'usuario.ano_exercicio');
    }, null, null, 'inner');

    query.join('administracao.unidade AS unidade', (JoinClause jc) {
      jc.on('unidade.cod_orgao', '=', 'usuario.cod_orgao');
      jc.on('unidade.cod_unidade', '=', 'usuario.cod_unidade');
      jc.on('unidade.ano_exercicio', '=', 'usuario.ano_exercicio');
    }, null, null, 'inner');

    query.join('administracao.departamento AS departamento', (JoinClause jc) {
      jc.on('departamento.cod_orgao', '=', 'usuario.cod_orgao');
      jc.on('departamento.cod_unidade', '=', 'usuario.cod_unidade');
      jc.on('departamento.cod_departamento', '=', 'usuario.cod_departamento');
      jc.on('departamento.ano_exercicio', '=', 'usuario.ano_exercicio');
    }, null, null, 'inner');

    query.join('administracao.setor AS setor', (JoinClause jc) {
      jc.on('setor.cod_orgao', '=', 'usuario.cod_orgao');
      jc.on('setor.cod_unidade', '=', 'usuario.cod_unidade');
      jc.on('setor.cod_departamento', '=', 'usuario.cod_departamento');
      jc.on('setor.cod_setor', '=', 'usuario.cod_setor');
      jc.on('setor.ano_exercicio', '=', 'usuario.ano_exercicio');
    }, null, null, 'inner');

    // filtra por um setor
    if (filtros?.isFilterBySetor == true) {
      query.where('usuario.cod_orgao', '=', filtros?.codOrgao);
      query.where('usuario.cod_unidade', '=', filtros?.codUnidade);
      query.where('usuario.cod_departamento', '=', filtros?.codDepartamento);
      query.where('usuario.cod_setor', '=', filtros?.codSetor);
      query.where('usuario.ano_exercicio', '=', filtros?.anoExercicio);
    }

    if (filtros?.isSearch == true) {
      for (var sField in filtros!.searchInFields) {
        if (sField.active) {
          if (sField.operator == 'ilike' || sField.operator == 'like') {
            //filtros.searchString = '%${filtros.searchString?.toLowerCase()}%';
            filtros.searchString =
                '%${filtros.searchString?.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '%')}%';
            query.whereRaw(
                ''' LOWER(TO_ASCII(${sField.field},'LATIN_1')) like LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
                [filtros.searchString]);
          } else {
            query.where(sField.field, sField.operator, filtros.searchString);
          }
        }
      }
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      //query.orderBy('nom_departamento');
    }

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    final dados = await query.get();

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  /// obtem um usuario pelo numero do CGM (id de pessoa)
  Future<Usuario> byNumCgm(int numCgm, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(Usuario.fqtn);
    query.where('numcgm', '=', numCgm);
    final map = await query.first();
    if(map == null){
      throw Exception('User not found');
    }
    return Usuario.fromMap(map) ;
  }

  /// cadastra um usuario na tabela administracao.usuario e cria usuario de banco com `CREATE USER`
  Future<Usuario> insert(Usuario usuario, {Connection? connection}) async {
    final conn = connection != null ? connection : db;

    //SELECT * FROM administracao.usuario WHERE UPPER(username) = UPPER('teste.teste') ORDER BY username;
    var isUserExist = await conn
        .table(Usuario.fqtn)
        .whereRaw(''' UPPER(username) = UPPER( ? ) ''', [usuario.username])
        .orderBy('username')
        .first();

    if (isUserExist != null) {
      throw Exception(
          'Erro na ação Incluir Usuário! O usuário ${usuario.username} já está cadastrado!');
    }
    // SELECT U.numcgm,U.cod_orgao,U.cod_unidade,U.cod_departamento,U.cod_setor,U.ano_exercicio,U.dt_cadastro,U.username, U.password,
    // U.status,C.nom_cgm,S.nom_setor FROM administracao.usuario as U,  sw_cgm as C,  administracao.setor as S
    // WHERE U.numcgm = C.numcgm  AND U.cod_setor = S.cod_setor AND U.cod_orgao = S.cod_orgao
    // AND U.cod_unidade = S.cod_unidade  AND U.cod_departamento = S.cod_departamento  AND U.ano_exercicio = S.ano_exercicio
    // AND U.numcgm = 133874;
    var isUserPesssoExist = await conn
        .table(Usuario.fqtn)
        .selectRaw(''' 
          us.numcgm, us.cod_orgao, us.cod_unidade, us.cod_departamento, us.cod_setor, us.ano_exercicio, us.dt_cadastro, 
          us.username, us.password, us.status, cgm.nom_cgm, setor.nom_setor 
           ''')
        .from('administracao.usuario as us')
        .join('sw_cgm AS cgm', (JoinClause jc) {
          jc.on('cgm.numcgm', '=', 'us.numcgm');
        })
        .join('administracao.setor AS setor', (JoinClause jc) {
          jc.on('setor.cod_setor', '=', 'us.cod_setor');
          jc.on('setor.cod_orgao', '=', 'us.cod_orgao');
          jc.on('setor.cod_unidade', '=', 'us.cod_unidade');
          jc.on('setor.cod_departamento', '=', 'us.cod_departamento');
          jc.on('setor.ano_exercicio', '=', 'us.ano_exercicio');
        })
        .whereRaw(' us.numcgm = ? ', [usuario.numCgm])
        .orderBy('username')
        .first();

    if (isUserPesssoExist != null) {
      throw Exception(
          'Erro na ação Incluir Usuário! O usuário ${usuario.username} já está cadastrado e vinculado ao CGM ${isUserPesssoExist["numcgm"]} !');
    }
    // cadastra usuario
    usuario.dtCadastro = DateTime.now();
    await conn.table(Usuario.fqtn).insert(usuario.toInsertMap());
    // cria usuario no banco
    await conn.affectingStatement(
      ''' CREATE USER "sw.${usuario.username}" PASSWORD '${usuario.password}' IN GROUP siamweb ''',
    );

    return usuario;
  }

  Future<Usuario> insertInTransaction(Usuario usuario,
      {Connection? connection}) async {
    final conn = connection != null ? connection : db;
    var user = await conn.transaction((ctx) async {
      return await insert(usuario, connection: ctx);
    });

    return user as Usuario;
  }

  Future<Usuario> update(Usuario usuario, {Connection? connection}) async {
    final conn = connection != null ? connection : db;

    var isUserPesssoExist = await conn
        .table(Usuario.fqtn)
        .selectRaw(''' 
          us.numcgm, us.cod_orgao, us.cod_unidade, us.cod_departamento, us.cod_setor, us.ano_exercicio, us.dt_cadastro, 
          us.username, us.password, us.status, cgm.nom_cgm, setor.nom_setor 
           ''')
        .from('administracao.usuario as us')
        .join('sw_cgm AS cgm', (JoinClause jc) {
          jc.on('cgm.numcgm', '=', 'us.numcgm');
        })
        .join('administracao.setor AS setor', (JoinClause jc) {
          jc.on('setor.cod_setor', '=', 'us.cod_setor');
          jc.on('setor.cod_orgao', '=', 'us.cod_orgao');
          jc.on('setor.cod_unidade', '=', 'us.cod_unidade');
          jc.on('setor.cod_departamento', '=', 'us.cod_departamento');
          jc.on('setor.ano_exercicio', '=', 'us.ano_exercicio');
        })
        .whereRaw(' us.numcgm = ? ', [usuario.numCgm])
        .orderBy('username')
        .first();

    if (isUserPesssoExist == null) {
      throw Exception(
          'Erro na ação Alterar Usuário! O usuário ${usuario.username} não está mais cadastrado pode ter sido removido!');
    }

    await conn
        .table(Usuario.fqtn)
        .where('numcgm', '=', usuario.numCgm)
        .update(usuario.toUpdateMap());

    return usuario;
  }
}
