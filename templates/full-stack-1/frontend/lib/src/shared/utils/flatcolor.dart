import 'dart:math';

import 'rainbow.dart';

/// var deg = 45; //insert your degree here or fetch it from some element
/// var x = new FlatColor(deg);
///
/// x.h //hue - number
/// x.s //saturation - number
/// x.v //value - number
/// x.r //red - number
/// x.g //green - number
/// x.b //blue - number
/// x.hex //hex - String, lowercase, starts with a '#'
///
class FlatColor {
  dynamic h;
  dynamic s;
  dynamic v;
  dynamic r;
  dynamic g;
  dynamic b;
  String hex = '';

  String generateHex2() {
    var random = Random();
    var chars = "0123456789ABCDEF";
    var color = "#";
    for (var i = 0; i < 6; i++) {
      color += chars[(random.nextDouble() * 16).floor()];
    }

    return color;
  }

  /// gera cores com base em um gradiente linear
  static List<String> generate2({int length = 20, bool inverse = true}) {
    var colors = <String>[];

    //print('FlatColor@generate2 length: $length');
    if(length == 0){
      return <String>[];
    }

    var rainbow = Rainbow(
        spectrum: ["#67b7dc", '#8067dc', '#dc67ce', '#dc8c67'],
        rangeStart: 0,
        rangeEnd: length);
    
    if (inverse) {
      for (var i = length; i > 0; i--) {
        var hexColour = rainbow[i];
        colors.add('#' + hexColour);
      }
    } else {
      for (var i = 0; i < length; i++) {
        var hexColour = rainbow[i];
        colors.add('#' + hexColour);
      }
    }

    return colors;
  }

  static List<String> generate(
    int length,
  ) =>
      List.generate(length, ((index) => FlatColor().generateHex2()));

  String get cssRgb => 'rgb($r,$g,$b)';

  // int floor(num numero) {
  //   return numero.floor();
  // }

  // int round(num numero) {
  //   return numero.round();
  // }

  String generateHex([double? deg]) {
    var random = Random();
    var PHI = 0.618033988749895;
    var s, v, hue;
    late double h;
    if (deg == null) {
      hue = ((random.nextDouble() * (360 - 0 + 1) + 0).floor()) / 360;
      h = (hue + (hue / PHI)) % 360;
    } else {
      h = deg;
      h /= 360;
    }

    v = (random.nextDouble() * (100 - 20 + 1) + 20).floor();
    s = (v - 10) / 100;
    v = v / 100;

    var r, g, b, i, f, p, q, t;
    i = (h * 6).floor();
    f = h * 6 - i;
    p = v * (1 - s);
    q = v * (1 - f * s);
    t = v * (1 - (1 - f) * s);
    switch (i % 6) {
      case 0:
        r = v;
        g = t;
        b = p;
        break;
      case 1:
        r = q;
        g = v;
        b = p;
        break;
      case 2:
        r = p;
        g = v;
        b = t;
        break;
      case 3:
        r = p;
        g = q;
        b = v;
        break;
      case 4:
        r = t;
        g = p;
        b = v;
        break;
      case 5:
        r = v;
        g = p;
        b = q;
        break;
    }
    r = (r * 255).round();
    g = (g * 255).round();
    b = (b * 255).round();

    var colo = "#" +
        (((1 << 24) + (r << 16) + (g << 8) + b) as int)
            .toRadixString(16)
            .substring(1);

    this.h = h;
    this.s = s;
    this.v = v;
    this.r = r;
    this.g = g;
    this.b = b;
    this.hex = colo;

    return colo;
  }
}
