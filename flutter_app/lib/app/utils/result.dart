// lib/utils/result.dart
sealed class Result<T> {
  const Result();

  // Pattern-matching principal
  R when<R>({
    required R Function(T data) ok,
    required R Function(String message) err,
  });

  // Constructores estáticos
  static Result<T> ok<T>(T data) => _Ok(data);
  static Result<T> err<T>(String message) => _Err(message);

  // 👇 Helpers convenientes (no obligatorios, pero muy útiles)
  bool get isOk => this is _Ok<T>;
  bool get isErr => this is _Err<T>;

  T? get okOrNull => this is _Ok<T> ? (this as _Ok<T>).data : null;
  String? get errOrNull => this is _Err<T> ? (this as _Err<T>).message : null;

  /// Permite encadenar lógica sin usar `when` explícitamente.
  /// Ejemplo: `result.map((v) => v.toString())`
  Result<R> map<R>(R Function(T data) transform) {
    return when(
      ok: (data) => Result.ok(transform(data)),
      err: (msg) => Result.err(msg),
    );
  }
}

class _Ok<T> extends Result<T> {
  final T data;
  const _Ok(this.data);

  @override
  R when<R>({
    required R Function(T data) ok,
    required R Function(String message) err,
  }) => ok(data);
}

class _Err<T> extends Result<T> {
  final String message;
  const _Err(this.message);

  @override
  R when<R>({
    required R Function(T data) ok,
    required R Function(String message) err,
  }) => err(message);
}
