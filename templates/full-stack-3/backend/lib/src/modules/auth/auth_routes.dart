import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

const authWebPublicRoutes = [
  MyRoute('post', '/auth/login', AuthController.authenticateSite),
  MyRoute('post', '/auth/check', AuthController.checkToken),
  MyRoute('post', '/auth/reset/pass', AuthController.resetaSenhaSite),
];

const authWebPrivatesRoutes = [
  MyRoute('post', '/auth/change/pass', AuthController.changeSenhaSite),
];
