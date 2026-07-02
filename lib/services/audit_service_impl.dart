import '../domain/models/logs.dart';
import '../domain/models/pet.dart';
import '../domain/models/yard.dart';
import 'audit_service.dart';
import 'exp_engine_impl.dart' show deriveLevel, deriveStage;
import 'log_port.dart';

/// AuditService 实现（spec-technical §3.3）。
///
/// 追加写流水；启动校验 INV-1（pet.exp==Σexp_log.delta）/ INV-4（balance==Σcurrency_log.delta）。
/// 不一致**不静默、不删流水**：以流水为真相源回正 scalar（因流水只追加不可篡改），
/// 并记 discrepancy。回正 exp 后同步重算 level/stage。宁可少给不误伤。
class AuditServiceImpl implements AuditService {
  final AuditLogPort _port;
  final List<Pet> Function() _petsProvider;
  final CurrencyWallet Function() _walletProvider;

  AuditServiceImpl(this._port, this._petsProvider, this._walletProvider);

  @override
  Future<void> appendExpLog(ExpLogEntry e) => _port.insertExp(e);

  @override
  Future<void> appendCurrencyLog(CurrencyLog e) => _port.insertCurrency(e);

  @override
  Future<AuditReport> verifyOnStartup() async {
    final discrepancies = <String>[];

    for (final pet in _petsProvider()) {
      final expected = await _port.sumExp(pet.id);
      if (pet.exp != expected) {
        discrepancies.add(
            'pet ${pet.id}: exp=${pet.exp} 但流水和=$expected → 回正为 $expected');
        // 以流水为真相源回正，并重算派生等级/档位。
        pet.exp = expected;
        pet.level = deriveLevel(expected);
        pet.stage = deriveStage(pet.level);
      }
    }

    final wallet = _walletProvider();
    final expectedBalance = await _port.sumCurrency();
    if (wallet.balance != expectedBalance) {
      discrepancies.add(
          'wallet: balance=${wallet.balance} 但流水和=$expectedBalance → 回正为 $expectedBalance');
      wallet.balance = expectedBalance;
    }

    return AuditReport(ok: discrepancies.isEmpty, discrepancies: discrepancies);
  }
}
