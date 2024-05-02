enum DatatableFormat { date, dateTime, text, bool }

class DatatableStyle {
  String? backgroudColor; //#f44336;
  String? fontColor; //#fff;

  String? display; //: inline-block;
  String? padding; // 0.3125rem 0.375rem;
  String? fontSize; //75%;
  String? fontWeight; // 500;
  String? lineHeight; // 1;
  String? textAlign; //: center;
  String? whiteSpace; //: nowrap;
  String? verticalAlign; //: baseline;
  String? borderRadius; //: 0.125rem;
  String? border;

  DatatableStyle({
    this.backgroudColor,
    this.fontColor,
    this.display,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.lineHeight,
    this.textAlign,
    this.whiteSpace,
    this.verticalAlign,
    this.borderRadius,
    this.border,
  });

  DatatableStyle.badge() {
    fontColor = '#fff';
    backgroudColor = '#f44336';

    display = 'inline-block';
    padding = '0.3125rem 0.375rem';
    fontSize = '75%';
    fontWeight = '500';
    lineHeight = '1';
    textAlign = 'center';
    whiteSpace = 'nowrap';
    verticalAlign = 'baseline';
    borderRadius = '0.125rem';
  }

  String get styleCss {
    var css = StringBuffer();
    if (fontColor != null) {
      css.write('color: $fontColor;');
    }
    if (backgroudColor != null) {
      css.write('background-color: $backgroudColor;');
    }
    if (padding != null) {
      css.write('padding: $padding;');
    }
    if (fontSize != null) {
      css.write('font-size: $fontSize;');
    }
    if (textAlign != null) {
      css.write('text-align: $textAlign;');
    }
    if (whiteSpace != null) {
      css.write('white-space: $whiteSpace;');
    }
    if (verticalAlign != null) {
      css.write('vertical-align: $verticalAlign;');
    }
    if (borderRadius != null) {
      css.write('border-radius: $borderRadius;');
    }
    if (border != null) {
      css.write('border: $border;');
    }

    return css.toString();
  }
}
