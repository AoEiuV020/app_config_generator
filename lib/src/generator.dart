import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:yaml/yaml.dart';

/// 配置生成器
class AppConfigGenerator implements Builder {
  final String configFile;
  final String outputFile;
  final String? overrideFile;

  AppConfigGenerator({
    this.configFile = 'app_config.yaml',
    this.outputFile = 'lib/config/app_config.g.dart',
    this.overrideFile = 'app_config_overrides.yaml',
  });

  @override
  Map<String, List<String>> get buildExtensions => {
        configFile: [outputFile]
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    // 读取基础配置文件
    final inputId = buildStep.inputId;
    final contents = await buildStep.readAsString(inputId);
    final yaml = loadYaml(contents) as Map;

    // 尝试读取override配置文件
    Map? overrideYaml;
    if (overrideFile != null) {
      final overrideId = AssetId(buildStep.inputId.package, overrideFile!);
      try {
        if (await buildStep.canRead(overrideId)) {
          final overrideContents = await buildStep.readAsString(overrideId);
          overrideYaml = loadYaml(overrideContents) as Map?;
        }
      } catch (e) {
        log.fine('No override config found or failed to read it: $e');
      }
    }

    // 合并配置
    final mergedYaml = {...yaml};
    if (overrideYaml != null) {
      mergedYaml.addAll(overrideYaml.cast<String, dynamic>());
    }

    // 生成代码
    final generated = generateConfig(mergedYaml);

    // 写入生成的代码
    final outputId = AssetId(
      buildStep.inputId.package,
      outputFile,
    );
    await buildStep.writeAsString(outputId, generated);
  }

  String generateConfig(Map yaml) {
    final cls = Class((c) {
      c
        ..name = 'AppConfig'
        ..modifier = ClassModifier.final$
        ..fields.addAll(
          yaml.entries.map((entry) {
            final key = entry.key as String;
            final value = entry.value;

            // 根据值的类型确定字段类型
            final type = _getTypeReference(value);

            // 转换字段名为驼峰命名
            final fieldName = _toCamelCase(key);

            return Field((f) => f
              ..name = fieldName
              ..modifier = FieldModifier.final$
              ..type = type
              ..static = true
              ..assignment = _getLiteralValue(value).code);
          }),
        );
    });

    final emitter = DartEmitter();
    final formatter = DartFormatter();

    return formatter.format('''
// GENERATED CODE - DO NOT MODIFY BY HAND
// 基础配置文件: $configFile
// 覆盖配置文件: ${overrideFile ?? 'None'}

${cls.accept(emitter)}
''');
  }

  /// 将下划线命名转换为驼峰命名
  String _toCamelCase(String input) {
    if (!input.contains('_')) return input;

    return input.split('_').indexed.map((item) {
      final word = item.$2;
      if (item.$1 == 0) return word;
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join('');
  }

  /// 根据值类型返回对应的Reference
  Reference _getTypeReference(dynamic value) {
    if (value is String) return refer('String');
    if (value is int) return refer('int');
    if (value is double) return refer('double');
    if (value is bool) return refer('bool');
    if (value is List) return refer('List<dynamic>');
    if (value is Map) return refer('Map<String, dynamic>');
    return refer('dynamic');
  }

  /// 根据值类型返回对应的Literal
  Expression _getLiteralValue(dynamic value) {
    if (value is String) return literalString(value);
    if (value is int) return literalNum(value);
    if (value is double) return literalNum(value);
    if (value is bool) return literalBool(value);
    if (value is List) return literalList(value);
    if (value is Map) return literalMap(value.cast<String, dynamic>());
    return literalNull;
  }
}
