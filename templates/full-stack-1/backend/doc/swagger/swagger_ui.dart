import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';

void main(List<String> args) async {
  final path = 'swagger_gen.yaml';
  final handler = SwaggerUI(path, title: 'Swagger Doc');
  var server = await io.serve(handler, 'localhost', 4001);
  print('Serving at http://${server.address.host}:${server.port}');
}