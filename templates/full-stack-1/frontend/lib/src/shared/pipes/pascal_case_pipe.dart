import 'package:new_sali_core/new_sali_core.dart';
import 'package:ngdart/angular.dart';
import '../exceptions/invalid_pipe_argument_exception.dart';

///
/// ### Examples
/// var str = 'How to text in angular';
///  {{ $pipe.pascalCase(str,6) }}             // output is 'how to...'
@Pipe('pascalCase', pure: true)
class PascalCasePipe {
  String? transform(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      if (value.isEmpty) {
        return '';
      }
      return StringUtils.toPascalCase(value);
    } else {
      throw InvalidPipeArgumentException(PascalCasePipe, value);
    }
  }

  const PascalCasePipe();
}
