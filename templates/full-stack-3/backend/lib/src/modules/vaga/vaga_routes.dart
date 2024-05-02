import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const vagaPrivateRoutes = [
  MyRoute('get', '/vagas', VagaController.getAll),
  MyRoute('get', '/vagas/:id', VagaController.getById),
  MyRoute('post', '/vagas', VagaController.create),
  MyRoute('put', '/vagas/:id', VagaController.update),
  MyRoute('delete', '/vagas', VagaController.removeAll),
  MyRoute('put', '/vagas-bloquear', VagaController.bloquearVaga),
  MyRoute('put', '/vagas-desbloquear', VagaController.desbloquearVaga),
  MyRoute(MyRoute.patch, '/vagas-validar/:id', VagaController.validarVaga),

  /// lista todos os bloqueios de encaminhamento de uma vaga
  MyRoute('get', '/vagas-bloqueios-encaminhamento/:idVaga',
      VagaController.getAllBloqueiosEncaminhamento),
];

const vagaPublicWebRoutes = [
  // /web/api/v1/vagas
  MyRoute('get', '/vagas', VagaController.getAllForSite),
];

const vagaPrivateWebRoutes = [
  // /web/api/v1/vagas
  MyRoute('get', '/vagas/:id', VagaController.getByIdFromWeb),
  MyRoute('post', '/vagas', VagaController.createFromWeb),
  MyRoute('put', '/vagas/:id', VagaController.updateFromWeb),
];
