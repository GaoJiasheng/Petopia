import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/app_info.dart';

void main() {
  test('support email URI preserves recipient, subject, and diagnostics', () {
    final uri = AppUrls.supportEmailUri(
      subject: 'Hearth & Tails Support Request',
      body: 'Please describe what happened.\n\nappErrors=1',
    );

    expect(uri.scheme, 'mailto');
    expect(uri.path, AppUrls.supportEmail);
    expect(uri.queryParameters['subject'], 'Hearth & Tails Support Request');
    expect(uri.queryParameters['body'], contains('appErrors=1'));
  });
}
