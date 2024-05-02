// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class RestError {
  String? message = '';
  String? exception = '';
  String? stackTrace = '';
  int? statusCode = -1;
  RestError({
    this.message,
    this.exception,
    this.stackTrace,
    this.statusCode,
  });

  RestError copyWith({
    String? message,
    String? exception,
    String? stackTrace,
    int? statusCode,
  }) {
    return RestError(
      message: message ?? this.message,
      exception: exception ?? this.exception,
      stackTrace: stackTrace ?? this.stackTrace,
      statusCode: statusCode ?? this.statusCode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'exception': exception,
      'stackTrace': stackTrace,
      'status_code': statusCode,
    };
  }

  factory RestError.fromMap(Map<String, dynamic> map) {
    return RestError(
      message: map['message'],
      exception: map['exception'],
      stackTrace: map['stackTrace'],
      statusCode: map['status_code'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RestError.fromJson(String source) =>
      RestError.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RestErro(message: $message, exception: $exception, stackTrace: $stackTrace, statusCode: $statusCode)';
  }

 
}
