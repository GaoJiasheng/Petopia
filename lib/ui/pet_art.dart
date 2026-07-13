import '../domain/enums.dart';

/// 宠物美术路径工具。集中管理 speciesId → 资产目录/文件 的映射，
/// 避免各屏散落硬编码。所有物种均有 var01 的 A/B/C/D 档立绘。
class PetArt {
  const PetArt._();

  static const _stageLetter = ['A', 'B', 'C', 'D'];

  /// speciesId（如 pet_cat）→ 目录名（cat）。
  static String dir(String speciesId) =>
      speciesId.startsWith('pet_') ? speciesId.substring(4) : speciesId;

  /// 档位立绘（院子/典礼用）。按宠物实际变体取图。
  static String stage(String speciesId, PetStage s, {String? variantId}) {
    final d = dir(speciesId);
    final variant = variantSlug(variantId) ?? 'var01';
    return 'assets/runtime/pets/$d/pet_${d}_${variant}_stage${_stageLetter[s.index]}.png';
  }

  /// 图鉴彩色肖像（图鉴收藏卡：含徽章/点缀，仅图鉴用）。
  static String dexColor(String speciesId) {
    final d = dir(speciesId);
    return 'assets/art/pets/dex/pet_${d}_dex_color.png';
  }

  /// 干净单只头像（裁自立绘、居中透明方图）。领养/相册用，避免图鉴卡的裁切错乱。
  static String portrait(String speciesId) {
    final d = dir(speciesId);
    return 'assets/art/pets/portraits/pet_$d.png';
  }

  /// 动作序列帧条（4096×512 = 8 帧，仅 stageC）。action ∈ eat/pat/play/bath/idle。
  static String actionSheet(String speciesId, String action) {
    final d = dir(speciesId);
    return 'assets/runtime/pets/$d/actions/pet_${d}_var01_stageC_$action.png';
  }

  /// 现有序列帧只对应 var01 成年体；其余形态使用当前立绘动作编排。
  static bool hasMatchingActionSheet(String? variantId, PetStage? stage) =>
      variantSlug(variantId) == 'var01' && stage == PetStage.c;

  static String? variantSlug(String? variantId) {
    if (variantId == null) return null;
    final match = RegExp(r'(?:^|_)v(?:ar)?0?([1-5])$').firstMatch(variantId);
    final value = match == null ? null : int.tryParse(match.group(1)!);
    return value == null ? null : 'var${value.toString().padLeft(2, '0')}';
  }
}
