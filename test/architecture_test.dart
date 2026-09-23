import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tool/check_architecture.dart';

void main() {
  late Directory root;
  setUp(() {
    root = Directory.systemTemp.createTempSync('architecture_');
    File(p.join(root.path, 'pubspec.yaml'))
        .writeAsStringSync('workspace: [common, domain]\n');
    for (final entry in {
      'common': 'core_common',
      'domain': 'auth_domain',
    }.entries) {
      Directory(p.join(root.path, entry.key, 'lib'))
          .createSync(recursive: true);
      File(p.join(root.path, entry.key, 'pubspec.yaml')).writeAsStringSync(
        'name: ${entry.value}\ndependencies: ${entry.key == 'domain' ? '{core_common: any}' : '{}'}\n',
      );
    }
  });
  tearDown(() => root.deleteSync(recursive: true));
  test('accepts allowed domain dependency', () {
    File(p.join(root.path, 'domain/lib/domain.dart'))
        .writeAsStringSync("import 'package:core_common/core_common.dart';");
    expect(checkArchitecture(root), isEmpty);
  });
  test('rejects framework and conditional platform imports', () {
    File(p.join(root.path, 'domain/lib/domain.dart')).writeAsStringSync(
      "import 'package:flutter/widgets.dart';\nimport 'stub.dart' if (dart.library.io) 'dart:io';",
    );
    expect(checkArchitecture(root), contains(contains('impure domain')));
    expect(checkArchitecture(root), contains(contains('platform dependency')));
  });
  test('rejects private exports and relative escapes', () {
    File(p.join(root.path, 'domain/lib/domain.dart')).writeAsStringSync(
      "export 'package:core_common/src/private.dart';\nexport '../../common/lib/common.dart';",
    );
    expect(checkArchitecture(root), contains(contains('private import')));
    expect(checkArchitecture(root), contains(contains('escapes library')));
  });
  test('rejects forbidden dependency and cycles', () {
    File(p.join(root.path, 'common/pubspec.yaml')).writeAsStringSync(
      'name: core_common\ndependencies: {auth_domain: any}\n',
    );
    expect(checkArchitecture(root), contains(contains('forbidden dependency')));
    expect(checkArchitecture(root), contains(contains('cycle')));
  });
  test('rejects implementations and imports in a package barrel', () {
    File(p.join(root.path, 'domain/lib/auth_domain.dart')).writeAsStringSync(
      "import 'package:core_common/core_common.dart';\nclass User {}",
    );
    expect(checkArchitecture(root), contains(contains('only exports')));
  });
  test('rejects unrelated public types in one implementation file', () {
    File(p.join(root.path, 'domain/lib/models.dart')).writeAsStringSync(
      'class User {}\nabstract interface class AuthRepository {}',
    );
    expect(checkArchitecture(root), contains(contains('split public types')));
  });
  test('accepts export barrels, private companions and generated types', () {
    File(p.join(root.path, 'domain/lib/auth_domain.dart'))
        .writeAsStringSync("export 'view.dart';");
    File(p.join(root.path, 'domain/lib/view.dart'))
        .writeAsStringSync('class View {}\nclass _ViewState {}');
    File(p.join(root.path, 'domain/lib/view.g.dart'))
        .writeAsStringSync('class GeneratedView {}\nclass GeneratedState {}');
    expect(checkArchitecture(root), isEmpty);
  });
}
