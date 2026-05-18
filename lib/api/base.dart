import 'package:dio/dio.dart';
import 'package:m3u_player/api/interceptors/api_interceptor.dart';

import 'errors.dart';

typedef Json = Map<String, dynamic>;
typedef ParamsType = Map<String, dynamic>;
typedef HeadersType = Map<String, String>;

class BaseClient {
  static final BaseClient _instance = BaseClient._();
  static const connectTimeoutSeconds = 15;
  static const receiveTimeoutSeconds = 60;

  late final Dio _baseClient;
  late final Dio _tmdbClient;

  BaseClient._() {
    _baseClient = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: receiveTimeoutSeconds),
      ),
    );
    _tmdbClient = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: receiveTimeoutSeconds),
      ),
    );
    _tmdbClient.interceptors.add(TMDbAuthInterceptor());
  }

  factory BaseClient() => _instance;

  Future<Response> get(
    String url, {
    ParamsType? params,
    HeadersType? headers,
    ResponseType? responseType,
    bool Function(int?)? validateStatus,
    bool tmdbClient = false,
  }) async {
    final response = await (tmdbClient ? _tmdbClient : _baseClient).get(
      url,
      queryParameters: params,
      options: Options(
        responseType: responseType,
        headers: headers,
        validateStatus: validateStatus,
      ),
    );
    response.check();
    return response;
  }
}

extension ResponseCheck on Response {
  bool isOk() => statusCode != null ? statusCode! ~/ 100 == 2 : false;

  void check() => (!isOk()) ? throw HttpStatusException(statusCode) : null;
}
