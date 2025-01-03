import 'package:example/src/config/app_config.g.dart';

void exampleMain() {
  print('App Name: ${AppConfig.appName}');
  print('API Base URL: ${AppConfig.api['baseUrl']}');
  print('Database Name: ${AppConfig.database['name']}');
  print('Dark Mode Enabled: ${AppConfig.features['darkMode']}');
}
