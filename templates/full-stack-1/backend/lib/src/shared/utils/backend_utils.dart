import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/src/shared/utils/duration_tersity.dart';

class BackendUtils {
  /// Pretty format [duration] in terms of milliseconds.
  ///
  /// If [terse] is true, microseconds are ignored.
  /// Use [language] to configure which locale to print for.
  /// Use [abbreviated] to control if the units should be abbreviated.
  static String prettyMilliseconds(Duration duration,
      {bool terse = false,
      DurationLocale language = const EnglishDurationLocale(),
      String separator = ' ',
      bool abbreviated = true}) {
    if (duration.inMilliseconds > 0) {
      final int us = duration.inMicroseconds % 1000;
      if (us == 0 || terse) {
        // If no microseconds are present, print "xxxxx ms"
        final sb = StringBuffer();
        sb.write(duration.inMilliseconds);
        sb.write(separator);
        sb.write(language.millisecond(duration.inMilliseconds, abbreviated));
        return sb.toString();
      } else {
        // If microseconds are present, print "xxx.yy ms"
        final sb = StringBuffer();
        sb.write(duration.inMilliseconds);
        sb.write('.');
        sb.write(_digits(us, 3));
        sb.write(separator);
        sb.write(language.millisecond(duration.inMilliseconds, abbreviated));
        return sb.toString();
      }
    } else {
      // If only microseconds are present, print "yyy us"
      final sb = StringBuffer();
      sb.write(duration.inMicroseconds);
      sb.write(separator);
      sb.write(language.microseconds(duration.inMicroseconds, abbreviated));
      return sb.toString();
    }
  }

  static String _digits(int data, int digits) {
    final String ret = data.toString();
    if (ret.length < digits) return '0' * (digits - ret.length) + ret;
    return ret;
  }

  static String prettyDuration2(Duration duration) {
    var components = <String>[];

    var days = duration.inDays;
    if (days != 0) {
      components.add('${days}d');
    }
    var hours = duration.inHours % 24;
    if (hours != 0) {
      components.add('${hours}h');
    }
    var minutes = duration.inMinutes % 60;
    if (minutes != 0) {
      components.add('${minutes}m');
    }

    var seconds = duration.inSeconds % 60;
    var centiseconds = (duration.inMilliseconds % 1000) ~/ 10;
    if (components.isEmpty || seconds != 0 || centiseconds != 0) {
      components.add('$seconds');
      if (centiseconds != 0) {
        components.add('.');
        components.add(centiseconds.toString().padLeft(2, '0'));
      }
      components.add('s');
    }
    return components.join();
  }

  /// Converts [duration] into legible string with given level of [tersity]
  ///
  /// Example:
  ///
  ///     final dur = Duration(
  ///         days: 5,
  ///         hours: 23,
  ///         minutes: 59,
  ///         seconds: 59,
  ///         milliseconds: 999,
  ///         microseconds: 999);
  ///     printDuration(dur); // => 5d 23h 59m 59s 999ms 999us
  ///
  /// Use [abbreviated] to determine if units should be abbreviated or not.
  ///
  /// Example:
  ///
  ///     // => 5 days 9 hours
  ///     printDuration(aDay * 5 + anHour * 9, abbreviated: false);
  ///
  /// Use [locale] to format according to the desired locale.
  ///
  /// Example:
  ///
  ///     // => 5días 9horas
  ///     printDuration(aDay * 5 + anHour * 9,
  ///         abbreviated: false, locale: spanishLocale);
  static String prettyDuration(Duration duration,
      {DurationTersity tersity = DurationTersity.second,
      DurationTersity upperTersity = DurationTersity.week,
      DurationLocale locale = const EnglishDurationLocale(),
      String? spacer,
      String? delimiter,
      String? conjunction,
      bool abbreviated = false,
      bool first = false}) {
    if (abbreviated && delimiter == null) {
      delimiter = ', ';
      spacer = '';
    } else {
      delimiter ??= ' ';
      spacer ??= locale.defaultSpacer;
    }

    var out = <String>[];

    for (final currentTersity in DurationTersity.list) {
      if (currentTersity > upperTersity) {
        continue;
      } else if (currentTersity < tersity) {
        break;
      }
      int value = duration.inUnit(currentTersity);
      if (currentTersity != upperTersity) {
        value %= currentTersity.mod;
      }
      if (value > 0) {
        out.add(
            '$value$spacer${locale.inUnit(currentTersity, value, abbreviated)}');
      } else if (currentTersity == tersity && out.isEmpty) {
        out.add('0$spacer${locale.inUnit(currentTersity, value, abbreviated)}');
      }
    }

    if (out.length == 1 || first == true) {
      return out.first;
    } else {
      if (conjunction == null || out.length == 1) {
        return out.join(delimiter);
      } else {
        return out.sublist(0, out.length - 1).join(delimiter) +
            conjunction +
            out.last;
      }
    }
  }

  /// verifica se o valor passado é diferente de null | -1 | "null"
  static bool isDefined(dynamic val) {
    return val != null && val != '-1' && val != -1 && val != 'null';
  }

  /// return string of hexadecimal digits
  static String stringToMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  static geraSenhaPsql(String password, String username) {
    var passAndUser = '${password}sw.${username}';
    return 'md5' + BackendUtils.stringToMd5(passAndUser);
  }

  static onlyNumbers(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static ocultarInicio(String value, {int limit = 3, String replace = '*'}) {
    if (value.isEmpty) {
      return value;
    }
    var end = value.substring(limit);
    return List.generate(limit, ((index) => replace)).join('') + end;
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

  static const dynamic DEFAULT_NULL = [];

  ///
  /// @param data
  /// @param tableName nome da tabela relacionada
  /// @param localKey key id da tabela relacionada
  /// @param foreignKey id contido nos dados passados pelo parametro data para comparar com o key id da tabela relacionada
  /// @param relationName nome da chave no map que estara com o resultado
  /// @param defaultNull valor padrão para a chave no map caso não tenha resultado List | null
  ///
  /// @param null callback_fields
  /// Este parametro deve ser uma função anonima com um parametro que é o campo
  /// utilizada para alterar as informações de um determinado campo vindo do banco
  /// Exemplo:
  /// (field) {
  ///  field['description'] = strip_tags(field['description']);
  /// }
  ///
  /// @param null $callback_query
  /// Este parametro deve ser uma função com um parametro. Neste parametro você
  /// receberá a query utilizada na consulta, possibilitando
  /// realizar operações de querys extras para esta ação.
  ///
  /// Exemplo:
  /// (query) {
  ///  query.orderBy('field_name', 'asc');
  /// }
  ///
  /// @param bool isSingle
  ///
  ///
  static Future<List<Map<String, dynamic>>> getRelationFromMaps(
    Connection connection,
    List<Map<String, dynamic>> data,
    String tableName,
    String localKey,
    String foreignKey, {
    String? relationName,
    dynamic defaultNull = DEFAULT_NULL,
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
    var query = connection.table(tableName).select();
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
      queryResult = await query.get();
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
