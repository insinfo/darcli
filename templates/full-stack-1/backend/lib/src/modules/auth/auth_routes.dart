import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_backend/src/shared/utils/route_item.dart';

//registrar rotas do modulo administracao aqui
const authPrivatesRoutes = [
  RouteItem('post', '/change/pass', AuthController.trocaSenha),
  RouteItem('get', '/auth/check/permissao/:cgm', AuthController.checkPermissao),
];

const authPublicRoutes = [
  RouteItem('post', '/auth/login', AuthController.authenticate),
  RouteItem('post', '/auth/check', AuthController.checkToken),
  RouteItem('get', '/auth/check/token', AuthController.checkTokenNew),
];
