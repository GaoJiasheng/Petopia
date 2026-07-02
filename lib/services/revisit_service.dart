import '../domain/models/pet.dart';

/// RevisitService（spec-technical §7 / §3）。
///
/// 毕业宠进入「世界漫游」后，每 7–14 天随机回院子串门 1–2 天，
/// 作为当日事件、与在养宠专属互动、20% 带旅伴。同时最多 1 只回访（INV-2）。
abstract interface class RevisitService {
  /// 安排下次回访（now + 7..14 天）。漫游开始或本次回访结束后调用。
  void scheduleNextRevisit(Pet pet);

  /// 今日是否到回访窗口（ROAMING 且 nextRevisitAt<=today）。
  bool isDue(Pet pet, DateTime today);

  /// 从到期漫游宠中选一个回访者；已有在访则返回 null（INV-2）。
  Pet? pickRevisitor(List<Pet> roaming, DateTime today,
      {bool hasCurrentRevisitor});

  /// 回访者与在养宠互动：在养宠获 REVISIT 经验(+5)。返回是否带了旅伴（20%）。
  bool onRevisitInteract(Pet revisitor, Pet? current);

  /// 本次回访结束，安排下一次。
  void onRevisitEnd(Pet pet);
}
