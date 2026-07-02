// 明信片内容库模型（spec-content-data.md · postcard_templates.json）。
// 顶层用 templates / encounters / incidents 三数组（非通用 items）。

/// 正文骨架模板（按性格 × 地点类别）。
class PostcardTemplate {
  final String id;
  final String personalityId; // p_glutton 等
  final String category; // 海滨/山地/…
  final String skeleton; // 带占位符：{location}{encounter}{incident}{petName}{ownerName}
  final List<String> slots; // 需要的槽位
  final String tone; // 语气要点

  const PostcardTemplate({
    required this.id,
    required this.personalityId,
    required this.category,
    required this.skeleton,
    this.slots = const [],
    this.tone = '',
  });
}

/// 遭遇词条（人物/动物 + 关系动词），按遭遇池归类。
class Encounter {
  final String id;
  final String poolId; // 关联 Location.encounterPoolId
  final String phrase; // 可入句短语
  final Map<String, double> personalityBias;

  const Encounter({
    required this.id,
    required this.poolId,
    required this.phrase,
    this.personalityBias = const {},
  });
}

/// 碰撞词条（趣味事故/巧合/小奇迹），按地点 vibe 归类。
class Incident {
  final String id;
  final String vibe; // 关联 Location.vibeTags
  final String phrase;
  final String poseHint; // 对齐 §6.5 姿态（用于照片合成）
  final Map<String, double> personalityBias;

  const Incident({
    required this.id,
    required this.vibe,
    required this.phrase,
    this.poseHint = 'idle',
    this.personalityBias = const {},
  });
}
