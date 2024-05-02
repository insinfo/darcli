import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sibem_frontend_site/sibem_frontend_site.dart';
import 'package:http_parser/http_parser.dart';

class RestServiceBase {
  final RestConfig conf;
  RestServiceBase(this.conf);

  Future<List<Map<String, dynamic>>> getAllJson(String path,
      {Map<String, dynamic>? queryParameters}) async {
    var resp = await rawGet(
        conf.getBackendUri(path, queryParameters: queryParameters),
        headers: conf.headers);

    if (resp.statusCode == 200) {
      var json = jsonDecode(resp.bodyUtf8);
      if (json is! List) {
        throw Exception(
            'RestServiceBase@getAllJson os dados não são uma lista $path ${resp.bodyUtf8}');
      }
      return json.map((e) => e as Map<String, dynamic>).toList();
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else {
      throw Exception(
          'RestServiceBase@getAllJson Falha ao buscar lista de dados $path ${resp.bodyUtf8}');
    }
  }

  Future<dynamic> getJson(String path,
      {Map<String, dynamic>? queryParameters}) async {
    var resp = await rawGet(
        conf.getBackendUri(path, queryParameters: queryParameters),
        headers: conf.headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else if (resp.statusCode == 404) {
      throw NotFoundException();
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  Future<DataFrame<T>> getDataFrame<T>(String path,
      {T Function(Map<String, dynamic>)? builder, Filters? filtros}) async {
    var json = await getJson(path, queryParameters: filtros?.getParams());
    return DataFrame<T>.fromMapWithFactory(json, builder);
  }

  Future<List<T>> getListEntity<T>(String path,
      {required T Function(Map<String, dynamic>) builder,
      Filters? filtros}) async {
    var json = await getJson(path, queryParameters: filtros?.getParams());
    return List<T>.from((json as List).map((e) => builder(e)));
  }

  Future<List<Map<String, dynamic>>> getListMap(String path,
      {Filters? filtros}) async {
    var json = await getJson(path, queryParameters: filtros?.getParams());
    return (json as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<T> getEntity<T>(String path,
      {required T Function(Map<String, dynamic>) builder,
      Map<String, dynamic>? queryParameters}) async {
    final json = await getJson(path, queryParameters: queryParameters);
    return builder(json);
  }

  /// send Entity implemented SerializeBase interface to server backend Rest API with jsonEncode
  /// `Return`  jsonDecode Map<String, dynamic> | dynamic
  Future<dynamic> insertEntity(SerializeBase entity, String path,
      {Map<String, String>? queryParameters}) async {
    final resp = await rawPost(
        conf.getBackendUri(path, queryParameters: queryParameters),
        headers: conf.headers,
        body: jsonEncode(entity.toMap()));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else {
      throw Exception(resp.bodyUtf8);
    }

    //HTTP  –
  }

  /// [arquivo] = {'originalFilename': fileBytes}
  Future<dynamic> insertEntityWithAnexo(
      SerializeBase entity, Map<String, List<int>> arquivo, String path,
      {Map<String, String>? queryParameters}) async {
    final uri = conf.getBackendUri(path, queryParameters: queryParameters);
    final headers = {'Authorization': conf.headers['Authorization']!};
    final files = <http.MultipartFile>[];

    final originalFilename = arquivo.keys.first;
    final bytes = arquivo.values.first;

    files.add(http.MultipartFile.fromBytes('file[]', bytes,
        contentType: MediaType('application', 'octet-stream'),
        filename: originalFilename));

    final resp = await rawMultipartRequest(
      uri,
      data: jsonEncode(entity.toMap()),
      headers: headers,
      files: files,
      method: 'POST',
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  /// [arquivos] = [{'originalFilename': fileBytes},...]
  Future<dynamic> insertEntityWithAnexos(
      SerializeBase entity, List<Map<String, List<int>>> arquivos, String path,
      {Map<String, String>? queryParameters}) async {
    var uri = conf.getBackendUri(path, queryParameters: queryParameters);
    var headers = {'Authorization': conf.headers['Authorization']!};
    var files = <http.MultipartFile>[];

    for (var arquivo in arquivos) {
      final originalFilename = arquivo.keys.first;
      final bytes = arquivo.values.first;
      files.add(http.MultipartFile.fromBytes('file[]', bytes,
          contentType: MediaType('application', 'octet-stream'),
          filename: originalFilename));
    }

    var resp = await rawMultipartRequest(
      uri,
      data: jsonEncode(entity.toMap()),
      headers: headers,
      files: files,
      method: 'POST',
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  /// [arquivos] = [{'originalFilename': fileBytes},...]
  Future<dynamic> updateEntityWithAnexos(
      SerializeBase entity, List<Map<String, List<int>>> arquivos, String path,
      {Map<String, String>? queryParameters}) async {
    final uri = conf.getBackendUri(path, queryParameters: queryParameters);
    final headers = {'Authorization': conf.headers['Authorization']!};
    final files = <http.MultipartFile>[];

    for (var arquivo in arquivos) {
      final originalFilename = arquivo.keys.first;
      final bytes = arquivo.values.first;

      files.add(http.MultipartFile.fromBytes('file[]', bytes,
          contentType: MediaType('application', 'octet-stream'),
          filename: originalFilename));
    }

    final resp = await rawMultipartRequest(
      uri,
      data: jsonEncode(entity.toMap()),
      headers: headers,
      files: files,
      method: 'PUT',
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  /// [arquivo] = {originalFilename: fileBytes}
  Future<dynamic> uploadFileBase(Map<String, List<int>> arquivo, String path,
      {Map<String, String>? queryParameters}) async {
    final uri = conf.getBackendUri(path, queryParameters: queryParameters);
    final headers = {'Authorization': conf.headers['Authorization']!};
    final files = <http.MultipartFile>[];

    final originalFilename = arquivo.keys.first;
    final bytes = arquivo.values.first;

    files.add(http.MultipartFile.fromBytes('file[]', bytes,
        contentType: MediaType('application', 'octet-stream'),
        filename: originalFilename));

    final resp = await rawMultipartRequest(
      uri,
      headers: headers,
      files: files,
      method: 'POST',
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  Future<dynamic> updateEntity(SerializeBase entity, String path,
      {Map<String, String>? queryParameters}) async {
    var resp = await rawPut(
        conf.getBackendUri(path, queryParameters: queryParameters),
        headers: conf.headers,
        body: jsonEncode(entity.toMap()));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  Future<dynamic> patchEntity(SerializeBase entity, String path,
      {Map<String, String>? queryParameters}) async {
    var resp = await rawPatch(
        conf.getBackendUri(path, queryParameters: queryParameters),
        headers: conf.headers,
        body: jsonEncode(entity.toMap()));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  Future<dynamic> deleteAllEntity(List<SerializeBase> entities, String path,
      {Map<String, String>? queryParameters}) async {
    var uri = conf.getBackendUri(path, queryParameters: queryParameters);
    var body = jsonEncode(entities.map((e) => e.toMap()).toList());

    final resp = await rawDelete(uri, body: body, headers: conf.headers);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  Future<dynamic> deleteAllMaps(List<Map> items, String path,
      {Map<String, String>? queryParameters}) async {
    var uri = conf.getBackendUri(path, queryParameters: queryParameters);
    var body = jsonEncode(items);

    final resp = await rawDelete(uri, body: body, headers: conf.headers);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  Future<dynamic> deleteEntity(SerializeBase entity, String path,
      {Map<String, String>? queryParameters}) async {
    var uri = conf.getBackendUri(path, queryParameters: queryParameters);
    var body = jsonEncode(entity.toMap());

    final resp = await rawDelete(uri, body: body, headers: conf.headers);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else if (resp.statusCode == 401 &&
        resp.bodyUtf8.contains('JWT token expired')) {
      throw TokenExpiredException();
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  Future<http.Response> rawMultipartRequest(Uri uri,
      {String? data,
      Map<String, String>? headers,
      List<http.MultipartFile>? files,
      Encoding encoding = utf8,
      String method = 'POST'}) async {
    final request = http.MultipartRequest(method, uri);
    if (headers != null) {
      request.headers.addAll(headers);
    }

    if (data != null) {
      request.fields['data'] = data;
    }

    if (files != null) {
      for (var i = 0; i < files.length; i++) {
        request.files.add(files[i]);
      }
    }

    final resp = await http.Response.fromStream(await request.send());

    if (resp.statusCode == 401 && resp.bodyUtf8.contains('JWT token expired')) {
      conf.router.navigate(RoutePaths.sessionExpired.toUrl());
    }
    return resp;
  }

  Future<http.Response> rawDelete(Uri uri,
      {Object? body,
      Map<String, String>? headers,
      Encoding encoding = utf8}) async {
    final request = http.Request('DELETE', uri);
    if (headers != null) {
      request.headers.addAll(conf.headers);
    }
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List) {
        request.bodyBytes = body.cast<int>();
      } else if (body is Map) {
        request.bodyFields = body.cast<String, String>();
      } else {
        throw ArgumentError('Invalid request body "$body".');
      }
    }
    final resp = await http.Response.fromStream(await request.send());

    if (resp.statusCode == 401 && resp.bodyUtf8.contains('JWT token expired')) {
      conf.router.navigate(RoutePaths.sessionExpired.toUrl());
    }
    return resp;
  }

  Future<http.Response> rawGet(Uri url, {Map<String, String>? headers}) async {
    var resp = await http.get(url, headers: headers);

    if (resp.statusCode == 401 && resp.bodyUtf8.contains('JWT token expired')) {
      //print('RestServiceBase@rawGet não autorizado');
      conf.router.navigate(RoutePaths.sessionExpired.toUrl());
    }

    return resp;
  }

  Future<http.Response> rawPost(Uri url,
      {Map<String, String>? headers,
      Object? body,
      Encoding? encoding = utf8}) async {
    var resp =
        await http.post(url, headers: headers, body: body, encoding: encoding);

    if (resp.statusCode == 401 && resp.bodyUtf8.contains('JWT token expired')) {
      conf.router.navigate(RoutePaths.sessionExpired.toUrl());
    }
    return resp;
  }

  Future<http.Response> rawPut(Uri url,
      {Map<String, String>? headers, body, Encoding? encoding = utf8}) async {
    var resp =
        await http.put(url, headers: headers, body: body, encoding: encoding);

    if (resp.statusCode == 401 && resp.bodyUtf8.contains('JWT token expired')) {
      conf.router.navigate(RoutePaths.sessionExpired.toUrl());
    }
    return resp;
  }

  Future<http.Response> rawPatch(Uri url,
      {Map<String, String>? headers, body, Encoding? encoding = utf8}) async {
    var resp =
        await http.patch(url, headers: headers, body: body, encoding: encoding);

    if (resp.statusCode == 401 && resp.bodyUtf8.contains('JWT token expired')) {
      conf.router.navigate(RoutePaths.sessionExpired.toUrl());
    }
    return resp;
  }
  // Future<http.Response> rawDelete(Uri url,
  //         {Map<String, String>? headers, Encoding? encoding = utf8}) =>
  //     http.delete(url, headers: headers, encoding: encoding);
}
