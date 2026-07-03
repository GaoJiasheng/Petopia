import '../domain/enums.dart';

/// 宠物美术路径工具。集中管理 speciesId → 资产目录/文件 的映射，
/// 避免各屏散落硬编码。所有物种均有 var01 的 A/B/C/D 档立绘。
class PetArt {
  const PetArt._();

  static const _stageLetter = ['A', 'B', 'C', 'D'];

  /// speciesId（如 pet_cat）→ 目录名（cat）。
  static String dir(String speciesId) =>
      speciesId.startsWith('pet_') ? speciesId.substring(4) : speciesId;

  /// 档位立绘（院子/典礼用）。统一取主变体 var01。
  static String stage(String speciesId, PetStage s) {
    final d = dir(speciesId);
    return 'assets/art/pets/$d/pet_${d}_var01_stage${_stageLetter[s.index]}.png';
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
}
