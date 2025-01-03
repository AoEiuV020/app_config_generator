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

            return Field((f) => f
              ..name = key
              ..modifier = FieldModifier.final$
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

  /// 根据值类型返回对应的Literal
  Expression _getLiteralValue(dynamic value) {
    if (value is String) return literalString(value);
    if (value is int) return literalNum(value);
    if (value is double) return literalNum(value);
    if (value is bool) return literalBool(value);
    if (value is List) return literalList(value);
    if (value is Map) {
      // 使用record语法生成map
      final entries = value.entries
          .map((e) => '${e.key}: ${_getStringValue(e.value)}')
          .join(',\n    ');
      return CodeExpression(Code('(\n    $entries,\n  )'));
    }
    return literalNull;
  }

  /// 获取值的字符串表示
  String _getStringValue(dynamic value) {
    if (value is String) return "'$value'";
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    if (value is List) return value.toString();
    if (value is Map) {
      final entries = value.entries
          .map((e) => '${e.key}: ${_getStringValue(e.value)}')
          .join(', ');
      return '($entries)';
    }
    return 'null';
  }
}
