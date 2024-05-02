import 'dart:convert';

import 'package:esic_core/esic_core.dart';

import '../rest_config.dart';
import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart';
import '../extensions/http_response_extension.dart';

class RestServiceBase {
  final RestConfig conf;
  RestServiceBase(this.conf);

  Future<List<Map<String, dynamic>>> getAllJson(String path,
      {Map<String, dynamic>? queryParameters}) async {
    var resp = await rawGet(conf.getBackendUri(path, queryParameters),
        headers: conf.headers);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      throw Exception('Falha ao buscar lista de dados');
    }
  }

  Future<Map<String, dynamic>> getJson(String path,
      {Map<String, dynamic>? queryParameters}) async {
    var resp = await rawGet(conf.getBackendUri(path, queryParameters),
        headers: conf.headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  Future<DataFrame<T>> getDataFrame<T>(
      String path, T Function(Map<String, dynamic>) factoryes,
      {Filters? filtros}) async {
    var json = await getJson(path, queryParameters: filtros?.getParams());
    return DataFrame<T>.fromMap(json, factoryes);
  }

  Future<T> getEntity<T>(String path, T Function(Map<String, dynamic>) factory,
      {Map<String, dynamic>? queryParameters}) async {
    var json = await getJson(path, queryParameters: queryParameters);
    return factory(json);
  }

  Future<dynamic> insertEntity(SerializeBase entity, String path,
      {Map<String, String>? queryParameters}) async {
    var resp = await rawPost(conf.getBackendUri(path, queryParameters),
        headers: conf.headers, body: jsonEncode(entity.toMap()));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  Future<dynamic> insertEntityWithAnexos(
      SerializeBase entity, List<Anexo> anexos, String path,
      {Map<String, String>? queryParameters}) async {
    var uri = conf.getBackendUri(path, queryParameters);

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({'Authorization': conf.headers['Authorization']!});
    request.fields['data'] = jsonEncode(entity.toMap());

    for (var i = 0; i < anexos.length; i++) {
      request.files.add(http.MultipartFile.fromBytes('file[]', anexos[i].bytes,
          contentType: MediaType('application', 'octet-stream'),
          filename: anexos[i].nome));
    }

    var resp = await request.send();

    var respBody = await resp.stream.bytesToString(utf8);
    if (resp.statusCode == 200) {
      return jsonDecode(respBody);
    } else {
      throw Exception(respBody);
    }
  }

  Future<dynamic> updateEntityWithAnexos(
      SerializeBase entity, List<Anexo> anexos, String path,
      {Map<String, String>? queryParameters}) async {
    var uri = conf.getBackendUri(path, queryParameters);

    var request = http.MultipartRequest('PUT', uri);
    request.headers.addAll({'Authorization': conf.headers['Authorization']!});
    request.fields['data'] = jsonEncode(entity.toMap());

    for (var i = 0; i < anexos.length; i++) {
      request.files.add(http.MultipartFile.fromBytes('file[]', anexos[i].bytes,
          contentType: MediaType('application', 'octet-stream'),
          filename: anexos[i].nome));
    }

    var resp = await request.send();

    var respBody = await resp.stream.bytesToString(utf8);
    if (resp.statusCode == 200) {
      return jsonDecode(respBody);
    } else {
      throw Exception(respBody);
    }
  }

  Future<dynamic> updateEntity(SerializeBase entity, String path,
      {Map<String, String>? queryParameters}) async {
    var resp = await rawPut(conf.getBackendUri(path, queryParameters),
        headers: conf.headers, body: jsonEncode(entity.toMap()));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.bodyUtf8);
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  Future<dynamic> deleteAllEntity(List<SerializeBase> entities, String path,
      {Map<String, String>? queryParameters}) async {
    var uri = conf.getBackendUri(path, queryParameters);
    var body = jsonEncode(entities.map((e) => e.toMap()).toList());

    final request = http.Request('DELETE', uri);
    request.headers.addAll(conf.headers);
    request.body = body;
    final resp = await request.send();
    var respBody = await resp.stream.bytesToString(utf8);

    if (resp.statusCode == 200) {
      return jsonDecode(respBody);
    } else {
      throw Exception(respBody);
    }
  }

  Future<dynamic> deleteEntity(SerializeBase entity, String path,
      {Map<String, String>? queryParameters}) async {
    var uri = conf.getBackendUri(path, queryParameters);
    var body = jsonEncode(entity.toMap());

    final request = http.Request('DELETE', uri);
    request.headers.addAll(conf.headers);
    request.body = body;
    final resp = await request.send();
    var respBody = await resp.stream.bytesToString(utf8);

    if (resp.statusCode == 200) {
      return jsonDecode(respBody);
    } else {
      throw Exception(respBody);
    }
  }

  Future<http.Response> rawGet(url, {Map<String, String>? headers}) =>
      http.get(url, headers: headers);

  Future<http.Response> rawPost(url,
          {Map<String, String>? headers, body, Encoding? encoding = utf8}) =>
      http.post(url, headers: headers, body: body, encoding: encoding);

  Future<http.Response> rawPut(url,
          {Map<String, String>? headers, body, Encoding? encoding = utf8}) =>
      http.put(url, headers: headers, body: body, encoding: encoding);

  Future<http.Response> rawDelete(url,
          {Map<String, String>? headers, Encoding? encoding = utf8}) =>
      http.delete(url, headers: headers, encoding: encoding);
}
