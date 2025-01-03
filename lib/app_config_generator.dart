import 'package:build/build.dart';

import 'src/generator.dart';

/// 创建AppConfig生成器的工厂方法
Builder configBuilder(BuilderOptions options) {
  return AppConfigGenerator(
    configFile: options.config['config_file'] as String? ?? 'app_config.yaml',
    outputFile: options.config['output_file'] as String? ??
        'lib/config/app_config.g.dart',
    overrideFile: options.config['override_file'] as String?,
  );
}
