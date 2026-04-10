#!/usr/bin/env bash

# DeepSeek-Coder-V2-Lite Quick Start Script
# Автоматизирует все шаги установки для nixlensk323

set -euo pipefail

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  DeepSeek-Coder-V2-Lite Quick Start (nixlensk323)            ║"
echo "║  AMD Vega 56 + llama.cpp + ROCm                              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

STEP=1

# ────────────────────────────────────────────────────────────────
# Step 1: Verify prerequisites
# ────────────────────────────────────────────────────────────────
echo "[$STEP/6] Verifying prerequisites..."
((STEP++))

if [ ! -f /etc/nixos/flake.nix ]; then
    echo "❌ /etc/nixos/flake.nix not found"
    exit 1
fi

if ! command -v sudo &> /dev/null; then
    echo "❌ sudo not found"
    exit 1
fi

echo "✓ Prerequisites OK"
echo ""

# ────────────────────────────────────────────────────────────────
# Step 2: Apply NixOS config
# ────────────────────────────────────────────────────────────────
echo "[$STEP/6] Applying NixOS configuration..."
echo "        (installs ROCm, llama-cpp-rocm, enables service)"
((STEP++))

if grep -q "services.llama-server" /etc/nixos/hosts/nixlensk323/configuration.nix; then
    echo "✓ Config already updated"
    
    read -p "Rebuild system now? (requires sudo password) [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Building NixOS config..."
        sudo /run/current-system/sw/bin/nixos-rebuild switch --flake /etc/nixos#nixlensk323 2>&1 | tail -20
        echo "✓ System rebuilt"
    else
        echo "⚠️  Skipped rebuild. Run manually:"
        echo "   sudo nixos-rebuild switch --flake /etc/nixos#nixlensk323"
        echo ""
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
else
    echo "❌ Config not found. Apply manually:"
    echo "   See /etc/nixos/.sisyphus/plans/deepseek-vega56.md"
    exit 1
fi

echo ""

# ────────────────────────────────────────────────────────────────
# Step 3: Download model
# ────────────────────────────────────────────────────────────────
echo "[$STEP/6] Downloading DeepSeek-Coder-V2-Lite model..."
echo "        (~5.4GB, may take 10-30 minutes)"
((STEP++))

MODEL_PATH="/var/lib/llama-models/DeepSeek-Coder-V2-Lite-Instruct.IQ2_XS.gguf"

if [ -f "$MODEL_PATH" ]; then
    echo "✓ Model already downloaded"
    ls -lh "$MODEL_PATH"
else
    bash /etc/nixos/modules/system/llama-server-download.sh
fi

echo ""

# ────────────────────────────────────────────────────────────────
# Step 4: Start service
# ────────────────────────────────────────────────────────────────
echo "[$STEP/6] Starting llama-server service..."
((STEP++))

if systemctl is-active --quiet llama-server; then
    echo "✓ Service already running"
else
    echo "Starting service..."
    sudo systemctl start llama-server
    sleep 3
    
    if systemctl is-active --quiet llama-server; then
        echo "✓ Service started"
    else
        echo "❌ Service failed to start"
        echo "   Check logs: journalctl -u llama-server -n 50"
        exit 1
    fi
fi

echo ""

# ────────────────────────────────────────────────────────────────
# Step 5: Run tests
# ────────────────────────────────────────────────────────────────
echo "[$STEP/6] Running validation tests..."
((STEP++))

bash /etc/nixos/modules/system/llama-server-test.sh

echo ""

# ────────────────────────────────────────────────────────────────
# Step 6: Integration instructions
# ────────────────────────────────────────────────────────────────
echo "[$STEP/6] OpenCode Integration Setup"
((STEP++))

echo ""
echo "✅ DEPLOYMENT COMPLETE!"
echo ""
echo "Next: Configure OpenCode"
echo "───────────────────────────"
echo ""
echo "1. Open OpenCode settings"
echo "2. Navigate to: LLM Provider → Custom API"
echo "3. Configure:"
echo "   - Endpoint: http://localhost:8080"
echo "   - Model: deepseek-coder-v2-lite"
echo "   - Max tokens: 2048"
echo "4. Test connection"
echo ""
echo "For detailed instructions, see:"
echo "   /etc/nixos/LLAMA_OPENCODE_INTEGRATION.md"
echo ""
echo "Useful commands:"
echo "   systemctl status llama-server"
echo "   journalctl -u llama-server -f"
echo "   rocm-smi  (GPU status)"
echo ""
