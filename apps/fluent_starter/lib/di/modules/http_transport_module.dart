import 'package:auth_data/auth_data.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@module
abstract class HttpTransportModule {
  @lazySingleton
  NetworkConfig networkConfig(AppConfig config) => NetworkConfig(
    baseUrl: config.baseUrl,
    log: kDebugMode ? debugPrint : null,
  );

  @lazySingleton
  HttpClientAdapter httpClientAdapter(AppConfig config) =>
      config.isDemo ? DemoAdapter() : HttpClientAdapter();
}
