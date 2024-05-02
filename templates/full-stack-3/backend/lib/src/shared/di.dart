import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

Future<void> dependencyInjection(Angel app) async {
  app.container.registerSingleton<AppConfig>(AppConfig.inst());
  final db = await dbConnect();
  app.container.registerSingleton<Connection>(db);
  //PMRO padrao
  app.container.registerSingleton<BairroRepository>(BairroRepository(db));
  app.container.registerSingleton<ComplementoPessoaFisicaRepository>(
      ComplementoPessoaFisicaRepository(db));
  app.container.registerSingleton<EnderecoRepository>(EnderecoRepository(db));
  app.container
      .registerSingleton<EscolaridadeRepository>(EscolaridadeRepository(db));
  app.container.registerSingleton<MunicipioRepository>(MunicipioRepository(db));
  app.container.registerSingleton<PaisRepository>(PaisRepository(db));
  app.container
      .registerSingleton<PessoaFisicaRepository>(PessoaFisicaRepository(db));
  app.container.registerSingleton<PessoaJuridicaRepository>(
      PessoaJuridicaRepository(db));
  app.container.registerSingleton<TelefoneRepository>(TelefoneRepository(db));
  app.container.registerSingleton<UfRepository>(UfRepository(db));
  app.container.registerSingleton<TipoDeficienciaRepository>(
      TipoDeficienciaRepository(db));

//
  app.container.registerSingleton<BloqueioEncaminhamentoRepository>(
      BloqueioEncaminhamentoRepository(db));
  app.container.registerSingleton<CandidatoRepository>(CandidatoRepository(db));
  app.container
      .registerSingleton<CandidatoWebRepository>(CandidatoWebRepository(db));
  app.container.registerSingleton<CargoRepository>(CargoRepository(db));
  app.container.registerSingleton<ConhecimentoExtraRepository>(
      ConhecimentoExtraRepository(db));
  app.container.registerSingleton<CursoRepository>(CursoRepository(db));
  app.container
      .registerSingleton<DivisaoCnaeRepository>(DivisaoCnaeRepository(db));
  app.container
      .registerSingleton<EmpregadorRepository>(EmpregadorRepository(db));
  app.container.registerSingleton<EncaminhamentoRepository>(
      EncaminhamentoRepository(db));
  app.container.registerSingleton<ExperienciaCandidatoCargoRepository>(
      ExperienciaCandidatoCargoRepository(db));
  app.container.registerSingleton<FaixaTempoResidenciaRepository>(
      FaixaTempoResidenciaRepository(db));
  app.container.registerSingleton<TipoConhecimentoRepository>(
      TipoConhecimentoRepository(db));
  app.container.registerSingleton<VagaRepository>(VagaRepository(db));
  //
  app.container.registerSingleton<AuthRepository>(AuthRepository(db));
  app.container
      .registerSingleton<UsuarioWebRepository>(UsuarioWebRepository(db));
  app.container
      .registerSingleton<EmpregadorWebRepository>(EmpregadorWebRepository(db));
  app.container.registerSingleton<AuditoriaRepository>(AuditoriaRepository(db));
  app.container
      .registerSingleton<EstatisticaRepository>(EstatisticaRepository(db));

  app.container.registerSingleton<BeneficioRepository>(BeneficioRepository(db));
}
