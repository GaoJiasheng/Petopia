import '../config/game_config.dart';
import 'game_state.dart';

/// Builds a support report from aggregate state only.
///
/// User-authored names, postcard copy, identifiers, timestamps from gameplay,
/// and device identifiers are deliberately excluded.
String buildDiagnosticReport({
  required GameSession session,
  required DateTime generatedAt,
  required String appVersion,
  required String platform,
  List<String> runtimeDiagnostics = const <String>[],
}) {
  final current = session.current;
  final unlockedAchievements = session.achievements.values
      .where((entry) => entry.unlockedAt != null)
      .length;
  final pendingJobs = session.jobs.where((job) => !job.consumed).length;
  final activeJourneys = session.journeys
      .where((journey) => journey.currentIdx < journey.stops.length)
      .length;

  return <String>[
    'Petopia diagnostic report',
    'generatedAtUtc=${generatedAt.toUtc().toIso8601String()}',
    'appVersion=$appVersion',
    'platform=$platform',
    'saveSchema=${session.settings.schemaVersion}',
    'portableSaveSchema=${GameConfig.currentSchemaVersion}',
    if (current == null)
      'currentPet=none'
    else
      'currentPet=${current.speciesId},stage=${current.stage.name},level=${current.level}',
    'petsTotal=${session.allPets.length}',
    'graduatedPets=${session.roaming.length}',
    'journeys=${session.journeys.length},active=$activeJourneys',
    'postcards=${session.postcards.length}',
    'visitorLogs=${session.visitorLog.length},active=${session.activeVisitor != null}',
    'revisitorActive=${session.revisitor != null}',
    'eventsPending=${session.pendingEvents.length}',
    'schedulerJobs=${session.jobs.length},pending=$pendingJobs',
    'achievements=${session.achievements.length},unlocked=$unlockedAchievements',
    'yardLuxury=${session.yard.luxuryStage}',
    'yardTheme=${session.yard.activeThemeId}',
    'onboardingComplete=${session.settings.onboardingComplete}',
    'notifications=${session.settings.notifications}',
    'music=${session.settings.music},effects=${session.settings.sound},haptics=${session.settings.haptics}',
    'renderQuality=${session.settings.renderQuality.name}',
    ...runtimeDiagnostics,
  ].join('\n');
}
