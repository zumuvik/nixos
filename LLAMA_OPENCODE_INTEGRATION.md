# Phase 6: OpenCode Integration

После завершения Фазы 5 (тесты пройдены, llama-server работает) настройте OpenCode.

## Вариант A: OpenCode API Configuration (Рекомендуется)

1. **Убедитесь, что сервис слушает на доступном IP**

   Если OpenCode на **той же машине** (localhost):
   ```bash
   # Текущая конфиг в llama-server.nix: слушает 127.0.0.1:8080 ✓
   curl http://localhost:8080/completions -X POST -H "Content-Type: application/json" -d '{"prompt":"test"}'
   ```

   Если OpenCode на **другой машине** в сети:
   - Отредактируйте `/etc/nixos/modules/system/llama-server.nix`
   - Измените `--host 127.0.0.1` на `--host 0.0.0.0`
   - Запустите: `sudo nixos-rebuild switch --flake /etc/nixos#nixleski323`

2. **Получите IP адрес nixleski323**
   ```bash
   hostname -I  # или посмотрите в конфиге: IP = 192.168.x.x
   ```

3. **Конфигурируйте OpenCode**
   - Откройте OpenCode UI
   - Settings → LLM Provider → Custom API
   - **Endpoint**: `http://localhost:8080` (или `http://192.168.x.x:8080` если удалённо)
   - **Model Name**: `deepseek-coder-v2-lite` (или любое имя)
   - **API Type**: llama.cpp compatible
   - **Max tokens**: 2048
   - **Temperature**: 0.7

4. **Тест подключения**
   ```
   OpenCode UI → Test Connection
   ```

## Вариант B: Через SSH Tunnel (если OpenCode вне LAN)

Если OpenCode на машине вне локальной сети:

```bash
# На вашей машине с OpenCode (client):
ssh -L 8080:localhost:8080 zumuvik@192.168.10.210

# Теперь в OpenCode используйте: http://localhost:8080
```

## API Endpoints (llama.cpp compatible)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/completions` | POST | Text completion |
| `/chat/completions` | POST | Chat mode |
| `/models` | GET | List models |
| `/tokenize` | POST | Tokenize text |

### Пример запроса (для проверки):

```bash
curl http://localhost:8080/completions \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "def fibonacci(n):",
    "n_predict": 100,
    "temperature": 0.7,
    "top_p": 0.95,
    "top_k": 40
  }'
```

### Response:
```json
{
  "content": "    if n <= 1: return n\n    return fibonacci(n-1) + fibonacci(n-2)",
  "tokens_predicted": 18,
  "timings": {
    "predicted_ms": 2450,
    "prompt_ms": 150
  }
}
```

## Troubleshooting

### OpenCode not connecting

```bash
# 1. Проверьте сервис
systemctl status llama-server

# 2. Проверьте логи
journalctl -u llama-server -n 100 -f

# 3. Проверьте API вручную
curl -v http://localhost:8080/completions -X POST \
  -H "Content-Type: application/json" \
  -d '{"prompt":"test"}'

# 4. Проверьте firewall
sudo ufw status
sudo ufw allow 8080/tcp  # если нужно
```

### Slow inference

```bash
# Проверьте использование GPU
rocm-smi

# Если GPU не используется:
# - Проверьте gpu-layers в llama-server.nix (установите > 0)
# - Проверьте VRAM: rocm-smi --showmeminfo
# - Уменьшите context_size если OOM
```

### Out of Memory

Если видите OOM ошибки:

1. Уменьшите `contextSize` в конфиге (с 4096 на 2048)
2. Используйте меньший квант: IQ2_XXS (5.1GB вместо 5.4GB)
3. Увеличьте GPU layers поэтапно

## Performance Notes

**Expected on Vega 56 + IQ2_XS:**
- TTFT (Time-to-First-Token): 10-30 seconds (first inference)
- Tokens/sec: 20-40 (depends on context size)
- Warm start: ~2-3 seconds (subsequent requests)

**Optimization tips:**
- Keep context_size ≤ 4096 (larger = slower)
- Increase gpu_layers if VRAM allows
- Use smaller context for quick responses
- Pre-warm model with dummy requests

## Integration Complete ✅

llama.cpp REST API теперь доступен для OpenCode!

**Далее:**
- Используйте DeepSeek-Coder для code generation tasks в OpenCode
- Мониторьте производительность: `journalctl -u llama-server -f`
- При необходимости туируйте параметры в llama-server.nix
