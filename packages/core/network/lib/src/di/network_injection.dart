import 'package:core_common/core_common.dart';
import 'package:core_network/src/config/network_config.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [NetworkConfig, CredentialStore, HttpClientAdapter],
  throwOnMissingDependencies: true,
)
void configureNetworkPackage() {}
