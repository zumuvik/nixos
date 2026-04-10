# Draft: DeepSeek-Coder-V2-Lite на Vega 56

## Hardware
- GPU: AMD Radeon RX Vega 56 (8GB HBM2 VRAM, gfx900)
- Host: nixlensk323 (gaming PC)
- Model: DeepSeek-Coder-V2-Lite (16B params, MoE)

## User Requirements
- Runtime: llama.cpp CLI + API for OpenCode integration
- Acceleration: ROCm (GPU ускорение)

## Research Findings

### NixOS packages available
- `llama-cpp-rocm` (v8667) - llama.cpp with ROCm support
- `ollama-rocm` (v0.20.3) - simpler, REST API
- Both support AMD GPU acceleration

### Модель (DeepSeek-Coder-V2-Lite)
| Quant | Size | VRAM |
|--------|-------|------|
| IQ2_XXS | 5.1GB | ~5.5GB |
| IQ2_XS | 5.4GB | ~6.4GB |
| Q4_K_S | 9.53GB | ~10GB |
| Q8_0 | 16.7GB | ~17GB |

**Выбор**: IQ2_XS (5.4GB) - баланс скорости и качества для 8GB VRAM

### ROCm поддержка
- Vega 56 = gfx900 (Vega 10)
- Поддерживается в ROCm 5.x-6.x (в 7.x убрана)
- llama.cpp использует rocBLAS/hipBLAS для GPU ускорения

## План

### Модули для создания
1. ROCm enablement (драйвера, hipBLAS)
2. llama-cpp-rocm пакет
3. Systemd сервис для API сервера
4. Модель скачивание (IQ2_XS GGUF)

### Architecture
- llama.cpp server на localhost:8080
- Systemd сервис для автозапуска
- OpenCode подключается к localhost:8080

## Решено
- Quant: IQ2_XS (5.4GB)
- Context: 4K (умолчание)
- Port: 8080 (llama.cpp server default)