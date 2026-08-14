import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/models/yard.dart';

void main() {
  test('replaceable yard points unlock to eight and then stay capped', () {
    expect(YardState(luxuryStage: 1).slotCapacity, 4);
    expect(YardState(luxuryStage: 2).slotCapacity, 5);
    expect(YardState(luxuryStage: 3).slotCapacity, 6);
    expect(YardState(luxuryStage: 4).slotCapacity, 8);
    expect(YardState(luxuryStage: 6).slotCapacity, 8);
  });

  test('pet-side utilities do not consume replaceable decor points', () {
    final yard = YardState(
      luxuryStage: 6,
      ownedDecorIds: ['water_bowl'],
      slots: [
        YardSlot(pos: 0, itemId: 'night_light'),
        YardSlot(pos: 1, itemId: 'food_bowl_full'),
        YardSlot(pos: 2, itemId: 'water_bowl'),
        YardSlot(pos: 11, itemId: 'fireplace'),
      ],
    );

    expect(yard.placedDecorIds, {'night_light', 'fireplace'});
    expect(
      yard.activeDecorIds,
      containsAll(['night_light', 'fireplace', 'water_bowl']),
    );
  });

  test('legacy overflow points map into free semantic points', () {
    final yard = YardState(
      luxuryStage: 6,
      slots: [
        YardSlot(pos: 0, itemId: 'night_light'),
        YardSlot(pos: 10, itemId: 'fireplace'),
        YardSlot(pos: 13, itemId: 'wind_chime'),
      ],
    );

    expect(
      yard.visibleDecorSlots
          .map((slot) => (slot.pos, slot.itemId))
          .toList(growable: false),
      [(0, 'night_light'), (1, 'fireplace'), (2, 'wind_chime')],
    );

    yard.normalizeDecorSlots();
    expect(
      yard.slots.map((slot) => (slot.pos, slot.itemId)).toList(growable: false),
      [(0, 'night_light'), (1, 'fireplace'), (2, 'wind_chime')],
    );
  });

  test('legacy water bowl becomes an owned fixed utility on normalization', () {
    final yard = YardState(
      luxuryStage: 4,
      slots: [YardSlot(pos: 3, itemId: 'water_bowl')],
    );

    yard.normalizeDecorSlots();

    expect(yard.slots, isEmpty);
    expect(yard.ownedDecorIds, contains('water_bowl'));
  });
}
