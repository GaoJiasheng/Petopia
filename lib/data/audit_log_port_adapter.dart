import '../domain/models/logs.dart';
import '../services/log_port.dart';
import 'sqlite/petopia_sqlite_dao.dart';

/// 把脊椎的 [AuditLogPort] 抽象接到 Codex 数据层的 sqflite DAO。
///
/// 装配层桥：ExpEngine/AuditService/EconomyService 通过 AuditLogPort 读写流水，
/// 运行期由本适配器落到真实 SQLite；单测则换内存实现。
class DaoAuditLogPort implements AuditLogPort {
  final PetopiaSqliteDao _dao;
  const DaoAuditLogPort(this._dao);

  @override
  Future<void> insertExp(ExpLogEntry e) => _dao.insertExpLog(e);

  @override
  Future<void> insertCurrency(CurrencyLog e) => _dao.insertCurrencyLog(e);

  @override
  Future<int> sumExp(String petId) => _dao.sumDelta(petId);

  @override
  Future<int> sumCurrency() => _dao.sumCurrencyDelta();
}
