# Petopia future yard theme concepts

These five concepts are design candidates for a later paid or high-warmfluff release. They are not registered in the shop, bundled as runtime assets, or connected to gameplay in the current release.

| Slug | 中文名 | English name | Visual anchor | Suggested bonus | Scope status | Suggested price |
| --- | --- | --- | --- | --- | --- | --- |
| `cloudloft` | 云端花园 | Cloud Garden | 云海、漂浮岛、彩虹一角 | `bird +8%` | Reuse existing `bird` scope | 900 warmfluff or US$2.99 equivalent |
| `firefly_night` | 萤火夏夜 | Firefly Summer Night | 稻田、萤火、纱帐凉棚 | `nocturnal +8%` | Reuse existing `nocturnal` scope | 850 warmfluff or US$2.99 equivalent |
| `lantern_festival` | 灯笼新春 | Lantern New Year | 红灯笼、无文字红饰幅、薄雪 | `winter +8%` | New `winter` scope required during implementation | 900 warmfluff or US$3.99 equivalent |
| `deepsea_bubble` | 海底泡泡 | Deep Sea Bubbles | 泡泡穹顶、海底光柱、珍珠珊瑚 | None; visual-only theme | No scope required | 900 warmfluff or US$2.99 equivalent |
| `pumpkin_eve` | 南瓜灯夜 | Pumpkin Eve | 南瓜灯、枫叶、友善幽灵灯串 | `nocturnal +5%` | Reuse existing `nocturnal` scope | 800 warmfluff or US$2.99 equivalent |

## Concept files

- [`all-concepts.png`](all-concepts.png) - side-by-side review sheet
- [`cloudloft.png`](cloudloft.png)
- [`firefly_night.png`](firefly_night.png)
- [`lantern_festival.png`](lantern_festival.png)
- [`deepsea_bubble.png`](deepsea_bubble.png)
- [`pumpkin_eve.png`](pumpkin_eve.png)

## Production notes

- Every concept keeps the middle and lower 55% available for pets, visitors, bowls, and decoration slots.
- Defining landmarks stay in the upper preview band and narrow side edges.
- A production pass still requires matching day/night portrait and wide assets, placement regression, shop-preview validation, and runtime compression.
- Implementing `lantern_festival` later requires adding the `winter` scope to the visitor-bonus parser. This concept batch deliberately does not change that code.

## Provenance

- Generated on 2026-08-15 with OpenAI imagegen.
- Style reference: Petopia-owned `assets/art/samples/petopia-golden-v5-yard-main.png`.
- Third-party assets: none.
- The images contain no baked text, logos, UI, or watermarks.
