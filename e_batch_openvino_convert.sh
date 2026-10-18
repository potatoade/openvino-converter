#!/bin/bash
#
# batch_convert.sh
# 複数の .safetensors モデルを LCM-LoRA + OpenVINO 形式へ一括変換するスクリプト
#
# 使い方:
#   1. このファイルを lcm-openvino-converter フォルダの中に置く
#      (lcm-convert.py と同じ階層)
#   2. venv を有効化してから実行する
#        source venv/bin/activate
#        chmod +x batch_convert.sh
#        ./batch_convert.sh /path/to/safetensors_folder /path/to/output_folder
#
#   引数を省略すると、下のデフォルト値が使われます。

set -u  # 未定義変数の使用でエラーにする

# ── 設定 ─────────────────────────────────────────
INPUT_DIR="${1:-$HOME/download/models}"      # safetensorsが入っているフォルダ
OUTPUT_DIR="${2:-$HOME/fastsdcpu/openvino-models}"  # 変換結果を集めるフォルダ
LORA_SCALE="1.0"
LOG_FILE="./batch_convert_$(date +%Y%m%d_%H%M%S).log"
# ─────────────────────────────────────────────────

mkdir -p "$OUTPUT_DIR"

SUCCESS_LIST=()
FAIL_LIST=()

echo "=================================================="
echo " Starting conversion process"
echo " Input : $INPUT_DIR"
echo " Output: $OUTPUT_DIR"
echo " Log   : $LOG_FILE"
echo "=================================================="

# venvが有効化されているか簡易チェック
if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    echo "⚠️  Warning: venv is not activated."
    echo "   Run 'source venv/bin/activate' before running this script."
    read -p "   Continue anyway? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Cancelled."
        exit 1
    fi
fi

# 対象ファイルを配列に格納(スペースを含むファイル名にも対応)
shopt -s nullglob
FILES=("$INPUT_DIR"/*.safetensors)
shopt -u nullglob

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "❌ Error: No .safetensors files found in $INPUT_DIR."
    exit 1
fi

echo "Number of target models: ${#FILES[@]}"
echo ""

for FILE in "${FILES[@]}"; do
    BASENAME=$(basename "$FILE" .safetensors)
    # ファイル名をモデル名として使う(記号は安全な文字に置換)
    MODEL_NAME=$(echo "$BASENAME" | tr -c 'a-zA-Z0-9_-' '_')

    echo "=================================================="
    echo " processing: $BASENAME"
    echo "      model: $MODEL_NAME"
    echo "=================================================="

    STEP1_DIR="models--local--${MODEL_NAME}/snapshots/${MODEL_NAME}"
    FINAL_OUTPUT_DIR="${OUTPUT_DIR}/${MODEL_NAME}-openvino"

    # すでに変換済みならスキップ
    if [[ -d "$FINAL_OUTPUT_DIR" && -f "$FINAL_OUTPUT_DIR/model_index.json" ]]; then
        echo "⏭  Output files already exist. Skipping conversion: $FINAL_OUTPUT_DIR"
        SUCCESS_LIST+=("$BASENAME (Skipped: Already exists)")
        continue
    fi

    # ── ステップ1: LCM-LoRA焼き込み ──
    echo "--- step1: LCM-LoRA ---" | tee -a "$LOG_FILE"
    rm -rf "models--local--${MODEL_NAME}"  # 前回の中途半端な残骸を掃除

    python lcm-convert.py --no-half \
        --model "$FILE" \
        --name "$MODEL_NAME" \
        --lora-scale "$LORA_SCALE" \
        >> "$LOG_FILE" 2>&1

    if [[ $? -ne 0 || ! -d "$STEP1_DIR" ]]; then
        echo "❌ Failed at step 1: $BASENAME"
        FAIL_LIST+=("$BASENAME (Failed at step 1)")
        continue
    fi
    echo "✅ Step 1 complete"

    # ── ステップ2: OpenVINOへ変換 ──
    echo "--- step2: OpenVINO ---" | tee -a "$LOG_FILE"

    optimum-cli export openvino \
        --model "$STEP1_DIR" \
        --task text-to-image \
        --weight-format fp16 \
        "$FINAL_OUTPUT_DIR" \
        >> "$LOG_FILE" 2>&1

    if [[ $? -ne 0 || ! -f "$FINAL_OUTPUT_DIR/model_index.json" ]]; then
        echo "❌  Failed at step 2: $BASENAME"
        FAIL_LIST+=("$BASENAME ( Failed at step 2)")
        continue
    fi
    echo "✅ Step 2 complete → $FINAL_OUTPUT_DIR"

    SUCCESS_LIST+=("$BASENAME")

    # ステップ1の生成物は消しておく。残したい場合はこの行をコメントアウト
    rm -rf "models--local--${MODEL_NAME}"

    echo ""
done

echo "=================================================="
echo " All processing completed"
echo "=================================================="
echo ""
echo "✅ Successful / Skipped  (${#SUCCESS_LIST[@]}models):"
for m in "${SUCCESS_LIST[@]}"; do
    echo "   - $m"
done
echo ""
if [[ ${#FAIL_LIST[@]} -gt 0 ]]; then
    echo "❌ Failed (${#FAIL_LIST[@]}件):"
    for m in "${FAIL_LIST[@]}"; do
        echo "   - $m"
    done
    echo ""
    echo "Check log for details: $LOG_FILE"
else
    echo "ALL MODELS HAVE BEEN SUCCESSFULLY CONVERTED!"
fi
