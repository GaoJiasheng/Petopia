import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/config/game_config.dart';
import 'package:petopia/data/content/content_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    '30/90/180 day economy supports comfort, variety and completion',
    () async {
      final content = AssetContentRepository();
      await content.loadAll();

      final shopTotal = content.shopItems.fold<int>(
        0,
        (total, item) => total + item.price,
      );
      final themePrices =
          content.shopItems
              .where((item) => item.category == '院子主题')
              .map((item) => item.price)
              .toList()
            ..sort();
      final achievementTotal = content.achievements.fold<int>(
        0,
        (total, achievement) => total + achievement.reward.fluff,
      );

      int baselineIncome({required int days, required int graduations}) {
        return days * GameConfig.dailyFirstCareFluff +
            graduations *
                ((GameConfig.maxLevel - 1) * GameConfig.levelUpFluff +
                    GameConfig.gradBaseFluff);
      }

      final casualThirtyDays = baselineIncome(days: 30, graduations: 1);
      expect(
        casualThirtyDays,
        greaterThanOrEqualTo(themePrices.first),
        reason: 'a steady first month should afford a complete yard mood',
      );

      final engagedNinetyDays = baselineIncome(days: 90, graduations: 6);
      expect(
        engagedNinetyDays,
        greaterThanOrEqualTo(
          themePrices.reversed.take(2).reduce((a, b) => a + b),
        ),
        reason: 'three months of regular care should support visible variety',
      );

      final completionistHalfYear =
          baselineIncome(days: 180, graduations: content.species.length) +
          achievementTotal;
      expect(
        completionistHalfYear,
        greaterThanOrEqualTo(shopTotal),
        reason:
            'a completionist path must not leave the finite catalog impossible',
      );

      expect(shopTotal, 9100);
      expect(achievementTotal, 4850);
    },
  );
}
