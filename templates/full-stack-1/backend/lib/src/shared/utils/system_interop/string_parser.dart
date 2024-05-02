
class StringParser {
  final String _buffer;
  final String _separator;
  final bool _skipEmpty;

  int _startIndex;
  int _endIndex;

  StringParser(this._buffer, this._separator, {bool skipEmpty = false})
      : _skipEmpty = skipEmpty,
        _startIndex = -1,
        _endIndex = -1;

  bool moveNext() {
    while (true) {
      if (_endIndex >= _buffer.length) {
        _startIndex = _endIndex;
        return false;
      }

      final nextSeparator = _buffer.indexOf(_separator, _endIndex + 1);
      _startIndex = _endIndex + 1;
      _endIndex = nextSeparator >= 0 ? nextSeparator : _buffer.length;

      if (!_skipEmpty || _endIndex >= _startIndex + 1) {
        return true;
      }
    }
  }

  void moveNextOrFail() {
    if (!moveNext()) {
      throw StateError('No more components to parse.');
    }
  }

  String moveAndExtractNext() {
    moveNextOrFail();
    return _buffer.substring(_startIndex, _endIndex);
  }

  String moveAndExtractNextInOuterParens() {
    moveNextOrFail();

    if (_buffer[_startIndex] != '(') {
      throw FormatException('Expected opening parenthesis.');
    }

    final lastParen = _buffer.lastIndexOf(')');
    if (lastParen == -1 || lastParen < _startIndex) {
      throw FormatException('Missing or mismatched closing parenthesis.');
    }

    final result = _buffer.substring(_startIndex + 1, lastParen);
    _endIndex = lastParen + 1;
    return result;
  }

  String extractCurrent() {
    if (_startIndex == -1) {
      throw StateError('Invalid operation.');
    }
    return _buffer.substring(_startIndex, _endIndex);
  }

  int parseNextInt32() {
    moveNextOrFail();

    final bufferSlice = _buffer.substring(_startIndex, _endIndex);
    final result = int.tryParse(bufferSlice);

    if (result == null) {
      throw FormatException('Failed to parse as Int32.');
    }

    return result;
  }

  int parseNextInt64() {
    moveNextOrFail();

    final bufferSlice = _buffer.substring(_startIndex, _endIndex);
    final result = int.tryParse(bufferSlice);

    if (result == null) {
      throw FormatException('Failed to parse as Int64.');
    }

    return result;
  }

  int parseNextUInt32() {
    moveNextOrFail();

    final bufferSlice = _buffer.substring(_startIndex, _endIndex);
    final result = int.tryParse(bufferSlice);

    if (result == null) {
      throw FormatException('Failed to parse as UInt32.');
    }

    return result;
  }

  int parseNextUInt64() {
    moveNextOrFail();

    final bufferSlice = _buffer.substring(_startIndex, _endIndex);

    final result = int.tryParse(bufferSlice);

    if (result == null) {
      throw FormatException('Failed to parse as UInt64.');
    }

    return result;
  }

  BigInt parseNextBigInt() {
    moveNextOrFail();

    final bufferSlice = _buffer.substring(_startIndex, _endIndex);

    final result = BigInt.tryParse(bufferSlice);

    if (result == null) {
      throw FormatException('Failed to parse as UInt64.');
    }

    return result;
  }

  String parseNextChar() {
    moveNextOrFail();

    if (_endIndex - _startIndex != 1) {
      throw FormatException('Expected a single character.');
    }

    return _buffer[_startIndex];
  }

  dynamic parseRaw(
      dynamic Function(String buffer, int startIndex, int endIndex) selector) {
    moveNextOrFail();
    return selector(_buffer, _startIndex, _endIndex);
  }

  String extractCurrentToEnd() {
    if (_startIndex == -1) {
      throw StateError('Invalid operation.');
    }
    return _buffer.substring(_startIndex);
  }
}

