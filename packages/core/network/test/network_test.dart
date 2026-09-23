import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  test('classifies timeout, authorization and server failures', () {
    final request = RequestOptions(path: '/me');
    expect(
      mapNetworkFailure(
        DioException(
          requestOptions: request,
          type: DioExceptionType.connectionTimeout,
        ),
      ).kind,
      FailureKind.timeout,
    );
    expect(
      mapNetworkFailure(
        DioException(
          requestOptions: request,
          response: Response<Object>(requestOptions: request, statusCode: 401),
        ),
      ).kind,
      FailureKind.unauthorized,
    );
    expect(
      mapNetworkFailure(
        DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response<Object>(requestOptions: request, statusCode: 503),
        ),
      ).kind,
      FailureKind.server,
    );
  });
}
