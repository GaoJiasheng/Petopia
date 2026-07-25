import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/diagnostic_report.dart';
import 'package:petopia/app/game_state.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/domain/models/pet.dart';

void main() {
  test('diagnostic report is useful without leaking authored content', () {
    final session = GameSession(
      current: Pet(
        id: 'private-pet-id',
        speciesId: 'pet_rabbit',
        variantId: 'pet_rabbit_v2',
        name: '不能出现在报告里的昵称',
        bornAt: DateTime.utc(2026, 7, 1),
        lastOnlineAt: DateTime.utc(2026, 7, 24),
        offlineDayKey: '2026-07-24',
        personality: const <String>['p_gentle', 'p_curious'],
        state: PetState.raising,
        exp: 210,
        level: 5,
        stage: PetStage.b,
      ),
    );
    session.postcards.add(
      Postcard(
        id: 'private-postcard-id',
        journeyId: 'private-journey-id',
        petId: 'private-pet-id',
        locationId: 'loc_lighthouse_bay',
        encounterId: null,
        incidentId: null,
        bodyText: '不能出现在报告里的明信片正文',
        photoAssetId: 'pc_bg_lighthouse_bay',
        stampId: 'pc_stamp_lighthouse_bay',
        sentAt: DateTime.utc(2026, 7, 20),
        season: Season.summer,
        timeOfDay: TimeOfDayOfDay.morning,
        weather: Weather.clear,
        seq: 0,
      ),
    );

    final report = buildDiagnosticReport(
      session: session,
      generatedAt: DateTime.utc(2026, 7, 24, 9, 30),
      appVersion: '1.0.0 (15)',
      platform: 'ios',
    );

    expect(report, contains('appVersion=1.0.0 (15)'));
    expect(report, contains('currentPet=pet_rabbit,stage=b,level=5'));
    expect(report, contains('postcards=1'));
    expect(report, contains('renderQuality=auto'));
    expect(report, isNot(contains('不能出现在报告里的昵称')));
    expect(report, isNot(contains('不能出现在报告里的明信片正文')));
    expect(report, isNot(contains('private-pet-id')));
    expect(report, isNot(contains('private-postcard-id')));
  });
}
