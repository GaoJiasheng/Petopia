/// Player-facing moments that can compete for presentation on the yard.
enum HomeMomentKind {
  notification,
  postcard,
  visitor,
  revisitor,
  offlineWelcome,
  saveRecovery,
  specialEvent,
  dailyEvent,
  achievement,
}

/// Stable priority policy for serialized yard presentation.
abstract final class HomeMomentPolicy {
  static HomeMomentKind? next({
    required bool hasNotification,
    required bool hasPostcard,
    required bool hasVisitor,
    required bool hasRevisitor,
    required bool hasOfflineWelcome,
    required bool hasSaveRecovery,
    required bool hasSpecialEvent,
    required bool hasDailyEvent,
    required bool hasAchievement,
    bool allowSocialArrivals = true,
    bool allowAutomaticMoment = true,
  }) {
    if (hasNotification) return HomeMomentKind.notification;
    if (!allowAutomaticMoment) return null;
    if (hasPostcard) return HomeMomentKind.postcard;
    if (allowSocialArrivals && hasVisitor) return HomeMomentKind.visitor;
    if (allowSocialArrivals && hasRevisitor) return HomeMomentKind.revisitor;
    if (hasOfflineWelcome) return HomeMomentKind.offlineWelcome;
    if (hasSaveRecovery) return HomeMomentKind.saveRecovery;
    if (hasSpecialEvent) return HomeMomentKind.specialEvent;
    if (hasDailyEvent) return HomeMomentKind.dailyEvent;
    if (hasAchievement) return HomeMomentKind.achievement;
    return null;
  }
}
