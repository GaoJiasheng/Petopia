# Petopia

一个手绘水彩（奶油可爱风）的小院子养宠手游。一次只养一只宠物，陪它从幼崽长大，满级后它「毕业」去环游世界——不是告别：它会持续寄回明信片，偶尔回院子串门。送走一只，再迎来下一只。院子里不时有野生动物访客路过，慢慢填满你的图鉴。

- **平台**：iOS + Android（Flutter + Flame）
- **调性**：治愈、零焦虑、绝不惩罚离线
- **状态**：App Store 上线前打磨中；核心养成、旅行明信片、回访、访客、商店、成就与 iPhone/iPad 自适应链路已接通

## 本地验证

```bash
flutter analyze
flutter test
flutter build ios --simulator --no-codesign
```

运行包使用 `assets/runtime/` 下的移动端优化副本；`assets/art/` 中的高质量 PNG 母图保留为生产源，不直接全量进入首包。
素材分层、质量基线与包体规则见 [`docs/runtime-asset-pack.md`](docs/runtime-asset-pack.md)。

## 文档

设计与实现规格全部在 [`docs/`](docs/)，以 [`docs/DESIGN.md`](docs/DESIGN.md) 为主纲，顶部有全部配套文档（内容库 / 实现规格 / 美术 / 音频）的索引。

## License

本项目源代码基于 [Apache License 2.0](LICENSE) 开源。美术、音频和运行时
衍生素材使用独立的 [Petopia Asset License](ASSET_LICENSE)，不纳入
Apache-2.0；来源、生成服务条款与发布哈希见
[`asset-rights-register.md`](docs/app-store/asset-rights-register.md)。
