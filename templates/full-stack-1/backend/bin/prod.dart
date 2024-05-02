import 'package:new_sali_backend/src/shared/bootstrap.dart';
import 'package:new_sali_backend/src/shared/dependencies/angel3_production/angel3_production.dart' as local;
import 'dart:io';

void main(List<String> args) async {
  final current = Directory.current;
  print('pid: $pid');
  print('main working directory: ${current.path}');
  return local.Runner('app_backend', configureServer).run(args);
}
