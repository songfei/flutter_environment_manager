library environment_manager;

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final log = Logger('EnvironmentManager');

enum EnvironmentType {
  product, // 正式环境
  gray, // 灰度环境
  test, // 测试环境
  develop, // 开发环境
  benchmark, // 压测环境
}

String describeEnvironment(EnvironmentType type) {
  try {
    return ['正式环境', '灰度环境', '测试环境', '开发环境', '压测环境'][type.index];
  } catch (e) {
    return '';
  }
}

class EnvironmentConfig {
  String name;
  String displayName;

  Map<EnvironmentType, Map<String, dynamic>> _config = {};

  void addConfig(EnvironmentType environmentType, String key, String value) {
    Map<String, dynamic> configMap = _config[environmentType];

    if (configMap == null) {
      configMap = {};
      _config[environmentType] = configMap;
    }

    configMap[key] = value;
  }

  String getConfig(EnvironmentType environmentType, String key) {
    Map<String, dynamic> configMap = _config[environmentType];
    if (configMap != null) {
      return configMap[key];
    }
    return null;
  }
}

class EnvironmentManager {
  /// Return singleton object
  factory EnvironmentManager() {
    return _instance;
  }

  EnvironmentManager._internal();

  static final EnvironmentManager _instance = EnvironmentManager._internal();

  Map<String, EnvironmentConfig> _configMap = {};
  Map<String, EnvironmentType> _environmentTypeMap = {};

  void registerEnvironmentConfig(EnvironmentConfig config) {
    if (_configMap[config.name] == null) {
      log.info('Register environment: ${config.name} ${config.displayName}');
      _configMap[config.name] = config;
      _environmentTypeMap[config.name] = EnvironmentType.product;
    } else {
      log.warning('Register environment duplicate name');
    }
  }

  Future<void> loadEnvironmentConfig() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool('app_environment_restart', true);
    for (final name in _configMap.keys) {
      _environmentTypeMap[name] = EnvironmentType.values[preferences.getInt('app_environment_$name') ?? 0];
    }
  }

  Future<void> saveEnvironmentConfig() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    for (final name in _environmentTypeMap.keys) {
      await preferences.setInt('app_environment_$name', _environmentTypeMap[name].index);
    }
    await preferences.setBool('app_environment_restart', false);
  }

  void setEnvironment(EnvironmentType type, [String name]) {
    if (name != null && name.isNotEmpty) {
      if (_environmentTypeMap[name] != null) {
        _environmentTypeMap[name] = type;
      }
    } else {
      for (final name in _configMap.keys) {
        _environmentTypeMap[name] = type;
      }
    }
  }

  String _getConfig(EnvironmentType environmentType, String name, String key) {
    EnvironmentConfig config = _configMap[name];
    if (config != null) {
      return config.getConfig(environmentType, key);
    }
    return null;
  }

  String getConfig(String name, String key) {
    List<EnvironmentType> environmentOrder = [
      EnvironmentType.product,
      EnvironmentType.gray,
      EnvironmentType.test,
      EnvironmentType.develop,
      EnvironmentType.benchmark,
    ];

    EnvironmentType environmentType = _environmentTypeMap[name];
    if (environmentType != null) {
      int environmentIndex = environmentOrder.indexOf(environmentType);

      String result;
      while (result == null && environmentIndex >= 0) {
        result = _getConfig(environmentOrder[environmentIndex], name, key);
        environmentIndex -= 1;
      }

      return result;
    }

    return null;
  }

  void reset() {
    _configMap = {};
    _environmentTypeMap = {};
  }
}
