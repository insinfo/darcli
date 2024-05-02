class TokenExpiredException implements Exception {
  /// The cause of this exception.
  String? message;

  /// An HTTP status code this exception will throw.
  int statusCode;

  TokenExpiredException({
    this.message = 'Sessão expirada!',
    this.statusCode = 401,
  }) {}

  @override
  String toString() {
    return '$message : $statusCode';
  }
}
