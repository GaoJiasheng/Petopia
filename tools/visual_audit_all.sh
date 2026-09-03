#!/bin/zsh
# 全量视觉审计：所有主题 / 宠物 / 来客 / 动作 / 配饰摆放 / 界面 / 三语 / 四台设备六种配置。
# 产物落到桌面，按套件与设备分目录；每次 run 的 flutter 输出存 _logs/。
# stdout 只打 [start]/[done]/[FAIL] 三类行，供监控使用。
set -u
cd "$(dirname "$0")/.."
OUT="${PETOPIA_AUDIT_OUT:-$HOME/Desktop/petopia-visual-audit-2026-09-02}"
mkdir -p "$OUT/_logs"

typeset -A UDID
UDID[iphone69]=00701277-220E-4074-BCAF-245FE12A5253   # iPhone 17 Pro Max 440x956  紧凑
UDID[iphone61]=E35A99F1-F6C1-4BF8-8EED-018CDDB93917   # iPhone 17e      390x844  紧凑(最窄)
UDID[ipadmini]=7759EEF5-F257-4C08-BBE0-600B320B724E   # iPad mini       744x1133 中 / 横屏侧栏
UDID[ipad13]=ED7AC183-F9B7-4784-9DF3-C5394AB51952     # iPad Pro 13     1032x1376 宽 / 横屏超宽
typeset -A LAND_W LAND_H   # 横屏物理像素（逻辑尺寸 × 2）
LAND_W[ipad13]=2752;   LAND_H[ipad13]=2064
LAND_W[ipadmini]=2266; LAND_H[ipadmini]=1488

run_test() {  # run_test <label> <target> <outdir> <prefix> <device> <landscape 0/1> [extra --dart-define ...]
  local label=$1 target=$2 outdir=$3 prefix=$4 dev=$5 land=$6; shift 6
  mkdir -p "$outdir"
  local before=$(ls "$outdir" 2>/dev/null | wc -l | tr -d ' ')
  echo "[start] $label"
  local defs=(--dart-define=PETOPIA_VISUAL_DIR="$outdir" --dart-define=PETOPIA_CAPTURE_DIR="$outdir"
              --dart-define=PETOPIA_VISUAL_PREFIX="$prefix" --dart-define=PETOPIA_CAPTURE_PREFIX="$prefix")
  # 横屏：flutter test 下 setPreferredOrientations 不会转模拟器，改用 setSurfaceSize 强制横屏逻辑尺寸（像素）
  if [[ $land == 1 ]]; then
    defs+=(--dart-define=PETOPIA_VISUAL_LANDSCAPE=true
           --dart-define=PETOPIA_VISUAL_EXPECTED_WIDTH="${LAND_W[$dev]}"
           --dart-define=PETOPIA_VISUAL_EXPECTED_HEIGHT="${LAND_H[$dev]}")
  fi
  if grep -q "All tests passed" "$OUT/_logs/$label.log" 2>/dev/null; then
    echo "[skip] $label (already done)"; return
  fi
  if flutter test "$target" -d "${UDID[$dev]}" "${defs[@]}" "$@" > "$OUT/_logs/$label.log" 2>&1; then
    local after=$(ls "$outdir" | wc -l | tr -d ' ')
    echo "[done] $label +$((after-before)) files"
  else
    local after=$(ls "$outdir" 2>/dev/null | wc -l | tr -d ' ')
    echo "[FAIL] $label (+$((after-before)) files before failure) see _logs/$label.log"
  fi
}

run_drive() {  # run_drive <label> <target> <outdir> <prefix> <device> [extra --dart-define ...]
  local label=$1 target=$2 outdir=$3 prefix=$4 dev=$5; shift 5
  mkdir -p "$outdir"
  echo "[start] $label"
  rm -f /tmp/"$prefix"-*.png
  if flutter drive --driver=test_driver/integration_test.dart --target="$target" -d "${UDID[$dev]}" \
       --dart-define=PETOPIA_VISUAL_PREFIX="$prefix" --dart-define=PETOPIA_CAPTURE_PREFIX="$prefix" "$@" \
       > "$OUT/_logs/$label.log" 2>&1; then
    local n=$(ls /tmp/"$prefix"-*.png 2>/dev/null | wc -l | tr -d ' ')
    mv /tmp/"$prefix"-*.png "$outdir"/ 2>/dev/null
    echo "[done] $label +$n files"
  else
    echo "[FAIL] $label see _logs/$label.log"
  fi
}

YARD=integration_test/yard_home_visual_test.dart
UI=integration_test/english_ui_visual_test.dart
POST=integration_test/postcard_visual_test.dart

# 六种配置：<设备> <横屏>
CONFIGS=("iphone69 0" "ipad13 0" "ipad13 1" "ipadmini 0" "ipadmini 1" "iphone61 0")

for cfg in "${CONFIGS[@]}"; do
  dev=${cfg% *}; land=${cfg#* }; tag=$dev; [[ $land == 1 ]] && tag="$dev-land" || tag="$dev-port"
  run_test "01-themes-$tag"  $YARD "$OUT/01-yard-themes/$tag" yard $dev $land --dart-define=PETOPIA_VISUAL_ALL_THEMES=true
  run_test "02-states-$tag"  $YARD "$OUT/02-yard-states/$tag" yard $dev $land
  for lang in en zh-Hans zh-Hant; do
    run_test "08-ui-$lang-$tag" $UI "$OUT/08-ui/$lang/$tag" ui $dev $land --dart-define=PETOPIA_VISUAL_LANGUAGE=$lang
  done
done

# 目录级：iPhone 6.9 + iPad 13 竖屏
for dev in iphone69 ipad13; do
  run_test "03-pets-$dev"       $YARD "$OUT/03-pets/$dev"       yard $dev 0 --dart-define=PETOPIA_VISUAL_CATALOG=pets
  run_test "04-visitors-$dev"   $YARD "$OUT/04-visitors/$dev"   yard $dev 0 --dart-define=PETOPIA_VISUAL_CATALOG=visitors
  run_test "05-revisitors-$dev" $YARD "$OUT/05-revisitors/$dev" yard $dev 0 --dart-define=PETOPIA_VISUAL_CATALOG=revisitors
  run_test "09-postcards-$dev"  $POST "$OUT/09-postcards/$dev"  postcard $dev 0 --dart-define=PETOPIA_VISUAL_ALL_POSTCARDS=true --dart-define=PETOPIA_VISUAL_ALL_WEATHER=true
  run_drive "10-support-$dev" integration_test/support_visual_test.dart "$OUT/10-support/$dev" support $dev
done
run_test "06-luxury-iphone69"   $YARD "$OUT/06-luxury/iphone69"   yard iphone69 0 --dart-define=PETOPIA_VISUAL_ALL_LUXURY=true
run_test "06-luxury-ipad13-land" $YARD "$OUT/06-luxury/ipad13-land" yard ipad13 1 --dart-define=PETOPIA_VISUAL_ALL_LUXURY=true
# 动作：每物种 var01 stageC × 4 动作（全量 960 张由 audit_runtime_art 门禁覆盖，这里抽样）
run_test "07-actions-iphone69" $YARD "$OUT/07-actions/iphone69" yard iphone69 0 \
  --dart-define=PETOPIA_VISUAL_CATALOG=actions --dart-define=PETOPIA_VISUAL_ACTION_VARIANT=1 --dart-define=PETOPIA_VISUAL_ACTION_STAGE=c
# 配饰摆放回归（同时产出全配饰覆盖图）
for cfg in "iphone69 0" "ipadmini 0" "ipadmini 1" "ipad13 0" "ipad13 1" "iphone61 0"; do
  dev=${cfg% *}; land=${cfg#* }; [[ $land == 1 ]] && tag="$dev-land" || tag="$dev-port"
  run_test "11-placements-$tag" $YARD "$OUT/11-placements/$tag" yard $dev $land --dart-define=PETOPIA_VISUAL_PLACEMENTS=true
done
run_drive "12-localization-iphone69" integration_test/localization_visual_test.dart "$OUT/12-localization/iphone69" petopia-localization iphone69

echo "[ALL DONE] $(find "$OUT" -name '*.png' | wc -l | tr -d ' ') png total"
