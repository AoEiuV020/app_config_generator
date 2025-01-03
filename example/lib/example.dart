import 'package:example/config/app_config.g.dart';

void exampleMain() {
  print('App Name: ${AppConfig.appName}');
  print('API Base URL: ${AppConfig.api['base_url']}');
  print('Database Name: ${AppConfig.database['name']}');
  print('Dark Mode Enabled: ${AppConfig.features['dark_mode']}');
}