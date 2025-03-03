import 'package:dio/dio.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:test/test.dart';
import 'package:sentry/src/sentry_exception_factory.dart';

import 'mocks.dart';

void main() {
  late Fixture fixture;

  setUp(() {
    fixture = Fixture();
  });

  test('$DioEventProcessor only processes ${DioError}s', () {
    final sut = fixture.getSut();

    final event = SentryEvent(throwable: Exception());
    final processedEvent = sut.apply(event) as SentryEvent;

    expect(event, processedEvent);
  });

  test(
      '$DioEventProcessor does not change anything '
      'if stacktrace is null and a request is present', () {
    final sut = fixture.getSut();

    final event = SentryEvent(
      throwable: DioError(
        requestOptions: RequestOptions(path: '/foo/bar'),
      ),
      request: SentryRequest(),
    );
    final processedEvent = sut.apply(event) as SentryEvent;

    expect(event.throwable, processedEvent.throwable);
    expect(event.request, processedEvent.request);
  });

  group('request', () {
    test('$DioEventProcessor adds request', () {
      final sut = fixture.getSut(sendDefaultPii: true);

      final request = requestOptions.copyWith(
        method: 'POST',
        data: 'foobar',
      );
      final event = SentryEvent(
        throwable: DioError(
          requestOptions: request,
          response: Response<dynamic>(
            requestOptions: request,
          ),
        ),
      );
      final processedEvent = sut.apply(event) as SentryEvent;

      expect(processedEvent.throwable, event.throwable);
      expect(processedEvent.request?.method, 'POST');
      expect(processedEvent.request?.queryString, 'foo=bar');
      expect(processedEvent.request?.headers, <String, String>{
        'foo': 'bar',
        'content-type': 'application/json; charset=utf-8'
      });
      expect(processedEvent.request?.data, 'foobar');
    });

    test('$DioEventProcessor adds request without pii', () {
      final sut = fixture.getSut(sendDefaultPii: false);

      final event = SentryEvent(
        throwable: DioError(
          requestOptions: requestOptions,
          response: Response<dynamic>(
            requestOptions: requestOptions,
            data: 'foobar',
          ),
        ),
      );
      final processedEvent = sut.apply(event) as SentryEvent;

      expect(processedEvent.throwable, event.throwable);
      expect(processedEvent.request?.method, 'GET');
      expect(processedEvent.request?.queryString, 'foo=bar');
      expect(processedEvent.request?.data, null);
      expect(processedEvent.request?.headers, <String, String>{});
    });
  });

  group('response', () {
    test('$DioEventProcessor adds response', () {
      final sut = fixture.getSut(sendDefaultPii: true);

      final request = requestOptions.copyWith(
        method: 'POST',
      );
      final event = SentryEvent(
        throwable: DioError(
          requestOptions: request,
          response: Response<dynamic>(
            data: 'foobar',
            headers: Headers.fromMap(<String, List<String>>{
              'foo': ['bar']
            }),
            requestOptions: request,
            isRedirect: true,
            statusCode: 200,
            statusMessage: 'OK',
          ),
        ),
      );
      final processedEvent = sut.apply(event) as SentryEvent;

      expect(processedEvent.throwable, event.throwable);
      expect(processedEvent.contexts.response, isNotNull);
      expect(processedEvent.contexts.response?.body, 'foobar');
      expect(processedEvent.contexts.response?.redirected, true);
      expect(processedEvent.contexts.response?.status, 'OK');
      expect(processedEvent.contexts.response?.statusCode, 200);
      expect(
        processedEvent.contexts.response?.url,
        'https://example.org/foo/bar?foo=bar',
      );
      expect(processedEvent.contexts.response?.headers, <String, String>{
        'foo': 'bar',
      });
    });

    test('$DioEventProcessor adds response without PII', () {
      final sut = fixture.getSut(sendDefaultPii: false);

      final request = requestOptions.copyWith(
        method: 'POST',
      );
      final event = SentryEvent(
        throwable: DioError(
          requestOptions: request,
          response: Response<dynamic>(
            data: 'foobar',
            headers: Headers.fromMap(<String, List<String>>{
              'foo': ['bar']
            }),
            requestOptions: request,
            isRedirect: true,
            statusCode: 200,
            statusMessage: 'OK',
          ),
        ),
      );
      final processedEvent = sut.apply(event) as SentryEvent;

      expect(processedEvent.throwable, event.throwable);
      expect(processedEvent.contexts.response, isNotNull);
      expect(processedEvent.contexts.response?.body, isNull);
      expect(processedEvent.contexts.response?.redirected, true);
      expect(processedEvent.contexts.response?.status, 'OK');
      expect(processedEvent.contexts.response?.statusCode, 200);
      expect(
        processedEvent.contexts.response?.url,
        'https://example.org/foo/bar?foo=bar',
      );
      expect(processedEvent.contexts.response?.headers, <String, String>{});
    });
  });

  test('$DioEventProcessor adds chained stacktraces', () {
    final sut = fixture.getSut(sendDefaultPii: false);
    final exception = Exception('foo bar');
    final dioError = DioError(
      error: exception,
      requestOptions: requestOptions,
    )..stackTrace = StackTrace.current;

    final event = SentryEvent(
      throwable: dioError,
      exceptions: [fixture.exceptionFactory.getSentryException(dioError)],
    );

    final processedEvent = sut.apply(event) as SentryEvent;

    expect(processedEvent.exceptions?.length, 2);
    expect(processedEvent.exceptions?[0].value, exception.toString());
    expect(processedEvent.exceptions?[0].stackTrace, isNotNull);
    expect(
      processedEvent.exceptions?[1].value,
      (dioError..stackTrace = null).toString(),
    );
    expect(processedEvent.exceptions?[1].stackTrace, isNotNull);
  });
}

final requestOptions = RequestOptions(
  path: '/foo/bar',
  baseUrl: 'https://example.org',
  queryParameters: <String, dynamic>{'foo': 'bar'},
  headers: <String, dynamic>{
    'foo': 'bar',
  },
  method: 'GET',
);

class Fixture {
  final SentryOptions options = SentryOptions(dsn: fakeDsn);

  // ignore: invalid_use_of_internal_member
  SentryExceptionFactory get exceptionFactory => options.exceptionFactory;

  DioEventProcessor getSut({bool sendDefaultPii = false}) {
    return DioEventProcessor(
      options..sendDefaultPii = sendDefaultPii,
      MaxRequestBodySize.always,
      MaxResponseBodySize.always,
    );
  }
}
