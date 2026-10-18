# openvino-converter

A simple script to batch convert `.safetensors` models to LCM-LoRA + OpenVINO IR format.  
`.safetensors` モデルを LCM-LoRA + OpenVINO IR形式へ一括変換するシンプルなスクリプトです。

## Prerequisites / 準備

Before running the script, make sure your virtual environment (`venv`) is activated and requirements are installed.  
スクリプトを実行する前に、仮想環境（`venv`）を有効化し、必要なライブラリをインストールしてください。

```bash
# Activate your venv (example)
source venv/bin/activate

# Install dependencies for your python scripts (e.g., optimum, openvino)
# pip install optimum[openvino] diffusers
```

Ensure `e_batch_openvino_convert.sh` and `lcm-convert.py` are in the same directory.  
`e_batch_openvino_convert.sh` と `lcm-convert.py` が同じフォルダ内にあることを確認してください。

## Usage / 使い方

1. Make the script executable:  
   スクリプトに実行権限を与えます。
   ```bash
   chmod +x e_batch_openvino_convert.sh
   ```

2. Run the script with input and output directories:  
   入力フォルダと出力先フォルダを指定して実行します。
   ```bash
   ./e_batch_openvino_convert.sh /path/to/safetensors_folder /path/to/output_folder
   ```

### Default Paths / 引数を省略した場合
If arguments are omitted, the script uses the following default paths:  
引数を省略した場合、以下のデフォルトパスが使用されます。

- **Input:** `$HOME/download/models`
- **Output:** `$HOME/fastsdcpu/openvino-models`

## Features / 主な機能

- **Batch Processing:** Automatically finds and converts all `.safetensors` files in the input directory. (一括自動変換)
- **Venv Check:** Warns you if the virtual environment is not activated. (venv有効化チェック)
- **Skip Existing:** Skips models that have already been successfully converted. (既存ファイルのスキップ機能)
- **Auto Cleanup:** Automatically cleans up intermediate snapshots after conversion to save disk space. (中間生成物の自動削除)
- **Logging:** Saves execution logs with timestamps (e.g., `batch_convert_YYYYMMDD_HHMMSS.log`). (タイムスタンプ付きログ保存)

## License / ライセンス

[MIT License](LICENSE)
