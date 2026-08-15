# 走查打磨修复单（W1–W5）· Codex

> 来源：`docs/app-store/polish-review-findings.md` §七（2026-08-15 iPad 真实新档全流程走查）。
> 性质：功能冻结期的纯打磨，**不加新功能、不改玩法数值、不动未提及的文件**。
> 每项都给了准确文件:行号与建议修法；建议修法只是方向，若你有更贴合现有代码习惯的等价实现可以替换，但验收标准不变。

---

## W1｜首启迎接页宠物悬空（P2）

- **现象**：三页 onboarding 的宠物立绘悬浮在背景拱门上方的半空，脚下无着地点；iPad 上尤其明显。
- **位置**：`lib/ui/onboarding_screen.dart:246-262`——`art` 直接以 `imageSize` 居中摆放，没有与背景的地面线对齐。
- **修法建议**（视觉层，任选其一）：
  a) 给立绘正下方加一枚淡淡的椭圆草影（参照宠物在院子里的做法），让它"落"在画面上；
  b) 或把整个 art+文案列整体下移，使立绘底边落在背景草地带（背景图约下 1/3 起是草地）。
- **验收**：iPhone 竖屏 + iPad 竖屏截图目检，三页立绘都不再有"漂浮感"；文字与"继续"按钮不重叠、不溢出。

## W2｜领养页 iPad 排版失衡（P2）

- **现象**：iPad 竖屏下三张物种卡贴顶，中间约 60% 屏幕纯空白，名字输入框贴底，画面重心断裂。
- **位置**：`lib/ui/adopt_screen.dart`（整体布局）。
- **修法建议**：宽屏（`width >= 600`）时：物种卡放大并垂直居中（卡片可增大到 ~1.4 倍），名字输入区紧跟卡片下方成组布局，而不是钉在屏幕底部；手机布局保持现状不动。
- **验收**：iPad 竖/横屏无大面积空白、视觉重心连贯；iPhone 布局与现状一致（可用 `integration_test` 相应场景或截图对比确认无回归）。

## W3｜支持页 StoreKit 错误透传英文（P2，本单最重要）

- **现象**：商品加载失败时页面横幅显示原始英文 `StoreKit: Failed to get response from platform.`。弱网/受限地区/模拟器均会出现，违反全局温柔文案基线。
- **根因**：`lib/purchases/support_purchase_controller.dart:135`——`message: query.error` 把 storefront 返回的**原始错误字符串**直接塞进用户可见 banner。同文件其他路径（:106、:124、:142）都已是温柔中文。
- **修法**：该分支改为固定文案（与 :124 风格一致），如：`商店暂时没有连上，稍后再来看看吧。当前院子不受影响。`；原始 `query.error` 仅 `debugPrint` 留档。**同步在 `lib/l10n/english_copy.dart` 增加对应英文条目**（如 "The shop couldn't connect just now — check back soon. Your garden is unaffected."）。
- **验收**：模拟器（无 StoreKit 配置）打开"支持小院"，横幅显示新中文文案；切英文显示英文文案；`grep -rn "query.error" lib/ui lib/purchases` 确认不再流入任何用户可见字符串。

## W4｜商店主题预览图一半无辨识度（P2）

- **现象**：主题卡预览（樱花小径/星夜帐篷/海风假日/糖果焙房等）显示的几乎全是草地——看不到樱花、夜色、海、糖果元素；雪屋暖灯/秋日果酱恰好特征在中部所以正常。
- **根因**：`lib/ui/shop_screen.dart:750-753`——`BoxFit.cover + Alignment.center` 对 1290×2796 竖长背景图裁切时命中中部草地带；各主题的特征元素（樱花树/星空/海面/屋顶）集中在图的**上半部**。
- **修法建议**：把预览对齐改为顶部偏上（如 `alignment: Alignment(0, -0.62)` 附近，逐主题微调不必做，统一一个值即可），或换用已打包的 wide 版主题图（`assets/runtime/yard/themes/wide/`，横构图更适合 112 高的卡片带）。
- **验收**：商店"院子主题"分类 11 张卡逐一目检，每张预览能一眼认出主题特征（樱花可见花、星夜可见夜空、雪屋可见雪…）；`cacheWidth` 保持或按需调整，不引入解码放大。

## W5｜设置-关于「应用名称」折行（P3，顺手修）

- **现象**：关于卡片里 label「应用名称」被 54pt 定宽折成「应用名/称」。
- **位置**：`lib/ui/settings_screen.dart:906`（label 文本）与 `:930-933`（`_InfoLine` 的 `SizedBox(width: 54)`）。
- **修法**（二选一）：label 改回「应用」——**注意**：`english_copy.dart` 中 `'应用'` 已映射为商店按钮的 "Use"，因此若改回「应用」必须新增独立措辞（推荐直接把定宽从 54 提到 66 并保留「应用名称」，零翻译改动）。
- **验收**：中文/英文两种语言下关于卡四行 label 均单行显示。

---

## 铁律

1. 只改本单列出的 5 处及其直接联动（英文条目、必要的测试快照）；不顺手重构、不动美术资产、不改 pubspec 版本号。
2. 新增/修改任何用户可见中文串，**必须同步 `lib/l10n/english_copy.dart`**；不确定措辞时参照同文件相邻条目的语气。
3. 改完必须全绿：`flutter analyze`（0 issue）、`flutter test`、`python3 tools/check_release_candidate.py`。
4. W1/W2/W4 属视觉修改：各出一张改后截图（iPhone + iPad 各一）放到 `assets/art/qa/walkthrough-fix/` 供人工复核；命名 `w1_onboarding_{phone,pad}.png` 式样。
5. 一个 finding 一个 commit，message 引用编号（如 `fix(ui): W3 支持页 StoreKit 错误改为温柔文案`）。
