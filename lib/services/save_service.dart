import 'dart:io';

/// 导入结果。
class ImportResult {
  final bool success;
  final String? failReason; // checksum/schema/audit 失败原因
  const ImportResult({required this.success, this.failReason});
}

/// SaveService（spec-technical §3.9）。
///
/// 自动存档（debounce）、A/B 双备份、schemaVersion 迁移、导入导出。
/// 导入是覆盖式（单宠位无合并语义）；导入后必跑 AuditService 校验 INV-1/4，不过则拒绝并保留原档。
abstract interface class SaveService {
  Future<void> autoSave(); // debounce autoSaveDebounceMs，写当前 slot 后切换
  Future<void> load(); // 优先 slot，校验失败回退备份 slot
  Future<int> migrateIfNeeded(
    int fromVersion,
  ); // 顺序执行 migrations[from..current]
  Future<File> export(); // 打包 session+SQLite 单文件（含 checksum）
  Future<ImportResult> import(File f);
}
