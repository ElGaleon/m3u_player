import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDbAuthInterceptor extends Interceptor {
  final bool logOnRequest;
  final bool logOnResponse;
  final bool logOnError;

  TMDbAuthInterceptor({
    this.logOnRequest = true,
    this.logOnResponse = false,
    this.logOnError = true,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = dotenv.get('TMDB_AUTH_TOKEN');
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
