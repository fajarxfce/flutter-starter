import 'package:fluent_starter/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final flavor in AppFlavor.values) {
    test('${flavor.name} explicitly supports demo and API', () {
      expect(
        AppConfig.parse(flavor: flavor.name, backend: 'demo').isDemo,
        isTrue,
      );
      expect(
        AppConfig.parse(
          flavor: flavor.name,
          backend: 'api',
          baseUrl: 'https://api.example.com',
        ).isDemo,
        isFalse,
      );
    });
  }
  test('API mode rejects absent, insecure or ambiguous origins', () {
    for (final url in [
      '',
      'http://api.example.com',
      'https://a:b@example.com',
      'https://api.example.com/v1',
    ]) {
      expect(
        () => AppConfig.parse(flavor: 'prod', backend: 'api', baseUrl: url),
        throwsArgumentError,
      );
    }
    expect(
      () => AppConfig.parse(flavor: 'unknown', backend: 'demo'),
      throwsArgumentError,
    );
    expect(
      () => AppConfig.parse(flavor: 'dev', backend: 'unknown'),
      throwsArgumentError,
    );
  });
}
