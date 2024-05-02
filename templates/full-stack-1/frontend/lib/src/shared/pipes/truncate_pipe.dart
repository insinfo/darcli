import 'package:ngdart/angular.dart';
import '../exceptions/invalid_pipe_argument_exception.dart';

///
///
///
/// ### Examples
/// var str = 'How to truncate text in angular';
///  {{ $pipe.truncate(str,6) }}             // output is 'how to...'
@Pipe('truncate', pure: true)
class TruncatePipe {
  String? transform(dynamic value, int limit, [String trail = '...']) {
    if (value == null) return null;
    // if (value != String?) {
    //   throw InvalidPipeArgumentException(TruncatePipe, value);
    // }
    if (value is String) {
      if (value.isEmpty) {
        return '';
      }
      return value.length > limit ? value.substring(0, limit) + trail : value;
    } else {
      throw InvalidPipeArgumentException(TruncatePipe, value);
    }
  }

  const TruncatePipe();
}
