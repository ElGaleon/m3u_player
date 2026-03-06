class HttpStatusException {
  final int? statusCode;

  const HttpStatusException(this.statusCode);

  @override
  String toString() => 'HttpStatusException{statusCode: $statusCode}';
}

class HttpResultException {
  final String? errorCode;
  final String? errorDescription;

  const HttpResultException(this.errorCode, this.errorDescription);

  @override
  String toString() =>
      'HttpResultException{errorCode: $errorCode, errorDescription: $errorDescription}';
}
