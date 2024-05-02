import 'dart:convert';

class InvalidPasswordException implements Exception {
  /// A list of errors that occurred when this exception was thrown.
  final List<String> errors = [];

  /// The error throw by exception.
  dynamic error;

  /// The cause of this exception.
  String? message;

  /// The [StackTrace] associated with this error.
  StackTrace? stackTrace;

  /// An HTTP status code this exception will throw.
  int statusCode;

  InvalidPasswordException(
      {this.message = 'Senha invalida',
      this.stackTrace,
      this.statusCode = 400,
      this.error,
      List<String> errors = const []}) {
    this.errors.addAll(errors);
  }

  // String toString() {
  //   Object? message = this.message;
  //   if (message == null) return "Exception";
  //   return "Exception: $message";
  // }

  Map toJson() {
    return {
      'is_error': true,
      'status_code': statusCode,
      'message': message,
      'errors': errors
    };
  }

  Map toMap() => toJson();

  @override
  String toString() {
    return '$message : $statusCode';
  }

  factory InvalidPasswordException.fromMap(Map data) {
    return InvalidPasswordException(
      statusCode: (data['status_code'] ?? data['statusCode'] ?? 500) as int,
      message: data['message']?.toString() ?? 'Internal Server Error',
      errors: data['errors'] is Iterable
          ? ((data['errors'] as Iterable).map((x) => x.toString()).toList())
          : <String>[],
    );
  }

  factory InvalidPasswordException.fromJson(String str) =>
      InvalidPasswordException.fromMap(jsonDecode(str) as Map);
}
