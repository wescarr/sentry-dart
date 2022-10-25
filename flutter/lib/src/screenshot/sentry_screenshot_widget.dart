import 'package:flutter/material.dart';

/// Key which is used to identify the [RepaintBoundary]
final sentryWidgetGlobalKey = GlobalKey(debugLabel: 'sentry_widget');

/// You can add screenshots of [child] to crash reports by adding this widget.
/// Ideally you are adding it around your app widget like in the following
/// example.
/// ```dart
/// runApp(SentryScreenshotWidget(child: App()));
/// ```
///
/// Remarks:
/// - Depending on the place where it's used, you might have a transparent
///   background.
/// - Platform Views currently can't be captured.
/// - It only works on Flutters Canvas Kit Web renderer. For more information
///   see https://flutter.dev/docs/development/tools/web-renderers
/// - You can only have one [SentryScreenshotWidget] widget in your widget tree at all
///   times.
class SentryScreenshotWidget extends StatefulWidget {
  const SentryScreenshotWidget({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  _SentryScreenshotWidgetState createState() => _SentryScreenshotWidgetState();
}

class _SentryScreenshotWidgetState extends State<SentryScreenshotWidget> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: sentryWidgetGlobalKey,
      child: widget.child,
    );
  }
}
