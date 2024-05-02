import 'dart:isolate';
import 'package:angel3_container/angel3_container.dart';
import 'package:angel3_framework/angel3_framework.dart';
import 'options.dart';

class RunnerArgsWithId {
  final int id;
  final RunnerArgs args;
  RunnerArgsWithId(this.id, this.args);
}

class RunnerArgs {
  final String name;

  final AngelConfigurer configureServer;

  final RunnerOptions options;

  final Reflector reflector;

  final SendPort loggingSendPort, pubSubSendPort;

  RunnerArgs(this.name, this.configureServer, this.options, this.reflector,
      this.loggingSendPort, this.pubSubSendPort);

  String get loggerName => name;
}
