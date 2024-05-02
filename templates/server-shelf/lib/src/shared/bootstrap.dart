import 'dart:isolate';


import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import 'dependencies/shelf_static/static_handler.dart';
import 'middleware/auth_middleware.dart';


Future<dynamic> configureServer(
    String address, int port, int numberOfIsolates) async {
  final arguments = [address, port];

  for (var i = 0; i < numberOfIsolates - 1; i++) {
    await Isolate.spawn(_startServer, [i, ...arguments],
        debugName: i.toString());
  }
  _startServer([numberOfIsolates - 1, ...arguments]);
}

void _startServer(List args) async {
  //int id = args[0];
  String address = args[1] as String;
  int port = args[2];

  final app = Router();
  routes(app);

  final staticFileHandler = createStaticHandler(
    'storage',
    useHeaderBytesForContentType: false,
  );
  app.all(r'/storage/<file|.*>', (Request rec, String file) async {
    //print('staticFileHandler ${rec.url}');
    final pathSegments = [...rec.url.pathSegments]..removeAt(0);
    rec.url.replace(pathSegments: pathSegments);
    //return staticFileHandler(rec);

    final response = await staticFileHandler(rec);

    final origin = rec.headers[ORIGIN];

    return response.change(headers: {
      ...{
       // 'Last-Modified': ,
      // HttpHeaders.lastModifiedHeader: formatHttpDate(stat.modified),
        ACCESS_CONTROL_ALLOW_ORIGIN: origin ?? "*", //'http://127.0.0.1:8080',
        ACCESS_CONTROL_EXPOSE_HEADERS: 'content-type',
        ACCESS_CONTROL_ALLOW_CREDENTIALS: 'true',
        ACCESS_CONTROL_ALLOW_HEADERS:
            'Origin,accept,accept-encoding,authorization,content-type,dnt,origin,user-agent',
        ACCESS_CONTROL_ALLOW_METHODS: 'DELETE,GET,OPTIONS,PATCH,POST,PUT',
        // 'Content-Type': 'image/generic'
      },
      ...response.headersAll,
    });
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      //.addMiddleware(AuthMiddleware.handleRequest())
      .addHandler(app);

  await auditoriaService.init();

  final server = await io.serve(handler, address, port, shared: true);
  server.defaultResponseHeaders.remove('X-Frame-Options', 'SAMEORIGIN');
  print('Serving at http://${server.address.host}:${server.port}');
}
