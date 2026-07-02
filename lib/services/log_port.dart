import '../domain/models/logs.dart';

/// 流水端口：脊椎（Audit/Economy/Exp）通过它读写只追加流水，
/// 由数据层（sqflite DAO）适配实现。抽象出来是为了脊椎可脱离持久化做纯单测。
abstract interface class AuditLogPort {
  Future<void> insertExp(ExpLogEntry e); // 只 INSERT
  Future<void> insertCurrency(CurrencyLog e); // 只 INSERT
  Future<int> sumExp(String petId); // Σexp_log.delta（INV-1）
  Future<int> sumCurrency(); // Σcurrency_log.delta（INV-4）
}
