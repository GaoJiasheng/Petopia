import '../domain/models/logs.dart';

/// 审计校验报告。
class AuditReport {
  final bool ok;
  final List<String> discrepancies; // 记录 petId + 期望/实际
  const AuditReport({required this.ok, this.discrepancies = const []});
}

/// AuditService（spec-technical §3.3）。
///
/// 流水（ExpLog/CurrencyLog）追加写入 + 启动完整性校验。
/// 不一致不静默修复：以流水为真相源回正 pet.exp/wallet.balance（因流水只追加不可篡改），
/// 绝不反向删流水。校验 INV-1 / INV-4。
abstract interface class AuditService {
  Future<void> appendExpLog(ExpLogEntry e); // INSERT only
  Future<void> appendCurrencyLog(CurrencyLog e); // INSERT only
  Future<AuditReport> verifyOnStartup();
}
