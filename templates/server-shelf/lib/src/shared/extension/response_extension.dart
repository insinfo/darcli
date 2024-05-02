import 'dart:convert';

import 'package:rava_core/rava_core.dart';
import 'package:shelf/shelf.dart';

const defaultHeaders = {'Content-Type': 'application/json;charset=utf-8'};

/// 422 Unprocessable Entity
Response responseError(String message,
    {dynamic exception, dynamic stackTrace, int statusCode = 422}) {
  final headers = {...defaultHeaders};
  final errorMsg = jsonEncode({
    'is_error': true,
    'status_code': statusCode,
    'message': message,
    'exception': exception?.toString(),
    'stackTrace': stackTrace?.toString()
  }, toEncodable: RavaCoreUtils.customJsonEncode);
  return Response(statusCode, body: errorMsg, headers: headers);
}

Response unauthorized(
    {String message = StatusMessage.ACESSO_NAO_AUTORIZADO,
    int statusCode = 401,
    dynamic exception}) {
  final headers = {...defaultHeaders};
  final errorMsg = jsonEncode({
    'is_error': true,
    'status_code': statusCode,
    'message': message,
    'exception': exception?.toString(),
  }, toEncodable: RavaCoreUtils.customJsonEncode);
  return Response(statusCode, body: errorMsg, headers: headers);
}

Response responseJson(Object? value,
    {int statusCode = 200, int? totalRecords}) {
  final headers = {...defaultHeaders};
  var json = value is String
      ? value
      : jsonEncode(value, toEncodable: RavaCoreUtils.customJsonEncode);

  if (totalRecords != null) {
    headers['total-records'] = '$totalRecords';
  }

  return Response(statusCode, body: json, headers: headers);
}

Response responsePage(DataFrame dataPage, {int statusCode = 200}) {
  final headers = {...defaultHeaders};
  // headers['Content-Type'] = 'application/json;charset=utf-8';
  headers['total-records'] = '${dataPage.totalRecords}';
  return Response(statusCode, body: dataPage.toJson(), headers: headers);
}

Response responseDataFrame(DataFrame dataPage, {int statusCode = 200}) {
  final headers = {...defaultHeaders};
  // headers['Content-Type'] = 'application/json;charset=utf-8';
  headers['total-records'] = '${dataPage.totalRecords}';
  return Response(statusCode, body: dataPage.toJson(), headers: headers);
}

Response responseModelList(List<SerializeBase> objects,
    {int? totalRecords, int statusCode = 200}) {
  final headers = {...defaultHeaders};

  headers['total-records'] =
      totalRecords != null ? '$totalRecords' : '${objects.length}';

  final json = jsonEncode(objects.map((e) => e.toMap()).toList(),
      toEncodable: RavaCoreUtils.customJsonEncode);

  return Response(statusCode, body: json, headers: headers);
}

/// response to http request json of models implemeted SerializeBase
Response responseModel(SerializeBase object,
    {int? totalRecords, int statusCode = 200}) {
  final headers = {...defaultHeaders};

  final json =
      jsonEncode(object.toMap(), toEncodable: RavaCoreUtils.customJsonEncode);

  return Response(statusCode, body: json, headers: headers);
}

Response responseSuccess(
    {String message = StatusMessage.SUCCESS, int statusCode = 200}) {
  final headers = {...defaultHeaders};

  final json = jsonEncode({'message': message},
      toEncodable: RavaCoreUtils.customJsonEncode);

  return Response(statusCode, body: json, headers: headers);
}
