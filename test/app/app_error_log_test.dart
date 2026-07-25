import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/app_error_log.dart';

void main() {
  test('runtime diagnostics retain useful frames without error messages', () {
    const privateMessage = 'private nickname and /Users/example/secret.txt';
    AppErrorLog.instance.record(
      StateError(privateMessage),
      StackTrace.fromString(
        '#0 package:petopia/ui/yard_home_screen.dart 120:8\n'
        '#1 /Users/example/secret.dart 4:2',
      ),
      source: 'ui:yard-test',
    );

    final report = AppErrorLog.instance.diagnosticLines().join('\n');
    expect(report, contains('lastAppErrorType=StateError'));
    expect(report, contains('package:petopia/ui/yard_home_screen.dart'));
    expect(report, isNot(contains(privateMessage)));
    expect(report, isNot(contains('/Users/example')));
  });
}
