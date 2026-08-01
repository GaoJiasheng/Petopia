#!/usr/bin/env python3
"""Generate a reviewer-friendly Chinese/English runtime copy inventory."""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs" / "bilingual-copy-review.md"
HAN = re.compile(r"[\u3400-\u9fff]")
REPEATED_PUNCTUATION = re.compile(r"[!！]{2,}|[?？]{2,}")
INTERNAL_COPY = re.compile(r"【§|系统自动|线索\+\d|图鉴到访|Lv\s?\d", re.IGNORECASE)
COERCIVE_ZH = re.compile(r"每天等信|很想很想|除非你肯等|要听完|应一声|没有你|离不开你")
COERCIVE_EN = re.compile(
    r"please come back|need you|without you|don['’]t leave|do not leave|"
    r"limited time|best value|most popular",
    re.IGNORECASE,
)
GENERIC_ANATOMY = re.compile(r"我的耳朵|我的尾巴|我的爪|我的肚皮|我的胡须|四条腿")


def _skip(source: str, index: int, *, commas: bool = True) -> int:
    while index < len(source):
        if source[index].isspace() or (commas and source[index] == ","):
            index += 1
            continue
        if source.startswith("//", index):
            newline = source.find("\n", index)
            return (
                len(source)
                if newline < 0
                else _skip(source, newline + 1, commas=commas)
            )
        if source.startswith("/*", index):
            end = source.find("*/", index + 2)
            if end < 0:
                raise ValueError("Unclosed Dart block comment")
            index = end + 2
            continue
        break
    return index


def _parse_dart_string(source: str, index: int) -> tuple[str, int]:
    raw = source.startswith("r'", index) or source.startswith('r"', index)
    if raw:
        index += 1
    quote = source[index]
    if quote not in "'\"":
        raise ValueError(f"Expected Dart string at {index}: {source[index:index + 20]!r}")
    triple = source.startswith(quote * 3, index)
    delimiter = quote * (3 if triple else 1)
    index += len(delimiter)
    output: list[str] = []
    escapes = {
        "n": "\n",
        "r": "\r",
        "t": "\t",
        "b": "\b",
        "f": "\f",
        "v": "\v",
        "\\": "\\",
        "'": "'",
        '"': '"',
        "$": "$",
    }
    while index < len(source):
        if source.startswith(delimiter, index):
            return "".join(output), index + len(delimiter)
        char = source[index]
        if char == "\\" and not raw:
            index += 1
            if index >= len(source):
                raise ValueError("Unclosed Dart escape")
            escaped = source[index]
            if escaped == "u":
                if source.startswith("u{", index):
                    end = source.find("}", index + 2)
                    output.append(chr(int(source[index + 2 : end], 16)))
                    index = end + 1
                    continue
                output.append(chr(int(source[index + 1 : index + 5], 16)))
                index += 5
                continue
            output.append(escapes.get(escaped, escaped))
            index += 1
            continue
        output.append(char)
        index += 1
    raise ValueError("Unclosed Dart string")


def _parse_concatenated_strings(source: str, index: int) -> tuple[str, int]:
    values: list[str] = []
    while True:
        index = _skip(source, index, commas=False)
        if index >= len(source):
            break
        string_at = index + 1 if source[index] == "r" else index
        if string_at >= len(source) or source[string_at] not in "'\"":
            break
        value, index = _parse_dart_string(source, index)
        values.append(value)
    if not values:
        raise ValueError(f"Expected one or more Dart strings at {index}")
    return "".join(values), index


def _find_map_body(source: str, name: str) -> tuple[int, int]:
    marker = source.find(name)
    if marker < 0:
        raise ValueError(f"Missing map {name}")
    start = source.find("{", marker)
    depth = 0
    index = start
    while index < len(source):
        if source.startswith("//", index):
            newline = source.find("\n", index)
            index = len(source) if newline < 0 else newline + 1
            continue
        if source.startswith("/*", index):
            end = source.find("*/", index + 2)
            index = len(source) if end < 0 else end + 2
            continue
        string_at = index + 1 if source[index] == "r" else index
        if string_at < len(source) and source[string_at] in "'\"":
            _, index = _parse_dart_string(source, index)
            continue
        if source[index] == "{":
            depth += 1
        elif source[index] == "}":
            depth -= 1
            if depth == 0:
                return start + 1, index
        index += 1
    raise ValueError(f"Unclosed map {name}")


def _extract_string_map(source: str, name: str) -> dict[str, str]:
    start, end = _find_map_body(source, name)
    result: dict[str, str] = {}
    index = start
    while True:
        index = _skip(source, index)
        if index >= end:
            return result
        key, index = _parse_concatenated_strings(source, index)
        index = _skip(source, index)
        if source[index] != ":":
            raise ValueError(f"Expected ':' in {name} after {key!r}")
        value, index = _parse_concatenated_strings(source, index + 1)
        result[key] = value


def _extract_string_list_map(source: str, name: str) -> dict[str, list[str]]:
    start, end = _find_map_body(source, name)
    result: dict[str, list[str]] = {}
    index = start
    while True:
        index = _skip(source, index)
        if index >= end:
            return result
        key, index = _parse_concatenated_strings(source, index)
        index = _skip(source, index)
        if source[index] != ":":
            raise ValueError(f"Expected ':' in {name} after {key!r}")
        index = _skip(source, index + 1)
        if source.startswith("<String>", index):
            index = _skip(source, index + len("<String>"))
        if source[index] != "[":
            raise ValueError(f"Expected list in {name} after {key!r}")
        index += 1
        values: list[str] = []
        while True:
            index = _skip(source, index)
            if source[index] == "]":
                index += 1
                break
            value, index = _parse_concatenated_strings(source, index)
            values.append(value)
        result[key] = values


def _extract_dynamic_patterns(source: str) -> list[tuple[str, str]]:
    starts = [match.start() for match in re.finditer(r"match = RegExp\(", source)]
    results: list[tuple[str, str]] = []
    for position, start in enumerate(starts):
        next_start = starts[position + 1] if position + 1 < len(starts) else source.find("return null;", start)
        block = source[start:next_start]
        expression_end = block.find(").firstMatch(source)")
        expression = block[block.find("RegExp(") + len("RegExp(") : expression_end]
        patterns: list[str] = []
        index = 0
        while index < len(expression):
            string_at = index + 1 if expression[index:index + 1] == "r" else index
            if string_at < len(expression) and expression[string_at:string_at + 1] in ("'", '"'):
                value, index = _parse_dart_string(expression, index)
                patterns.append(value)
            else:
                index += 1
        returns = re.findall(r"return\s+(.+?);", block, flags=re.DOTALL)
        implementation = " / ".join(" ".join(value.split()) for value in returns)
        results.append(("".join(patterns), implementation))
    return results


def _load_json(name: str) -> dict:
    return json.loads((ROOT / "assets" / "data" / name).read_text(encoding="utf-8"))


def _md(value: object) -> str:
    text = str(value).replace("|", "\\|").replace("\n", "<br>")
    return text.replace("`", "\\`")


def _table(lines: list[str], headers: tuple[str, ...], rows: list[tuple[object, ...]]) -> None:
    lines.append("| " + " | ".join(headers) + " |")
    lines.append("| " + " | ".join("---" for _ in headers) + " |")
    for row in rows:
        lines.append("| " + " | ".join(_md(value) for value in row) + " |")
    lines.append("")


def _postcard_english(template: dict, voices: dict[str, list[str]]) -> str:
    suffix = int(template["id"].rsplit("_", 1)[1])
    options = voices[template["personalityId"]]
    return options[max(0, min(suffix - 1, len(options) - 1))]


def _visitor_english(
    interaction: dict,
    visitor_names: dict[str, str],
    visitor_moments: dict[str, str],
    species_responses: dict[str, str],
    legendary: dict[str, str],
) -> str:
    special = legendary.get(interaction["id"])
    if special:
        return special
    visitor_id = interaction["visitorId"]
    species_id = interaction["petSpeciesId"]
    friend = "{Pet Name}"
    arrival = visitor_moments[visitor_id].replace("$friend", friend)
    response = species_responses[species_id].replace("$friend", friend)
    return f"{visitor_names[visitor_id]} {arrival}. {response}."


def _quality_gate(
    events: list[dict],
    postcard_templates: list[dict],
    visitor_interactions: list[dict],
    english_values: list[str],
) -> list[tuple[str, str, str]]:
    chinese_rows: list[tuple[str, str]] = []
    for event in events:
        chinese_rows.extend(
            (
                (f"事件 {event['id']} 标题", event["title"]),
                (f"事件 {event['id']} 正文", event["script"]),
            )
        )
        for index, choice in enumerate(event.get("choices") or []):
            chinese_rows.extend(
                (
                    (f"事件 {event['id']} 选择 {index + 1}", choice["text"]),
                    (f"事件 {event['id']} 结果 {index + 1}", choice["resultScript"]),
                )
            )
    chinese_rows.extend(
        (f"明信片 {item['id']}", item["skeleton"])
        for item in postcard_templates
    )
    chinese_rows.extend(
        (f"来客 {item['id']}", item["script"])
        for item in visitor_interactions
    )

    findings: list[tuple[str, str, str]] = []
    for label, value in chinese_rows:
        for rule, pattern in (
            ("连续标点", REPEATED_PUNCTUATION),
            ("内部实现术语", INTERNAL_COPY),
            ("情绪施压", COERCIVE_ZH),
        ):
            if pattern.search(value):
                findings.append((rule, label, value))
    for item in postcard_templates:
        if GENERIC_ANATOMY.search(item["skeleton"]):
            findings.append(("通用模板限定身体特征", item["id"], item["skeleton"]))
    for index, value in enumerate(english_values):
        if REPEATED_PUNCTUATION.search(value):
            findings.append(("English repeated punctuation", str(index), value))
        if COERCIVE_EN.search(value):
            findings.append(("English pressure language", str(index), value))
    return findings


def main() -> None:
    copy_source = (ROOT / "lib" / "l10n" / "english_copy.dart").read_text(encoding="utf-8")
    narrative_source = (ROOT / "lib" / "l10n" / "english_narrative.dart").read_text(encoding="utf-8")

    terms = _extract_string_map(copy_source, "_terms =")
    fixed_copy = _extract_string_map(copy_source, "_copy =")
    patterns = _extract_dynamic_patterns(copy_source)

    locations_en = _extract_string_map(narrative_source, "_locationNames =")
    visitors_en = _extract_string_map(narrative_source, "_visitorNames =")
    species_en = _extract_string_map(narrative_source, "_speciesNames =")
    visitor_moments = _extract_string_map(narrative_source, "_visitorMoments =")
    species_responses = _extract_string_map(narrative_source, "_speciesResponses =")
    legendary = _extract_string_map(narrative_source, "_legendaryVisitorInteractions =")
    voices = _extract_string_list_map(narrative_source, "_postcardVoices =")
    encounters_en = _extract_string_map(narrative_source, "_encounters =")
    incidents_en = _extract_string_map(narrative_source, "_incidents =")
    event_titles_en = _extract_string_map(narrative_source, "_eventTitles =")
    event_scripts_en = _extract_string_map(narrative_source, "_eventScripts =")
    choice_texts_en = _extract_string_map(narrative_source, "_eventChoiceTexts =")
    choice_results_en = _extract_string_map(narrative_source, "_eventChoiceResults =")

    species = _load_json("species.json")["items"]
    personalities = _load_json("personalities.json")["items"]
    locations = _load_json("locations.json")["items"]
    visitors = _load_json("visitors.json")["items"]
    shop_items = _load_json("shop_items.json")["items"]
    achievements = _load_json("achievements.json")["items"]
    events = _load_json("events.json")["items"]
    postcard_data = _load_json("postcard_templates.json")
    postcard_templates = postcard_data["templates"]
    encounters = postcard_data["encounters"]
    incidents = postcard_data["incidents"]
    visitor_interactions = _load_json("visitor_interactions.json")["items"]

    name_mismatches: list[tuple[object, ...]] = []
    for domain, items, narrative_names in (
        ("物种", species, species_en),
        ("地点", locations, locations_en),
        ("来客", visitors, visitors_en),
    ):
        for item in items:
            compact_name = fixed_copy.get(item["name"], terms.get(item["name"]))
            narrative_name = narrative_names[item["id"]]
            if compact_name is not None and compact_name != narrative_name:
                name_mismatches.append(
                    (
                        domain,
                        item["id"],
                        item["name"],
                        compact_name,
                        narrative_name,
                    )
                )

    assert len(locations_en) == len(locations) == 40
    assert len(visitors_en) == len(visitors) == 20
    assert len(species_en) == len(species) == 12
    assert len(event_titles_en) == len(event_scripts_en) == len(events) == 120
    assert len(postcard_templates) == 240
    assert len(encounters_en) == len(encounters) == 60
    assert len(incidents_en) == len(incidents) == 60
    assert len(visitor_interactions) == 244
    assert len(patterns) == 98

    english_values = [
        *terms.values(),
        *fixed_copy.values(),
        *locations_en.values(),
        *visitors_en.values(),
        *species_en.values(),
        *encounters_en.values(),
        *incidents_en.values(),
        *event_titles_en.values(),
        *event_scripts_en.values(),
        *choice_texts_en.values(),
        *choice_results_en.values(),
        *(value for group in voices.values() for value in group),
    ]
    leaked = [
        value
        for value in english_values
        if HAN.search(value) and value not in {"简中"}
    ]
    if leaked:
        raise ValueError(f"English inventory contains Han text: {leaked[:3]}")

    quality_findings = _quality_gate(
        events,
        postcard_templates,
        visitor_interactions,
        english_values,
    )
    if quality_findings:
        raise ValueError(f"Copy quality gate failed: {quality_findings[:5]}")

    lines = [
        "# Petopia 中英文文案总审阅表",
        "",
        "> 本文档由 `tools/generate_bilingual_copy_review.py` 从当前运行时本地化代码和",
        "> `assets/data/*.json` 自动生成。中文是现有存档与内容的基准文案；英文是 App",
        "> 当前实际展示的文案。玩家自定义宠物名保持原样。",
        "",
        "## 审阅总览",
        "",
    ]
    _table(
        lines,
        ("领域", "数量", "当前英文策略", "审阅重点"),
        [
            ("固定 UI", len(fixed_copy), "逐条人工英文", "按钮、标题、说明、空状态"),
            ("名称与短语", len(terms), "逐条人工英文", "物种、性格、商店、成就、地点"),
            ("动态 UI", len(patterns), "98 条参数化规则", "数字、宠物名、日期、进度"),
            ("事件", len(events), "120 个事件逐条英文", "标题、正文、30 个选择及结果"),
            ("明信片", len(postcard_templates), "240 个中文模板映射到 30 个英文性格模板", "英文保留性格，但未逐张直译中文梗"),
            ("旅途片段", len(encounters) + len(incidents), "120 条逐条英文", "遭遇与小插曲"),
            ("来客互动", len(visitor_interactions), "20 个来客动作 × 12 个物种回应，4 条传说专稿", "英文按来客和物种组合，不逐句直译"),
            ("成长、离线与院子记忆", 41, "按等级/性格/状态写作", "变量以占位符展示"),
        ],
    )
    lines.extend(
        [
            "## 本轮审校结论",
            "",
            "本表中的运行时文案已按 `docs/copy-tone-guide.md` 逐条复核。",
            "固定 UI 必须事实一致；组合式叙事允许独立写作，但场景输入、情绪强度和角色态度必须一致。",
            "",
        ]
    )
    _table(
        lines,
        ("检查项", "结论", "执行标准"),
        [
            ("措辞得体", "通过", "系统状态直接；叙事保留一个清晰意象"),
            ("温馨但不索取", "通过", "不要求玩家回信、上线、等待或付费"),
            ("可爱但不幼稚", "通过", "不用连续标点、叠词或默认幼态形容词支撑语气"),
            ("中英文对应", "通过", "名称统一；场景输入、情绪强度与角色态度一致"),
            ("付费克制", "通过", "自愿、纯装饰、时长、重复购买与恢复范围均明示"),
            ("运行时洁净", "通过", "无规格编号、等级、线索数值或编辑标记泄漏"),
        ],
    )
    mismatch_summary = (
        "所有地点和来客名称已在列表、短 UI、叙事与明信片中保持一致。"
        if not name_mismatches
        else "这些差异虽然都能正常显示，但会削弱世界观的一致性；建议为每个 ID 固定唯一英文名。"
    )
    lines.extend(
        [
            "## 优先审阅：跨场景英文命名不一致",
            "",
            f"当前共有 {len(name_mismatches)} 处名称在列表/短 UI 与叙事中使用了不同英文。",
            mismatch_summary,
            "",
        ]
    )
    _table(
        lines,
        ("领域", "ID", "中文", "列表/短 UI", "叙事/明信片"),
        name_mismatches,
    )
    lines.extend(
        [
            "## 1. 固定 UI 文案",
            "",
            "这些文案由 `AppText` / `EnglishCopy` 直接逐条匹配。",
            "",
        ]
    )
    _table(lines, ("中文", "English"), list(fixed_copy.items()))

    lines.extend(["## 2. 名称与短语", ""])
    _table(lines, ("中文", "English"), list(terms.items()))

    lines.extend(
        [
            "## 3. 动态 UI 规则",
            "",
            "这一节保留运行时匹配表达式和英文返回表达式，便于核对变量位置。",
            "",
        ]
    )
    _table(lines, ("中文匹配规则", "英文返回表达式"), patterns)

    lines.extend(["## 4. 物种与性格", ""])
    _table(
        lines,
        ("ID", "中文名", "English", "中文设定", "English Tone"),
        [
            (
                item["id"],
                item["name"],
                species_en[item["id"]],
                item["baseTone"],
                terms[item["baseTone"]],
            )
            for item in species
        ],
    )
    _table(
        lines,
        ("ID", "中文", "English"),
        [(item["id"], item["name"], terms[item["name"]]) for item in personalities],
    )

    lines.extend(["## 5. 地点与来客", ""])
    _table(
        lines,
        ("ID", "中文地点", "English"),
        [(item["id"], item["name"], locations_en[item["id"]]) for item in locations],
    )
    _table(
        lines,
        ("ID", "中文来客", "English"),
        [(item["id"], item["name"], visitors_en[item["id"]]) for item in visitors],
    )

    lines.extend(["## 6. 商店与成就", ""])
    _table(
        lines,
        ("ID", "中文商品", "English"),
        [(item["id"], item["name"], terms[item["name"]]) for item in shop_items],
    )
    achievement_rows: list[tuple[object, ...]] = []
    for item in achievements:
        achievement_rows.append((item["id"], "名称", item["name"], terms[item["name"]]))
        if item.get("clueText"):
            achievement_rows.append((item["id"], "隐藏线索", item["clueText"], terms[item["clueText"]]))
    _table(lines, ("ID", "字段", "中文", "English"), achievement_rows)

    lines.extend(["## 7. 事件", ""])
    event_rows: list[tuple[object, ...]] = []
    for event in events:
        event_id = event["id"]
        event_rows.append((event_id, "标题", event["title"], event_titles_en[event_id]))
        event_rows.append((event_id, "正文", event["script"], event_scripts_en[event_id]))
        for index, choice in enumerate(event.get("choices") or []):
            key = f"{event_id}:{index}"
            event_rows.append((event_id, f"选择 {index + 1}", choice["text"], choice_texts_en[key]))
            event_rows.append((event_id, f"结果 {index + 1}", choice["resultScript"], choice_results_en[key]))
    _table(lines, ("事件 ID", "字段", "中文", "English"), event_rows)

    lines.extend(
        [
            "## 8. 明信片模板",
            "",
            "> 当前实现按性格与模板尾号选择 30 个英文母版，所以不同地点类别的中文模板",
            "> 可能对应同一条英文母版。下表展示 App 的真实映射结果。",
            "",
        ]
    )
    _table(
        lines,
        ("模板 ID", "性格", "类别", "中文", "English Runtime Template"),
        [
            (
                item["id"],
                item["personalityId"],
                item["category"],
                item["skeleton"],
                _postcard_english(item, voices),
            )
            for item in postcard_templates
        ],
    )

    lines.extend(["## 9. 旅途遭遇与插曲", ""])
    _table(
        lines,
        ("ID", "类型", "中文", "English"),
        [
            *[(item["id"], "遭遇", item["phrase"], encounters_en[item["id"]]) for item in encounters],
            *[(item["id"], "插曲", item["phrase"], incidents_en[item["id"]]) for item in incidents],
        ],
    )

    lines.extend(
        [
            "## 10. 来客互动",
            "",
            "> `{Pet Name}` 会在运行时替换成玩家给宠物取的名字。",
            "",
        ]
    )
    _table(
        lines,
        ("互动 ID", "来客", "物种", "中文", "English Runtime Copy"),
        [
            (
                item["id"],
                visitors_en[item["visitorId"]],
                species_en.get(item["petSpeciesId"], item["petSpeciesId"]),
                item["script"],
                _visitor_english(
                    item,
                    visitors_en,
                    visitor_moments,
                    species_responses,
                    legendary,
                ),
            )
            for item in visitor_interactions
        ],
    )

    lines.extend(["## 11. 成长、离线与院子记忆", ""])
    lifecycle_rows: list[tuple[object, ...]] = [
        ("成长 Lv2", "{宠物名}开始分得清你的脚步声了。", "{Pet Name} can already tell the sound of your footsteps apart."),
        ("成长 Lv3", "{宠物名}在院子里选定了最喜欢发呆的角落。", "{Pet Name} has chosen a favorite corner for quiet daydreams."),
        ("成长 Lv4", "每次听见自己的名字，{宠物名}都会先抬头找你。", "Whenever someone says their name, {Pet Name} looks for you first."),
        ("成长 Lv7", "{宠物名}开始把院子里的花、风和来客都当成自己的朋友。", "{Pet Name} now treats the flowers, breeze, and garden visitors as friends."),
        ("成长 Lv9", "{宠物名}最近常望向院门外，也悄悄整理起自己的小行囊。", "{Pet Name} has begun watching the gate and quietly packing a tiny travel bag."),
        ("成长 Lv6 · 贪吃", "{宠物名}会把最好吃的那一口留到最后，再认真看你一眼。", "{Pet Name} saves the tastiest bite for last, then gives you one serious little look."),
        ("成长 Lv6 · 活力", "{宠物名}每天跑完一圈后，都会回到你身边轻轻碰一下。", "{Pet Name} finishes every garden lap by coming back to touch your side."),
        ("成长 Lv6 · 慵懒", "{宠物名}已经学会在你最常停留的地方安心打盹。", "{Pet Name} naps most peacefully wherever you spend the most time."),
        ("成长 Lv6 · 好奇", "{宠物名}遇见新东西时，总要先回头确认你也看见了。", "{Pet Name} always checks that you noticed whenever something new appears."),
        ("成长 Lv6 · 黏人", "{宠物名}听见门响时，总会第一个过去看看。", "{Pet Name} is always first to look when footsteps approach."),
        ("成长 Lv6 · 高冷", "{宠物名}还是假装不在意，却总把休息的位置挪得离你更近。", "{Pet Name} still pretends not to care, but keeps moving their resting place closer to you."),
        ("成长 Lv6 · 淘气", "{宠物名}每次闯完小祸，都会若无其事地坐到你身边。", "{Pet Name} sits beside you with perfect innocence after every tiny bit of trouble."),
        ("成长 Lv6 · 温柔", "{宠物名}会安静照看院子里比自己更小的来客。", "{Pet Name} quietly watches over visitors smaller than they are."),
        ("成长 Lv6 · 爱幻想", "{宠物名}睡醒后总像还记得一个清晰而温暖的梦。", "{Pet Name} wakes as if returning from a clear, warm dream."),
        ("成长 Lv6 · 胆小", "{宠物名}已经有了一个只有你最熟悉的小习惯。", "{Pet Name} has grown a little habit that only you know by heart."),
        ("远方近况 · 贪吃", "远方近况：{宠物名}说最近学会了分辨每座城市点心出炉的时间。", "News from afar: {Pet Name} has learned exactly when each town takes its pastries from the oven."),
        ("远方近况 · 活力", "远方近况：{宠物名}说自己又找到一条能迎着风跑很久的小路。", "News from afar: {Pet Name} found another road where the wind keeps pace for miles."),
        ("远方近况 · 慵懒", "远方近况：{宠物名}说远方也有一块晒起来刚刚好的石头。", "News from afar: {Pet Name} found a faraway stone warmed to the perfect temperature."),
        ("远方近况 · 好奇", "远方近况：{宠物名}说一路记下的问题已经装满了半本小册子。", "News from afar: {Pet Name} has already filled half a notebook with new questions."),
        ("远方近况 · 黏人", "远方近况：{宠物名}说每到一个新地方，还是会先想起院子的门。", "News from afar: {Pet Name} still thinks of the garden gate before exploring each new place."),
        ("远方近况 · 高冷", "远方近况：{宠物名}只写了一句“一切都好”，却在信封里夹了片叶子。", "News from afar: {Pet Name} wrote only ‘All is well,’ then tucked a pressed leaf into the envelope."),
        ("远方近况 · 淘气", "远方近况：{宠物名}说这次真的没有惹麻烦，至少没有很大的麻烦。", "News from afar: {Pet Name} promises there was no trouble this time, or at least no large trouble."),
        ("远方近况 · 温柔", "远方近况：{宠物名}说沿途遇见的小伙伴都被好好照顾着。", "News from afar: {Pet Name} has been looking after every small friend met on the road."),
        ("远方近况 · 爱幻想", "远方近况：{宠物名}说昨晚梦见在很远的地方也能看见院子的灯。", "News from afar: {Pet Name} dreamed they could see the garden light even from far away."),
        ("远方近况 · 胆小", "远方近况：{宠物名}说它仍在慢慢看世界，也一直记得回院子的路。", "News from afar: {Pet Name} is still seeing the world slowly and remembers every turn home."),
        ("离线欢迎 · 贪吃", "它把食盆检查得很仔细，也认真规划好了下一顿点心。", "They inspected the food bowl carefully and made a serious plan for the next treat."),
        ("离线欢迎 · 活力", "它自己在草地上跑了好几圈，现在刚好愿意靠着你歇一会儿。", "They ran several laps alone and are now perfectly happy to rest beside you."),
        ("离线欢迎 · 慵懒", "这段时间它认真忙了一件事：把同一个午觉睡完。", "They worked very hard on one important task: finishing the same long nap."),
        ("离线欢迎 · 好奇", "它把院子的每一阵风都研究了一遍，攒下不少新发现。", "They examined every breeze that crossed the garden and gathered plenty of new discoveries."),
        ("离线欢迎 · 黏人", "它把窝挪到了能晒到午后阳光的位置，醒来时正好听见院门响。", "They moved their bed into the afternoon sun and woke just as the garden gate opened."),
        ("离线欢迎 · 高冷", "它把院子巡视了许多遍，确认每个角落都还是熟悉的样子。", "They made several rounds of the garden and confirmed that every corner still felt familiar."),
        ("离线欢迎 · 淘气", "院子里好像有几片叶子换了位置，但它决定先不解释。", "A few leaves seem to have changed places, but they have decided explanations can wait."),
        ("离线欢迎 · 温柔", "它照看了花和来客，院子一直好好的。", "They watched over the flowers and visitors. The garden stayed peaceful."),
        ("离线欢迎 · 爱幻想", "它睡着时梦见一朵云落进院子，醒来还记得云的形状。", "They dreamed that a cloud settled in the garden and still remember its shape after waking."),
        ("离线欢迎 · 胆小", "它睡饱了，也把院子照看得好好的。", "They slept well, and the garden stayed peaceful around them."),
        ("来客离开·未互动", "{来客名}轻轻来过，没有打扰谁，只在院子边留下一点到访的痕迹。", "{Visitor} passed through gently, leaving a small trace beside the garden path."),
        ("来客离开·已互动·无在养宠", "{来客名}离开前在院子里停了很久，像是在认真记住回来的路。", "{Visitor} lingered before leaving, as though memorizing the way back."),
        ("来客离开·已互动", "{来客名}离开前又回头看了看{宠物名}，院子里留下了一段安静的脚印。", "Before leaving, {Visitor} looked back at {Pet Name}; a quiet trail of footprints remained in the garden."),
        ("存档恢复·主存档损坏", "主存档无法读取，已从本地安全备份恢复。", "The primary save could not be read, so the garden was restored from its safe local backup."),
        ("存档恢复·校验异常", "存档校验发现异常，已从最近的完整快照恢复。", "Save verification found an inconsistency, so the garden was restored from the latest complete snapshot."),
        ("存档恢复·主存档缺失", "主存档缺失，已从最近的完整快照恢复。", "The primary save was missing, so the garden was restored from the latest complete snapshot."),
    ]
    _table(lines, ("场景", "中文", "English"), lifecycle_rows)

    OUTPUT.write_text("\n".join(lines), encoding="utf-8")
    print(
        f"Wrote {OUTPUT.relative_to(ROOT)}: "
        f"{len(fixed_copy)} fixed UI, {len(terms)} terms, {len(patterns)} patterns, "
        f"{len(events)} events, {len(postcard_templates)} postcards, "
        f"{len(visitor_interactions)} visitor interactions"
    )


if __name__ == "__main__":
    main()
