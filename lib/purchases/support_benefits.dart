import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'support_catalog.dart';

class SupportBenefits {
  const SupportBenefits({
    this.guardian = false,
    this.treatUntil,
    this.lanternUntil,
    this.bouquetUntil,
    this.pendingTreat = 0,
    this.pendingLantern = 0,
    this.pendingBouquet = 0,
    this.lastFreeLanternAt,
    this.processedTransactions = const <String>[],
    this.lastProductId,
    this.lastSupportedAt,
  });

  final bool guardian;
  final DateTime? treatUntil;
  final DateTime? lanternUntil;
  final DateTime? bouquetUntil;
  final int pendingTreat;
  final int pendingLantern;
  final int pendingBouquet;
  final DateTime? lastFreeLanternAt;
  final List<String> processedTransactions;
  final String? lastProductId;
  final DateTime? lastSupportedAt;

  bool treatActive(DateTime now) => treatUntil?.isAfter(now) ?? false;

  bool lanternActive(DateTime now) => lanternUntil?.isAfter(now) ?? false;

  bool bouquetActive(DateTime now) => bouquetUntil?.isAfter(now) ?? false;

  bool get hasSupported => lastSupportedAt != null || guardian;

  int pendingCount(SupportProductKind kind) => switch (kind) {
    SupportProductKind.treat => pendingTreat,
    SupportProductKind.lantern => pendingLantern,
    SupportProductKind.bouquet => pendingBouquet,
    SupportProductKind.guardian => 0,
  };

  int get pendingGiftCount => pendingTreat + pendingLantern + pendingBouquet;

  bool get hasPendingGifts => pendingGiftCount > 0;

  SupportProductSpec? get nextPendingGift {
    final last = SupportCatalog.byId(lastProductId ?? '');
    if (last != null && pendingCount(last.kind) > 0) return last;
    for (final product in SupportCatalog.all) {
      if (pendingCount(product.kind) > 0) return product;
    }
    return null;
  }

  bool canLightFreeLantern(DateTime now) {
    if (!guardian) return false;
    final last = lastFreeLanternAt;
    return last == null || !_isSameLocalCalendarDay(last, now);
  }

  SupportBenefits lightFreeLantern(DateTime now) {
    if (!canLightFreeLantern(now)) return this;
    return SupportBenefits(
      guardian: guardian,
      treatUntil: treatUntil,
      lanternUntil: _extend(lanternUntil, now, SupportCatalog.lantern.duration),
      bouquetUntil: bouquetUntil,
      pendingTreat: pendingTreat,
      pendingLantern: pendingLantern,
      pendingBouquet: pendingBouquet,
      lastFreeLanternAt: now,
      processedTransactions: processedTransactions,
      lastProductId: lastProductId,
      lastSupportedAt: lastSupportedAt,
    );
  }

  SupportBenefits apply({
    required SupportProductSpec product,
    required String transactionKey,
    required DateTime now,
  }) {
    if (processedTransactions.contains(transactionKey)) return this;

    final processed = <String>[...processedTransactions, transactionKey];
    final retained = processed.length <= 64
        ? processed
        : processed.sublist(processed.length - 64);
    return SupportBenefits(
      guardian: guardian || product.kind == SupportProductKind.guardian,
      treatUntil: treatUntil,
      lanternUntil: lanternUntil,
      bouquetUntil: bouquetUntil,
      pendingTreat:
          pendingTreat + (product.kind == SupportProductKind.treat ? 1 : 0),
      pendingLantern:
          pendingLantern + (product.kind == SupportProductKind.lantern ? 1 : 0),
      pendingBouquet:
          pendingBouquet + (product.kind == SupportProductKind.bouquet ? 1 : 0),
      lastFreeLanternAt: lastFreeLanternAt,
      processedTransactions: retained,
      lastProductId: product.id,
      lastSupportedAt: now,
    );
  }

  SupportBenefits openGift({
    required SupportProductSpec product,
    required DateTime now,
  }) {
    if (!product.consumable || pendingCount(product.kind) <= 0) return this;
    return SupportBenefits(
      guardian: guardian,
      treatUntil: product.kind == SupportProductKind.treat
          ? _extend(treatUntil, now, product.duration)
          : treatUntil,
      lanternUntil: product.kind == SupportProductKind.lantern
          ? _extend(lanternUntil, now, product.duration)
          : lanternUntil,
      bouquetUntil: product.kind == SupportProductKind.bouquet
          ? _extend(bouquetUntil, now, product.duration)
          : bouquetUntil,
      pendingTreat:
          pendingTreat - (product.kind == SupportProductKind.treat ? 1 : 0),
      pendingLantern:
          pendingLantern - (product.kind == SupportProductKind.lantern ? 1 : 0),
      pendingBouquet:
          pendingBouquet - (product.kind == SupportProductKind.bouquet ? 1 : 0),
      lastFreeLanternAt: lastFreeLanternAt,
      processedTransactions: processedTransactions,
      lastProductId: product.id,
      lastSupportedAt: lastSupportedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'version': 3,
    'guardian': guardian,
    'treatUntil': treatUntil?.toUtc().toIso8601String(),
    'lanternUntil': lanternUntil?.toUtc().toIso8601String(),
    'bouquetUntil': bouquetUntil?.toUtc().toIso8601String(),
    'pendingTreat': pendingTreat,
    'pendingLantern': pendingLantern,
    'pendingBouquet': pendingBouquet,
    'lastFreeLanternAt': lastFreeLanternAt?.toUtc().toIso8601String(),
    'processedTransactions': processedTransactions,
    'lastProductId': lastProductId,
    'lastSupportedAt': lastSupportedAt?.toUtc().toIso8601String(),
  };

  static SupportBenefits fromJson(Map<String, Object?> json) {
    DateTime? date(Object? value) =>
        value is String ? DateTime.tryParse(value)?.toUtc() : null;
    int pending(Object? value) => value is int && value > 0 ? value : 0;

    final processed = json['processedTransactions'];
    return SupportBenefits(
      guardian: json['guardian'] == true,
      treatUntil: date(json['treatUntil']),
      lanternUntil: date(json['lanternUntil']),
      bouquetUntil: date(json['bouquetUntil']),
      pendingTreat: pending(json['pendingTreat']),
      pendingLantern: pending(json['pendingLantern']),
      pendingBouquet: pending(json['pendingBouquet']),
      lastFreeLanternAt: date(json['lastFreeLanternAt']),
      processedTransactions: processed is List<Object?>
          ? processed.whereType<String>().take(64).toList(growable: false)
          : const <String>[],
      lastProductId: json['lastProductId'] is String
          ? json['lastProductId']! as String
          : null,
      lastSupportedAt: date(json['lastSupportedAt']),
    );
  }

  static DateTime? _extend(
    DateTime? current,
    DateTime now,
    Duration? duration,
  ) {
    if (duration == null) return current;
    final anchor = current != null && current.isAfter(now) ? current : now;
    return anchor.add(duration);
  }

  static bool _isSameLocalCalendarDay(DateTime left, DateTime right) {
    final localLeft = left.toLocal();
    final localRight = right.toLocal();
    return localLeft.year == localRight.year &&
        localLeft.month == localRight.month &&
        localLeft.day == localRight.day;
  }
}

abstract interface class SupportBenefitsStore {
  Future<SupportBenefits> load();

  Future<void> save(SupportBenefits benefits);
}

class FileSupportBenefitsStore implements SupportBenefitsStore {
  FileSupportBenefitsStore({Future<Directory> Function()? supportDirectory})
    : _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _supportDirectory;
  Future<void> _saveTail = Future<void>.value();

  Future<File> _file() async {
    final root = await _supportDirectory();
    final directory = Directory(p.join(root.path, 'petopia', 'support'));
    await directory.create(recursive: true);
    return File(p.join(directory.path, 'support-benefits.json'));
  }

  @override
  Future<SupportBenefits> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const SupportBenefits();
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, Object?>) {
        return const SupportBenefits();
      }
      return SupportBenefits.fromJson(decoded);
    } on Object {
      return const SupportBenefits();
    }
  }

  @override
  Future<void> save(SupportBenefits benefits) {
    final next = _saveTail
        .catchError((Object _, StackTrace _) {})
        .then((_) => _write(benefits));
    _saveTail = next.catchError((Object _, StackTrace _) {});
    return next;
  }

  Future<void> _write(SupportBenefits benefits) async {
    final file = await _file();
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert(benefits.toJson()),
      flush: true,
    );
    await temporary.rename(file.path);
  }
}
