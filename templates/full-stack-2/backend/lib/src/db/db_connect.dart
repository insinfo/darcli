import 'package:fluent_query_builder/fluent_query_builder.dart';

import 'db_config.dart';

final DbLayer esicDb = DbLayer(esicComInfo);

Future<DbLayer> connect() async {
  await esicDb.connect();
  print('connect on ${esicComInfo.host}');
  return esicDb;
}
