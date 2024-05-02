import 'dart:async';

import 'package:angel3_framework/angel3_framework.dart';
import 'http_methods.dart';
import 'package:meta/meta.dart' show sealed;

import 'router_entry.dart';

/// Middleware to remove body from request.
// Future Function(RequestContext req, ResponseContext res) _removeBody(
//     innerHandler) {
//   return (RequestContext req, ResponseContext res) async {
//     if (res.headers['content-length'] != null) {
//       res.headers['content-length'] = '0';
//     }
//     return res.buffer!.clear();
//   };
// }

/// Example: 
/// 
///   final router = CustomRouter();
///   router.get('/', (req, res) => res.write('a'));
///   for (final rota in rotasPublicas) {
///      router.add(rota.methodUpper(), basePath + rota.pathAsShelf(),
///          rota.handler as CustomHandler);
///    }
/// 
///    for (final rota in rotasPrivadas) {
///      router.add(rota.methodUpper(), basePath + rota.pathAsShelf(),
///          rota.handler as CustomHandler,
///          middleware: AuthMiddleware.handleRequest);
///    }
/// 
///    app.all('*', router.call);
/// 
@sealed
class CustomRouter {
  final List<RouterEntry> _routes = [];
  final CustomHandler _notFoundHandler;

  static CustomHandler _defaultNotFound = (req, res) {
    res.headers['Content-Type'] = 'application/json;charset=utf-8';
    res.statusCode = 404;
    res.write(
        '''{"message": "Rota não existe","exception": "Rota não existe","stackTrace": ""}''');
  };

  CustomRouter({CustomHandler? notFoundHandler})
      : _notFoundHandler = notFoundHandler ?? _defaultNotFound;

  /// Add [handler] for [verb] requests to [route].
  ///
  /// If [verb] is `GET` the [handler] will also be called for `HEAD` requests
  /// matching [route]. This is because handling `GET` requests without handling
  /// `HEAD` is always wrong. To explicitely implement a `HEAD` handler it must
  /// be registered before the `GET` handler.
  void add(
    String verb,
    String route,
    CustomHandler handler, {
    CustomMiddleware? middleware,
  }) {
    if (!isHttpMethod(verb)) {
      throw ArgumentError.value(verb, 'verb', 'expected a valid HTTP method');
    }
    verb = verb.toUpperCase();

    // if (verb == 'GET') {
    //   // Handling in a 'GET' request without handling a 'HEAD' request is always
    //   // wrong, thus, we add a default implementation that discards the body.
    //   _routes.add(RouterEntry('HEAD', route, handler, middleware: _removeBody));
    // }
    _routes.add(RouterEntry(verb, route, handler, middleware: middleware));
  }

  /// Handle all request to [route] using [handler].
  void all(String route, Function handler, {CustomMiddleware? middleware}) {
    _routes.add(RouterEntry('ALL', route, handler, middleware: middleware));
  }

  /// Route incoming requests to registered handlers.
  ///
  /// This method allows a Router instance to be a [Handler].
  Future call(RequestContext request, ResponseContext resp) async {
    // Note: this is a great place to optimize the implementation by building
    //       a trie for faster matching... left as an exercise for the reader :)
    for (final route in _routes) {
      if (route.verb != request.method.toUpperCase() && route.verb != 'ALL') {
        continue;
      }
      final path =
          request.path.startsWith('/') ? request.path : '/${request.path}';
      final params = route.match(path);
      if (params != null) {
        return await route.invoke(request, resp, params);
      }
    }
    return await _notFoundHandler(request, resp);
  }

  // Handlers for all methods

  /// Handle `GET` request to [route] using [handler].
  ///
  /// If no matching handler for `HEAD` requests is registered, such requests
  /// will also be routed to the [handler] registered here.
  void get(String route, CustomHandler handler, {CustomMiddleware? middleware}) =>
      add('GET', route, handler, middleware: middleware);

  /// Handle `HEAD` request to [route] using [handler].
  void head(String route, CustomHandler handler, {CustomMiddleware? middleware}) =>
      add('HEAD', route, handler, middleware: middleware);

  /// Handle `POST` request to [route] using [handler].
  void post(String route, CustomHandler handler, {CustomMiddleware? middleware}) =>
      add('POST', route, handler, middleware: middleware);

  /// Handle `PUT` request to [route] using [handler].
  void put(String route, CustomHandler handler, {CustomMiddleware? middleware}) =>
      add('PUT', route, handler, middleware: middleware);

  /// Handle `DELETE` request to [route] using [handler].
  void delete(String route, CustomHandler handler, {CustomMiddleware? middleware}) =>
      add('DELETE', route, handler, middleware: middleware);

  /// Handle `CONNECT` request to [route] using [handler].
  void connect(String route, CustomHandler handler,
          {CustomMiddleware? middleware}) =>
      add('CONNECT', route, handler, middleware: middleware);

  /// Handle `OPTIONS` request to [route] using [handler].
  void options(String route, CustomHandler handler,
          {CustomMiddleware? middleware}) =>
      add('OPTIONS', route, handler, middleware: middleware);

  /// Handle `TRACE` request to [route] using [handler].
  void trace(String route, CustomHandler handler, {CustomMiddleware? middleware}) =>
      add('TRACE', route, handler, middleware: middleware);

  /// Handle `PATCH` request to [route] using [handler].
  void patch(String route, CustomHandler handler, {CustomMiddleware? middleware}) =>
      add('PATCH', route, handler, middleware: middleware);
}
