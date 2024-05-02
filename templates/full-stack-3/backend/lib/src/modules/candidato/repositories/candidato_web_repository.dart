import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class CandidatoWebRepository {
  final Connection db;
  CandidatoWebRepository(this.db);

  /// lista todos
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(CandidatoWeb.fqtn);
    query.selectRaw(''' 
    candidatos_web.*,  
    pessoas.nome AS "nomeRespValidacao", 
    cargo1.nome AS "nomeCargo1",
    cargo2.nome AS "nomeCargo2",
    cargo3.nome AS "nomeCargo3"
    ''');
    query.join(Pessoa.fqtn, 'pessoas.id', '=',
        'candidatos_web.usuarioRespValidacao', 'left');
    //cargo 1
    query.join(
        '${Cargo.fqtn} as cargo1', 'cargo1.id', '=', 'candidatos_web.idCargo1');
    //cargo 2
    query.join('${Cargo.fqtn} as cargo2', 'cargo2.id', '=',
        'candidatos_web.idCargo2', 'left');
    //cargo 3
    query.join('${Cargo.fqtn} as cargo3', 'cargo3.id', '=',
        'candidatos_web.idCargo3', 'left');

    if (filtros?.isValidado != null) {
      query.where(CandidatoWeb.tableName + '.' + CandidatoWeb.validadoCol, '=',
          filtros!.isValidado);
    }

    if (filtros?.searchString != null && filtros?.searchString?.trim() != '') {
      for (var filtroItem in filtros!.searchInFields) {
        var field = filtroItem.field;
        final fieldsValidos = ['nome','cpf'];
        if (fieldsValidos.contains(filtroItem.field)) {
          field = '${CandidatoWeb.tableName}.${filtroItem.field}';
        }
        if (filtroItem.active) {
          if (filtroItem.operator == 'ilike' || filtroItem.operator == 'like') {
            filtros.searchString = '%${filtros.searchString!.toLowerCase()}%';
            query.whereRaw(''' LOWER(unaccent(${field})) like unaccent( ? ) ''',
                [filtros.searchString]);
          } else {
            query.where(field, filtroItem.operator, filtros.searchString);
          }
        }
      }
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      if (totalRecords > 1) {
        query.orderBy('id', 'desc');
      }
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

  Future<Map<String, dynamic>> getByIdAsMap(int id) async {
    final query =
        db.table(CandidatoWeb.fqtn).selectRaw('*').where('id', '=', id);
    final data = await query.first();
    if (data == null) {
      throw Exception('Não encontrado com o id = $id');
    }
    return data;
  }

  Future<CandidatoWeb> getByCpf(String cpf) async {
    final query = db
        .table(CandidatoWeb.fqtn)
        .selectRaw('*')
        .where('cpf', '=', CPFValidator.strip(cpf));
    final map = await query.first();
    if (map == null) {
      throw NotFoundException(message: 'Não encontrado com o CPF = $cpf');
    }
    return CandidatoWeb.fromMap(map);
  }

  Future<Map<String, dynamic>> getByCpfAsMap(String cpf) async {
    final query = db
        .table(CandidatoWeb.fqtn)
        .selectRaw('*')
        .where('cpf', '=', CPFValidator.strip(cpf));
    final data = await query.first();
    if (data == null) {
      throw NotFoundException(message: 'Não encontrado com o CPF = $cpf');
    }
    return data;
  }

  Future<int> create(CandidatoWeb item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(CandidatoWeb.fqtn);
    await query.insert(item.toInsertMap());
    return item.id;
  }

  Future<void> update(CandidatoWeb item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(CandidatoWeb.fqtn).where('id', '=', item.id);
    await query.update(item.toUpdateMap());
  }

  /// define um Candidato como Validado = true
  Future<void> validar(String cpf, int idUsuarioRespValidacao,
      {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(CandidatoWeb.fqtn).where('cpf', '=', cpf);
    await query.update({
      'validado': true,
      'dataValidacao': DateTime.now(),
      'usuarioRespValidacao': idUsuarioRespValidacao
    });
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    await conn.table(CandidatoWeb.fqtn).where('id', '=', id).delete();
  }

  Future<void> removeAllInTransaction(List<CandidatoWeb> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.id, connection: ctx);
      }
    });
  }
}
