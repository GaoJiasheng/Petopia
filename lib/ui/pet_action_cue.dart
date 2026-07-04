import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 一次动作播放请求：action=eat/pat/play/bath；seq 自增以便重复触发同一动作。
class PetActionCue {
  final String action;
  final int seq;
  const PetActionCue(this.action, this.seq);
}

/// 院子动作栏 / 点击宠物 → 写入；PetSprite 监听后播放对应序列帧。
final petActionCueProvider = StateProvider<PetActionCue?>((ref) => null);
