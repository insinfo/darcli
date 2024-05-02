import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';

/// Check if the [regexp] is non-capturing.
bool _isNoCapture(String regexp) {
  // Construct a new regular expression matching anything containing regexp,
  // then match with empty-string and count number of groups.
  return RegExp('^(?:$regexp)|.*\$').firstMatch('')!.groupCount == 0;
}


typedef CustomHandler = FutureOr<dynamic> Function( RequestContext req, ResponseContext res);
typedef CustomMiddleware = CustomHandler Function(CustomHandler innerHandler);

/// Entry in the router.
///
/// This class implements the logic for matching the path pattern.
class RouterEntry {
  /// Pattern for parsing the route pattern
  static final RegExp _parser = RegExp(r'([^<]*)(?:<([^>|]+)(?:\|([^>]*))?>)?');

  final String verb, route;
  final Function _handler;
  final CustomMiddleware? _middleware;

  /// Expression that the request path must match.
  ///
  /// This also captures any parameters in the route pattern.
  final RegExp _routePattern;

  /// Names for the parameters in the route pattern.
  final List<String> _params;

  /// List of parameter names in the route pattern.
  List<String> get params => _params.toList(); // exposed for using generator.

  RouterEntry._(this.verb, this.route, this._handler, this._middleware,
      this._routePattern, this._params);

  factory RouterEntry(
    String verb,
    String route,
    Function handler, {
    CustomMiddleware? middleware,
  }) {
    if (!route.startsWith('/')) {
      throw ArgumentError.value(
          route, 'route', 'expected route to start with a slash');
    }

    final params = <String>[];
    var pattern = '';
    for (var m in _parser.allMatches(route)) {
      pattern += RegExp.escape(m[1]!);
      if (m[2] != null) {
        params.add(m[2]!);
        if (m[3] != null && !_isNoCapture(m[3]!)) {
          throw ArgumentError.value(
              route, 'route', 'expression for "${m[2]}" is capturing');
        }
        pattern += '(${m[3] ?? r'[^/]+'})';
      }
    }
    final routePattern = RegExp('^$pattern\$');

    return RouterEntry._(
        verb, route, handler, middleware, routePattern, params);
  }

  /// Returns a map from parameter name to value, if the path matches the
  /// route pattern. Otherwise returns null.
  Map<String, String>? match(String path) {
    // Check if path matches the route pattern
    var m = _routePattern.firstMatch(path);
    if (m == null) {
      return null;
    }
    // Construct map from parameter name to matched value
    var params = <String, String>{};
    for (var i = 0; i < _params.length; i++) {
      // first group is always the full match, we ignore this group.
      params[_params[i]] = m[i + 1]!;
    }
    return params;
  }

  // invoke handler with given request and params
  Future<dynamic> invoke(RequestContext request, ResponseContext response,
      Map<String, String> params) async {
    request.params.addAll(params);
  
    if (_middleware != null) {
      return await _middleware!((request, response) async {
        return await _handler(request, response);
      });
    } else {
      return await _handler(request, response);
    }
  }
}
