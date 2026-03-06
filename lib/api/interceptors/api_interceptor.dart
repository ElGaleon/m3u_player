import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  final bool logOnRequest;
  final bool logOnResponse;
  final bool logOnError;

  ApiInterceptor({
    this.logOnRequest = true,
    this.logOnResponse = false,
    this.logOnError = true,
  });

  @override
  void onRequest(RequestOptions, RequestInterceptorHandler handler) {}
}
