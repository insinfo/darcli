import 'dart:convert';

class UnauthorizedException implements Exception {
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

  UnauthorizedException(
      {this.message = 'Acesso não permitido, verifique se você esta logado!',
      this.stackTrace,
      this.statusCode = 403,
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
    return '$message erro: $statusCode';
  }

  factory UnauthorizedException.fromMap(Map data) {
    return UnauthorizedException(
      statusCode: (data['status_code'] ?? data['statusCode'] ?? 500) as int,
      message: data['message']?.toString() ?? 'Internal Server Error',
      errors: data['errors'] is Iterable
          ? ((data['errors'] as Iterable).map((x) => x.toString()).toList())
          : <String>[],
    );
  }

  factory UnauthorizedException.fromJson(String str) =>
      UnauthorizedException.fromMap(jsonDecode(str) as Map);
}
