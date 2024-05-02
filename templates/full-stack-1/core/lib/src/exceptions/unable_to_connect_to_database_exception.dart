//Unable to connect to database

/// Exception thrown when a socket operation fails.
class UnableToConnectToDatabaseException {
  /// Description of the error.
  final String message;

  final String? address;

  final String? osError;

  /// The port of the socket giving rise to the exception.
  ///
  /// This is either the source or destination address of a socket,
  /// or it can be `null` if no socket end-point was involved in the cause of
  /// the exception.
  final int? port;

  const UnableToConnectToDatabaseException(
      {this.message = 'Não foi possivel se conectar ao banco de dados',
      this.osError,
      this.address,
      this.port});

  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.write("UnableToConnectToDatabaseException");
    if (message.isNotEmpty) {
      sb.write(": $message");
      if (osError != null) {
        sb.write(" ($osError)");
      }
    } else if (osError != null) {
      sb.write(": $osError");
    }
    if (address != null) {
      sb.write(", address = ${address}");
    }
    if (port != null) {
      sb.write(", port = $port");
    }
    return sb.toString();
  }
}
