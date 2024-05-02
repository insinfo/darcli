import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const usuarioWebPublicRoutes = [
  MyRoute('post', '/usuarios-web', UsuarioWebController.create),
  MyRoute('get', '/usuarios-web/confirmacao',
      UsuarioWebController.confirmaCadastro),
];
