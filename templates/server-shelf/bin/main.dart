import 'package:args/args.dart';
import 'package:__projectName__/__projectName__.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('address', abbr: 'a', defaultsTo: appConfig.serverHost)
    ..addOption('port', abbr: 'p', defaultsTo: appConfig.serverPort)
    ..addOption('isolates', abbr: 'j', defaultsTo: '1');
  final argsParsed = parser.parse(args);
  final numberOfIsolates = int.parse(argsParsed['isolates']);

  await configureServer(
      argsParsed['address'], int.parse(argsParsed['port']), numberOfIsolates);
}
