import 'package:environment_manager/environment_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(
    () {
      EnvironmentManager().reset();

      EnvironmentManager().registerEnvironmentConfig(
        EnvironmentConfig()
          ..name = 'abc'
          ..displayName = '测试'
          ..addConfig(EnvironmentType.product, 'url', 'product')
          ..addConfig(EnvironmentType.test, 'url', 'test'),
      );

      EnvironmentManager().registerEnvironmentConfig(
        EnvironmentConfig()
          ..name = 'abc2'
          ..displayName = '测试2'
          ..addConfig(EnvironmentType.product, 'url', 'product---')
          ..addConfig(EnvironmentType.test, 'url', 'test---'),
      );

      EnvironmentManager().registerEnvironmentConfig(
        EnvironmentConfig()
          ..name = 'abc3'
          ..displayName = '测试3'
          ..addConfig(EnvironmentType.product, 'url', 'product==='),
      );
    },
  );

  test('default config', () {
    expect(EnvironmentManager().getConfig('abc', 'url'), 'product');
    expect(EnvironmentManager().getConfig('abc2', 'url'), 'product---');

    EnvironmentManager().setEnvironment(EnvironmentType.test);
    expect(EnvironmentManager().getConfig('abc', 'url'), 'test');
    expect(EnvironmentManager().getConfig('abc2', 'url'), 'test---');
  });

  test('default config2', () {
    expect(EnvironmentManager().getConfig('abc3', 'url'), 'product===');

    EnvironmentManager().setEnvironment(EnvironmentType.test);
    expect(EnvironmentManager().getConfig('abc3', 'url'), 'product===');
  });
}
