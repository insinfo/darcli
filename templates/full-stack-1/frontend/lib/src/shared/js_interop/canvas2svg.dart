@JS()
library canvas2svg_interop;

import 'dart:html';

import 'package:js/js.dart';

@JS()
@anonymous
abstract class C2SOptions {
  // width: 500, height: 500, enableMirroring: false
  external factory C2SOptions(
      {bool enableMirroring = false,
      int width= 500,
      int height= 500,
      ctx = null,
      canvas = null});

  external bool get enableMirroring;
  external int get width;
  external int get height;
  external CanvasRenderingContext2D get ctx;
  external CanvasElement get canvas;
}

@JS('window.C2S')
class C2S {
  //JsObject.jsify(Object object);

  ///
  ///  The mock canvas context
  ///  @param o - options include:
  ///  ctx - existing Context2D to wrap around
  ///  width - width of your canvas (defaults to 500)
  ///  height - height of your canvas (defaults to 500)
  ///  enableMirroring - enables canvas mirroring (get image data) (defaults to false)
  ///  document - the document object (defaults to the current document)
  ///
  external factory C2S(C2SOptions config);

  external dynamic getContext(String contextId);

  ///
  /// Returns the serialized value of the svg so far
  /// @param fixNamedEntities - Standalone SVG doesn't support named entities, which document.createTextNode encodes.
  ///                           If true, we attempt to find all named entities and encode it as a numeric entity.
  /// @return serialized svg
  ///
  external String getSerializedSvg([bool fixNamedEntities = false]);

  ///
  /// Returns the root svg
  /// @return
  ///
  external dynamic getSvg();

  external set fillStyle(String color);
  external set strokeStyle(String color);

  external String get fillStyle;
  external String get strokeStyle;

  /**
     * adds a rectangle element
     */
  external void fillRect(num x, num y, num width, num height);

  external CanvasRenderingContext2D getContext2d();
}
