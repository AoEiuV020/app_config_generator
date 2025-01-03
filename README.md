# App Config Generator

一个用于自动生成 App 配置代码的 Dart 包。通过简单的 YAML 配置文件，自动生成类型安全的 Dart 配置类。

[![Main version](https://img.shields.io/pub/v/app_config_generator.svg)](https://pub.dev/packages/app_config_generator)
[![CI](https://github.com/AoEiuV020/app_config_generator/workflows/CI/badge.svg)](https://github.com/AoEiuV020/app_config_generator/actions)
[![Using melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

## 特性

- 从 YAML 文件自动生成 Dart 配置类
- 支持类型安全的配置访问
- 支持 Map 和 Record 两种访问方式
- 支持配置覆盖文件
- 支持自动代码生成和热重载

## 安装

将 `app_config_generator` 添加到你的 `pubspec.yaml` 的 dev_dependencies 中：

```yaml
dev_dependencies:
  app_config_generator: ^1.0.0
  build_runner: ^2.4.0
```

## 使用方法

### 1. 配置 build.yaml

在项目根目录创建或编辑 `build.yaml`：

```yaml
targets:
  $default:
    sources:
      include:
        - app_config.yaml
        - app_config_overrides.yaml
    builders:
      app_config_generator:app_config:
        options:
          output_file: lib/src/config/app_config.g.dart  # 可选，默认是 lib/config/app_config.g.dart
          use_record_type: false  # 可选，默认false使用Map类型，true使用Record类型
          class_name: AppConfig  # 可选，默认是 AppConfig
```

### 2. 创建配置文件

创建 `app_config.yaml` 文件：

```yaml
appName: My App
api:
  baseUrl: https://api.example.com
  timeout: 30
database:
  name: app.db
  version: 1
```

### 3. 生成配置代码

运行以下命令生成配置代码：

```bash
dart run build_runner build
```

或者在开发时使用 watch 命令：

```bash
dart run build_runner watch
```

### 4. 使用生成的配置

默认使用 Map 类型（`use_record_type: false`）：

```dart
import 'package:your_app/config/app_config.g.dart';

void main() {
  print(AppConfig.appName);  // String
  print(AppConfig.api['baseUrl']);  // String
  print(AppConfig.api['timeout']);  // int
}
```

使用 Record 类型（`use_record_type: true`）：

```dart
import 'package:your_app/config/app_config.g.dart';

void main() {
  print(AppConfig.appName);  // String
  print(AppConfig.api.baseUrl);  // String
  print(AppConfig.api.timeout);  // int
  
  // 支持解构
  final (baseUrl: url, timeout: t) = AppConfig.api;
  print(url);  // https://api.example.com
}
```

## 配置覆盖

你可以创建 `app_config_overrides.yaml` 来覆盖默认配置，这个文件通常被添加到 `.gitignore` 中：

```yaml
api:
  baseUrl: http://localhost:8080
```

## License

MIT 
