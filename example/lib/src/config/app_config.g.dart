// GENERATED CODE - DO NOT MODIFY BY HAND
// 基础配置文件: app_config.yaml
// 覆盖配置文件: app_config_overrides.yaml

final class AppConfig {
  static final appName = 'Example Override';

  static final version = '1.0.0';

  static final api = (baseUrl: 'https://api.example.com', timeout: 30);

  static final database = (name: 'example.db', version: 1);

  static final features = (darkMode: true, notifications: true);

  static final theme = (
    colors: (
      primary: '#2196F3',
      secondary: '#FF4081',
      background: '#FFFFFF',
      text: '#000000'
    ),
    typography: (
      fontFamily: 'Roboto',
      fontSize: (small: 12, medium: 16, large: 24, headline: 32)
    ),
    spacing: (small: 8, medium: 16, large: 24),
    components: (
      button: (
        borderRadius: 4,
        padding: (vertical: 12, horizontal: 24),
        variants: (
          filled: (background: '#2196F3', textColor: '#FFFFFF'),
          outlined: (borderColor: '#2196F3', textColor: '#2196F3'),
          text: (textColor: '#2196F3')
        )
      ),
      card: (borderRadius: 8, elevation: 2, padding: (all: 16))
    )
  );
}
