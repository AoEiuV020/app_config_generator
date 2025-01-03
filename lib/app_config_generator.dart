import 'package:build/build.dart';

import 'src/generator.dart';

/// 创建AppConfig生成器的工厂方法
Builder appConfig(BuilderOptions options) {
  return AppConfigGenerator(
    configFile: options.config['config_file'] as String? ?? 'app_config.yaml',
    outputFile: options.config['output_file'] as String? ??
        'lib/config/app_config.g.dart',
    overrideFile: options.config['override_file'] as String? ??
        'app_config_overrides.yaml',
    useRecordType: options.config['use_record_type'] as bool? ?? false,
    className: options.config['class_name'] as String? ?? 'AppConfig',
  );
}
