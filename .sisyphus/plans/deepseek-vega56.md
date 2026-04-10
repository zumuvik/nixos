# План: DeepSeek-Coder-V2-Lite на AMD Vega 56

## Контекст
- **Хост**: nixlensk323 (gaming PC)
- **GPU**: AMD Radeon RX Vega 56 (8GB HBM2, gfx900)
- **Цель**: Запустить DeepSeek-Coder-V2-Lite локально с llama.cpp CLI + REST API
- **Requirement**: GPU ускорение (ROCm)
- **Integration**: API для подключения в OpenCode

## Архитектура решения

```
┌─────────────────┐
│  DeepSeek Model │ (IQ2_XS, 5.4GB GGUF)
│   16B params    │ (MoE, 2.4B active)
└────────┬────────┘
         │
    ┌────▼─────┐
    │llama.cpp │ (+rocBLAS, GPU offload)
    │ v8667    │ (nixpkgs.llama-cpp-rocm)
    └────┬─────┘
         │
    ┌────▼──────────┐
    │Systemd service│ (listener on :8080)
    │auto-start     │
    └────┬──────────┘
         │
    ┌────▼──────────────┐
    │REST API            │
    │localhost:8080      │ (OpenCode client)
    └───────────────────┘
```

## Фазы реализации

### Фаза 1: ROCm Setup
- [ ] Проверить ROCm версию (5.x-6.x требуется, 7.x не поддерживает Vega)
- [ ] Добавить rocm/hipBLAS в systemPackages (если требуется явно)
- [ ] Проверить GPU detection: `rocminfo` (или `clinfo` для OpenCL)
- [ ] Verify: `/dev/kfd` и `/dev/dri/*` доступны пользователю

### Фаза 2: llama.cpp Installation
- [ ] Добавить `llama-cpp-rocm` в home.packages или systemPackages
- [ ] Verify: `llama-cpp-rocm --version` работает
- [ ] Verify: llama-cpp компилирован с поддержкой rocBLAS

### Фаза 3: Model Download & Setup
- [ ] Создать директорию: `~/.local/share/llama-models/`
- [ ] Скачать: `mradermacher/DeepSeek-Coder-V2-Lite-Instruct-GGUF` (IQ2_XS quant)
  - Файл: `DeepSeek-Coder-V2-Lite-Instruct.IQ2_XS.gguf` (5.4GB)
  - Source: https://huggingface.co/mradermacher/DeepSeek-Coder-V2-Lite-Instruct-GGUF
- [ ] Verify файл скачан полностью (SHA256 check, если доступно)

### Фаза 4: Systemd Service
- [ ] Создать `/etc/systemd/user/llama-server.service`
  ```ini
  [Unit]
  Description=llama.cpp REST API Server
  After=network.target
  
  [Service]
  Type=simple
  ExecStart=/run/current-system/sw/bin/llama-cpp-rocm \
    --server \
    --model ~/.local/share/llama-models/DeepSeek-Coder-V2-Lite-Instruct.IQ2_XS.gguf \
    --port 8080 \
    --gpu-layers 60 \
    --ctx-size 4096 \
    --n-gpu-layers 32
  Restart=on-failure
  RestartSec=5
  
  [Install]
  WantedBy=default.target
  ```
- [ ] Enable & start: `systemctl --user enable llama-server`

### Фаза 5: Testing
- [ ] Запустить сервис: `systemctl --user start llama-server`
- [ ] Проверить логи: `journalctl --user -u llama-server -f`
- [ ] Verify GPU использование: `rocm-smi` (или посмотреть в процессе)
- [ ] Test API: `curl http://localhost:8080/completions -X POST ...`

### Фаза 6: Integration
- [ ] OpenCode API configuration (host:port)
- [ ] Тест через OpenCode UI
- [ ] Benchmark: время ответа, TTFT (time-to-first-token)

## Риски & Guardrails

### Критические
1. **ROCm версия**: Vega 56 требует ROCm 5.x-6.x, не 7.x
   - Mitigation: Проверить `rocminfo` перед началом
   - Fallback: CPU-only mode (медленнее в 10x)

2. **VRAM недостаточно**: IQ2_XS = 5.4GB + буферы = ~6.4GB требуется
   - Mitigation: Использовать IQ2_XXS (5.1GB) если надо
   - Fallback: Q2_K (6.43GB) или CPU+swap

3. **hipBLAS/rocBLAS не найдены**: llama.cpp скомпилирован без GPU поддержки
   - Mitigation: Проверить `llama-cpp-rocm --help | grep -i gpu`
   - Fallback: Перекомпилировать с явным rocBLAS

### Обычные
- Первый запуск медленнее (model loading, GPU init)
- Context size > 4K может OOM (swap to disk)
- Fan noise при максимальной нагрузке GPU

### Edge Cases
- Если процесс llama-cpp зависит на старте
  - Проверить `/dev/kfd` permissions: `ls -la /dev/kfd`
  - Добавить user в группу `render` (или `video`)
- Если API перестает отвечать
  - Перезагрузить сервис: `systemctl --user restart llama-server`

## Решения (locked in)
| Параметр | Значение | Reasoning |
|----------|----------|-----------|
| Model | DeepSeek-Coder-V2-Lite-Instruct | 16B + MoE |
| Quant | IQ2_XS (5.4GB) | Fits 8GB, good quality |
| Context | 4096 tokens | Reasonable for most tasks |
| API Port | 8080 | llama.cpp default |
| GPU Layers | 32-60 | Tunable, depends on available VRAM |
| Batch Size | default (512) | Start with default |

## Unresolved Questions

1. **Exact llama-cpp-rocm compilation flags**: Does nixpkgs.llama-cpp-rocm include rocBLAS support?
   - Check: `llama-cpp-rocm --help | grep -i rocblas` или `ldd`
   - If NO: May need nixpkgs override or compilation

2. **ROCm driver compatibility**: Which ROCm version is in nixpkgs.llama-cpp-rocm?
   - Check: Run on system, see if GPU is detected
   - Fallback: Document CPU-only instructions

3. **User permissions for /dev/kfd**: Does zumuvik need to be in render/video group?
   - Test: `rocm-smi` as user before deployment

4. **Performance baseline**: What TTFT/tokens/sec to expect on Vega 56?
   - Unknown: Depends on GPU layers offloaded, context size
   - Test in Фаза 5

## Success Criteria

- [ ] llama-cpp-rocm server starts and listens on 0.0.0.0:8080
- [ ] GPU is detected and used (rocm-smi shows activity)
- [ ] First completion request completes in <30 sec (cold start)
- [ ] Subsequent requests <5 sec with 4K context
- [ ] Memory usage stable (no OOM after 1hr continuous use)
- [ ] OpenCode can connect and generate code snippets

## Примечания для реализации

- ROCm может требовать специальные environment variables (HIP_VISIBLE_DEVICES, etc.)
- llama-cpp-rocm может нужны permission adjustments при первом запуске
- Systemd service может заваливаться если /dev/kfd недоступен — проверить логи
- Model download может быть медленным — рассмотреть offline download заранее

## Временная оценка
- ROCm verification: 10 min
- llama-cpp install: 5 min (already in nixpkgs)
- Model download: 30-60 min (зависит от интернета, 5.4GB)
- Service setup: 10 min
- Testing & tuning: 30 min
- **Total: 1.5-2 hours**
