import '../domain/models/pet.dart';

/// GraduationService（spec-technical §3.2 / §5.1）。
///
/// Lv10 毕业编排：暖绒结算（EconomyService.settleGraduation）、生成 Journey、
/// 宠物转 TRAVELING、院子 gradCount++（驱动豪华度进化）、置 nextRevisitAt 前置。
/// 由 ExpEngine 触发 graduated 时调用。
abstract interface class GraduationService {
  /// 执行毕业典礼编排，返回创建的 Journey id。
  Future<String> graduate(Pet pet);
}
