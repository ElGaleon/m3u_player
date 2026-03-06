import 'package:dio/dio.dart';

import 'errors.dart';

typedef Json = Map<String, dynamic>;
typedef ParamsType = Map<String, dynamic>;
typedef HeadersType = Map<String, String>;

class BaseClient {
  static final BaseClient _instance = BaseClient._();
  static const connectTimeoutSeconds = 15;
  static const receiveTimeoutSeconds = 60;

  late final Dio _omdbClient;

  BaseClient._() {
    _omdbClient = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: receiveTimeoutSeconds),
      ),
    );
  }

  factory BaseClient() => _instance;

  Future<Response> get(
    String url, {
    ParamsType? params,
    HeadersType? headers,
    ResponseType? responseType,
    bool Function(int?)? validateStatus,
  }) async {
    final response = await _omdbClient.get(
      url,
      queryParameters: params,
      options: Options(
        responseType: responseType,
        headers: headers,
        validateStatus: validateStatus,
      ),
    );
    response.check();
    return response.data!;
  }
}

extension ResponseCheck on Response {
  bool isOk() => statusCode != null ? statusCode! ~/ 100 == 2 : false;

  void check() => (!isOk()) ? throw HttpStatusException(statusCode) : null;
}
