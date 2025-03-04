<p align="center">
  <a href="https://sentry.io" target="_blank" align="center">
    <img src="https://sentry-brand.storage.googleapis.com/sentry-logo-black.png" width="280">
  </a>
  <br />
</p>

Sentry integration for `logging` package
===========

| package | build | pub | likes | popularity | pub points |
| ------- | ------- | ------- | ------- | ------- | ------- |
| sentry_logging | [![build](https://github.com/getsentry/sentry-dart/workflows/sentry-logging/badge.svg?branch=main)](https://github.com/getsentry/sentry-dart/actions?query=workflow%3Alogging) | [![pub package](https://img.shields.io/pub/v/sentry_logging.svg)](https://pub.dev/packages/sentry_logging) | [![likes](https://badges.bar/sentry_logging/likes)](https://pub.dev/packages/sentry_logging/score) | [![popularity](https://badges.bar/sentry_logging/popularity)](https://pub.dev/packages/sentry_logging/score) | [![pub points](https://badges.bar/sentry_logging/pub%20points)](https://pub.dev/packages/sentry_logging/score)

Integration for the [`logging`](https://pub.dev/packages/logging) package.

#### Usage

- Sign up for a Sentry.io account and get a DSN at https://sentry.io.

- Follow the installing instructions on [pub.dev](https://pub.dev/packages/sentry/install).

- Initialize the Sentry SDK using the DSN issued by Sentry.io and add the `LoggingIntegration`

```dart
import 'package:sentry/sentry.dart';
import 'package:sentry_logging/sentry_logging.dart';

Future<void> main() async {
  await Sentry.init(
    (options) {
      options.dsn = 'https://example@sentry.io/example';
      options.addIntegration(LoggingIntegration());
    },
    appRunner: initApp, // Init your App.
  );
}

void initApp() {
  // your app code
}
```

#### Resources

* [![Documentation](https://img.shields.io/badge/documentation-sentry.io-green.svg)](https://docs.sentry.io/platforms/dart/)
* [![Forum](https://img.shields.io/badge/forum-sentry-green.svg)](https://forum.sentry.io/c/sdks)
* [![Discord](https://img.shields.io/discord/621778831602221064)](https://discord.gg/Ww9hbqr)
* [![Stack Overflow](https://img.shields.io/badge/stack%20overflow-sentry-green.svg)](https://stackoverflow.com/questions/tagged/sentry)
* [![Twitter Follow](https://img.shields.io/twitter/follow/getsentry?label=getsentry&style=social)](https://twitter.com/intent/follow?screen_name=getsentry)
