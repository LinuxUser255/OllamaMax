# OllamaMax Model Pull System

## Overview
OllamaMax now uses a unified model pulling system through the `ollama_pull_and_run.sh` script, which handles:
- Automatic Ollama installation (if needed)
- Hardware detection (GPU/CPU)
- Optimal quantization selection
- Model downloading and preparation

## Primary Script: `ollama_pull_and_run.sh`

### Usage Modes

#### 1. **Parameter Mode** (Used by Application)
```bash
./ollama_pull_and_run.sh llama3.1:8b
```
- Called automatically when a user selects a model from the dropdown
- Accepts model name as parameter
- Returns success/failure status
- Handles quantization automatically based on hardware

#### 2. **Interactive Mode** (Manual Use)
```bash
./ollama_pull_and_run.sh
```
- Shows menu with all 15 models (A-O options)
- User selects model interactively
- Good for manual testing or setup

## Integration Flow

### When User Selects Model in UI:

1. **Frontend** (index.html/script.js)
   - User selects model from dropdown
   - Sends model name to backend via WebSocket/API

2. **Backend** (main.go)
   - Receives model selection
   - Checks if model is installed (`checkModelInstalled()`)
   - If not installed, calls `pullOllamaModel()`

3. **Model Pull** (`pullOllamaModel()`)
   - Executes: `bash ./ollama_pull_and_run.sh <model-name>`
   - Script handles:
     - Ollama installation check
     - Hardware detection (Apple Silicon, NVIDIA GPU, CPU)
     - Quantization selection:
       - Apple Silicon: Native (FP16)
       - NVIDIA 6GB+: `:q5_k_m`
       - NVIDIA <6GB or CPU: `:q4_0`
   - Falls back to direct `ollama pull` if script fails

4. **Response**
   - Success: Model ready for use
   - Failure: Error message returned to user

## Hardware-Aware Quantization

The script automatically detects hardware and applies optimal quantization:

| Hardware | Detection | Quantization |
|----------|-----------|--------------|
| Apple Silicon | `sysctl -n machdep.cpu.brand_string` | Native (no suffix) |
| NVIDIA GPU 6GB+ | `nvidia-smi` VRAM check | `:q5_k_m` |
| NVIDIA GPU <6GB | `nvidia-smi` VRAM check | `:q4_0` |
| CPU Only | No GPU detected | `:q4_0` |

## Models That Don't Need Quantization

These models are used as-is without quantization suffixes:
- `phi3:mini`
- `tinyllama:*`
- `moondream:*`
- `nomic-embed-text`
- `deepseek-r1`
- `glm-4.6`
- `deepseek-v3.1`
- `qwen3-vl`

## Other Installation Scripts (Manual Use Only)

### `ollama_install_basic.sh`
- Original basic installer
- Kept for manual use
- Has its own menu system (A-O)

### `ollam-linuxmac-optimized.sh`
- Linux/Mac optimized version
- For advanced users
- Manual use only

## Testing the System

### Test Parameter Mode:
```bash
# Test with a specific model
./ollama_pull_and_run.sh llama3.1:8b

# Should output:
# [*] OllamaMax Model Pull & Run
# [*] Model requested: llama3.1:8b
# [*] Ollama already installed
# [!] Hardware detection message
# [*] Processing model: llama3.1:8b
# [*] Model ready!
```

### Test Interactive Mode:
```bash
# Run without parameters
./ollama_pull_and_run.sh

# Shows menu with A-O options
# User selects, model gets pulled
```

## Troubleshooting

### Script Not Found
```bash
chmod +x ollama_pull_and_run.sh
```

### Ollama Not Installing
- Check internet connection
- Ensure curl is installed
- Try manual install: `curl -fsSL https://ollama.com/install.sh | sh`

### Wrong Quantization Applied
- Script auto-detects hardware
- Check GPU detection: `nvidia-smi` (Linux) or `sysctl -n machdep.cpu.brand_string` (Mac)
- Override by editing the script's `detect_quant()` function

### Model Pull Fails
- Check model name spelling
- Ensure model exists in Ollama registry
- Check disk space
- Try direct pull: `ollama pull model-name`

## File Structure
```
/home/linux/Projects/Bots/OllamaBots/OllamaMax/
├── ollama_pull_and_run.sh       # PRIMARY - Used by application
├── ollama_install_basic.sh      # Manual use only
├── ollam-linuxmac-optimized.sh  # Manual use only
├── main.go                       # Calls ollama_pull_and_run.sh
├── static/
│   ├── index.html               # Model dropdown UI
│   └── script.js                # Sends model selection to backend
└── MODELS_ALIGNMENT.md          # Model list documentation
```