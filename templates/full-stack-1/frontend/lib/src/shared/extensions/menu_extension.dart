import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';



extension MenuItemExtension on MenuItem {
  RoutePath? get getRoutePath {
    if (this.codAcao != null) {
      return RoutePaths.mapRotaToAcao(this.codAcao!) ;
    }
    return null;
  }
}
