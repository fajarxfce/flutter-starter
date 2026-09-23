import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const allowed = <String, Set<String>>{
  'core_common': {},
  'core_data': {'core_common'},
  'core_network': {'core_common'},
  'core_design_system': {},
  'core_testing': {'core_common'},
  'auth_domain': {'core_common'},
  'auth_data': {'auth_domain', 'core_common', 'core_network'},
  'auth_presentation': {'auth_domain', 'core_common', 'core_design_system'},
  'home_presentation': {'core_design_system'},
  'fluent_starter': {
    'core_common',
    'core_data',
    'core_network',
    'core_design_system',
    'auth_domain',
    'auth_data',
    'auth_presentation',
    'home_presentation',
  },
};

List<String> checkArchitecture(Directory root) {
  final errors = <String>[];
  final spec = loadYaml(
    File(p.join(root.path, 'pubspec.yaml')).readAsStringSync(),
  ) as YamlMap;
  final packages = <String, ({String directory, YamlMap spec})>{};
  for (final entry in (spec['workspace'] as YamlList).cast<String>()) {
    final directory = p.normalize(p.absolute(root.path, entry));
    final data = loadYaml(
      File(p.join(directory, 'pubspec.yaml')).readAsStringSync(),
    ) as YamlMap;
    packages[data['name'] as String] = (directory: directory, spec: data);
  }
  final graph = <String, Set<String>>{};
  for (final entry in packages.entries) {
    final name = entry.key;
    final package = entry.value;
    final pure = name.endsWith('_domain') || name == 'core_common';
    final dependencies =
        (package.spec['dependencies'] as YamlMap?) ?? YamlMap();
    graph[name] = dependencies.keys
        .cast<String>()
        .where(packages.containsKey)
        .toSet();
    if (!allowed.containsKey(name)) {
      errors.add('$name: register an explicit dependency policy');
    }
    for (final dep in graph[name]!) {
      if (!(allowed[name]?.contains(dep) ?? false)) {
        errors.add('$name: forbidden dependency $dep');
      }
    }
    if (pure && dependencies.keys.any((key) => key != 'core_common')) {
      errors.add(
        '$name: domain/common may depend only on Dart SDK and core_common',
      );
    }
    final lib = Directory(p.join(package.directory, 'lib'));
    if (!lib.existsSync()) continue;
    for (final file
        in lib
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final unit = parseString(
        content: file.readAsStringSync(),
        throwIfDiagnostics: false,
      ).unit;
      final uris = <String>[];
      for (final directive in unit.directives) {
        if (directive is UriBasedDirective) {
          final uri = directive.uri.stringValue;
          if (uri != null) uris.add(uri);
        }
        if (directive is NamespaceDirective) {
          uris.addAll(
            directive.configurations
                .map((c) => c.uri.stringValue)
                .whereType<String>(),
          );
        }
      }
      for (final uri in uris) {
        final parsed = Uri.parse(uri);
        if (parsed.scheme == 'dart') {
          if (pure &&
              {'ui', 'io', 'html', 'js_interop'}.contains(parsed.path)) {
            errors.add('$name: platform dependency $uri');
          }
          continue;
        }
        if (parsed.scheme == 'package') {
          final segments = parsed.pathSegments;
          final target = segments.first;
          if (target != name && !dependencies.containsKey(target)) {
            errors.add('$name: undeclared production import $uri');
          }
          if (target != name && segments.skip(1).contains('src')) {
            errors.add('$name: private import $uri');
          }
          if (packages.containsKey(target) &&
              target != name &&
              !(allowed[name]?.contains(target) ?? false)) {
            errors.add('$name: forbidden import $uri');
          }
          if (pure && target != name && target != 'core_common') {
            errors.add('$name: impure domain import $uri');
          }
        } else {
          final resolved = p.normalize(p.join(p.dirname(file.path), uri));
          if (parsed.hasScheme || !p.isWithin(lib.path, resolved)) {
            errors.add('$name: import escapes library: $uri');
          }
        }
      }
      if (name != 'fluent_starter' &&
          uris.any(
            (u) =>
                u.startsWith('package:get_it/') ||
                u.startsWith('package:injectable/'),
          )) {
        errors.add('$name: service locator/DI belongs to app composition');
      }
    }
  }
  final visited = <String>{};
  final active = <String>{};
  void visit(String name) {
    if (active.contains(name)) {
      errors.add('Dependency cycle at $name');
      return;
    }
    if (!visited.add(name)) return;
    active.add(name);
    for (final dep in graph[name] ?? <String>{}) {
      visit(dep);
    }
    active.remove(name);
  }

  for (final name in graph.keys) {
    visit(name);
  }
  return errors;
}

void main() {
  final errors = checkArchitecture(Directory.current);
  if (errors.isNotEmpty) {
    stderr.writeln(errors.join('\n'));
    exitCode = 1;
  } else {
    stdout.writeln('Architecture boundaries passed.');
  }
}
