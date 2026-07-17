import '../enums.dart';

/// 宠物运行期实体（spec-technical §1.3）。
///
/// 纯 domain 模型（无 Isar/IO 依赖）；数据层负责持久化映射。
/// 不变量：INV-1（exp==Σ流水）、INV-2（RAISING/REVISITING 全局≤1）、INV-5（exp≥0）。
class Pet {
  String id;
  String speciesId; // 引用 PetSpecies
  String variantId; // 加权随机自 species.variantIds
  String name; // 领养时取名，非空
  List<String> personality; // 长度=2，10 选 2 不重复
  DateTime bornAt; // UTC
  int level; // 1..10
  int exp; // ≥0
  PetStage stage; // 由 level 派生（1-4=A,5-7=B,8-9=C,10=D）；冗余存储
  PetState state;
  DateTime lastOnlineAt; // 离线 renew 锚点（§3.2/§4）
  int offlineExpGrantedToday; // 0..dailyCap；跨日归零
  String offlineDayKey; // yyyy-MM-dd（本地日），判定跨日归零
  String? wishId; // ev_s03 流星愿望写入
  DateTime? graduatedAt;
  String? journeyId;
  DateTime? nextRevisitAt; // ROAMING 时设置
  List<String> pastNames; // 支持「名字不重复」隐藏成就判定
  Map<String, double> personalityBonusCarry; // 小额性格加成的跨动作余数，避免 floor 永久吞掉

  Pet({
    required this.id,
    required this.speciesId,
    required this.variantId,
    required this.name,
    required this.personality,
    required this.bornAt,
    required this.lastOnlineAt,
    required this.offlineDayKey,
    this.level = 1,
    this.exp = 0,
    this.stage = PetStage.a,
    this.state = PetState.raising,
    this.offlineExpGrantedToday = 0,
    this.wishId,
    this.graduatedAt,
    this.journeyId,
    this.nextRevisitAt,
    List<String>? pastNames,
    Map<String, double>? personalityBonusCarry,
  }) : pastNames = pastNames ?? <String>[],
       personalityBonusCarry = personalityBonusCarry ?? <String, double>{};
}
