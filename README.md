# openvino-converter

A simple script to batch convert `.safetensors` models to LCM-LoRA + OpenVINO IR format.  
`.safetensors` モデルを LCM-LoRA + OpenVINO IR形式へ一括変換するシンプルなスクリプトです。

## ⚙️ Prerequisites / 準備

### Tested Environment / 動作確認済み環境
This script has been tested and verified with the following specific version combination to avoid build and compatibility issues.  
ビルドや互換性の問題を避けるため、以下の特定のバージョンの組み合わせで動作確認を行っています。

- **Python:** `3.11` *(Note: Python 3.14 caused build issues / 3.14ではビルドエラーが発生したため3.11を推奨)*
- **transformers:** `4.45.2`
- **diffusers:** `0.32.2`
- **accelerate:** `1.2.1`
- **optimum:** `1.23.3`
- **optimum-intel:** `1.20.0`
- **openvino / openvino-tokenizers:** `2024.6.0`
- **nncf:** `2.13.0`
- **peft:** *(Latest / バージョン指定なし)*

### Installation / インストール方法

1. Activate your virtual environment (`venv`) with Python 3.11.  
   Python 3.11の仮想環境（`venv`）を有効化します。
   ```bash
   source venv/bin/activate
   ```

2. Install the verified versions:  
   検証済みのバージョンを一括でインストールします。
   ```bash
   pip install transformers==4.45.2 diffusers==0.32.2 accelerate==1.2.1 optimum==1.23.3 optimum-intel==1.20.0 openvino==2024.6.0 openvino-tokenizers==2024.6.0 nncf==2.13.0 peft
   ```

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
