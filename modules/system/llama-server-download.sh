#!/usr/bin/env bash
set -euo pipefail

# DeepSeek-Coder-V2-Lite Model Download Script
# Usage: bash download-model.sh
# This will download IQ2_XS quantization (~5.4GB) to /var/lib/llama-models/

MODEL_URL="https://huggingface.co/mradermacher/DeepSeek-Coder-V2-Lite-Instruct-GGUF/resolve/main/DeepSeek-Coder-V2-Lite-Instruct.IQ2_XS.gguf"
MODEL_PATH="/var/lib/llama-models/DeepSeek-Coder-V2-Lite-Instruct.IQ2_XS.gguf"
MODEL_SIZE_GB=5.4

echo "📦 DeepSeek-Coder-V2-Lite Model Download"
echo "==========================================="
echo ""
echo "Model: DeepSeek-Coder-V2-Lite-Instruct"
echo "Quantization: IQ2_XS"
echo "Size: ~${MODEL_SIZE_GB}GB"
echo "Target: ${MODEL_PATH}"
echo ""

# Create directory if not exists
if [ ! -d "$(dirname "$MODEL_PATH")" ]; then
    echo "📁 Creating directory: $(dirname "$MODEL_PATH")"
    sudo mkdir -p "$(dirname "$MODEL_PATH")"
fi

# Check if file exists
if [ -f "$MODEL_PATH" ]; then
    echo "✅ Model already exists: $MODEL_PATH"
    ls -lh "$MODEL_PATH"
    exit 0
fi

# Download using curl with progress bar
echo "⬇️  Downloading model from Hugging Face..."
echo "This may take 10-30 minutes depending on connection speed."
echo ""

sudo -u root bash -c "curl -L --progress-bar '$MODEL_URL' -o '$MODEL_PATH'" || {
    echo "❌ Download failed. Check your internet connection and try again."
    exit 1
}

# Verify file exists and has reasonable size
if [ -f "$MODEL_PATH" ]; then
    FILE_SIZE=$(stat -f%z "$MODEL_PATH" 2>/dev/null || stat -c%s "$MODEL_PATH" 2>/dev/null || echo "unknown")
    if command -v numfmt &> /dev/null; then
        FILE_SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B $FILE_SIZE 2>/dev/null || echo "~5.4GB")
    else
        FILE_SIZE_HUMAN="~5.4GB"
    fi
    echo ""
    echo "✅ Download complete!"
    echo "📊 File size: ${FILE_SIZE_HUMAN}"
    ls -lh "$MODEL_PATH"
else
    echo "❌ Download failed - file not created."
    exit 1
fi

echo ""
echo "✅ Model ready for inference!"
echo ""
echo "Next steps:"
echo "1. Apply NixOS config: sudo nixos-rebuild switch --flake /etc/nixos#nixlensk323"
echo "2. Start llama-server: systemctl start llama-server"
echo "3. Check status: systemctl status llama-server"
echo "4. Test API: curl http://localhost:8080/completions -X POST -d '{...}'"
echo ""
