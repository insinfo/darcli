import 'package:esic_backend/src/shared/app_config.dart';
import 'package:fluent_query_builder/fluent_query_builder.dart';

final esicComInfo = DBConnectionInfo(
  host: AppConfig.inst().dbHost,
  port: AppConfig.inst().dbPort,
  database: AppConfig.inst().dbName,
  driver: ConnectionDriver.pgsql,
  username: 'username',
  password: AppConfig.inst().dbPass,
  schemes: ['esic'],
);
