import 'package:sibem_frontend/sibem_frontend.dart';

class VagaService extends RestServiceBase {
  VagaService(RestConfig conf) : super(conf);

  String path = '/vagas';

  Future<DataFrame<Vaga>> all(Filters filtros) async {
    final data =
        await getDataFrame<Vaga>(path, builder: Vaga.fromMap, filtros: filtros);

    return data;
  }

  /// lista todos os bloqueios de encaminhamento de uma vaga
  Future<DataFrame<BloqueioEncaminhamento>> getAllBloqueiosEncaminhamento(
      int idVaga,
      {Filters? filtros}) async {
    final data = await getDataFrame<BloqueioEncaminhamento>(
        '/vagas-bloqueios-encaminhamento/$idVaga',
        builder: BloqueioEncaminhamento.fromMap,
        filtros: filtros);
    return data;
  }

  Future<Vaga> getById(int id) async {
    return await getEntity<Vaga>('$path/$id', builder: Vaga.fromMap);
  }

  Future<void> validarVaga(Vaga vaga) async {
    return patchEntity(vaga, '/vagas-validar/${vaga.id}');
  }

  /// cadastra
  Future<void> insert(Vaga item) async {
    await insertEntity(item, path);
  }

  Future<void> bloquearVaga(BloqueioEncaminhamento item) async {
    await updateEntity(item, '/vagas-bloquear');
  }

  Future<void> desbloquearVaga(BloqueioEncaminhamento item) async {
    await updateEntity(item, '/vagas-desbloquear');
  }

  /// atualiza
  Future<void> update(Vaga item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> delete(Vaga item) async {
    await deleteEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<Vaga> items) async {
    await deleteAllEntity(items, path);
  }
}
