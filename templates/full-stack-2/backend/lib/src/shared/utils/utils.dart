import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fluent_query_builder/fluent_query_builder.dart';

class Utils {
  static String stringToMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  static String toMd5String(dynamic input) {
    return md5.convert(utf8.encode(input.toString())).toString();
  }

  static String intToMd5(int input) {
    return md5.convert(utf8.encode(input.toString())).toString();
  }

  static String? unaccent(String? str) {
    if (str == null) {
      return null;
    }
    var withDia =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    var withoutDia =
        'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    for (int i = 0; i < withDia.length; i++) {
      str = str!.replaceAll(withDia[i], withoutDia[i]);
    }

    return str;
  }

  /// [foreignKey] tem que serm uma chave na lista de maps [data]
  /// [localKey] tem que ser um campo definido na tabela [tableName]
  static Future<List<Map<String, dynamic>>> getRelationFromMaps(
    DbLayer db,
    List<Map<String, dynamic>> data,
    String tableName,
    String localKey,
    String foreignKey, {
    String? relationName,
    dynamic defaultNull = null,
    Function(Map<String?, dynamic>)? callback_fields,
    Function(QueryBuilder)? callback_query,
    isSingle = false,
  }) async {
    //1º obtem os ids
    var itens_id = <dynamic>[];
    for (var map in data) {
      var itemId = map.containsKey(foreignKey) ? map[foreignKey] : null;

      //não adiciona se for nulo ou vazio ou diferente de int
      if (itemId != null) {
        itens_id.add(itemId);
      }
    }

    //instancia o objeto query builder
    var query = db.select().from(tableName);
    //checa se foi passado callback_query para mudar a query
    if (callback_query != null) {
      callback_query(query);
    }

    List<Map<String?, dynamic>>? queryResult;
    //se ouver itens a serem pegos no banco
    if (itens_id.isNotEmpty) {
      //prepara a query where in e executa
      query.whereRaw(
          '"$tableName"."$localKey" in (${itens_id.map((e) => "'$e'").join(",")})');
      queryResult = await query.getAsMap();
    } else {
      queryResult = null;
    }

    //verifica se foi passado um nome para o node de resultados
    if (relationName != null) {
      relationName = relationName + '';
    } else {
      relationName = tableName;
    }
    if (isSingle) {
      defaultNull = null;
    }

    //var result = <Map<String, dynamic>>[];
    //intera sobre a lista de dados passados
    for (var item in data) {
      //result.add({relationName: defaultNull});
      item[relationName] = defaultNull;
      var conjunto = [];
      //faz o loop sobre os resultados da query
      if (queryResult != null) {
        for (Map<String?, dynamic>? value in queryResult) {
          if (value is Map<String, dynamic>) {
            //verifica se o item corrente tem relação com algum filho trazido pela query
            if (item[foreignKey] == value[localKey]) {
              //checa se foi passado callback_fields
              if (callback_fields != null) {
                value = callback_fields(value);
              }
              //verifica se é para trazer um filho ou varios
              if (isSingle) {
                item[relationName] = value ?? defaultNull;
                break;
              } else {
                conjunto.add(value ?? defaultNull);
              }

              item[relationName] = conjunto;
            }
          }
        }
      }
    }

    //fim
    return data;
  }
}
