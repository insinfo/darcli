import 'package:new_sali_core/new_sali_core.dart';
import 'package:ngdart/angular.dart';
import '../exceptions/invalid_pipe_argument_exception.dart';

///
///
///
/// ### Examples
/// var str = 'How to truncate text in angular';
///  {{ $pipe.hideString(str,2) }}             // output is 'how to...'
@Pipe('hideString', pure: true)
class HideStringPipe {
  String? transform(dynamic value,
      [int visibleCharacters = 2, String trail = '*']) {
    if (value == null) return null;
    // if (value != String?) {
    //   throw InvalidPipeArgumentException(TruncatePipe, value);
    // }
    //static String hidePartsOfString(String string, {int visibleCharacters = 2,String trail = '*' }) {
    if (value is String ) {
      if(value.isEmpty){
        return '';
      }
      return SaliCoreUtils.hidePartsOfString(value,
          visibleCharacters: visibleCharacters, trail: trail);
    } else {
      throw InvalidPipeArgumentException(HideStringPipe, value);
    }
  }

  const HideStringPipe();
}
