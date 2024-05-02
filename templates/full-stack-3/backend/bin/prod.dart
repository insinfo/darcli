import 'package:angel3_production/angel3_production.dart';
import 'package:sibem_backend/src/shared/bootstrap.dart';


void main(List<String> args) async {
  startCronService();
  await Runner('sibem', configureServer).run(args);
}
