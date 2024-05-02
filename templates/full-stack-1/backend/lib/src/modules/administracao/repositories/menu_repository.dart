import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class MenuRepository {
  final Connection db;

  MenuRepository(this.db);

  Future<List<MenuItem>> getHierarquia(String anoExercicio, int numcgm) async {
    // obtem gestões que o usuario tem acesso
    final gestoes = await GestaoRepository(db)
        .getAllByExercicioAndCgm(anoExercicio, numcgm);

    //obtem modulos que o usuario tem acesso
    final modulos = gestoes.isNotEmpty
        ? await ModuloRepository(db).getAllByExercicioCgmGestoes(
            anoExercicio, numcgm, gestoes.map((e) => e.codGestao).toList())
        : <Modulo>[];

    //obtem funcionalidades que o usuario tem acesso
    final funcionalidades = modulos.isNotEmpty
        ? await FuncionalidadeRepository(db).getAllByExercicioCgmModulos(
            anoExercicio, numcgm, modulos.map((e) => e.codModulo).toList())
        : <Funcionalidade>[];

    //obtem acoes que o usuario tem acesso
    final acoes = funcionalidades.isNotEmpty
        ? await AcaoRepository(db).getAllByExercicioCgmFuncionalidade(
            anoExercicio,
            numcgm,
            funcionalidades.map((e) => e.codFuncionalidade).toList())
        : <Acao>[];

    // print('acoes ${acoes.length}');

    var result = <MenuItem>[];
    //var id = 1;//, idPai = 1;
    for (var gestao in gestoes) {
      result.add(
        MenuItem(
          type: 'Gestao',
          codGestao: gestao.codGestao,
          level: 0,
          label: gestao.nomGestao,
          //   rota: '#/${SaliCoreUtils.slugify(gestao.nomGestao)}',
          children: modulos.isNotEmpty
              ? modulos
                  .where((m) => m.codGestao == gestao.codGestao)
                  .map((modulo) {
                  final menu = MenuItem(
                    type: 'Modulo',
                    codGestao: gestao.codGestao,
                    codModulo: modulo.codModulo,
                    level: 1,
                    label: modulo.nomModulo,
                    rota: '',
                    children: funcionalidades.isNotEmpty
                        ? funcionalidades
                            .where((fu) => fu.codModulo == modulo.codModulo)
                            .map((fu) {
                            final menu = MenuItem(
                              type: 'Funcionalidade',
                              codGestao: gestao.codGestao,
                              codModulo: modulo.codModulo,
                              codFuncionalidade: fu.codFuncionalidade,
                              level: 2,
                              label: fu.nomFuncionalidade,
                              rota: '',
                              children: acoes
                                  .where((ac) =>
                                      ac.codFuncionalidade ==
                                      fu.codFuncionalidade)
                                  .map((ac) {
                                //id++;
                                final menu = MenuItem(
                                  codGestao: gestao.codGestao,
                                  codModulo: modulo.codModulo,
                                  codFuncionalidade: fu.codFuncionalidade,
                                  codAcao: ac.codAcao,
                                  type: 'Acao',
                                  level: 3,
                                  label: ac.nomAcao,
                                  rota: '',
                                  children: [],
                                );
                                return menu;
                              }).toList(),
                            );
                            return menu;
                          }).toList()
                        : [],
                  );
                  //idModulo = idPai+1;
                  return menu;
                }).toList()
              : [],
        ),
      );
      //id++;
      //idPai = id;
    }

    return result;
  }
}
