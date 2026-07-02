import '../enums.dart';

/// 只追加流水行模型（spec-technical §1.4，SQLite）。
/// 只 INSERT，不 UPDATE/DELETE —— 审计真相源（INV-1 / INV-4）。

/// 经验流水。delta>0。exp_after 冗余便于即时自检。
class ExpLogEntry {
  final String id;
  final String petId;
  final DateTime timestamp; // UTC
  final ExpSource sourceType;
  final String? sourceRef;
  final int delta; // >0
  final int levelAt;
  final int expAfter; // 冗余校验
  final String? note; // 展示短语

  const ExpLogEntry({
    required this.id,
    required this.petId,
    required this.timestamp,
    required this.sourceType,
    required this.delta,
    required this.levelAt,
    required this.expAfter,
    this.sourceRef,
    this.note,
  });
}

/// 暖绒流水。delta 可正可负（负=消费）。balance_after 冗余。
class CurrencyLog {
  final String id;
  final DateTime timestamp;
  final int delta; // + 收入 / - 消费
  final CurrencyReason reason;
  final String? ref; // 商品/成就/petId（幂等发奖用稳定 ref）
  final int balanceAfter;

  const CurrencyLog({
    required this.id,
    required this.timestamp,
    required this.delta,
    required this.reason,
    required this.balanceAfter,
    this.ref,
  });
}

/// 明信片（§6.3）。body_text 存渲染定稿以保证回看一致。
class Postcard {
  final String id;
  final String petId;
  final String journeyId;
  final String locationId;
  final int seq; // 第几站
  final DateTime sentAt;
  final DateTime? receivedAt;
  final Season season;
  final TimeOfDayOfDay timeOfDay;
  final Weather weather;
  final String? encounterId;
  final String? incidentId;
  final String bodyText;
  final String photoAssetId;
  final String stampId;
  final String? clueToPet; // 彩蛋线索载体
  final String? clueToVisitor;

  const Postcard({
    required this.id,
    required this.petId,
    required this.journeyId,
    required this.locationId,
    required this.seq,
    required this.sentAt,
    required this.season,
    required this.timeOfDay,
    required this.weather,
    required this.bodyText,
    required this.photoAssetId,
    required this.stampId,
    this.receivedAt,
    this.encounterId,
    this.incidentId,
    this.clueToPet,
    this.clueToVisitor,
  });
}

/// 事件流水（§9.1）。用于冷却判定（event_id+date）与 oncePerPet（pet_id）。
class EventLogEntry {
  final String id;
  final String eventId;
  final String? petId;
  final DateTime date;
  final int? choiceIdx;
  final int expGranted;

  const EventLogEntry({
    required this.id,
    required this.eventId,
    required this.date,
    required this.expGranted,
    this.petId,
    this.choiceIdx,
  });
}
