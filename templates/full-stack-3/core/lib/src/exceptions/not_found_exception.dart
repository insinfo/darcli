import 'dart:convert';

class NotFoundException implements Exception {
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

  NotFoundException(
      {this.message = 'Não encontrado',
      this.stackTrace,
      this.statusCode = 404,
      this.error,
      List<String> errors = const []}) {
    this.errors.addAll(errors);
  }

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

  factory NotFoundException.fromMap(Map data) {
    return NotFoundException(
      statusCode: (data['status_code'] ?? data['statusCode'] ?? 500) as int,
      message: data['message']?.toString() ?? 'Internal Server Error',
      errors: data['errors'] is Iterable
          ? ((data['errors'] as Iterable).map((x) => x.toString()).toList())
          : <String>[],
    );
  }

  factory NotFoundException.fromJson(String str) =>
      NotFoundException.fromMap(jsonDecode(str) as Map);
}
