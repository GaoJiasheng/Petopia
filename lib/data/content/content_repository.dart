import '../../domain/models/content_entities.dart';

/// ContentRepository（spec-technical §3 / §5.2）。
///
/// 启动时 loadAll() 读全部 assets/data/*.json 到不可变内存 map；
/// schemaVersion 与代码期望不符则报错（内容与代码版本对齐）。运行期只读。
abstract interface class ContentRepository {
  /// 加载全部静态内容（幂等）。schemaVersion 校验失败抛异常。
  Future<void> loadAll();

  List<PetSpecies> get species;
  List<PersonalityTag> get personalities;
  List<Location> get locations;
  List<Visitor> get visitors;
  List<VisitorPetInteraction> get visitorInteractions;
  List<Event> get events;
  List<Achievement> get achievements;
  List<ShopItem> get shopItems;

  PetSpecies? speciesById(String id);
  PersonalityTag? personalityById(String id);
  Location? locationById(String id);
  Visitor? visitorById(String id);
  Event? eventById(String id);
  Achievement? achievementById(String id);
  ShopItem? shopItemById(String id);
}
