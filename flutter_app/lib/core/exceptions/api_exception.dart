// Archivo: lib/core/exceptions/api_exception.dart

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    // Esto crea un mensaje detallado para el desarrollador.
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}