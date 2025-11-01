// lib/utils/result.dart
sealed class Result<T> {
  const Result();
  R when<R>({required R Function(T) ok, required R Function(String) err});
  static Result<T> ok<T>(T data) => _Ok(data);
  static Result<T> err<T>(String message) => _Err(message);
}

class _Ok<T> extends Result<T> {
  final T data;
  const _Ok(this.data);
  @override
  R when<R>({required R Function(T) ok, required R Function(String) err}) =>
      ok(data);
}

class _Err<T> extends Result<T> {
  final String message;
  const _Err(this.message);
  @override
  R when<R>({required R Function(T) ok, required R Function(String) err}) =>
      err(message);
}
