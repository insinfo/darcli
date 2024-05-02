import 'package:new_sali_core/new_sali_core.dart';
import 'package:ngdart/angular.dart';
import '../exceptions/invalid_pipe_argument_exception.dart';

///
/// ### Examples
/// var str = 'How to text in angular';
///  {{ $pipe.titleCase(str) }}             // output is 'how to...'
@Pipe('titleCase', pure: true)
class TitleCasePipe {
  static const DEFAULT_SEPARATOR = ' ';

  String? transform(dynamic value) {
    //, [String separator = TitleCasePipe.DEFAULT_SEPARATOR, List<String> exclusions = const []]
    if (value == null) return null;

    if (value is String) {
      if (value.isEmpty) {
        return '';
      }
      //return StringUtils.toTitleCase(value, separator, exclusions);
      return StringUtils.titleCase(value);
    } else {
      throw InvalidPipeArgumentException(TitleCasePipe, value);
    }
  }

  const TitleCasePipe();
}
