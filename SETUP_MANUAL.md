# 🚀 DeepSeek-Coder-V2-Lite Setup (nixlensk323)

## Quick Setup (Manual Steps)

Все конфиги уже подготовлены в git. Выполните вручную:

### Step 1: Apply NixOS Configuration
```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixlensk323
```

⏱️ **Ожидание**: 3-10 минут (скачивание/сборка пакетов)

✅ **Проверка**: 
```bash
which rocm-smi
which llama-cpp-rocm
```

### Step 2: Download Model (~5.4GB)
```bash
bash /etc/nixos/modules/system/llama-server-download.sh
```

⏱️ **Ожидание**: 10-30 минут (зависит от интернета, 5.4GB)

✅ **Проверка**:
```bash
ls -lh /var/lib/llama-models/DeepSeek-Coder-V2-Lite-Instruct.IQ2_XS.gguf
```

### Step 3: Start Service
```bash
sudo systemctl start llama-server
sudo systemctl enable llama-server
```

✅ **Проверка**:
```bash
systemctl status llama-server
```

### Step 4: Run Tests
```bash
bash /etc/nixos/modules/system/llama-server-test.sh
```

Ожидается:
- ✅ GPU detected (rocm-smi)
- ✅ llama-cpp-rocm found
- ✅ Model file present
- ✅ Service running
- ✅ API responding on :8080
- ✅ First inference succeeds (cold start ~30 sec)

### Step 5: Verify GPU Usage
```bash
rocm-smi
# or during inference:
watch -n 0.5 'rocm-smi'
```

Expected: GPU memory increasing during inference

### Step 6: Test API Manually
```bash
curl http://localhost:8080/completions \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "def fibonacci(n):",
    "n_predict": 64,
    "temperature": 0.7
  }'
```

Expected response: JSON with `"content"` field containing generated Python code

---

## Troubleshooting

### "Cannot find nixos-rebuild"
```bash
sudo /run/current-system/sw/bin/nixos-rebuild switch --flake /etc/nixos#nixlensk323
```

### "rocm-smi: command not found"
Rebuild didn't complete or failed. Check:
```bash
sudo nixos-rebuild build --flake /etc/nixos#nixlensk323
journalctl -xe  # check for errors
```

### "llama-server service failed"
Check logs:
```bash
journalctl -u llama-server -n 50 -f
```

Common issues:
- Model file not found: Run Step 2
- Out of memory: Reduce `gpuLayers` in config or use smaller quant
- GPU not detected: Run `rocm-smi` to verify

### "API not responding"
```bash
curl -v http://localhost:8080/
journalctl -u llama-server | grep -i error
```

If service crashed, restart:
```bash
sudo systemctl restart llama-server
sleep 3
sudo systemctl status llama-server
```

---

## OpenCode Integration

Once API is responding on localhost:8080:

1. Open OpenCode settings
2. Go to: **LLM Provider** → **Custom API**
3. Set:
   - **Endpoint**: `http://localhost:8080`
   - **Model**: `deepseek-coder-v2-lite`
   - **Max tokens**: `2048`
4. Click **Test Connection**

See full docs: [`LLAMA_OPENCODE_INTEGRATION.md`](./LLAMA_OPENCODE_INTEGRATION.md)

---

## Performance Expectations

| Metric | Value |
|--------|-------|
| TTFT (cold start) | 20-30 sec |
| TTFT (warm) | 2-3 sec |
| Tokens/sec | 20-40 |
| Model VRAM | ~6.4GB (out of 8GB) |

---

## Config Files Reference

All changes in `/etc/nixos/`:

- `modules/system/llama-server.nix` - systemd service definition
- `hosts/nixlensk323/configuration.nix` - host-specific config
- `modules/system/llama-server-download.sh` - model download
- `modules/system/llama-server-test.sh` - validation test suite
- `.sisyphus/plans/deepseek-vega56.md` - full deployment plan
- `.sisyphus/drafts/deepseek-vega56.md` - research notes

---

## Useful Commands

```bash
# Service management
sudo systemctl start llama-server
sudo systemctl stop llama-server
sudo systemctl restart llama-server
sudo systemctl status llama-server
sudo systemctl enable llama-server

# Logs
journalctl -u llama-server -f  # follow
journalctl -u llama-server -n 100  # last 100 lines

# GPU info
rocm-smi
rocm-smi --showmeminfo
rocm-smi --showtemp

# Model info
ls -lh /var/lib/llama-models/

# Test API
curl http://localhost:8080/models
curl http://localhost:8080/completions -X POST -d '{"prompt":"test"}'

# Kill hung process
sudo pkill -f llama-cpp-rocm
```

---

**Done!** Your LLM inference setup is ready. 🎉
