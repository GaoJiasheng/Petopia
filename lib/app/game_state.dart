import '../domain/models/pet.dart';
import '../domain/models/yard.dart';
import '../domain/models/game_state.dart';
import '../domain/models/logs.dart';

/// 运行期游戏状态容器（单宠位）。装配层持有，服务读写它。
/// 生产由 SaveService 与各 Repository 持久化；单测用内存实例。
class GameSession {
  Pet? current; // 当前在养宠（≤1，INV-2）
  final CurrencyWallet wallet;
  final YardState yard;
  final Settings settings;
  final ShopInventory shopInventory;

  final Map<String, ClueCounter> clues = {};
  final Map<String, AchievementProgress> achievements = {};

  /// 按 petId 累计的事件/访客互动数（供毕业结算与成就）。
  final Map<String, int> eventCounts = {};
  final Map<String, int> visitorCounts = {};

  /// 成就累计计数器（跨宠累计，持久化；供 UnlockService 推进）。
  int careActionCount = 0; // 照料动作总次数（喂/摸/玩/洗）
  int revisitCount = 0; // 回访发生总次数
  int specialEventCount = 0; // 彩蛋事件触发总次数
  final Map<String, int> achievementSignals = {};
  final Set<String> ownedVariants = {};

  final List<Pet> roaming = []; // 毕业宠（世界漫游）
  final List<Journey> journeys = [];
  final List<Postcard> postcards = []; // 收到的明信片（旅行相册数据源）
  final List<ScheduledJob> jobs = [];
  final Set<String> generatedDays = {};
  final Set<String> firedSpecials = {}; // 'petId:eventId'，oncePerPet 特殊事件去重
  final Map<String, DateTime> eventLastFiredAt = {};
  final List<VisitorLogEntry> visitorLog = [];
  ActiveVisitor? activeVisitor; // 当前在院子停留的野生访客（≤1，默认 24h）
  late CareLedger careLedger;
  final List<PendingGameEvent> pendingEvents = [];
  final Set<String> ownedSpecies = {}; // 曾养过的物种（图鉴 OWNED_BEFORE）
  Pet? revisitor; // 当前在访的毕业宠（≤1）
  DateTime? revisitorArrivedAt;
  DateTime? revisitorLeavesAt;
  bool revisitorArrivalSeen = false;
  bool revisitorInteracted = false;

  GameSession({
    this.current,
    CurrencyWallet? wallet,
    YardState? yard,
    Settings? settings,
    ShopInventory? shopInventory,
  }) : wallet = wallet ?? CurrencyWallet(),
       yard = yard ?? YardState(),
       shopInventory = shopInventory ?? ShopInventory(),
       settings =
           settings ??
           Settings(
             createdAt: DateTime.now().toUtc(),
             lastWallClockAt: DateTime.now().toUtc(),
           ) {
    final now = DateTime.now();
    careLedger = CareLedger(dayKey: _dayKey(now));
  }

  /// 参与审计的全部宠物（在养 + 漫游）。
  List<Pet> get allPets => [?current, ...roaming];

  static String _dayKey(DateTime t) {
    final local = t.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}
