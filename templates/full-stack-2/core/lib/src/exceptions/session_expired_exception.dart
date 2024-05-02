import 'dart:convert';

class SessionExpiredException implements Exception {
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

  SessionExpiredException(
      {this.message = 'Sessão expirada!',
      this.stackTrace,
      this.statusCode = 440,
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

  factory SessionExpiredException.fromMap(Map data) {
    return SessionExpiredException(
      statusCode: (data['status_code'] ?? data['statusCode'] ?? 500) as int,
      message: data['message']?.toString() ?? 'Internal Server Error',
      errors: data['errors'] is Iterable
          ? ((data['errors'] as Iterable).map((x) => x.toString()).toList())
          : <String>[],
    );
  }

  factory SessionExpiredException.fromJson(String str) =>
      SessionExpiredException.fromMap(jsonDecode(str) as Map);
}
