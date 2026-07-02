import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/services/audit_service.dart';
import 'package:petopia/data/save/save_service_impl.dart';

class FakeStore implements SaveSnapshotStore {
  FakeStore(this.snapshot);

  SaveDataSnapshot snapshot;
  final List<SaveDataSnapshot> replacements = <SaveDataSnapshot>[];

  @override
  Future<SaveDataSnapshot> exportSnapshot() async => snapshot;

  @override
  Future<void> replaceAll(SaveDataSnapshot snapshot) async {
    this.snapshot = snapshot;
    replacements.add(snapshot);
  }
}

class FakeAudit implements AuditService {
  FakeAudit(this.report);

  AuditReport report;
  int verifyCalls = 0;

  @override
  Future<void> appendCurrencyLog(CurrencyLog e) async {}

  @override
  Future<void> appendExpLog(ExpLogEntry e) async {}

  @override
  Future<AuditReport> verifyOnStartup() async {
    verifyCalls += 1;
    return report;
  }
}

SaveDataSnapshot _snapshot(int marker) {
  return SaveDataSnapshot(
    schemaVersion: 1,
    isar: <String, Object?>{
      'marker': marker,
      'settings': <String, Object?>{'schemaVersion': 1},
    },
    sqlite: <String, Object?>{'logs': <Object?>[]},
  );
}

int _marker(SaveDataSnapshot snapshot) => snapshot.isar['marker']! as int;

Map<String, Object?> _readJson(File file) {
  return jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
}

void main() {
  late Directory tempDir;
  late DateTime now;

  LocalSaveService service(FakeStore store, {FakeAudit? audit}) {
    return LocalSaveService(
      snapshotStore: store,
      auditService: audit ?? FakeAudit(const AuditReport(ok: true)),
      saveDirectory: tempDir,
      now: () => now,
      autoSaveDebounce: Duration.zero,
    );
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('petopia_save_service_');
    now = DateTime.utc(2026, 7, 2, 12);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('autoSave debounce 后按 A/B slot 轮换写入', () async {
    final store = FakeStore(_snapshot(1));
    final save = service(store);

    await save.autoSave();
    final slotA = File('${tempDir.path}/slot_A.json');
    final slotB = File('${tempDir.path}/slot_B.json');
    expect(slotA.existsSync(), true);
    expect(slotB.existsSync(), false);
    expect(_readJson(slotA)['checksum'], isA<String>());

    store.snapshot = _snapshot(2);
    now = now.add(const Duration(minutes: 1));
    await save.autoSave();

    expect(slotB.existsSync(), true);
    final slotBPayload = _readJson(slotB)['payload']! as Map<String, Object?>;
    final slotBIsar = slotBPayload['isar']! as Map<String, Object?>;
    expect(slotBIsar['marker'], 2);
  });

  test('load 优先较新 slot，较新损坏时回退另一 slot', () async {
    final store = FakeStore(_snapshot(1));
    final save = service(store);

    await save.autoSave();
    store.snapshot = _snapshot(2);
    now = now.add(const Duration(minutes: 1));
    await save.autoSave();

    File('${tempDir.path}/slot_B.json').writeAsStringSync('not-json');
    store.snapshot = _snapshot(99);

    await save.load();

    expect(_marker(store.snapshot), 1);

    store.snapshot = _snapshot(3);
    now = now.add(const Duration(minutes: 1));
    await save.autoSave();
    final slotBPayload =
        _readJson(File('${tempDir.path}/slot_B.json'))['payload']!
            as Map<String, Object?>;
    final slotBIsar = slotBPayload['isar']! as Map<String, Object?>;
    expect(slotBIsar['marker'], 3);
  });

  test('import audit 不通过则拒绝并保留原档', () async {
    final exportDir = Directory('${tempDir.path}/export');
    final importDir = Directory('${tempDir.path}/import');
    final exportStore = FakeStore(_snapshot(2));
    final exportService = LocalSaveService(
      snapshotStore: exportStore,
      auditService: FakeAudit(const AuditReport(ok: true)),
      saveDirectory: exportDir,
      now: () => now,
      autoSaveDebounce: Duration.zero,
    );
    final file = await exportService.export();

    final importStore = FakeStore(_snapshot(1));
    final audit = FakeAudit(
      const AuditReport(ok: false, discrepancies: <String>['INV-1']),
    );
    final importService = LocalSaveService(
      snapshotStore: importStore,
      auditService: audit,
      saveDirectory: importDir,
      now: () => now,
      autoSaveDebounce: Duration.zero,
    );

    final result = await importService.import(file);

    expect(result.success, false);
    expect(result.failReason, contains('audit'));
    expect(audit.verifyCalls, 1);
    expect(_marker(importStore.snapshot), 1);
    expect(importStore.replacements.map(_marker), <int>[2, 1]);
  });
}
