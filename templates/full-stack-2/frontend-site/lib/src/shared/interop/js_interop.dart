@JS()
library js_interop;

import 'package:js/js.dart';

@JS()
external void addPreventScrolling(dynamic element);

@JS()
external void removePreventScrolling(dynamic element);

@JS()
external void addStopPropagationScrolling(dynamic element);

@JS()
external void removeStopPropagationScrolling(dynamic element);

@JS('console.log')
external void consolelog(dynamic contnt);
