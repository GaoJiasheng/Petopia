import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/home_moment_queue.dart';

HomeMomentKind? _next({
  bool notification = false,
  bool postcard = false,
  bool visitor = false,
  bool revisitor = false,
  bool offline = false,
  bool recovery = false,
  bool special = false,
  bool daily = false,
  bool achievement = false,
  bool allowSocialArrivals = true,
  bool allowAutomaticMoment = true,
}) {
  return HomeMomentPolicy.next(
    hasNotification: notification,
    hasPostcard: postcard,
    hasVisitor: visitor,
    hasRevisitor: revisitor,
    hasOfflineWelcome: offline,
    hasSaveRecovery: recovery,
    hasSpecialEvent: special,
    hasDailyEvent: daily,
    hasAchievement: achievement,
    allowSocialArrivals: allowSocialArrivals,
    allowAutomaticMoment: allowAutomaticMoment,
  );
}

void main() {
  test('yard moments use one deterministic presentation priority', () {
    expect(
      _next(
        notification: true,
        postcard: true,
        visitor: true,
        revisitor: true,
        offline: true,
        recovery: true,
        special: true,
        daily: true,
        achievement: true,
      ),
      HomeMomentKind.notification,
    );
    expect(
      _next(
        postcard: true,
        visitor: true,
        revisitor: true,
        offline: true,
        recovery: true,
        special: true,
        daily: true,
        achievement: true,
      ),
      HomeMomentKind.postcard,
    );
    expect(
      _next(
        visitor: true,
        revisitor: true,
        offline: true,
        recovery: true,
        special: true,
        daily: true,
        achievement: true,
      ),
      HomeMomentKind.visitor,
    );
    expect(
      _next(
        revisitor: true,
        offline: true,
        recovery: true,
        special: true,
        daily: true,
        achievement: true,
      ),
      HomeMomentKind.revisitor,
    );
    expect(
      _next(offline: true, special: true, daily: true, achievement: true),
      HomeMomentKind.offlineWelcome,
    );
    expect(
      _next(recovery: true, special: true, daily: true, achievement: true),
      HomeMomentKind.saveRecovery,
    );
    expect(
      _next(special: true, daily: true, achievement: true),
      HomeMomentKind.specialEvent,
    );
    expect(_next(daily: true, achievement: true), HomeMomentKind.dailyEvent);
    expect(_next(achievement: true), HomeMomentKind.achievement);
    expect(_next(), isNull);
  });

  test('first-care quiet period suppresses social arrival popups', () {
    expect(
      _next(visitor: true, revisitor: true, allowSocialArrivals: false),
      isNull,
    );
    expect(
      _next(postcard: true, visitor: true, allowSocialArrivals: false),
      HomeMomentKind.postcard,
    );
  });

  test('one automatic moment is allowed per activation', () {
    expect(
      _next(postcard: true, visitor: true, allowAutomaticMoment: false),
      isNull,
    );
    expect(
      _next(notification: true, postcard: true, allowAutomaticMoment: false),
      HomeMomentKind.notification,
    );
  });
}
