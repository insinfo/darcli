/// Angel CORS middleware.
library angel3_cors;

import 'dart:async';

import 'package:angel3_framework/angel3_framework.dart';
import 'cors_options.dart';
export 'cors_options.dart';


/// Determines if a request origin is CORS-able.
typedef _CorsFilter = bool Function(String origin);

bool _isOriginAllowed(String? origin, [allowedOrigin]) {
  allowedOrigin ??= [];
  if (allowedOrigin is Iterable) {
    return allowedOrigin.any((x) => _isOriginAllowed(origin, x));
  } else if (allowedOrigin is String) {
    return origin == allowedOrigin;
  } else if (allowedOrigin is RegExp) {
    return origin != null && allowedOrigin.hasMatch(origin);
  } else if (origin != null && allowedOrigin is _CorsFilter) {
    return allowedOrigin(origin);
  } else {
    return allowedOrigin != false;
  }
}

/// On-the-fly configures the [cors] handler. Use this when the context of the surrounding request
/// is necessary to decide how to handle an incoming request.
Future<bool> Function(RequestContext, ResponseContext) dynamicCors(
    FutureOr<CorsOptions> Function(RequestContext, ResponseContext) f) {
  return (req, res) async {
    var opts = await f(req, res);
    var handler = cors(opts);
    return await handler(req, res);
  };
}

/// Applies the given [CorsOptions].
Future<bool> Function(RequestContext, ResponseContext) cors(
    [CorsOptions? options]) {
  options ??= CorsOptions();

  return (req, res) async {
    // access-control-allow-credentials
    if (options!.credentials == true) {
      res.headers[ACCESS_CONTROL_ALLOW_CREDENTIALS] = 'true';
    }

    // access-control-allow-headers
    if (req.method == OPTIONS && options.allowedHeaders.isNotEmpty) {
      res.headers[ACCESS_CONTROL_ALLOW_HEADERS] =
          options.allowedHeaders.join(',');
    } else if (req.headers![ACCESS_CONTROL_REQUEST_HEADERS] != null) {
      res.headers[ACCESS_CONTROL_ALLOW_HEADERS] =
          req.headers!.value(ACCESS_CONTROL_REQUEST_HEADERS)!;
    }

    // access-control-expose-headers
    if (options.exposedHeaders.isNotEmpty) {
      res.headers[ACCESS_CONTROL_EXPOSE_HEADERS] =
          options.exposedHeaders.join(',');
    }

    // access-control-allow-methods
    if (req.method == OPTIONS && options.methods.isNotEmpty) {
      res.headers[ACCESS_CONTROL_ALLOW_METHODS] = options.methods.join(',');
    }

    // access-control-max-age
    if (req.method == OPTIONS && options.maxAge != null) {
      res.headers[ACCESS_CONTROL_MAX_AGE] = options.maxAge.toString();
    }

    // access-control-allow-origin
    if (options.origin == false || options.origin == '*') {
      res.headers[ACCESS_CONTROL_ALLOW_ORIGIN] = '*';
    } else if (options.origin is String) {
      res
        ..headers[ACCESS_CONTROL_ALLOW_ORIGIN] = options.origin as String
        ..headers[VARY] = ORIGIN;
    } else {
      var isAllowed =
          _isOriginAllowed(req.headers!.value(ORIGIN), options.origin);

      res.headers[ACCESS_CONTROL_ALLOW_ORIGIN] =
          isAllowed ? req.headers!.value(ORIGIN)! : false.toString();

      if (isAllowed) {
        res.headers[VARY] = ORIGIN;
      }
    }

    if (req.method != OPTIONS) return true;
    //res.statusCode = options.successStatus ?? 204;
    res.statusCode = options.successStatus;
    res.contentLength = 0;
    await res.close();
    return options.preflightContinue;
  };
}
