import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter/src/integrations/integrations.dart';
import 'package:sentry_flutter/src/version.dart';
import 'mocks.dart';
import 'mocks.mocks.dart';
import 'sentry_flutter_util.dart';

/// These are the integrations which should be added on every platform.
/// They don't depend on the underlying platform.
final platformAgnosticIntegrations = [
  WidgetsFlutterBindingIntegration,
  OnErrorIntegration,
  FlutterErrorIntegration,
  LoadReleaseIntegration,
  DebugPrintIntegration,
];

// These should only be added to Android
final androidIntegrations = [
  LoadImageListIntegration,
];

// These should be added to iOS and macOS
final iOsAndMacOsIntegrations = [
  LoadImageListIntegration,
  LoadContextsIntegration,
];

// These should be added to every platform which has a native integration.
final nativeIntegrations = [
  NativeSdkIntegration,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Test platform integrations', () {
    setUp(() async {
      await Sentry.close();
    });

    test('Android', () async {
      List<Integration> integrations = [];
      Transport transport = MockTransport();

      await SentryFlutter.init(
        (options) async {
          options.dsn = fakeDsn;
          integrations = options.integrations;
          transport = options.transport;
        },
        appRunner: appRunner,
        packageLoader: loadTestPackage,
        platformChecker: getPlatformChecker(platform: MockPlatform.android()),
      );

      testTransport(
        transport: transport,
        hasFileSystemTransport: true,
      );

      testConfiguration(
          integrations: integrations,
          shouldHaveIntegrations: [
            ...androidIntegrations,
            ...nativeIntegrations,
            ...platformAgnosticIntegrations,
          ],
          shouldNotHaveIntegrations: iOsAndMacOsIntegrations);

      integrations
          .indexWhere((element) => element is WidgetsFlutterBindingIntegration);

      testBefore(
          integrations: integrations,
          beforeIntegration: WidgetsFlutterBindingIntegration,
          afterIntegration: OnErrorIntegration);

      await Sentry.close();
    }, testOn: 'vm');

    test('iOS', () async {
      List<Integration> integrations = [];
      Transport transport = MockTransport();

      await SentryFlutter.init(
        (options) async {
          options.dsn = fakeDsn;
          integrations = options.integrations;
          transport = options.transport;
        },
        appRunner: appRunner,
        packageLoader: loadTestPackage,
        platformChecker: getPlatformChecker(platform: MockPlatform.iOs()),
      );

      testTransport(
        transport: transport,
        hasFileSystemTransport: true,
      );

      testConfiguration(
        integrations: integrations,
        shouldHaveIntegrations: [
          ...iOsAndMacOsIntegrations,
          ...nativeIntegrations,
          ...platformAgnosticIntegrations,
        ],
        shouldNotHaveIntegrations: androidIntegrations,
      );

      testBefore(
          integrations: integrations,
          beforeIntegration: WidgetsFlutterBindingIntegration,
          afterIntegration: OnErrorIntegration);

      await Sentry.close();
    }, testOn: 'vm');

    test('macOS', () async {
      List<Integration> integrations = [];
      Transport transport = MockTransport();

      await SentryFlutter.init(
        (options) async {
          options.dsn = fakeDsn;
          integrations = options.integrations;
          transport = options.transport;
        },
        appRunner: appRunner,
        packageLoader: loadTestPackage,
        platformChecker: getPlatformChecker(platform: MockPlatform.macOs()),
      );

      testTransport(
        transport: transport,
        hasFileSystemTransport: true,
      );

      testConfiguration(
        integrations: integrations,
        shouldHaveIntegrations: [
          ...iOsAndMacOsIntegrations,
          ...nativeIntegrations,
          ...platformAgnosticIntegrations,
        ],
        shouldNotHaveIntegrations: androidIntegrations,
      );

      testBefore(
          integrations: integrations,
          beforeIntegration: WidgetsFlutterBindingIntegration,
          afterIntegration: OnErrorIntegration);

      await Sentry.close();
    }, testOn: 'vm');

    test('Windows', () async {
      List<Integration> integrations = [];
      Transport transport = MockTransport();

      await SentryFlutter.init(
        (options) async {
          options.dsn = fakeDsn;
          integrations = options.integrations;
          transport = options.transport;
        },
        appRunner: appRunner,
        packageLoader: loadTestPackage,
        platformChecker: getPlatformChecker(platform: MockPlatform.windows()),
      );

      testTransport(
        transport: transport,
        hasFileSystemTransport: false,
      );

      testConfiguration(
        integrations: integrations,
        shouldHaveIntegrations: platformAgnosticIntegrations,
        shouldNotHaveIntegrations: [
          ...androidIntegrations,
          ...iOsAndMacOsIntegrations,
          ...nativeIntegrations,
        ],
      );

      testBefore(
          integrations: integrations,
          beforeIntegration: WidgetsFlutterBindingIntegration,
          afterIntegration: OnErrorIntegration);

      await Sentry.close();
    }, testOn: 'vm');

    test('Linux', () async {
      List<Integration> integrations = [];
      Transport transport = MockTransport();

      await SentryFlutter.init(
        (options) async {
          options.dsn = fakeDsn;
          integrations = options.integrations;
          transport = options.transport;
        },
        appRunner: appRunner,
        packageLoader: loadTestPackage,
        platformChecker: getPlatformChecker(platform: MockPlatform.linux()),
      );

      testTransport(
        transport: transport,
        hasFileSystemTransport: false,
      );

      testConfiguration(
        integrations: integrations,
        shouldHaveIntegrations: platformAgnosticIntegrations,
        shouldNotHaveIntegrations: [
          ...androidIntegrations,
          ...iOsAndMacOsIntegrations,
          ...nativeIntegrations,
        ],
      );

      testBefore(
          integrations: integrations,
          beforeIntegration: WidgetsFlutterBindingIntegration,
          afterIntegration: OnErrorIntegration);

      await Sentry.close();
    }, testOn: 'vm');

    test('Web', () async {
      List<Integration> integrations = [];
      Transport transport = MockTransport();

      await SentryFlutter.init(
        (options) async {
          options.dsn = fakeDsn;
          integrations = options.integrations;
          transport = options.transport;
        },
        appRunner: appRunner,
        packageLoader: loadTestPackage,
        platformChecker: getPlatformChecker(
          isWeb: true,
          platform: MockPlatform.linux(),
        ),
      );

      testTransport(
        transport: transport,
        hasFileSystemTransport: false,
      );

      testConfiguration(
        integrations: integrations,
        shouldHaveIntegrations: platformAgnosticIntegrations,
        shouldNotHaveIntegrations: [
          ...androidIntegrations,
          ...iOsAndMacOsIntegrations,
          ...nativeIntegrations,
        ],
      );

      testBefore(
          integrations: integrations,
          beforeIntegration: WidgetsFlutterBindingIntegration,
          afterIntegration: OnErrorIntegration);

      await Sentry.close();
    });

    test('Web && (iOS || macOS) ', () async {
      List<Integration> integrations = [];
      Transport transport = MockTransport();

      // Tests that iOS || macOS integrations aren't added on a browser which
      // runs on iOS or macOS
      await SentryFlutter.init(
        (options) async {
          options.dsn = fakeDsn;
          integrations = options.integrations;
          transport = options.transport;
        },
        appRunner: appRunner,
        packageLoader: loadTestPackage,
        platformChecker: getPlatformChecker(
          isWeb: true,
          platform: MockPlatform.iOs(),
        ),
      );

      testTransport(
        transport: transport,
        hasFileSystemTransport: false,
      );

      testConfiguration(
        integrations: integrations,
        shouldHaveIntegrations: platformAgnosticIntegrations,
        shouldNotHaveIntegrations: [
          ...androidIntegrations,
          ...iOsAndMacOsIntegrations,
          ...nativeIntegrations,
        ],
      );

      testBefore(
          integrations: integrations,
          beforeIntegration: WidgetsFlutterBindingIntegration,
          afterIntegration: OnErrorIntegration);

      await Sentry.close();
    });

    test('Web && (macOS)', () async {
      List<Integration> integrations = [];
      Transport transport = MockTransport();

      // Tests that iOS || macOS integrations aren't added on a browswer which
      // runs on iOS or macOS
      await SentryFlutter.init(
        (options) async {
          options.dsn = fakeDsn;
          integrations = options.integrations;
          transport = options.transport;
        },
        appRunner: appRunner,
        packageLoader: loadTestPackage,
        platformChecker: getPlatformChecker(
          isWeb: true,
          platform: MockPlatform.macOs(),
        ),
      );

      testTransport(
        transport: transport,
        hasFileSystemTransport: false,
      );

      testConfiguration(
        integrations: integrations,
        shouldHaveIntegrations: platformAgnosticIntegrations,
        shouldNotHaveIntegrations: [
          ...androidIntegrations,
          ...iOsAndMacOsIntegrations,
          ...nativeIntegrations,
        ],
      );

      testBefore(
          integrations: integrations,
          beforeIntegration: WidgetsFlutterBindingIntegration,
          afterIntegration: OnErrorIntegration);

      await Sentry.close();
    });

    test('Web && Android', () async {
      List<Integration> integrations = [];
      Transport transport = MockTransport();

      // Tests that Android integrations aren't added on an Android browswer
      await SentryFlutter.init(
        (options) async {
          options.dsn = fakeDsn;
          integrations = options.integrations;
          transport = options.transport;
        },
        appRunner: appRunner,
        packageLoader: loadTestPackage,
        platformChecker: getPlatformChecker(
          isWeb: true,
          platform: MockPlatform.android(),
        ),
      );

      testTransport(
        transport: transport,
        hasFileSystemTransport: false,
      );

      testConfiguration(
        integrations: integrations,
        shouldHaveIntegrations: platformAgnosticIntegrations,
        shouldNotHaveIntegrations: [
          ...androidIntegrations,
          ...iOsAndMacOsIntegrations,
          ...nativeIntegrations,
        ],
      );

      testBefore(
          integrations: integrations,
          beforeIntegration: WidgetsFlutterBindingIntegration,
          afterIntegration: OnErrorIntegration);

      await Sentry.close();
    });
  });

  group('initial values', () {
    setUp(() async {
      await Sentry.close();
    });

    test('test that initial values are set correctly', () async {
      await SentryFlutter.init(
        (options) {
          options.dsn = fakeDsn;

          expect(false, options.debug);
          expect('debug', options.environment);
          expect(sdkName, options.sdk.name);
          expect(sdkVersion, options.sdk.version);
          expect('pub:sentry_flutter', options.sdk.packages.last.name);
          expect(sdkVersion, options.sdk.packages.last.version);
        },
        appRunner: appRunner,
        packageLoader: loadTestPackage,
        platformChecker: getPlatformChecker(
          platform: MockPlatform.android(),
          isWeb: true,
        ),
      );

      await Sentry.close();
    });
  });
}

void appRunner() {}

Future<PackageInfo> loadTestPackage() async {
  return PackageInfo(
    appName: 'appName',
    packageName: 'packageName',
    version: 'version',
    buildNumber: 'buildNumber',
    buildSignature: '',
  );
}

PlatformChecker getPlatformChecker({
  required MockPlatform platform,
  bool isWeb = false,
}) {
  final platformChecker = PlatformChecker(
    isWeb: isWeb,
    platform: platform,
  );
  return platformChecker;
}
