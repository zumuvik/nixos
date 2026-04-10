#!/usr/bin/env bash
set -euo pipefail

# Phase 5: Testing & GPU Validation
# Run this AFTER: sudo nixos-rebuild switch && model download && systemctl start llama-server

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 5: Testing & GPU Validation (llama-cpp-rocm)       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# ────────────────────────────────────────────────────────────────
# 1. ROCm/GPU Detection
# ────────────────────────────────────────────────────────────────
echo "🔍 [TEST 1] ROCm GPU Detection"
echo "─────────────────────────────────────"

if ! command -v rocm-smi &> /dev/null; then
    echo "❌ rocm-smi not found. Did rebuild complete?"
    exit 1
fi

echo "✓ rocm-smi found"
echo ""
echo "GPU Info:"
rocm-smi --showproductname || echo "⚠️  rocm-smi --showproductname failed"
echo ""

if rocm-smi 2>&1 | grep -q "gfx900\|Vega"; then
    echo "✅ GPU detected: Vega 56 (gfx900)"
else
    echo "⚠️  GPU not detected or wrong architecture"
fi

echo ""

# ────────────────────────────────────────────────────────────────
# 2. llama-cpp-rocm Binary Check
# ────────────────────────────────────────────────────────────────
echo "🔍 [TEST 2] llama-cpp-rocm Binary"
echo "─────────────────────────────────────"

if ! command -v llama-cpp-rocm &> /dev/null; then
    echo "❌ llama-cpp-rocm not found"
    exit 1
fi

echo "✓ llama-cpp-rocm found at: $(which llama-cpp-rocm)"
llama-cpp-rocm --version || echo "⚠️  Version check failed"
echo ""

# Check if compiled with GPU support
if llama-cpp-rocm --help 2>&1 | grep -q "gpu-layers\|rocm"; then
    echo "✅ llama-cpp-rocm compiled with GPU support"
else
    echo "⚠️  GPU support flags not visible in help"
fi

echo ""

# ────────────────────────────────────────────────────────────────
# 3. Model File Check
# ────────────────────────────────────────────────────────────────
echo "🔍 [TEST 3] Model File"
echo "─────────────────────────────────────"

MODEL_PATH="/var/lib/llama-models/DeepSeek-Coder-V2-Lite-Instruct.IQ2_XS.gguf"

if [ ! -f "$MODEL_PATH" ]; then
    echo "❌ Model not found: $MODEL_PATH"
    echo "   Run: bash /etc/nixos/modules/system/llama-server-download.sh"
    exit 1
fi

echo "✅ Model found"
MODEL_SIZE=$(ls -lh "$MODEL_PATH" | awk '{print $5}')
echo "   Size: ${MODEL_SIZE}"
echo ""

# ────────────────────────────────────────────────────────────────
# 4. Systemd Service Check
# ────────────────────────────────────────────────────────────────
echo "🔍 [TEST 4] Systemd Service Status"
echo "─────────────────────────────────────"

if systemctl is-active --quiet llama-server; then
    echo "✅ llama-server is running"
else
    echo "⚠️  llama-server is not running"
    echo "   Start with: sudo systemctl start llama-server"
fi

systemctl status llama-server --no-pager || true
echo ""

# ────────────────────────────────────────────────────────────────
# 5. HTTP Server Response
# ────────────────────────────────────────────────────────────────
echo "🔍 [TEST 5] HTTP API Response"
echo "─────────────────────────────────────"

sleep 2  # Wait for service to stabilize

if timeout 5 curl -s http://localhost:8080/ > /dev/null 2>&1; then
    echo "✅ API server responding on localhost:8080"
else
    echo "❌ API server not responding"
    echo "   Check: systemctl status llama-server"
    echo "          journalctl -u llama-server -n 50"
    exit 1
fi

echo ""

# ────────────────────────────────────────────────────────────────
# 6. Test Completion (with TTFT measurement)
# ────────────────────────────────────────────────────────────────
echo "🔍 [TEST 6] Model Inference (TTFT + tokens/sec)"
echo "─────────────────────────────────────────────────"
echo "   (This will take ~30 seconds on first run, model loading...)"
echo ""

START_TIME=$(date +%s.%N)

RESPONSE=$(timeout 120 curl -s http://localhost:8080/completions \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "def factorial(n):",
    "n_predict": 64,
    "temperature": 0.7,
    "top_p": 0.95
  }' || echo "{\"error\": \"timeout\"}")

END_TIME=$(date +%s.%N)
DURATION=$(echo "$END_TIME - $START_TIME" | bc)

echo "Response received in ${DURATION}s"
echo ""

if echo "$RESPONSE" | grep -q '"content"'; then
    echo "✅ Inference successful!"
    
    # Extract and show generated content
    CONTENT=$(echo "$RESPONSE" | grep -o '"content":"[^"]*"' | cut -d'"' -f4 | head -c 100)
    echo "   Generated (first 100 chars):"
    echo "   >>> $CONTENT"
    
    # Count tokens if available
    if echo "$RESPONSE" | grep -q '"tokens_predicted"'; then
        TOKENS=$(echo "$RESPONSE" | grep -o '"tokens_predicted":[0-9]*' | cut -d':' -f2)
        if [ -n "$TOKENS" ] && [ "$DURATION" != "0" ]; then
            TOKENS_PER_SEC=$(echo "scale=2; $TOKENS / $DURATION" | bc)
            echo "   Tokens: ${TOKENS} in ${DURATION}s → ${TOKENS_PER_SEC} tokens/sec"
        fi
    fi
else
    echo "⚠️  Inference failed or no content in response"
    echo "   Response: $RESPONSE" | head -c 200
fi

echo ""
echo ""

# ────────────────────────────────────────────────────────────────
# 7. Memory & GPU Load (ongoing)
# ────────────────────────────────────────────────────────────────
echo "🔍 [TEST 7] GPU Memory Usage (snapshot)"
echo "─────────────────────────────────────────"

if command -v rocm-smi &> /dev/null; then
    rocm-smi --showmeminfo || echo "⚠️  Memory info unavailable"
else
    echo "⚠️  rocm-smi not available"
fi

echo ""
echo ""

# ────────────────────────────────────────────────────────────────
# Final Summary
# ────────────────────────────────────────────────────────────────
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  PHASE 5 COMPLETE - Test Summary                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ If all tests passed:"
echo "   → Proceed to Phase 6: OpenCode Integration"
echo "   → Configure: localhost:8080 in OpenCode settings"
echo ""
echo "❌ If tests failed:"
echo "   → Check logs: journalctl -u llama-server -f"
echo "   → Verify GPU: rocm-smi"
echo "   → Rebuild if needed: sudo nixos-rebuild switch --flake /etc/nixos#nixleski323"
echo ""
