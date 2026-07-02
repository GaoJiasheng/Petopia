import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'isar_documents.dart';

abstract final class PetopiaIsar {
  static const String defaultName = 'petopia';

  static final List<CollectionSchema<dynamic>> schemas =
      <CollectionSchema<dynamic>>[
        PetDocSchema,
        CurrencyWalletDocSchema,
        YardStateDocSchema,
        JourneyDocSchema,
        ClueCounterDocSchema,
        AchievementProgressDocSchema,
        VisitorLogEntryDocSchema,
        ScheduledJobDocSchema,
        SettingsDocSchema,
      ];

  static Future<Isar> open({
    String? directory,
    String name = defaultName,
    bool inspector = true,
  }) async {
    final existing = Isar.getInstance(name);
    if (existing != null && existing.isOpen) {
      return existing;
    }

    final dbDirectory =
        directory ?? (await getApplicationDocumentsDirectory()).path;
    return Isar.open(
      schemas,
      directory: dbDirectory,
      name: name,
      inspector: inspector,
    );
  }
}
